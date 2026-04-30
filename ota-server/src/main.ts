import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join, sep } from 'node:path';
import { AppModule } from './app.module';
import { env } from './config/env';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);

  app.setGlobalPrefix(env.API_PREFIX);
  app.useStaticAssets(join(process.cwd(), 'public'), {
    setHeaders: (res, filePath) => {
      const normalizedPath = filePath.split(sep).join('/');

      if (normalizedPath.includes('/admin-app/')) {
        res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
        return;
      }

      if (normalizedPath.includes('/firmware/')) {
        res.setHeader('Cache-Control', 'no-store');
      }
    },
  });
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
    }),
  );

  await app.listen(env.PORT);
}

void bootstrap();
