import { HttpException, HttpStatus } from '@nestjs/common';

/**
 * Custom exception for rate limiting (429 Too Many Requests)
 * 
 * Ensures GraphQL error response has correct code: "TOO_MANY_REQUESTS"
 * instead of "INTERNAL_SERVER_ERROR"
 */
export class ThrottlerException extends HttpException {
  constructor(message = 'Too Many Requests') {
    super(
      {
        statusCode: HttpStatus.TOO_MANY_REQUESTS,
        message,
        error: 'Too Many Requests',
        code: 'TOO_MANY_REQUESTS',
      },
      HttpStatus.TOO_MANY_REQUESTS,
    );
  }
}
