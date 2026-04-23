import { AuthenticatedAdmin, AuthService } from './auth.service';
import { LoginAdminDto } from './dto/login-admin.dto';
import { LogoutSessionDto } from './dto/logout-session.dto';
import { RefreshSessionDto } from './dto/refresh-session.dto';
type RequestLike = {
    ip?: string;
    headers: Record<string, string | string[] | undefined>;
    admin?: AuthenticatedAdmin;
};
export declare class AuthController {
    private readonly authService;
    constructor(authService: AuthService);
    login(body: LoginAdminDto, request: RequestLike): Promise<{
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
    refresh(body: RefreshSessionDto, request: RequestLike): Promise<{
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
    logout(body: LogoutSessionDto): Promise<{
        ok: boolean;
    }>;
    me(request: RequestLike): AuthenticatedAdmin | undefined;
    health(): {
        ok: boolean;
    };
    private extractRequestMeta;
}
export {};
