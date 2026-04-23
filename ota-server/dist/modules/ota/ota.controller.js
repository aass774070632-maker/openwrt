"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OtaController = void 0;
const common_1 = require("@nestjs/common");
const heartbeat_dto_1 = require("./dto/heartbeat.dto");
const register_device_dto_1 = require("./dto/register-device.dto");
const update_query_dto_1 = require("./dto/update-query.dto");
const ota_service_1 = require("./ota.service");
let OtaController = class OtaController {
    constructor(otaService) {
        this.otaService = otaService;
    }
    register(body, request) {
        return this.otaService.register(body, this.extractMeta(request));
    }
    update(query, request) {
        return this.otaService.checkUpdate(query, this.extractMeta(request));
    }
    heartbeat(body, request) {
        return this.otaService.heartbeat(body, this.extractMeta(request));
    }
    extractMeta(request) {
        return {
            ipAddress: request.ip ?? null,
            signature: this.pickHeader(request.headers, 'x-ota-signature'),
            timestamp: this.pickHeader(request.headers, 'x-ota-ts'),
        };
    }
    pickHeader(headers, name) {
        const value = headers[name];
        if (!value) {
            return null;
        }
        return Array.isArray(value) ? value[0] ?? null : value;
    }
};
exports.OtaController = OtaController;
__decorate([
    (0, common_1.Post)('register'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [register_device_dto_1.RegisterDeviceDto, Object]),
    __metadata("design:returntype", void 0)
], OtaController.prototype, "register", null);
__decorate([
    (0, common_1.Get)('update'),
    __param(0, (0, common_1.Query)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [update_query_dto_1.UpdateQueryDto, Object]),
    __metadata("design:returntype", void 0)
], OtaController.prototype, "update", null);
__decorate([
    (0, common_1.Post)('heartbeat'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [heartbeat_dto_1.HeartbeatDto, Object]),
    __metadata("design:returntype", void 0)
], OtaController.prototype, "heartbeat", null);
exports.OtaController = OtaController = __decorate([
    (0, common_1.Controller)(),
    __metadata("design:paramtypes", [ota_service_1.OtaService])
], OtaController);
//# sourceMappingURL=ota.controller.js.map