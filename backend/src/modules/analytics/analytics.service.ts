import { Injectable } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { subDays } from "date-fns";

@Injectable()
export class AnalyticsService {
  constructor(private prisma: PrismaService) {}

  async trackEvent(data: {
    eventName: string;
    userId?: string;
    familyId?: string;
    childId?: string;
    deviceId?: string;
    properties?: Record<string, any>;
  }) {
    return this.prisma.analyticsEvent.create({
      data: {
        eventName: data.eventName,
        userId: data.userId,
        familyId: data.familyId,
        childId: data.childId,
        deviceId: data.deviceId,
        properties: data.properties as any,
      },
    });
  }

  async getMetrics(filters: {
    eventName?: string;
    familyId?: string;
    childId?: string;
    startDate?: Date;
    endDate?: Date;
  }) {
    const where: any = {};

    if (filters.eventName) where.eventName = filters.eventName;
    if (filters.familyId) where.familyId = filters.familyId;
    if (filters.childId) where.childId = filters.childId;
    if (filters.startDate || filters.endDate) {
      where.timestamp = {};
      if (filters.startDate) where.timestamp.gte = filters.startDate;
      if (filters.endDate) where.timestamp.lte = filters.endDate;
    }

    const events = await this.prisma.analyticsEvent.findMany({
      where,
      orderBy: { timestamp: "desc" },
      take: 10000,
    });

    return this.aggregateMetrics(events);
  }

  async getFunnel(eventNames: string[], familyId?: string, days = 30) {
    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    const events = await this.prisma.analyticsEvent.findMany({
      where: {
        eventName: { in: eventNames },
        timestamp: { gte: startDate },
        ...(familyId ? { familyId } : {}),
      },
      select: {
        eventName: true,
        userId: true,
        familyId: true,
        timestamp: true,
      },
    });

    const funnel = eventNames.map((name) => ({
      eventName: name,
      count: events.filter((e) => e.eventName === name).length,
      uniqueUsers: new Set(
        events
          .filter((e) => e.eventName === name)
          .map((e) => e.userId)
          .filter((id): id is string => id !== null),
      ).size,
    }));

    return funnel;
  }

  async getRetention(cohortDate: Date, familyId?: string) {
    const cohortUsers = await this.prisma.analyticsEvent.findMany({
      where: {
        eventName: "REGISTRATION_COMPLETED",
        timestamp: {
          gte: cohortDate,
          lt: new Date(cohortDate.getTime() + 24 * 60 * 60 * 1000),
        },
        ...(familyId ? { familyId } : {}),
      },
      select: { userId: true },
    });

    const userIds = [
      ...new Set(
        cohortUsers
          .map((e) => e.userId)
          .filter((id): id is string => id !== null),
      ),
    ];

    const retention = [];
    for (let day = 1; day <= 30; day++) {
      const activeUsers = await this.prisma.analyticsEvent.findMany({
        where: {
          userId: { in: userIds },
          timestamp: {
            gte: new Date(cohortDate.getTime() + day * 24 * 60 * 60 * 1000),
            lt: new Date(
              cohortDate.getTime() + (day + 1) * 24 * 60 * 60 * 1000,
            ),
          },
        },
        select: { userId: true },
      });

      retention.push({
        day,
        activeUsers: new Set(activeUsers.map((e) => e.userId)).size,
        retentionRate:
          userIds.length > 0
            ? Math.round(
                (new Set(activeUsers.map((e) => e.userId)).size /
                  userIds.length) *
                  100,
              )
            : 0,
      });
    }

    return retention;
  }

  private aggregateMetrics(events: any[]) {
    const byEvent: Record<string, number> = {};
    const byDay: Record<string, number> = {};
    const uniqueUsers = new Set<string>();
    const uniqueFamilies = new Set<string>();

    events.forEach((e) => {
      byEvent[e.eventName] = (byEvent[e.eventName] || 0) + 1;
      const day = e.timestamp.toISOString().split("T")[0];
      byDay[day] = (byDay[day] || 0) + 1;
      if (e.userId) uniqueUsers.add(e.userId);
      if (e.familyId) uniqueFamilies.add(e.familyId);
    });

    return {
      totalEvents: events.length,
      uniqueUsers: uniqueUsers.size,
      uniqueFamilies: uniqueFamilies.size,
      byEvent,
      byDay: Object.entries(byDay).map(([date, count]) => ({ date, count })),
    };
  }
}
