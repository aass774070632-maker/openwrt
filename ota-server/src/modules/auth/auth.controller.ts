import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { AdminJwtGuard } from './admin-jwt.guard';
import { AuthenticatedAdmin, AuthService } from './auth.service';
import { LoginAdminDto } from './dto/login-admin.dto';
import { LogoutSessionDto } from './dto/logout-session.dto';
import { RefreshSessionDto } from './dto/refresh-session.dto';

type RequestLike = {
  ip?: string;
  headers: Record<string, string | string[] | undefined>;
  admin?: AuthenticatedAdmin;
};

@Controller('admin/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  login(@Body() body: LoginAdminDto, @Req() request: RequestLike) {
    return this.authService.login(body, this.extractRequestMeta(request));
  }

  @Post('refresh')
  refresh(@Body() body: RefreshSessionDto, @Req() request: RequestLike) {
    return this.authService.refresh(body.refresh_token, this.extractRequestMeta(request));
  }

  @Post('logout')
  logout(@Body() body: LogoutSessionDto) {
    return this.authService.logout(body.refresh_token);
  }

  @Get('me')
  @UseGuards(AdminJwtGuard)
  me(@Req() request: RequestLike) {
    return request.admin;
  }

  @Get('health')
  health() {
    return { ok: true };
  }

  private extractRequestMeta(request: RequestLike) {
    return {
      ipAddress: request.ip ?? null,
      userAgent: request.headers['user-agent'] ?? null,
    };
  }
}