import { JwtService } from '@nestjs/jwt';
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
export declare class AuthService {
    private readonly prisma;
    private readonly jwtService;
    constructor(prisma: PrismaService, jwtService: JwtService);
    login(body: LoginAdminDto, meta: RequestMeta): Promise<{
        access_token: string;
        token_type: string;
        expires_in: number;
        refresh_token: string;
        refresh_expires_in: number;
        admin: {
            id: number;
            email: string;
            role: string;
        };
    }>;
    refresh(refreshToken: string, meta: RequestMeta): Promise<{
        access_token: string;
        token_type: string;
        expires_in: number;
        refresh_token: string;
        refresh_expires_in: number;
        admin: {
            id: number;
            email: string;
            role: string;
        };
    }>;
    logout(refreshToken: string): Promise<{
        ok: boolean;
    }>;
    authenticateAccessToken(accessToken: string): Promise<AuthenticatedAdmin>;
    private issueSession;
    private generateRefreshToken;
    private hashRefreshToken;
    private normalizeUserAgent;
}
export {};
