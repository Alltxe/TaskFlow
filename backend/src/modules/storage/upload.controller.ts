import {
  Controller,
  Post,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { memoryStorage } from 'multer';
import { JwtAuthGuard } from '../auth/auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { StorageService } from './storage.service';
import type { User } from '@prisma/client';

interface MulterFile {
  fieldname: string;
  originalname: string;
  encoding: string;
  mimetype: string;
  size: number;
  buffer: Buffer;
}

const AVATAR_MIME_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/gif'];
const ATTACHMENT_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/gif',
  'image/webp',
  'application/pdf',
  'application/msword',
  'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'application/vnd.ms-excel',
  'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'text/plain',
];

@Controller('upload')
export class UploadController {
  constructor(private readonly storageService: StorageService) {}

  /**
   * POST /upload/avatar
   * Accepts image, returns { url: string }
   */
  @Post('avatar')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        if (!AVATAR_MIME_TYPES.includes(file.mimetype)) {
          cb(
            new BadRequestException(
              `Разрешены только изображения (jpeg, png, webp, gif)`,
            ),
            false,
          );
          return;
        }
        cb(null, true);
      },
    }),
  )
  async uploadAvatar(
    @UploadedFile() file: MulterFile,
    @CurrentUser() user: User,
  ) {
    if (!file) throw new BadRequestException('Файл не передан');

    const url = await this.storageService.uploadFile(
      `avatars/${user.id}`,
      file.buffer,
      file.originalname,
      file.mimetype,
    );

    return { url };
  }

  /**
   * POST /upload/reward-image
   * Accepts image, returns { url: string }
   */
  @Post('reward-image')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        if (!AVATAR_MIME_TYPES.includes(file.mimetype)) {
          cb(
            new BadRequestException(
              `Разрешены только изображения (jpeg, png, webp, gif)`,
            ),
            false,
          );
          return;
        }
        cb(null, true);
      },
    }),
  )
  async uploadRewardImage(
    @UploadedFile() file: MulterFile,
    @CurrentUser() _user: User,
  ) {
    if (!file) throw new BadRequestException('Файл не передан');

    const url = await this.storageService.uploadFile(
      'reward-images',
      file.buffer,
      file.originalname,
      file.mimetype,
    );

    return { url };
  }

  /**
   * POST /upload/task-attachment
   * Accepts image or document, returns { url, filename, fileSize, mimeType }
   */
  @Post('task-attachment')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: memoryStorage(),
      limits: { fileSize: 10 * 1024 * 1024 },
      fileFilter: (_req, file, cb) => {
        if (!ATTACHMENT_MIME_TYPES.includes(file.mimetype)) {
          cb(
            new BadRequestException(
              `Тип файла '${file.mimetype}' не поддерживается`,
            ),
            false,
          );
          return;
        }
        cb(null, true);
      },
    }),
  )
  async uploadTaskAttachment(
    @UploadedFile() file: MulterFile,
    @CurrentUser() _user: User,
  ) {
    if (!file) throw new BadRequestException('Файл не передан');

    const url = await this.storageService.uploadFile(
      'task-attachments',
      file.buffer,
      file.originalname,
      file.mimetype,
    );

    return {
      url,
      filename: file.originalname,
      fileSize: file.size,
      mimeType: file.mimetype,
    };
  }
}
