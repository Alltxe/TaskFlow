import { Module } from '@nestjs/common';
import { GroupService } from './group.service';
import { GroupResolver } from './group.resolver';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  providers: [GroupService, GroupResolver],
  exports: [GroupService],
})
export class GroupModule {}
