import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { OtaService } from './ota.service';

@Controller()
export class OtaController {
  constructor(private readonly otaService: OtaService) {}

  @Post('register')
  register(@Body() body: RegisterDeviceDto) {
    return this.otaService.register(body);
  }

  @Get('update')
  update(@Query() query: UpdateQueryDto) {
    return this.otaService.checkUpdate(query);
  }

  @Post('heartbeat')
  heartbeat(@Body() body: HeartbeatDto) {
    return this.otaService.heartbeat(body);
  }
}
