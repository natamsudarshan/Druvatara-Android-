import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class LocationService {
  constructor(private prisma: PrismaService) {}

  async updateLocation(
    deviceId: string,
    latitude: number,
    longitude: number,
    accuracy?: number,
  ) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      select: { id: true, familyId: true, childId: true },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    const location = await this.prisma.location.create({
      data: {
        childId: device.childId,
        deviceId,
        latitude,
        longitude,
        accuracyMeters: accuracy || 0,
        source: "GPS",
        capturedAt: new Date(),
      },
    });

    // Check geofences
    await this.checkGeofences(device.childId, latitude, longitude);

    return location;
  }

  async getCurrentLocation(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const latest = await this.prisma.location.findFirst({
      where: { childId },
      orderBy: { capturedAt: "desc" },
    });

    return latest;
  }

  async getLocationHistory(childId: string, userId: string, hours = 24) {
    await this.validateChildAccess(childId, userId);

    const startTime = new Date(Date.now() - hours * 60 * 60 * 1000);

    return this.prisma.location.findMany({
      where: {
        childId,
        capturedAt: { gte: startTime },
      },
      orderBy: { capturedAt: "desc" },
      take: 1000,
    });
  }

  private async checkGeofences(
    childId: string,
    latitude: number,
    longitude: number,
  ) {
    const geofences = await this.prisma.geofence.findMany({
      where: { childId, isActive: true },
    });

    for (const geofence of geofences) {
      const distance = this.calculateDistance(
        latitude,
        longitude,
        geofence.latitude,
        geofence.longitude,
      );
      const inside = distance <= geofence.radiusMeters;

      // Check if there's a recent event for this geofence
      const recentEvent = await this.prisma.geofenceEvent.findFirst({
        where: {
          geofenceId: geofence.id,
          eventType: inside ? "ENTER" : "EXIT",
          triggeredAt: { gte: new Date(Date.now() - 5 * 60 * 1000) }, // 5 minutes
        },
      });

      if (!recentEvent) {
        await this.prisma.geofenceEvent.create({
          data: {
            geofenceId: geofence.id,
            childId,
            eventType: inside ? "ENTER" : "EXIT",
            latitude,
            longitude,
            accuracy: 0,
            triggeredAt: new Date(),
          },
        });
      }
    }
  }

  private calculateDistance(
    lat1: number,
    lon1: number,
    lat2: number,
    lon2: number,
  ): number {
    const R = 6371000; // Earth radius in meters
    const dLat = this.toRad(lat2 - lat1);
    const dLon = this.toRad(lon2 - lon1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRad(lat1)) *
        Math.cos(this.toRad(lat2)) *
        Math.sin(dLon / 2) *
        Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRad(deg: number): number {
    return (deg * Math.PI) / 180;
  }

  private async validateChildAccess(childId: string, userId: string) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true },
    });

    if (!child) {
      throw new NotFoundException("Child not found");
    }

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId: child.familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }
}
