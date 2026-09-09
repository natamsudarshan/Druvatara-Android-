import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateChildDto } from "./dto/create-child.dto";
import { UpdateChildDto } from "./dto/update-child.dto";

@Injectable()
export class ChildService {
  constructor(private prisma: PrismaService) {}

  async create(
    familyId: string,
    userId: string,
    createChildDto: CreateChildDto,
  ) {
    await this.validateFamilyAccess(familyId, userId);

    const subscription = await this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
      orderBy: { createdAt: "desc" },
    });

    const tierEntitlements = this.getTierEntitlements(
      subscription?.tier || "FREE",
    );
    const currentChildren = await this.prisma.child.count({
      where: { familyId, isActive: true },
    });

    if (currentChildren >= tierEntitlements.maxChildren) {
      throw new ForbiddenException(
        `Maximum children limit (${tierEntitlements.maxChildren}) reached for ${subscription?.tier || "FREE"} tier`,
      );
    }

    const child = await this.prisma.child.create({
      data: {
        familyId,
        displayName: createChildDto.displayName,
        name: createChildDto.displayName,
        ageGroup: createChildDto.ageGroup,
        avatarId: createChildDto.avatarId,
        birthYear: createChildDto.birthYear,
        birthMonth: createChildDto.birthMonth,
        settings: this.getDefaultSettings(createChildDto.ageGroup),
      },
    });

    await this.createDefaultPolicy(familyId, child.id);

    return child;
  }

  async findById(childId: string, userId: string) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      include: {
        devices: { where: { isActive: true } },
        policies: {
          where: { isActive: true },
          orderBy: { version: "desc" },
          take: 1,
        },
        _count: {
          select: {
            devices: true,
            alerts: { where: { status: "NEW" } },
            requests: { where: { status: "PENDING" } },
          },
        },
      },
    });

    if (!child) {
      throw new NotFoundException("Child not found");
    }

    await this.validateFamilyAccess(child.familyId, userId);

    return child;
  }

  async findAll(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    return this.prisma.child.findMany({
      where: { familyId, isActive: true },
      include: {
        devices: { where: { isActive: true } },
        _count: {
          select: {
            alerts: { where: { status: "NEW" } },
            requests: { where: { status: "PENDING" } },
          },
        },
      },
      orderBy: { createdAt: "asc" },
    });
  }

  async getSummary(childId: string, userId: string) {
    const child = await this.findById(childId, userId);

    const [
      todayUsage,
      weeklyUsage,
      screenTimeEvents,
      safetyScore,
      activePolicy,
    ] = await Promise.all([
      this.getTodayUsage(childId),
      this.getWeeklyUsage(childId),
      this.prisma.screenTimeEvent.findMany({
        where: {
          childId,
          triggeredAt: { gte: new Date(Date.now() - 24 * 60 * 60 * 1000) },
        },
        orderBy: { triggeredAt: "desc" },
        take: 10,
      }),
      this.prisma.safetyScore.findFirst({
        where: { childId },
        orderBy: { calculatedAt: "desc" },
      }),
      this.prisma.policy.findFirst({
        where: { childId, isActive: true },
        orderBy: { version: "desc" },
      }),
    ]);

    return {
      child: {
        id: child.id,
        displayName: child.displayName,
        ageGroup: child.ageGroup,
        avatarId: child.avatarId,
      },
      todayUsage,
      weeklyUsage,
      recentScreenTimeEvents: screenTimeEvents,
      safetyScore: safetyScore?.score || 0,
      safetyScoreFactors: safetyScore?.factors || {},
      activePolicyVersion: activePolicy?.version || 0,
      devices: child.devices.map((d) => ({
        id: d.id,
        name: d.deviceName,
        platform: d.platform,
        status: d.status,
        lastSeenAt: d.lastSeenAt,
      })),
      pendingAlerts: child._count.alerts,
      pendingRequests: child._count.requests,
    };
  }

  async update(
    childId: string,
    userId: string,
    updateChildDto: UpdateChildDto,
  ) {
    const child = await this.findById(childId, userId);

    return this.prisma.child.update({
      where: { id: childId },
      data: {
        displayName: updateChildDto.displayName,
        ageGroup: updateChildDto.ageGroup,
        avatarId: updateChildDto.avatarId,
        birthYear: updateChildDto.birthYear,
        birthMonth: updateChildDto.birthMonth,
        settings: updateChildDto.settings,
      },
    });
  }

  async delete(childId: string, userId: string) {
    const child = await this.findById(childId, userId);

    await this.prisma.child.update({
      where: { id: childId },
      data: { isActive: false, deletedAt: new Date() },
    });

    return { success: true, message: "Child profile deactivated" };
  }

  private async validateFamilyAccess(familyId: string, userId: string) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }

  private getDefaultSettings(ageGroup: string) {
    const defaults: Record<string, any> = {
      TODDLER: {
        screenTimeLimit: 3600000,
        bedtime: "19:00",
        wakeTime: "07:00",
        webSafety: "STRICT",
        locationTracking: true,
      },
      YOUNG_CHILD: {
        screenTimeLimit: 7200000,
        bedtime: "20:00",
        wakeTime: "07:00",
        webSafety: "MODERATE",
        locationTracking: true,
      },
      PRE_TEEN: {
        screenTimeLimit: 10800000,
        bedtime: "21:00",
        wakeTime: "06:30",
        webSafety: "MODERATE",
        locationTracking: true,
      },
      TEENAGER: {
        screenTimeLimit: 14400000,
        bedtime: "22:00",
        wakeTime: "06:00",
        webSafety: "BASIC",
        locationTracking: false,
      },
    };
    return defaults[ageGroup] || defaults.YOUNG_CHILD;
  }

  private getTierEntitlements(tier: string) {
    const tiers: Record<string, any> = {
      FREE: { maxChildren: 1, maxDevices: 1 },
      BASIC: { maxChildren: 2, maxDevices: 3 },
      PREMIUM: { maxChildren: 4, maxDevices: 6 },
      FAMILY: { maxChildren: 6, maxDevices: 10 },
    };
    return tiers[tier] || tiers.FREE;
  }

  private async createDefaultPolicy(familyId: string, childId: string) {
    await this.prisma.policy.create({
      data: {
        familyId,
        childId,
        version: 1,
        screenTime: { dailyLimitMs: 7200000, essentialApps: [] },
        applications: { rules: [] },
        schedules: [],
        webSafety: { mode: "MODERATE", safeSearch: true, categories: [] },
        location: { enabled: true, backgroundLocation: false },
        safeZones: [],
        essentialApps: [],
        temporaryOverrides: [],
      },
    });
  }

  private async getTodayUsage(childId: string) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, date: today },
    });

    const totalMs = summaries.reduce((acc, s) => acc + Number(s.durationMs), 0);
    const byApp = summaries.map((s) => ({
      packageName: s.packageName,
      appName: s.appName,
      durationMs: Number(s.durationMs),
      launchCount: s.launchCount,
    }));

    return { totalMs, byApp };
  }

  private async getWeeklyUsage(childId: string) {
    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, date: { gte: weekAgo } },
    });

    const byDay: Record<string, number> = {};
    summaries.forEach((s) => {
      const day = s.date.toISOString().split("T")[0];
      byDay[day] = (byDay[day] || 0) + Number(s.durationMs);
    });

    return byDay;
  }
}
