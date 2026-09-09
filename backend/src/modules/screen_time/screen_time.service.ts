import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { UpdateScreenTimeDto } from "./dto/update-screen-time.dto";

@Injectable()
export class ScreenTimeService {
  constructor(private prisma: PrismaService) {}

  async getScreenTimeConfig(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const policy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
      select: { screenTime: true },
    });

    return (
      policy?.screenTime || {
        dailyLimitMs: 7200000,
        essentialApps: [],
        warningThresholds: [900000, 300000, 60000],
      }
    );
  }

  async updateScreenTimeConfig(
    childId: string,
    userId: string,
    updateScreenTimeDto: UpdateScreenTimeDto,
  ) {
    await this.validateChildAccess(childId, userId, true);

    const latestPolicy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
    });

    if (!latestPolicy) {
      throw new NotFoundException("No active policy found");
    }

    const newVersion = latestPolicy.version + 1;

    return this.prisma.policy.create({
      data: {
        familyId: latestPolicy.familyId,
        childId,
        version: newVersion,
        screenTime: updateScreenTimeDto as any,
        applications: latestPolicy.applications as any,
        schedules: latestPolicy.schedules as any,
        webSafety: latestPolicy.webSafety as any,
        location: latestPolicy.location as any,
        safeZones: latestPolicy.safeZones as any,
        essentialApps: latestPolicy.essentialApps as any,
        temporaryOverrides: latestPolicy.temporaryOverrides as any,
      },
    });
  }

  async getTodayUsage(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

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

    return { date: today.toISOString().split("T")[0], totalMs, byApp };
  }

  async getWeeklyUsage(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const weekAgo = new Date();
    weekAgo.setDate(weekAgo.getDate() - 7);
    weekAgo.setHours(0, 0, 0, 0);

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, date: { gte: weekAgo } },
      orderBy: { date: "asc" },
    });

    const byDay: Record<string, number> = {};
    summaries.forEach((s) => {
      const day = s.date.toISOString().split("T")[0];
      byDay[day] = (byDay[day] || 0) + Number(s.durationMs);
    });

    return Object.entries(byDay).map(([date, totalMs]) => ({ date, totalMs }));
  }

  async getScreenTimeEvents(childId: string, userId: string, limit = 50) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.screenTimeEvent.findMany({
      where: { childId },
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
