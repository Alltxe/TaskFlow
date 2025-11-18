import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { GqlExecutionContext } from '@nestjs/graphql';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger(LoggingInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const gqlContext = GqlExecutionContext.create(context);
    const info = gqlContext.getInfo();
    const args = gqlContext.getArgs();
    const request = gqlContext.getContext().req;

    const operationType = info?.operation?.operation || 'unknown';
    const operationName = info?.fieldName || 'unknown';

    this.logger.log(`\n${'='.repeat(80)}`);
    this.logger.log(`[${operationType.toUpperCase()}] ${operationName}`);
    this.logger.log(`Arguments: ${JSON.stringify(args, null, 2)}`);

    if (request?.body) {
      this.logger.log(`Request Body: ${JSON.stringify(request.body, null, 2)}`);
    }

    if (request?.headers?.['user-agent']) {
      this.logger.log(`User-Agent: ${request.headers['user-agent']}`);
    }

    const now = Date.now();
    return next.handle().pipe(
      tap({
        next: (data) => {
          const duration = Date.now() - now;
          this.logger.log(`✓ Success in ${duration}ms`);
          this.logger.log(`${'='.repeat(80)}\n`);
        },
        error: (error) => {
          const duration = Date.now() - now;
          this.logger.error(`✗ Error in ${duration}ms: ${error.message}`);
          this.logger.error(`Error stack: ${error.stack}`);
          this.logger.log(`${'='.repeat(80)}\n`);
        },
      }),
    );
  }
}
