import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from "@nestjs/common";
import { JwtService } from "@nestjs/jwt";
import * as bcrypt from "bcrypt";
import { PrismaService } from "../../prisma/prisma.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { TokenPayload } from "./interfaces/token-payload.interface";
import { DeviceTokenPayload } from "./interfaces/device-token-payload.interface";

@Injectable()
export class AuthService {
  constructor(
    private prisma: PrismaService,
    private jwtService: JwtService,
  ) {}

  async register(registerDto: RegisterDto) {
    const existingUser = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });

    if (existingUser) {
      throw new ConflictException("Email already registered");
    }

    const passwordHash = await bcrypt.hash(registerDto.password, 12);

    const user = await this.prisma.user.create({
      data: {
        email: registerDto.email,
        name: registerDto.name,
        passwordHash,
        country: registerDto.country || "IN",
      },
      select: {
        id: true,
        email: true,
        name: true,
        country: true,
        createdAt: true,
      },
    });

    const family = await this.prisma.family.create({
      data: {
        name: `${user.name}'s Family`,
        ownerId: user.id,
      },
    });

    await this.prisma.familyMember.create({
      data: {
        familyId: family.id,
        userId: user.id,
        role: "OWNER",
      },
    });

    const tokens = await this.generateTokens(user.id, family.id);

    return {
      user,
      familyId: family.id,
      ...tokens,
    };
  }

  async login(loginDto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: loginDto.email },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException("Invalid credentials");
    }

    const isPasswordValid = await bcrypt.compare(
      loginDto.password,
      user.passwordHash,
    );
    if (!isPasswordValid) {
      throw new UnauthorizedException("Invalid credentials");
    }

    const familyMember = await this.prisma.familyMember.findFirst({
      where: { userId: user.id, isActive: true },
      include: { family: true },
    });

    if (!familyMember) {
      throw new BadRequestException("No active family found");
    }

    const tokens = await this.generateTokens(user.id, familyMember.familyId);

    return {
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        country: user.country,
        timezone: user.timezone,
        language: user.language,
      },
      familyId: familyMember.familyId,
      ...tokens,
    };
  }

  async refreshToken(refreshTokenDto: RefreshTokenDto) {
    try {
      const payload = this.jwtService.verify(refreshTokenDto.refreshToken, {
        secret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
      });

      const session = await this.prisma.session.findUnique({
        where: { refreshToken: refreshTokenDto.refreshToken },
      });

      if (!session || session.revokedAt || session.expiresAt < new Date()) {
        throw new UnauthorizedException("Invalid or expired refresh token");
      }

      const user = await this.prisma.user.findUnique({
        where: { id: payload.sub },
      });

      if (!user || !user.isActive) {
        throw new UnauthorizedException("User not found or inactive");
      }

      const familyMember = await this.prisma.familyMember.findFirst({
        where: { userId: user.id, isActive: true },
      });

      if (!familyMember) {
        throw new BadRequestException("No active family found");
      }

      await this.prisma.session.update({
        where: { id: session.id },
        data: { revokedAt: new Date() },
      });

      const tokens = await this.generateTokens(user.id, familyMember.familyId);

      return tokens;
    } catch (error) {
      if (
        error instanceof UnauthorizedException ||
        error instanceof BadRequestException
      ) {
        throw error;
      }
      throw new UnauthorizedException("Invalid refresh token");
    }
  }

  async logout(userId: string, sessionId?: string, accessToken?: string) {
    if (sessionId) {
      await this.prisma.session.update({
        where: { id: sessionId, userId },
        data: { revokedAt: new Date() },
      });
    } else if (accessToken) {
      await this.prisma.session.updateMany({
        where: { userId, accessToken, revokedAt: null },
        data: { revokedAt: new Date() },
      });
    }
  }

  async logoutAll(userId: string) {
    await this.prisma.session.updateMany({
      where: { userId, revokedAt: null },
      data: { revokedAt: new Date() },
    });
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
      throw new UnauthorizedException("Session not found");
    }

    await this.prisma.session.update({
      where: { id: sessionId },
      data: { revokedAt: new Date() },
    });
  }

  async generateDeviceToken(deviceId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      include: { child: true },
    });

    if (!device || !device.isActive) {
      throw new UnauthorizedException("Device not found or inactive");
    }

    const payload = {
      sub: device.id,
      deviceId: device.id,
      familyId: device.familyId,
      childId: device.childId,
      credentialVersion: device.credentialVersion,
      type: "device",
    };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: "1h",
      secret: process.env.DEVICE_JWT_SECRET || process.env.JWT_SECRET,
    });

    return { accessToken, expiresIn: 3600 };
  }

  private async generateTokens(userId: string, familyId: string) {
    const payload = {
      sub: userId,
      familyId,
      type: "user",
    };

    const accessToken = this.jwtService.sign(payload, {
      expiresIn: "15m",
    });

    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: "30d",
      secret: process.env.JWT_REFRESH_SECRET || process.env.JWT_SECRET,
    });

    const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

    await this.prisma.session.create({
      data: {
        userId,
        accessToken,
        refreshToken,
        expiresAt,
      },
    });

    return { accessToken, refreshToken, expiresIn: 900 };
  }

  async validateUser(payload: any) {
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
      select: {
        id: true,
        email: true,
        name: true,
        isActive: true,
        role: true,
      },
    });

    if (!user || !user.isActive) {
      throw new UnauthorizedException("User not found or inactive");
    }

    const familyMember = await this.prisma.familyMember.findFirst({
      where: { userId: user.id, isActive: true },
      include: { family: true },
    });

    if (!familyMember) {
      throw new UnauthorizedException("No active family found");
    }

    return {
      sub: user.id,
      familyId: familyMember.familyId,
      type: "user" as const,
      email: user.email,
      name: user.name,
      role: user.role,
      isActive: user.isActive,
    };
  }

  async validateDevice(payload: any) {
    const deviceSelect = {
      id: true,
      familyId: true,
      childId: true,
      credentialVersion: true,
      isActive: true,
      status: true,
    };

    const device = await this.prisma.device.findUnique({
      where: { id: payload.deviceId },
      select: deviceSelect,
    });

    if (
      !device ||
      !device.isActive ||
      device.credentialVersion !== payload.credentialVersion
    ) {
      throw new UnauthorizedException(
        "Device not found or credential mismatch",
      );
    }

    return device;
  }
}
