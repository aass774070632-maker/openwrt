import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { AdminJwtGuard } from '../auth/admin-jwt.guard';
import { CreateReleaseDto } from './dto/create-release.dto';
import { AdminService } from './admin.service';

@Controller('admin/releases')
@UseGuards(AdminJwtGuard)
export class AdminController {
  constructor(private readonly adminService: AdminService) {}

  @Get()
  listReleases() {
    return this.adminService.listReleases();
  }

  @Post()
  createRelease(@Body() body: CreateReleaseDto) {
    return this.adminService.createRelease(body);
  }
}