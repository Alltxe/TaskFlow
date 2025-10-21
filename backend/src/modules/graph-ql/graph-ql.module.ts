import { Module } from '@nestjs/common';
import { GraphQLModule } from '@nestjs/graphql';
import { ApolloDriver, ApolloDriverConfig } from '@nestjs/apollo';
import { join } from 'path';
import { AppResolver } from './app.resolver';

@Module({
  imports: [
    GraphQLModule.forRoot<ApolloDriverConfig>({
      driver: ApolloDriver,
      autoSchemaFile: join(process.cwd(), 'src/schema.gql'),
      playground: false,
      introspection: true,
      formatError: (error) => {
        // Получаем оригинальную ошибку
        const originalError = error.extensions?.originalError as any;
        const response = error.extensions?.response as any;
        
        // Определяем HTTP статус код
        const statusCode = originalError?.statusCode || response?.statusCode;
        
        // Определяем код ошибки на основе статуса
        let errorCode = error.extensions?.code;
        if (!errorCode || errorCode === 'INTERNAL_SERVER_ERROR') {
          const codeMap: Record<number, string> = {
            400: 'BAD_REQUEST',
            401: 'UNAUTHENTICATED',
            403: 'FORBIDDEN',
            404: 'NOT_FOUND',
            409: 'CONFLICT',
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
    }),
  ],
  providers: [AppResolver],
})
export class GraphQlModule {}
