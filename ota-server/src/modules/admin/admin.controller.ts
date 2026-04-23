import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  ParseIntPipe,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { AdminJwtGuard } from '../auth/admin-jwt.guard';
import { AuthenticatedAdmin } from '../auth/auth.service';
import { CreateCampaignDto } from './dto/create-campaign.dto';
import { CreateDeviceGroupDto } from './dto/create-device-group.dto';
import { CreateDeviceTagDto } from './dto/create-device-tag.dto';
import { CreateFirmwareModelDto } from './dto/create-firmware-model.dto';
import { CreateReleaseDto } from './dto/create-release.dto';
import { UpdateCampaignDto } from './dto/update-campaign.dto';
import { AdminService } from './admin.service';

type AdminRequestLike = {
  admin?: AuthenticatedAdmin;
};

@Controller('admin')
@UseGuards(AdminJwtGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get('dashboard')
  dashboard() {
    return this.adminService.getDashboardSummary();
  }

  @Get('devices')
  listDevices() {
    return this.adminService.listDevices();
  }

  @Get('models')
  listModels() {
    return this.adminService.listFirmwareModels();
  }

  @Post('models')
  createModel(@Body() body: CreateFirmwareModelDto, @Req() request: AdminRequestLike) {
    return this.adminService.createFirmwareModel(body, request.admin?.id);
  }

  @Get('groups')
  listGroups() {
    return this.adminService.listDeviceGroups();
  }

  @Post('groups')
  createGroup(@Body() body: CreateDeviceGroupDto, @Req() request: AdminRequestLike) {
    return this.adminService.createDeviceGroup(body, request.admin?.id);
  }

  @Post('devices/:deviceId/groups/:groupId')
  addDeviceToGroup(
    @Param('deviceId', ParseIntPipe) deviceId: number,
    @Param('groupId', ParseIntPipe) groupId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.addDeviceToGroup(deviceId, groupId, request.admin?.id);
  }

  @Delete('devices/:deviceId/groups/:groupId')
  removeDeviceFromGroup(
    @Param('deviceId', ParseIntPipe) deviceId: number,
    @Param('groupId', ParseIntPipe) groupId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.removeDeviceFromGroup(deviceId, groupId, request.admin?.id);
  }

  @Get('tags')
  listTags() {
    return this.adminService.listDeviceTags();
  }

  @Post('tags')
  createTag(@Body() body: CreateDeviceTagDto, @Req() request: AdminRequestLike) {
    return this.adminService.createDeviceTag(body, request.admin?.id);
  }

  @Post('devices/:deviceId/tags/:tagId')
  addTagToDevice(
    @Param('deviceId', ParseIntPipe) deviceId: number,
    @Param('tagId', ParseIntPipe) tagId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.addTagToDevice(deviceId, tagId, request.admin?.id);
  }

  @Delete('devices/:deviceId/tags/:tagId')
  removeTagFromDevice(
    @Param('deviceId', ParseIntPipe) deviceId: number,
    @Param('tagId', ParseIntPipe) tagId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.removeTagFromDevice(deviceId, tagId, request.admin?.id);
  }

  @Get('releases')
  listReleases() {
    return this.adminService.listReleases();
  }

  @Post('releases')
  createRelease(@Body() body: CreateReleaseDto, @Req() request: AdminRequestLike) {
    return this.adminService.createRelease(body, request.admin?.id);
  }

  @Get('campaigns')
  listCampaigns(@Query('include_archived') includeArchived?: string) {
    return this.adminService.listCampaigns(includeArchived === 'true');
  }

  @Get('audit-logs')
  listAuditLogs(@Query('limit') limit?: string) {
    return this.adminService.listAuditLogs(limit == null ? undefined : Number(limit));
  }

  @Get('campaigns/:campaignId/devices')
  listCampaignDevices(@Param('campaignId', ParseIntPipe) campaignId: number) {
    return this.adminService.listCampaignDevices(campaignId);
  }

  @Post('campaigns')
  createCampaign(@Body() body: CreateCampaignDto, @Req() request: AdminRequestLike) {
    return this.adminService.createCampaign(body, request.admin?.id);
  }

  @Patch('campaigns/:campaignId')
  updateCampaign(
    @Param('campaignId', ParseIntPipe) campaignId: number,
    @Body() body: UpdateCampaignDto,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.updateCampaign(campaignId, body, request.admin?.id);
  }

  @Post('campaigns/:campaignId/archive')
  archiveCampaign(
    @Param('campaignId', ParseIntPipe) campaignId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.archiveCampaign(campaignId, request.admin?.id);
  }

  @Delete('campaigns/:campaignId')
  deleteCampaign(
    @Param('campaignId', ParseIntPipe) campaignId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.deleteCampaign(campaignId, request.admin?.id);
  }

  @Post('campaigns/:campaignId/activate')
  activateCampaign(
    @Param('campaignId', ParseIntPipe) campaignId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.setCampaignActive(campaignId, true, request.admin?.id);
  }

  @Post('campaigns/:campaignId/pause')
  pauseCampaign(
    @Param('campaignId', ParseIntPipe) campaignId: number,
    @Req() request: AdminRequestLike,
  ) {
    return this.adminService.setCampaignActive(campaignId, false, request.admin?.id);
  }
}