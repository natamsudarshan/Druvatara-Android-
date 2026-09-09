import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { UpdateUserDto } from "./dto/update-user.dto";
import { UpdatePreferencesDto } from "./dto/update-preferences.dto";
import * as bcrypt from "bcrypt";

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async findMe(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        country: true,
        timezone: true,
        language: true,
        avatarUrl: true,
        role: true,
        createdAt: true,
        lastLoginAt: true,
      },
    });
  }

  async updateMe(userId: string, updateUserDto: UpdateUserDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        name: updateUserDto.name,
        timezone: updateUserDto.timezone,
        language: updateUserDto.language,
        avatarUrl: updateUserDto.avatarUrl,
      },
      select: {
        id: true,
        email: true,
        name: true,
        country: true,
        timezone: true,
        language: true,
        avatarUrl: true,
      },
    });
  }

  async updatePreferences(
    userId: string,
    updatePreferencesDto: UpdatePreferencesDto,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { preferences: true },
    });

    const currentPreferences = (user?.preferences as Record<string, any>) || {};

    return this.prisma.user.update({
      where: { id: userId },
      data: {
        preferences: {
          ...currentPreferences,
          ...updatePreferencesDto.preferences,
        },
      },
      select: { preferences: true },
    });
  }

  async getSecurityStatus(userId: string) {
    const sessions = await this.prisma.session.findMany({
      where: { userId, revokedAt: null },
      select: {
        id: true,
        deviceName: true,
        devicePlatform: true,
        ipAddress: true,
        createdAt: true,
        lastUsedAt: true,
      },
      orderBy: { lastUsedAt: "desc" },
    });

    const hasMfa = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { mfaEnabled: true, mfaSecret: true },
    });

    return {
      activeSessions: sessions.length,
      sessions,
      mfaEnabled: hasMfa?.mfaEnabled || false,
      passwordLastChanged: null, // Would track this separately
    };
  }

  async changePassword(
    userId: string,
    currentPassword: string,
    newPassword: string,
  ) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { passwordHash: true },
    });

    if (!user) {
      throw new NotFoundException("User not found");
    }

    const isValid = await bcrypt.compare(currentPassword, user.passwordHash);
    if (!isValid) {
      throw new ForbiddenException("Current password is incorrect");
    }

    const newHash = await bcrypt.hash(newPassword, 12);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash: newHash },
    });

    // Revoke all other sessions
    const currentSessionId = await this.getCurrentSessionId(userId);
    await this.prisma.session.updateMany({
      where: {
        userId,
        ...(currentSessionId ? { id: { not: currentSessionId } } : {}),
      },
      data: { revokedAt: new Date() },
    });

    return { success: true, message: "Password changed successfully" };
  }

  private async getCurrentSessionId(userId: string): Promise<string | null> {
    // This would be extracted from the request context in practice
    return null;
  }

  async getSessions(userId: string) {
    return this.prisma.session.findMany({
      where: { userId },
      select: {
        id: true,
        deviceName: true,
        devicePlatform: true,
        ipAddress: true,
        createdAt: true,
        lastUsedAt: true,
        revokedAt: true,
        expiresAt: true,
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async revokeSession(userId: string, sessionId: string) {
    const session = await this.prisma.session.findUnique({
      where: { id: sessionId },
    });

    if (!session || session.userId !== userId) {
      throw new NotFoundException("Session not found");
    }

    await this.prisma.session.update({
      where: { id: sessionId },
      data: { revokedAt: new Date() },
    });

    return { success: true };
  }
}
