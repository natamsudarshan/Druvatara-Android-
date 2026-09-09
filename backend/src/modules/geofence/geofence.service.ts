import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateGeofenceDto } from "./dto/create-geofence.dto";
import { UpdateGeofenceDto } from "./dto/update-geofence.dto";

@Injectable()
export class GeofenceService {
  constructor(private prisma: PrismaService) {}

  async getGeofences(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.geofence.findMany({
      where: { childId },
      include: { events: { orderBy: { triggeredAt: "desc" }, take: 5 } },
      orderBy: { createdAt: "desc" },
    });
  }

  async createGeofence(
    childId: string,
    userId: string,
    createGeofenceDto: CreateGeofenceDto,
  ) {
    await this.validateChildAccess(childId, userId, true);

    return this.prisma.geofence.create({
      data: {
        childId,
        name: createGeofenceDto.name,
        latitude: createGeofenceDto.latitude,
        longitude: createGeofenceDto.longitude,
        radiusMeters: createGeofenceDto.radiusMeters,
        type: createGeofenceDto.type || "CIRCLE",
        alertOnEnter: createGeofenceDto.alertOnEnter ?? true,
        alertOnExit: createGeofenceDto.alertOnExit ?? true,
      },
    });
  }

  async updateGeofence(
    geofenceId: string,
    userId: string,
    updateGeofenceDto: UpdateGeofenceDto,
  ) {
    const geofence = await this.prisma.geofence.findUnique({
      where: { id: geofenceId },
      select: { childId: true },
    });

    if (!geofence) {
      throw new NotFoundException("Geofence not found");
    }

    await this.validateChildAccess(geofence.childId, userId, true);

    return this.prisma.geofence.update({
      where: { id: geofenceId },
      data: {
        name: updateGeofenceDto.name,
        latitude: updateGeofenceDto.latitude,
        longitude: updateGeofenceDto.longitude,
        radiusMeters: updateGeofenceDto.radiusMeters,
        alertOnEnter: updateGeofenceDto.alertOnEnter,
        alertOnExit: updateGeofenceDto.alertOnExit,
        isActive: updateGeofenceDto.isActive,
      },
    });
  }

  async deleteGeofence(geofenceId: string, userId: string) {
    const geofence = await this.prisma.geofence.findUnique({
      where: { id: geofenceId },
      select: { childId: true },
    });

    if (!geofence) {
      throw new NotFoundException("Geofence not found");
    }

    await this.validateChildAccess(geofence.childId, userId, true);

    await this.prisma.geofence.delete({
      where: { id: geofenceId },
    });

    return { success: true, message: "Geofence deleted" };
  }

  async getGeofenceEvents(childId: string, userId: string, limit = 50) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.geofenceEvent.findMany({
      where: { childId },
      include: { geofence: { select: { id: true, name: true } } },
      orderBy: { triggeredAt: "desc" },
      take: limit,
    });
  }

  private async validateChildAccess(
    childId: string,
    userId: string,
    requireModify = false,
  ) {
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

    if (requireModify && !["OWNER", "ADMIN"].includes(membership.role)) {
      const coParentPerm = await this.prisma.coParentPermission.findUnique({
        where: {
          familyId_childId_parentId: {
            familyId: child.familyId,
            childId,
            parentId: userId,
          },
        },
      });
      if (!coParentPerm?.modifyPolicies) {
        throw new ForbiddenException("Insufficient permissions");
      }
    }
  }
}
