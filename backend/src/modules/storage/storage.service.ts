import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import * as Minio from 'minio';
import { v4 as uuidv4 } from 'uuid';
import * as path from 'path';

@Injectable()
export class StorageService implements OnModuleInit {
  private readonly logger = new Logger(StorageService.name);
  private readonly client: Minio.Client;
  private readonly bucket: string;
  private readonly publicUrl: string;

  constructor() {
    const endpoint = process.env.MINIO_ENDPOINT || 'localhost';
    const port = parseInt(process.env.MINIO_PORT || '9000', 10);
    const useSSL = process.env.MINIO_USE_SSL === 'true';

    this.bucket = process.env.MINIO_BUCKET || 'taskflow';
    this.publicUrl =
      process.env.MINIO_PUBLIC_URL ||
      `${useSSL ? 'https' : 'http'}://${endpoint}:${port}`;

    this.client = new Minio.Client({
      endPoint: endpoint,
      port,
      useSSL,
      accessKey: process.env.MINIO_ACCESS_KEY || 'minioadmin',
      secretKey: process.env.MINIO_SECRET_KEY || 'minioadmin',
    });
  }

  async onModuleInit() {
    await this.ensureBucket();
  }

  private async ensureBucket() {
    try {
      const exists = await this.client.bucketExists(this.bucket);
      if (!exists) {
        await this.client.makeBucket(this.bucket);
        this.logger.log(`Bucket '${this.bucket}' created`);
      }

      // Set public-read policy so files are accessible via URL
      const policy = JSON.stringify({
        Version: '2012-10-17',
        Statement: [
          {
            Effect: 'Allow',
            Principal: { AWS: ['*'] },
            Action: ['s3:GetObject'],
            Resource: [`arn:aws:s3:::${this.bucket}/*`],
          },
        ],
      });
      await this.client.setBucketPolicy(this.bucket, policy);
    } catch (err) {
      this.logger.warn(
        `MinIO bucket setup failed (service may be unavailable): ${err?.message}`,
      );
    }
  }

  /**
   * Upload a file to MinIO and return its public URL.
   * @param prefix  Folder prefix, e.g. 'avatars/userId' or 'task-attachments'
   * @param buffer  File buffer
   * @param originalName  Original filename (used for extension)
   * @param mimeType  MIME type
   */
  async uploadFile(
    prefix: string,
    buffer: Buffer,
    originalName: string,
    mimeType: string,
  ): Promise<string> {
    const ext = path.extname(originalName) || '';
    const key = `${prefix}/${uuidv4()}${ext}`;

    await this.client.putObject(this.bucket, key, buffer, buffer.length, {
      'Content-Type': mimeType,
    });

    return `${this.publicUrl}/${this.bucket}/${key}`;
  }

  /**
   * Delete a file from MinIO by its full URL.
   */
  async deleteFileByUrl(fileUrl: string): Promise<void> {
    try {
      const key = this.extractKeyFromUrl(fileUrl);
      if (key) {
        await this.client.removeObject(this.bucket, key);
      }
    } catch (err) {
      this.logger.warn(`Failed to delete file '${fileUrl}': ${err?.message}`);
    }
  }

  private extractKeyFromUrl(url: string): string | null {
    // URL format: <publicUrl>/<bucket>/<key>
    const prefix = `${this.publicUrl}/${this.bucket}/`;
    if (url.startsWith(prefix)) {
      return url.slice(prefix.length);
    }
    return null;
  }
}
