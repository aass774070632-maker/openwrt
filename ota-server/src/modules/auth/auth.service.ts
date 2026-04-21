import { randomBytes, createHash } from 'node:crypto';
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { AdminUser } from '@prisma/client';
import * as argon2 from 'argon2';
import { env } from '../../config/env';
import { PrismaService } from '../prisma/prisma.service';
import { LoginAdminDto } from './dto/login-admin.dto';

type RequestMeta = {
  ipAddress: string | null;
  userAgent: string | string[] | null;
};

export type AuthenticatedAdmin = {
  id: number;
  email: string;
  role: string;
  sessionId: number;
};

type AccessTokenPayload = {
  sub: number;
  email: string;
  role: string;
  session_id: number;
};

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async login(body: LoginAdminDto, meta: RequestMeta) {
    const adminUser = await this.prisma.adminUser.findUnique({
      where: { email: body.email.toLowerCase() },
    });

    if (!adminUser || !(await argon2.verify(adminUser.passwordHash, body.password))) {
      throw new UnauthorizedException('invalid email or password');
    }

    return this.issueSession(adminUser, meta);
  }

  async refresh(refreshToken: string, meta: RequestMeta) {
    const session = await this.prisma.adminSession.findUnique({
      where: {
        refreshTokenHash: this.hashRefreshToken(refreshToken),
      },
      include: {
        adminUser: true,
      },
    });

    if (!session || session.revokedAt || session.expiresAt <= new Date()) {
      throw new UnauthorizedException('invalid refresh token');
    }

    await this.prisma.adminSession.delete({
      where: { id: session.id },
    });

    return this.issueSession(session.adminUser, meta);
  }

  async logout(refreshToken: string) {
    const refreshTokenHash = this.hashRefreshToken(refreshToken);

    await this.prisma.adminSession.updateMany({
      where: {
        refreshTokenHash,
        revokedAt: null,
      },
      data: {
        revokedAt: new Date(),
      },
    });

    return { ok: true };
  }

  async authenticateAccessToken(accessToken: string): Promise<AuthenticatedAdmin> {
    let payload: AccessTokenPayload;

    try {
      payload = await this.jwtService.verifyAsync<AccessTokenPayload>(accessToken, {
        secret: env.JWT_ACCESS_SECRET,
      });
    } catch {
      throw new UnauthorizedException('invalid access token');
    }

    const session = await this.prisma.adminSession.findUnique({
      where: { id: payload.session_id },
      include: {
        adminUser: true,
      },
    });

    if (
      !session
      || session.revokedAt
      || session.expiresAt <= new Date()
      || session.adminUserId !== payload.sub
    ) {
      throw new UnauthorizedException('invalid access token');
    }

    await this.prisma.adminSession.update({
      where: { id: session.id },
      data: {
        lastUsedAt: new Date(),
      },
    });

    return {
      id: session.adminUser.id,
      email: session.adminUser.email,
      role: session.adminUser.role,
      sessionId: session.id,
    };
  }

  private async issueSession(adminUser: AdminUser, meta: RequestMeta) {
    const refreshToken = this.generateRefreshToken();
    const now = new Date();
    const expiresAt = new Date(now.getTime() + env.REFRESH_TOKEN_TTL_SECONDS * 1000);

    const session = await this.prisma.adminSession.create({
      data: {
        adminUserId: adminUser.id,
        refreshTokenHash: this.hashRefreshToken(refreshToken),
        ipAddress: meta.ipAddress,
        userAgent: this.normalizeUserAgent(meta.userAgent),
        lastUsedAt: now,
        expiresAt,
      },
    });

    const accessToken = await this.jwtService.signAsync({
      sub: adminUser.id,
      email: adminUser.email,
      role: adminUser.role,
      session_id: session.id,
    }, {
      secret: env.JWT_ACCESS_SECRET,
      expiresIn: env.JWT_ACCESS_TTL_SECONDS,
    });

    return {
      access_token: accessToken,
      token_type: 'Bearer',
      expires_in: env.JWT_ACCESS_TTL_SECONDS,
      refresh_token: refreshToken,
      refresh_expires_in: env.REFRESH_TOKEN_TTL_SECONDS,
      admin: {
        id: adminUser.id,
        email: adminUser.email,
        role: adminUser.role,
      },
    };
  }

  private generateRefreshToken(): string {
    return randomBytes(48).toString('base64url');
  }

  private hashRefreshToken(refreshToken: string): string {
    return createHash('sha256').update(refreshToken).digest('hex');
  }

  private normalizeUserAgent(userAgent: string | string[] | null): string | null {
    if (!userAgent) {
      return null;
    }

    return Array.isArray(userAgent) ? userAgent[0] ?? null : userAgent;
  }
}