import { Body, Controller, Get, HttpCode, HttpStatus, Post, Query, Req } from '@nestjs/common';
import { HeartbeatDto } from './dto/heartbeat.dto';
import { HotspotVerifyDto } from './dto/hotspot-verify.dto';
import { RegisterDeviceDto } from './dto/register-device.dto';
import { UpdateQueryDto } from './dto/update-query.dto';
import { OtaService } from './ota.service';

type OtaRequestLike = {
  ip?: string;
  headers: Record<string, string | string[] | undefined>;
};

@Controller()
export class OtaController {
  constructor(private readonly otaService: OtaService) {}

  @Post('register')
  @HttpCode(HttpStatus.OK)
  register(@Body() body: RegisterDeviceDto, @Req() request: OtaRequestLike) {
    return this.otaService.register(body, this.extractMeta(request));
  }

  @Get('update')
  update(@Query() query: UpdateQueryDto, @Req() request: OtaRequestLike) {
    return this.otaService.checkUpdate(query, this.extractMeta(request));
  }

  @Post('heartbeat')
  @HttpCode(HttpStatus.OK)
  heartbeat(@Body() body: HeartbeatDto, @Req() request: OtaRequestLike) {
    return this.otaService.heartbeat(body, this.extractMeta(request));
  }

  @Post('hotspot-verify')
  @HttpCode(HttpStatus.OK)
  hotspotVerify(@Body() body: HotspotVerifyDto, @Req() request: OtaRequestLike) {
    const guardSig = this.pickHeader(request.headers, 'x-guard-sig');
    const meta = { ...this.extractMeta(request), signature: guardSig };
    return this.otaService.hotspotVerify(body, meta);
  }

  private extractMeta(request: OtaRequestLike) {
    return {
      ipAddress: request.ip ?? null,
      signature: this.pickHeader(request.headers, 'x-ota-signature'),
      timestamp: this.pickHeader(request.headers, 'x-ota-ts'),
    };
  }

  private pickHeader(headers: OtaRequestLike['headers'], name: string): string | null {
    const value = headers[name];

    if (!value) {
      return null;
    }

    return Array.isArray(value) ? value[0] ?? null : value;
  }
}
