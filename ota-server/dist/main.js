"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const node_path_1 = require("node:path");
const app_module_1 = require("./app.module");
const env_1 = require("./config/env");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    app.setGlobalPrefix(env_1.env.API_PREFIX);
    app.useStaticAssets((0, node_path_1.join)(process.cwd(), 'public'), {
        setHeaders: (res, filePath) => {
            const normalizedPath = filePath.split(node_path_1.sep).join('/');
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
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
        forbidNonWhitelisted: true,
    }));
    await app.listen(env_1.env.PORT);
}
void bootstrap();
//# sourceMappingURL=main.js.map