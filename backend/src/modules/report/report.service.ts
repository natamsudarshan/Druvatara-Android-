import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { subDays, startOfDay, endOfDay } from "date-fns";

@Injectable()
export class ReportService {
  constructor(private prisma: PrismaService) {}

  async getReportTypes() {
    return [
      {
        id: "DAILY",
        name: "Daily Summary",
        description: "Daily usage and safety summary",
      },
      {
        id: "WEEKLY",
        name: "Weekly Report",
        description: "Comprehensive weekly analysis",
      },
      {
        id: "MONTHLY",
        name: "Monthly Report",
        description: "Monthly trends and insights",
      },
      {
        id: "SAFETY",
        name: "Safety Report",
        description: "Safety score and alert analysis",
      },
      {
        id: "USAGE",
        name: "Usage Report",
        description: "Detailed app and web usage",
      },
    ];
  }

  async generateReport(
    familyId: string,
    childId: string,
    userId: string,
    type: string,
    periodStart: Date,
    periodEnd: Date,
  ) {
    await this.validateChildAccess(childId, userId);

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      include: {
        devices: { where: { isActive: true } },
        policies: {
          where: { isActive: true },
          orderBy: { version: "desc" },
          take: 1,
        },
      },
    });

    if (!child) throw new NotFoundException("Child not found");

    const data = await this.collectReportData(
      childId,
      type,
      periodStart,
      periodEnd,
    );

    const report = await this.prisma.report.create({
      data: {
        familyId,
        childId,
        type,
        periodStart,
        periodEnd,
        data: data as any,
      },
    });

    return report;
  }

  async getReports(
    familyId: string,
    childId: string,
    userId: string,
    type?: string,
  ) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.report.findMany({
      where: { childId, ...(type ? { type } : {}) },
      orderBy: { generatedAt: "desc" },
      take: 20,
    });
  }

  async getReportById(reportId: string, userId: string) {
    const report = await this.prisma.report.findUnique({
      where: { id: reportId },
    });

    if (!report) throw new NotFoundException("Report not found");

    await this.validateChildAccess(report.childId, userId);

    return report;
  }

  private async collectReportData(
    childId: string,
    type: string,
    periodStart: Date,
    periodEnd: Date,
  ) {
    const [
      usageSummaries,
      screenTimeEvents,
      alerts,
      geofenceEvents,
      locationHistory,
      appRules,
      schedules,
      safetyScores,
    ] = await Promise.all([
      this.prisma.usageSummary.findMany({
        where: { childId, date: { gte: periodStart, lte: periodEnd } },
      }),
      this.prisma.screenTimeEvent.findMany({
        where: { childId, triggeredAt: { gte: periodStart, lte: periodEnd } },
      }),
      this.prisma.alert.findMany({
        where: { childId, createdAt: { gte: periodStart, lte: periodEnd } },
      }),
      this.prisma.geofenceEvent.findMany({
        where: { childId, triggeredAt: { gte: periodStart, lte: periodEnd } },
      }),
      this.prisma.location.findMany({
        where: { childId, capturedAt: { gte: periodStart, lte: periodEnd } },
        orderBy: { capturedAt: "desc" },
        take: 100,
      }),
      this.prisma.appRule.findMany({ where: { childId, isActive: true } }),
      this.prisma.schedule.findMany({ where: { childId, isActive: true } }),
      this.prisma.safetyScore.findMany({
        where: { childId, calculatedAt: { gte: periodStart, lte: periodEnd } },
        orderBy: { calculatedAt: "asc" },
      }),
    ]);

    const totalUsage = usageSummaries.reduce(
      (acc, s) => acc + Number(s.durationMs),
      0,
    );
    const byApp = usageSummaries.reduce(
      (acc, s) => {
        acc[s.packageName] = (acc[s.packageName] || 0) + Number(s.durationMs);
        return acc;
      },
      {} as Record<string, number>,
    );

    const topApps = Object.entries(byApp)
      .sort(([, a], [, b]) => b - a)
      .slice(0, 10)
      .map(([packageName, durationMs]) => ({ packageName, durationMs }));

    return {
      summary: {
        totalScreenTimeMs: totalUsage,
        totalScreenTimeHours:
          Math.round((totalUsage / (1000 * 60 * 60)) * 10) / 10,
        topApps,
        screenTimeEventsCount: screenTimeEvents.length,
        alertsCount: alerts.length,
        geofenceEventsCount: geofenceEvents.length,
        locationPointsCount: locationHistory.length,
        avgSafetyScore:
          safetyScores.length > 0
            ? Math.round(
                safetyScores.reduce((acc, s) => acc + s.score, 0) /
                  safetyScores.length,
              )
            : null,
      },
      usage: {
        daily: this.aggregateByDay(usageSummaries),
        byApp: topApps,
      },
      screenTime: {
        events: screenTimeEvents,
        limitReached: screenTimeEvents.filter(
          (e) => e.eventType === "SCREEN_TIME_LIMIT_REACHED",
        ).length,
        warnings: screenTimeEvents.filter(
          (e) => e.eventType === "SCREEN_TIME_WARNING",
        ).length,
      },
      safety: {
        alerts: {
          total: alerts.length,
          bySeverity: alerts.reduce((acc: Record<string, number>, a) => {
            acc[a.severity] = (acc[a.severity] || 0) + 1;
            return acc;
          }, {}),
          byType: alerts.reduce((acc: Record<string, number>, a) => {
            acc[a.type] = (acc[a.type] || 0) + 1;
            return acc;
          }, {}),
          resolved: alerts.filter((a) => a.status === "RESOLVED").length,
        },
        geofenceEvents,
        safetyScores: safetyScores.map((s) => ({
          score: s.score,
          calculatedAt: s.calculatedAt,
        })),
      },
      configuration: {
        appRules,
        schedules,
      },
      location: {
        points: locationHistory.length,
        lastKnown: locationHistory[0] || null,
      },
    };
  }

  private aggregateByDay(summaries: any[]) {
    const byDay: Record<string, number> = {};
    summaries.forEach((s) => {
      const day = s.date.toISOString().split("T")[0];
      byDay[day] = (byDay[day] || 0) + Number(s.durationMs);
    });
    return Object.entries(byDay).map(([date, totalMs]) => ({ date, totalMs }));
  }

  private async validateChildAccess(childId: string, userId: string) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true },
    });

    if (!child) throw new NotFoundException("Child not found");

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId: child.familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }
}
