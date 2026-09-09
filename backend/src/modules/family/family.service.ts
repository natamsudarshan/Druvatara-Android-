import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateFamilyDto } from "./dto/create-family.dto";
import { UpdateFamilyDto } from "./dto/update-family.dto";

@Injectable()
export class FamilyService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, createFamilyDto: CreateFamilyDto) {
    const family = await this.prisma.family.create({
      data: {
        name: createFamilyDto.name,
        ownerId: userId,
        timezone: createFamilyDto.timezone || "Asia/Kolkata",
        language: createFamilyDto.language || "en",
      },
    });

    await this.prisma.familyMember.create({
      data: {
        familyId: family.id,
        userId,
        role: "OWNER",
      },
    });

    return family;
  }

  async findById(familyId: string, userId: string) {
    const family = await this.prisma.family.findUnique({
      where: { id: familyId },
      include: {
        members: {
          where: { isActive: true },
          include: {
            user: {
              select: { id: true, name: true, email: true, avatarUrl: true },
            },
          },
        },
        children: { where: { isActive: true } },
        devices: { where: { isActive: true } },
        _count: {
          select: {
            children: true,
            devices: true,
            alerts: { where: { status: "NEW" } },
          },
        },
      },
    });

    if (!family) {
      throw new NotFoundException("Family not found");
    }

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }

    return family;
  }

  async getSummary(familyId: string, userId: string) {
    await this.validateMembership(familyId, userId);

    const [
      childrenCount,
      devicesCount,
      unresolvedAlerts,
      pendingRequests,
      protectionState,
    ] = await Promise.all([
      this.prisma.child.count({ where: { familyId, isActive: true } }),
      this.prisma.device.count({ where: { familyId, isActive: true } }),
      this.prisma.alert.count({ where: { familyId, status: "NEW" } }),
      this.prisma.childRequest.count({
        where: { child: { familyId }, status: "PENDING" },
      }),
      this.getProtectionState(familyId),
    ]);

    return {
      childrenCount,
      devicesCount,
      unresolvedAlerts,
      pendingRequests,
      protectionState,
    };
  }

  async update(
    familyId: string,
    userId: string,
    updateFamilyDto: UpdateFamilyDto,
  ) {
    await this.validateOwner(familyId, userId);

    return this.prisma.family.update({
      where: { id: familyId },
      data: {
        name: updateFamilyDto.name,
        timezone: updateFamilyDto.timezone,
        language: updateFamilyDto.language,
        settings: updateFamilyDto.settings,
      },
    });
  }

  async requestDeletion(familyId: string, userId: string) {
    await this.validateOwner(familyId, userId);

    return this.prisma.family.update({
      where: { id: familyId },
      data: { deletedAt: new Date(), isActive: false },
    });
  }

  async getEntitlements(familyId: string, userId: string) {
    await this.validateMembership(familyId, userId);

    const subscription = await this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
      orderBy: { createdAt: "desc" },
    });

    const tier = subscription?.tier || "FREE";
    const entitlements = this.getTierEntitlements(tier);

    return { tier, ...entitlements };
  }

  private async validateMembership(familyId: string, userId: string) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }

  private async validateOwner(familyId: string, userId: string) {
    const family = await this.prisma.family.findUnique({
      where: { id: familyId },
      select: { ownerId: true },
    });

    if (!family || family.ownerId !== userId) {
      throw new ForbiddenException("Only family owner can perform this action");
    }
  }

  private async getProtectionState(familyId: string): Promise<string> {
    const devices = await this.prisma.device.findMany({
      where: { familyId, isActive: true },
      select: { status: true },
    });

    if (devices.length === 0) return "NO_DEVICES";

    const allProtected = devices.every((d) => d.status === "ACTIVE");
    const anyAttention = devices.some(
      (d) => d.status === "PARTIALLY_PROTECTED",
    );
    const anyOffline = devices.some((d) => d.status === "OFFLINE");

    if (allProtected) return "PROTECTED";
    if (anyAttention) return "ATTENTION_REQUIRED";
    if (anyOffline) return "OFFLINE";
    return "PARTIALLY_PROTECTED";
  }

  private getTierEntitlements(tier: string) {
    const tiers: Record<string, any> = {
      FREE: {
        maxChildren: 1,
        maxDevices: 1,
        screenTime: true,
        webFiltering: false,
        location: false,
        geofencing: false,
        tara: false,
        reports: "basic",
      },
      BASIC: {
        maxChildren: 2,
        maxDevices: 3,
        screenTime: true,
        webFiltering: true,
        location: true,
        geofencing: true,
        tara: true,
        reports: "standard",
      },
      PREMIUM: {
        maxChildren: 4,
        maxDevices: 6,
        screenTime: true,
        webFiltering: true,
        location: true,
        geofencing: true,
        tara: true,
        reports: "detailed",
      },
      FAMILY: {
        maxChildren: 6,
        maxDevices: 10,
        screenTime: true,
        webFiltering: true,
        location: true,
        geofencing: true,
        tara: true,
        reports: "full",
      },
    };
    return tiers[tier] || tiers.FREE;
  }
}
