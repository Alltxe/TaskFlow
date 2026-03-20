import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import helmet from 'helmet';
import { WINSTON_MODULE_NEST_PROVIDER } from 'nest-winston';
import { join } from 'path';
import { NestExpressApplication } from '@nestjs/platform-express';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  // Use Winston logger
  app.useLogger(app.get(WINSTON_MODULE_NEST_PROVIDER));

  // Security Headers (Helmet) - PRD 4.2
  app.use(
    helmet({
      contentSecurityPolicy: process.env.NODE_ENV === 'production'
        ? {
            directives: {
              defaultSrc: ["'self'"],
              styleSrc: ["'self'", "'unsafe-inline'"],
              scriptSrc: ["'self'"],
              imgSrc: ["'self'", 'data:', 'https:'],
              connectSrc: ["'self'", 'ws:', 'wss:'],
            },
          }
        : false, // Отключаем CSP в development для удобства разработки
      crossOriginEmbedderPolicy: false,
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
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept', 'ngrok-skip-browser-warning'],
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

  // Serve static frontend files from dist folder
  const frontendPath = join(__dirname, '..', '..', 'frontend', 'dist');
  app.useStaticAssets(frontendPath);

  // SPA fallback: все неизвестные routes отправляются на index.html
  app.use((req, res, next) => {
    // Пропускаем GraphQL и API запросы
    if (req.path.startsWith('/graphql') || req.path.startsWith('/api')) {
      return next();
    }
    // Пропускаем запросы к статическим файлам (с расширением)
    if (req.path.match(/\.\w+$/)) {
      return next();
    }
    // Остальные запросы - отдаем index.html для SPA роутинга
    res.sendFile(join(frontendPath, 'index.html'));
  });

  // Глобальный фильтр исключений (убирает stacktrace из ответов)
  app.useGlobalFilters(new AllExceptionsFilter());

  const port = process.env.PORT ?? 3000;
  await app.listen(port);
  console.log(`🚀 Application is running on: http://localhost:${port}/graphql`);
}
bootstrap();
