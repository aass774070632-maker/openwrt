import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { createHash } from 'node:crypto';
import { readFile, stat } from 'node:fs/promises';
import path from 'node:path';
import { env } from '../../config/env';
import { PrismaService } from '../prisma/prisma.service';
import { CreateReleaseDto } from './dto/create-release.dto';

type ReleaseWithFiles = Prisma.ReleaseGetPayload<{ include: { files: true } }>;

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async listReleases() {
    const releases = await this.prisma.release.findMany({
      include: {
        files: true,
      },
      orderBy: [
        { createdAt: 'desc' },
        { id: 'desc' },
      ],
    });

    return releases.map((release) => this.serializeRelease(release));
  }

  async createRelease(body: CreateReleaseDto) {
    const channel = body.channel ?? 'stable';
    const active = body.active ?? true;
    const force = body.force ?? false;
    const rolloutPercent = body.rollout_percent ?? 100;
    const normalizedArtifactPath = this.normalizeArtifactPath(body.artifact_path);
    const filePath = this.resolveArtifactPath(normalizedArtifactPath);
    const [buffer, fileStats] = await Promise.all([readFile(filePath), stat(filePath)]);
    const sha256 = createHash('sha256').update(buffer).digest('hex');
    const downloadUrl = `${this.trimTrailingSlash(env.FIRMWARE_PUBLIC_BASE_URL)}${normalizedArtifactPath}`;

    const release = await this.prisma.$transaction(async (tx) => {
      await tx.releaseFile.deleteMany({
        where: {
          release: {
            model: body.model,
            version: body.version,
            channel,
          },
        },
      });

      await tx.release.deleteMany({
        where: {
          model: body.model,
          version: body.version,
          channel,
        },
      });

      if (active) {
        await tx.release.updateMany({
          where: {
            model: body.model,
            channel,
            active: true,
          },
          data: {
            active: false,
          },
        });
      }

      return tx.release.create({
        data: {
          model: body.model,
          version: body.version,
          versionCode: body.version_code ?? null,
          downloadUrl,
          sha256,
          changelog: body.changelog ?? '',
          force,
          rolloutPercent,
          active,
          channel,
          files: {
            create: [
              {
                kind: 'sysupgrade',
                url: downloadUrl,
                sha256,
                sizeBytes: BigInt(fileStats.size),
              },
            ],
          },
        },
        include: {
          files: true,
        },
      });
    });

    return this.serializeRelease(release);
  }

  private normalizeArtifactPath(artifactPath: string): string {
    const normalized = path.posix.normalize(artifactPath);

    if (!normalized.startsWith('/firmware/')) {
      throw new BadRequestException('artifact_path must start with /firmware/');
    }

    return normalized;
  }

  private resolveArtifactPath(artifactPath: string): string {
    const firmwareRoot = path.resolve(process.cwd(), 'public', 'firmware');
    const resolvedPath = path.resolve(process.cwd(), 'public', `.${artifactPath}`);

    if (resolvedPath !== firmwareRoot && !resolvedPath.startsWith(`${firmwareRoot}${path.sep}`)) {
      throw new BadRequestException('artifact_path resolves outside public/firmware');
    }

    return resolvedPath;
  }

  private serializeRelease(release: ReleaseWithFiles) {
    return {
      id: release.id,
      model: release.model,
      version: release.version,
      version_code: release.versionCode,
      download_url: release.downloadUrl,
      sha256: release.sha256,
      changelog: release.changelog ?? '',
      force: release.force,
      rollout_percent: release.rolloutPercent,
      active: release.active,
      channel: release.channel,
      created_at: release.createdAt.toISOString(),
      updated_at: release.updatedAt.toISOString(),
      files: release.files.map((file) => ({
        id: file.id,
        kind: file.kind,
        url: file.url,
        sha256: file.sha256,
        size_bytes: file.sizeBytes === null ? null : Number(file.sizeBytes),
        created_at: file.createdAt.toISOString(),
      })),
    };
  }

  private trimTrailingSlash(value: string): string {
    return value.endsWith('/') ? value.slice(0, -1) : value;
  }
}