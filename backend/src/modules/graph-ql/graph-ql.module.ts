import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';
import { AppResolver } from './app.resolver';
import {
  fieldExtensionsEstimator,
  getComplexity,
  simpleEstimator,
} from 'graphql-query-complexity';
import { GraphQLError } from 'graphql';

@Module({
  imports: [
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      // Enable GraphiQL playground only in development
      graphiql: process.env.NODE_ENV !== 'production',
      // Enable introspection only in development (security best practice)
      introspection: process.env.NODE_ENV !== 'production',
      csrfPrevention: false, // Отключаем CSRF защиту в режиме разработки
      formatError: (error) => {
        // Получаем оригинальную ошибку из разных возможных мест
        const originalError = error.extensions?.originalError as any;
        const response = error.extensions?.response as any;
        const exception = error.extensions?.exception as any;
        
        // Определяем HTTP статус код из разных источников (включая status и statusCode)
        const statusCode = 
          error.extensions?.status || // GraphQL может передавать как 'status'
          originalError?.statusCode || 
          response?.statusCode || 
          exception?.statusCode ||
          error.extensions?.statusCode;
        
        // Пытаемся получить код ошибки из originalError (наше кастомное исключение)
        const customCode = 
          originalError?.code || // Наш кастомный код здесь!
          response?.code || 
          exception?.code;
        
        // Определяем код ошибки на основе кастомного кода или статуса
        let errorCode = customCode || error.extensions?.code;
        
        // Если код все еще INTERNAL_SERVER_ERROR, пытаемся определить по statusCode
        if (!errorCode || errorCode === 'INTERNAL_SERVER_ERROR') {
          const codeMap: Record<number, string> = {
            400: 'BAD_REQUEST',
            401: 'UNAUTHENTICATED',
            403: 'FORBIDDEN',
            404: 'NOT_FOUND',
            409: 'CONFLICT',
            429: 'TOO_MANY_REQUESTS',
            500: 'INTERNAL_SERVER_ERROR',
          };
          errorCode = statusCode ? codeMap[statusCode] || 'INTERNAL_SERVER_ERROR' : 'INTERNAL_SERVER_ERROR';
        }

        // Убираем stacktrace из ответа GraphQL
        const formattedError: any = {
          message: error.message,
          extensions: {
            code: errorCode,
            statusCode: statusCode || 500,
          },
        };

        // В режиме разработки добавляем путь
        if (process.env.NODE_ENV === 'development') {
          formattedError.path = error.path;
        }

        return formattedError;
      },
      context: ({ req, res }) => ({ req, res }),
      plugins: [
        {
          async requestDidStart() {
            return {
              async didResolveOperation({ request, document, schema }) {
                /**
                 * Query Complexity Analysis (PRD 4.1 Performance)
                 * Prevents expensive queries from overloading the server
                 * Max complexity: 1000 (configurable)
                 */
                const complexity = getComplexity({
                  schema,
                  operationName: request.operationName,
                  query: document,
                  variables: request.variables,
                  estimators: [
                    fieldExtensionsEstimator(),
                    simpleEstimator({ defaultComplexity: 1 }),
                  ],
                });

                const maxComplexity = 1000; // Adjust based on your needs
                if (complexity > maxComplexity) {
                  throw new GraphQLError(
                    `Query too complex: ${complexity}. Maximum allowed complexity: ${maxComplexity}`,
                    {
                      extensions: {
                        code: 'QUERY_TOO_COMPLEX',
                        complexity,
                        maxComplexity,
                      },
                    },
                  );
                }

                // Request-level complexity logging is intentionally disabled
                // to avoid noisy global per-request logs.
              },
            };
          },
        },
      ],
    }),
  ],
  providers: [AppResolver],
})
export class GraphQlModule {}
