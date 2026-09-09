import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { subDays, startOfDay, endOfDay, format } from "date-fns";

@Injectable()
export class UsageService {
  constructor(private prisma: PrismaService) {}

  async recordUsage(deviceId: string, usageData: any[]) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      select: { id: true, childId: true, familyId: true },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    const today = startOfDay(new Date());

    const results = [];
    for (const usage of usageData) {
      const result = await this.prisma.usageSummary.upsert({
        where: {
          deviceId_childId_date_packageName: {
            deviceId,
            childId: device.childId,
            date: today,
            packageName: usage.packageName,
          },
        },
        update: {
          appName: usage.appName,
          durationMs: { increment: BigInt(usage.durationMs || 0) },
          launchCount: { increment: usage.launchCount || 0 },
          lastUsedAt: new Date(usage.lastUsedAt || Date.now()),
        },
        create: {
          deviceId,
          childId: device.childId,
          date: today,
          packageName: usage.packageName,
          appName: usage.appName,
          durationMs: BigInt(usage.durationMs || 0),
          launchCount: usage.launchCount || 0,
          firstUsedAt: new Date(usage.firstUsedAt || Date.now()),
          lastUsedAt: new Date(usage.lastUsedAt || Date.now()),
        },
      });
      results.push(result);
    }

    return results;
  }

  async getTodayUsage(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const today = startOfDay(new Date());

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, date: today },
      orderBy: { durationMs: "desc" },
    });

    const totalMs = summaries.reduce((acc, s) => acc + Number(s.durationMs), 0);

    return {
      date: format(today, "yyyy-MM-dd"),
      totalMs,
      byApp: summaries.map((s) => ({
        packageName: s.packageName,
        appName: s.appName,
        durationMs: Number(s.durationMs),
        launchCount: s.launchCount,
      })),
    };
  }

  async getWeeklyUsage(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const weekAgo = startOfDay(subDays(new Date(), 7));

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, date: { gte: weekAgo } },
      orderBy: { date: "asc" },
    });

    const byDay: Record<string, { totalMs: number; apps: any[] }> = {};

    for (const summary of summaries) {
      const day = format(summary.date, "yyyy-MM-dd");
      if (!byDay[day]) {
        byDay[day] = { totalMs: 0, apps: [] };
      }
      byDay[day].totalMs += Number(summary.durationMs);
      byDay[day].apps.push({
        packageName: summary.packageName,
        appName: summary.appName,
        durationMs: Number(summary.durationMs),
        launchCount: summary.launchCount,
      });
    }

    return Object.entries(byDay).map(([date, data]) => ({
      date,
      ...data,
    }));
  }

  async getAppUsage(
    childId: string,
    packageName: string,
    userId: string,
    days = 30,
  ) {
    await this.validateChildAccess(childId, userId);

    const startDate = startOfDay(subDays(new Date(), days));

    const summaries = await this.prisma.usageSummary.findMany({
      where: { childId, packageName, date: { gte: startDate } },
      orderBy: { date: "asc" },
    });

    return summaries.map((s) => ({
      date: format(s.date, "yyyy-MM-dd"),
      durationMs: Number(s.durationMs),
      launchCount: s.launchCount,
    }));
  }

  async getTopApps(childId: string, userId: string, limit = 10, days = 7) {
    await this.validateChildAccess(childId, userId);

    const startDate = startOfDay(subDays(new Date(), days));

    const summaries = await this.prisma.usageSummary.groupBy({
      by: ["packageName", "appName"],
      where: { childId, date: { gte: startDate } },
      _sum: { durationMs: true, launchCount: true },
      orderBy: { _sum: { durationMs: "desc" } },
      take: limit,
    });

    return summaries.map((s) => ({
      packageName: s.packageName,
      appName: s.appName,
      totalDurationMs: Number(s._sum.durationMs || 0),
      totalLaunchCount: s._sum.launchCount || 0,
    }));
  }

  async getScreenTimeEvents(childId: string, userId: string, limit = 50) {
    await this.validateChildAccess(childId, userId);

    const events = await this.prisma.screenTimeEvent.findMany({
      where: { childId },
      orderBy: { triggeredAt: "desc" },
      take: limit,
    });

    return events;
  }

  private async validateChildAccess(childId: string, userId: string) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true, isActive: true },
    });

    if (!child || !child.isActive) {
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
