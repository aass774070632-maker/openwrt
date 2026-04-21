import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { AuthService, AuthenticatedAdmin } from './auth.service';

type RequestWithHeaders = {
  headers: Record<string, string | string[] | undefined>;
  admin?: AuthenticatedAdmin;
};

@Injectable()
export class AdminJwtGuard implements CanActivate {
  constructor(private readonly authService: AuthService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<RequestWithHeaders>();
    const authorization = request.headers.authorization;
    const header = Array.isArray(authorization) ? authorization[0] : authorization;

    if (!header) {
      throw new UnauthorizedException('missing bearer token');
    }

    const [scheme, token] = header.split(' ');

    if (scheme !== 'Bearer' || !token) {
      throw new UnauthorizedException('invalid bearer token');
    }

    const admin = await this.authService.authenticateAccessToken(token);

    if (admin.role !== 'admin') {
      throw new UnauthorizedException('admin role required');
    }

    request.admin = admin;
    return true;
  }
}