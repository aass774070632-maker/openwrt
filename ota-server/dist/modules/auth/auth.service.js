"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthService = void 0;
const node_crypto_1 = require("node:crypto");
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const argon2 = __importStar(require("argon2"));
const env_1 = require("../../config/env");
const prisma_service_1 = require("../prisma/prisma.service");
let AuthService = class AuthService {
    constructor(prisma, jwtService) {
        this.prisma = prisma;
        this.jwtService = jwtService;
    }
    async login(body, meta) {
        const adminUser = await this.prisma.adminUser.findUnique({
            where: { email: body.email.toLowerCase() },
        });
        if (!adminUser || !(await argon2.verify(adminUser.passwordHash, body.password))) {
            throw new common_1.UnauthorizedException('invalid email or password');
        }
        return this.issueSession(adminUser, meta);
    }
    async refresh(refreshToken, meta) {
        const session = await this.prisma.adminSession.findUnique({
            where: {
                refreshTokenHash: this.hashRefreshToken(refreshToken),
            },
            include: {
                adminUser: true,
            },
        });
        if (!session || session.revokedAt || session.expiresAt <= new Date()) {
            throw new common_1.UnauthorizedException('invalid refresh token');
        }
        await this.prisma.adminSession.delete({
            where: { id: session.id },
        });
        return this.issueSession(session.adminUser, meta);
    }
    async logout(refreshToken) {
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
    async authenticateAccessToken(accessToken) {
        let payload;
        try {
            payload = await this.jwtService.verifyAsync(accessToken, {
                secret: env_1.env.JWT_ACCESS_SECRET,
            });
        }
        catch {
            throw new common_1.UnauthorizedException('invalid access token');
        }
        const session = await this.prisma.adminSession.findUnique({
            where: { id: payload.session_id },
            include: {
                adminUser: true,
            },
        });
        if (!session
            || session.revokedAt
            || session.expiresAt <= new Date()
            || session.adminUserId !== payload.sub) {
            throw new common_1.UnauthorizedException('invalid access token');
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
    async issueSession(adminUser, meta) {
        const refreshToken = this.generateRefreshToken();
        const now = new Date();
        const expiresAt = new Date(now.getTime() + env_1.env.REFRESH_TOKEN_TTL_SECONDS * 1000);
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
            secret: env_1.env.JWT_ACCESS_SECRET,
            expiresIn: env_1.env.JWT_ACCESS_TTL_SECONDS,
        });
        return {
            access_token: accessToken,
            token_type: 'Bearer',
            expires_in: env_1.env.JWT_ACCESS_TTL_SECONDS,
            refresh_token: refreshToken,
            refresh_expires_in: env_1.env.REFRESH_TOKEN_TTL_SECONDS,
            admin: {
                id: adminUser.id,
                email: adminUser.email,
                role: adminUser.role,
            },
        };
    }
    generateRefreshToken() {
        return (0, node_crypto_1.randomBytes)(48).toString('base64url');
    }
    hashRefreshToken(refreshToken) {
        return (0, node_crypto_1.createHash)('sha256').update(refreshToken).digest('hex');
    }
    normalizeUserAgent(userAgent) {
        if (!userAgent) {
            return null;
        }
        return Array.isArray(userAgent) ? userAgent[0] ?? null : userAgent;
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map