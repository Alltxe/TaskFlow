import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { LoggingInterceptor } from './common/interceptors/logging.interceptor';
import helmet from 'helmet';
import { WINSTON_MODULE_NEST_PROVIDER } from 'nest-winston';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Use Winston logger
  app.useLogger(app.get(WINSTON_MODULE_NEST_PROVIDER));

  // Global logging interceptor
  app.useGlobalInterceptors(new LoggingInterceptor());

  // Security Headers (Helmet) - PRD 4.2
  app.use(
    helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"], // GraphQL playground needs inline styles
          scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"], // GraphQL playground needs eval
          imgSrc: ["'self'", 'data:', 'https:'],
        },
      },
      crossOriginEmbedderPolicy: false, // GraphQL playground compatibility
    }),
  );

  // Включение CORS для поддержки запросов с фронтенда - PRD 4.2
  const allowedOrigins = process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(',')
    : ['http://localhost:5173', 'http://localhost:4173'];

  app.enableCors({
    origin: process.env.NODE_ENV === 'production' 
      ? allowedOrigins 
      : true, // Allow all origins in development
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
    maxAge: 3600, // Cache preflight requests for 1 hour
  });

  // Глобальная валидация с защитой от XSS - PRD 4.2
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip properties that don't have decorators
      forbidNonWhitelisted: true, // Throw error if unknown properties are present
      transform: true, // Automatically transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true,
      },
      exceptionFactory: (errors) => {
        console.error('❌ Validation errors:', JSON.stringify(errors, null, 2));
        return errors;
      },
    }),
  );

  // Глобальный фильтр исключений (убирает stacktrace из ответов)
  app.useGlobalFilters(new AllExceptionsFilter());

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`🚀 Application is running on: http://localhost:${port}/graphql`);
}
bootstrap();
