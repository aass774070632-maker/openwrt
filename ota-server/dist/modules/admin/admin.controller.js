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
exports.AdminController = void 0;
const common_1 = require("@nestjs/common");
const admin_jwt_guard_1 = require("../auth/admin-jwt.guard");
const create_campaign_dto_1 = require("./dto/create-campaign.dto");
const create_device_group_dto_1 = require("./dto/create-device-group.dto");
const create_device_tag_dto_1 = require("./dto/create-device-tag.dto");
const create_firmware_model_dto_1 = require("./dto/create-firmware-model.dto");
const create_release_dto_1 = require("./dto/create-release.dto");
const update_campaign_dto_1 = require("./dto/update-campaign.dto");
const admin_service_1 = require("./admin.service");
let AdminController = class AdminController {
    constructor(adminService) {
        this.adminService = adminService;
    }
    dashboard() {
        return this.adminService.getDashboardSummary();
    }
    listDevices() {
        return this.adminService.listDevices();
    }
    listModels() {
        return this.adminService.listFirmwareModels();
    }
    createModel(body, request) {
        return this.adminService.createFirmwareModel(body, request.admin?.id);
    }
    listGroups() {
        return this.adminService.listDeviceGroups();
    }
    createGroup(body, request) {
        return this.adminService.createDeviceGroup(body, request.admin?.id);
    }
    addDeviceToGroup(deviceId, groupId, request) {
        return this.adminService.addDeviceToGroup(deviceId, groupId, request.admin?.id);
    }
    removeDeviceFromGroup(deviceId, groupId, request) {
        return this.adminService.removeDeviceFromGroup(deviceId, groupId, request.admin?.id);
    }
    listTags() {
        return this.adminService.listDeviceTags();
    }
    createTag(body, request) {
        return this.adminService.createDeviceTag(body, request.admin?.id);
    }
    addTagToDevice(deviceId, tagId, request) {
        return this.adminService.addTagToDevice(deviceId, tagId, request.admin?.id);
    }
    removeTagFromDevice(deviceId, tagId, request) {
        return this.adminService.removeTagFromDevice(deviceId, tagId, request.admin?.id);
    }
    listReleases() {
        return this.adminService.listReleases();
    }
    createRelease(body, request) {
        return this.adminService.createRelease(body, request.admin?.id);
    }
    listCampaigns(includeArchived) {
        return this.adminService.listCampaigns(includeArchived === 'true');
    }
    listAuditLogs(limit) {
        return this.adminService.listAuditLogs(limit == null ? undefined : Number(limit));
    }
    listCampaignDevices(campaignId) {
        return this.adminService.listCampaignDevices(campaignId);
    }
    createCampaign(body, request) {
        return this.adminService.createCampaign(body, request.admin?.id);
    }
    updateCampaign(campaignId, body, request) {
        return this.adminService.updateCampaign(campaignId, body, request.admin?.id);
    }
    archiveCampaign(campaignId, request) {
        return this.adminService.archiveCampaign(campaignId, request.admin?.id);
    }
    deleteCampaign(campaignId, request) {
        return this.adminService.deleteCampaign(campaignId, request.admin?.id);
    }
    activateCampaign(campaignId, request) {
        return this.adminService.setCampaignActive(campaignId, true, request.admin?.id);
    }
    pauseCampaign(campaignId, request) {
        return this.adminService.setCampaignActive(campaignId, false, request.admin?.id);
    }
};
exports.AdminController = AdminController;
__decorate([
    (0, common_1.Get)('dashboard'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "dashboard", null);
__decorate([
    (0, common_1.Get)('devices'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listDevices", null);
__decorate([
    (0, common_1.Get)('models'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listModels", null);
__decorate([
    (0, common_1.Post)('models'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_firmware_model_dto_1.CreateFirmwareModelDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createModel", null);
__decorate([
    (0, common_1.Get)('groups'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listGroups", null);
__decorate([
    (0, common_1.Post)('groups'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_device_group_dto_1.CreateDeviceGroupDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createGroup", null);
__decorate([
    (0, common_1.Post)('devices/:deviceId/groups/:groupId'),
    __param(0, (0, common_1.Param)('deviceId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('groupId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "addDeviceToGroup", null);
__decorate([
    (0, common_1.Delete)('devices/:deviceId/groups/:groupId'),
    __param(0, (0, common_1.Param)('deviceId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('groupId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "removeDeviceFromGroup", null);
__decorate([
    (0, common_1.Get)('tags'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listTags", null);
__decorate([
    (0, common_1.Post)('tags'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_device_tag_dto_1.CreateDeviceTagDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createTag", null);
__decorate([
    (0, common_1.Post)('devices/:deviceId/tags/:tagId'),
    __param(0, (0, common_1.Param)('deviceId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('tagId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "addTagToDevice", null);
__decorate([
    (0, common_1.Delete)('devices/:deviceId/tags/:tagId'),
    __param(0, (0, common_1.Param)('deviceId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Param)('tagId', common_1.ParseIntPipe)),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "removeTagFromDevice", null);
__decorate([
    (0, common_1.Get)('releases'),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listReleases", null);
__decorate([
    (0, common_1.Post)('releases'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_release_dto_1.CreateReleaseDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createRelease", null);
__decorate([
    (0, common_1.Get)('campaigns'),
    __param(0, (0, common_1.Query)('include_archived')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listCampaigns", null);
__decorate([
    (0, common_1.Get)('audit-logs'),
    __param(0, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listAuditLogs", null);
__decorate([
    (0, common_1.Get)('campaigns/:campaignId/devices'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "listCampaignDevices", null);
__decorate([
    (0, common_1.Post)('campaigns'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [create_campaign_dto_1.CreateCampaignDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "createCampaign", null);
__decorate([
    (0, common_1.Patch)('campaigns/:campaignId'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Body)()),
    __param(2, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, update_campaign_dto_1.UpdateCampaignDto, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "updateCampaign", null);
__decorate([
    (0, common_1.Post)('campaigns/:campaignId/archive'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "archiveCampaign", null);
__decorate([
    (0, common_1.Delete)('campaigns/:campaignId'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "deleteCampaign", null);
__decorate([
    (0, common_1.Post)('campaigns/:campaignId/activate'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "activateCampaign", null);
__decorate([
    (0, common_1.Post)('campaigns/:campaignId/pause'),
    __param(0, (0, common_1.Param)('campaignId', common_1.ParseIntPipe)),
    __param(1, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Number, Object]),
    __metadata("design:returntype", void 0)
], AdminController.prototype, "pauseCampaign", null);
exports.AdminController = AdminController = __decorate([
    (0, common_1.Controller)('admin'),
    (0, common_1.UseGuards)(admin_jwt_guard_1.AdminJwtGuard),
    __metadata("design:paramtypes", [admin_service_1.AdminService])
], AdminController);
//# sourceMappingURL=admin.controller.js.map