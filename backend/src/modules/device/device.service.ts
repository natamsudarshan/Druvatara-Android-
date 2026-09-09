import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { RegisterDeviceDto } from "./dto/register-device.dto";
import { DevicePlatform, DeviceStatus, ConnectionType } from "@prisma/client";
import { v4 as uuidv4 } from "uuid";

@Injectable()
export class DeviceService {
  constructor(private prisma: PrismaService) {}

  async registerDevice(
    familyId: string,
    childId: string | null,
    dto: RegisterDeviceDto,
    pairingCode?: string,
  ) {
    let device: any;

    if (pairingCode) {
      const pairing = await this.prisma.pairingSession.findUnique({
        where: { pairingCode },
      });

      if (!pairing || pairing.expiresAt < new Date() || pairing.usedAt) {
        throw new BadRequestException("Invalid or expired pairing code");
      }

      // familyId is derived from pairing session when using pairing code
      familyId = pairing.familyId;

      device = await this.prisma.device.create({
        data: {
          familyId,
          childId: pairing.childId || childId || "",
          deviceName:
            dto.deviceName ||
            `${dto.manufacturer || ""} ${dto.model || ""}`.trim() ||
            "New Device",
          platform: dto.platform,
          platformVersion: dto.platformVersion,
          manufacturer: dto.manufacturer,
          model: dto.model,
          appVersion: dto.appVersion,
          buildNumber: dto.buildNumber,
          installationId: dto.installationId,
          internalId: pairing.deviceInternalId || uuidv4(),
          capabilities: dto.capabilities as any,
          publicKey: "",
          credentialVersion: 1,
          status: DeviceStatus.ACTIVE,
          connectionType: ConnectionType.WIFI,
        },
      });

      await this.prisma.pairingSession.update({
        where: { id: pairing.id },
        data: {
          usedAt: new Date(),
          claimedAt: new Date(),
          deviceId: device.id,
        },
      });
    } else {
      device = await this.prisma.device.create({
        data: {
          familyId,
          childId: childId || "",
          deviceName:
            dto.deviceName ||
            `${dto.manufacturer || ""} ${dto.model || ""}`.trim() ||
            "New Device",
          platform: dto.platform,
          platformVersion: dto.platformVersion,
          manufacturer: dto.manufacturer,
          model: dto.model,
          appVersion: dto.appVersion,
          buildNumber: dto.buildNumber,
          installationId: dto.installationId,
          internalId: uuidv4(),
          capabilities: dto.capabilities as any,
          publicKey: "",
          credentialVersion: 1,
          status: DeviceStatus.ACTIVE,
          connectionType: ConnectionType.WIFI,
        },
      });
    }

    return device;
  }

  async getDevice(deviceId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      include: {
        child: { select: { id: true, name: true, avatarId: true } },
        policies: true,
      },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    return device;
  }

  async getFamilyDevices(familyId: string) {
    return this.prisma.device.findMany({
      where: { familyId },
      include: {
        child: { select: { id: true, name: true, avatarId: true } },
      },
      orderBy: { createdAt: "desc" },
    });
  }

  async updateDevice(
    deviceId: string,
    data: Partial<{
      name: string;
      status: DeviceStatus;
      connectionType: ConnectionType;
      lastIp: string;
      capabilities: Record<string, any>;
      appVersion: string;
      buildNumber: string;
    }>,
  ) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    return this.prisma.device.update({
      where: { id: deviceId },
      data,
    });
  }

  async updateDeviceStatus(
    deviceId: string,
    status: DeviceStatus,
    connectionType?: ConnectionType,
  ) {
    return this.updateDevice(deviceId, {
      status,
      ...(connectionType && { connectionType }),
    });
  }

  async updateDeviceHeartbeat(deviceId: string, ipAddress?: string) {
    return this.prisma.device.update({
      where: { id: deviceId },
      data: {
        lastSeenAt: new Date(),
        ...(ipAddress && { lastIp: ipAddress }),
      },
    });
  }

  async updatePublicKey(
    deviceId: string,
    publicKey: string,
    credentialVersion: number,
  ) {
    return this.prisma.device.update({
      where: { id: deviceId },
      data: { publicKey, credentialVersion },
    });
  }

  async deleteDevice(deviceId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    await this.prisma.device.update({
      where: { id: deviceId },
      data: { isActive: false, status: DeviceStatus.REMOVED },
    });

    return { success: true };
  }

  async getDeviceHealth(deviceId: string) {
    const device = await this.getDevice(deviceId);
    const now = new Date();
    const fiveMinutesAgo = new Date(now.getTime() - 5 * 60 * 1000);

    const isOnline = device.lastSeenAt && device.lastSeenAt > fiveMinutesAgo;

    const recentEvents = await this.prisma.deviceEvent.count({
      where: {
        deviceId,
        capturedAt: { gte: fiveMinutesAgo },
      },
    });

    return {
      deviceId,
      isOnline,
      status: device.status,
      lastSeenAt: device.lastSeenAt,
      lastIp: device.lastIp,
      batteryLevel: device.batteryLevel,
      storageUsed: device.storageUsed,
      storageTotal: device.storageTotal,
      recentEventCount: recentEvents,
    };
  }

  async getDevicesByChild(childId: string) {
    return this.prisma.device.findMany({
      where: { childId, isActive: true },
      orderBy: { createdAt: "desc" },
    });
  }
}
