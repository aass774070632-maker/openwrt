import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { env } from '../../config/env';
import { PrismaModule } from '../prisma/prisma.module';
import { AdminJwtGuard } from './admin-jwt.guard';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [
    PrismaModule,
    JwtModule.register({
      secret: env.JWT_ACCESS_SECRET,
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, AdminJwtGuard],
  exports: [AuthService, AdminJwtGuard],
})
export class AuthModule {}