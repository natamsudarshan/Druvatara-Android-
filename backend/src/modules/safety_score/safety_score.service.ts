import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { Cron, CronExpression } from "@nestjs/schedule";

@Injectable()
export class SafetyScoreService {
  constructor(private prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_2AM)
  async calculateDailyScores() {
    const children = await this.prisma.child.findMany({
      where: { isActive: true },
      select: { id: true, familyId: true },
    });

    for (const child of children) {
      try {
        await this.calculateScore(child.id);
      } catch (error) {
        console.error(
          `Failed to calculate safety score for child ${child.id}:`,
          error,
        );
      }
    }
  }

  async calculateScore(childId: string) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      include: {
        devices: { where: { isActive: true } },
        alerts: { where: { status: { in: ["NEW", "ACKNOWLEDGED"] } } },
        screenTimeEvents: {
          where: {
            triggeredAt: {
              gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
            },
          },
        },
      },
    });

    if (!child) return;

    const factors = await this.calculateFactors(child);
    const score = this.computeScore(factors);

    await this.prisma.safetyScore.create({
      data: {
        childId,
        score,
        factors: factors as any,
        formulaVersion: "1.0",
        completeness: this.calculateCompleteness(factors),
      },
    });

    return { score, factors };
  }

  private async calculateFactors(child: any) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const todayUsage = await this.prisma.usageSummary.findMany({
      where: { childId: child.id, date: today },
    });

    const totalToday = todayUsage.reduce(
      (acc, s) => acc + Number(s.durationMs),
      0,
    );
    const dailyLimit = child.settings?.screenTimeLimit || 7200000;
    const screenTimeRatio = Math.min(1, totalToday / dailyLimit);

    const activeDevices = child.devices.length;
    const protectedDevices = child.devices.filter(
      (d: any) => d.status === "ACTIVE",
    ).length;
    const protectionRatio =
      activeDevices > 0 ? protectedDevices / activeDevices : 0;

    const unresolvedAlerts = child.alerts.length;
    const alertPenalty = Math.min(1, unresolvedAlerts * 0.1);

    const screenTimeEvents = child.screenTimeEvents.length;
    const eventPenalty = Math.min(1, screenTimeEvents * 0.05);

    const hasVpn = child.devices.some((d: any) => d.capabilities?.vpnFiltering);
    const hasLocation = child.devices.some(
      (d: any) => d.capabilities?.backgroundLocation,
    );

    return {
      protectionStatus: protectionRatio,
      screenTimeBalance: 1 - screenTimeRatio,
      alertResolution: 1 - alertPenalty,
      screenTimeCompliance: 1 - eventPenalty,
      vpnEnabled: hasVpn ? 1 : 0.5,
      locationEnabled: hasLocation ? 1 : 0.7,
      accountSecurity: 1, // Would check MFA, password strength, etc.
    };
  }

  private computeScore(factors: Record<string, number>): number {
    const weights = {
      protectionStatus: 0.25,
      screenTimeBalance: 0.2,
      alertResolution: 0.15,
      screenTimeCompliance: 0.15,
      vpnEnabled: 0.1,
      locationEnabled: 0.1,
      accountSecurity: 0.05,
    };

    let score = 0;
    for (const [key, weight] of Object.entries(weights)) {
      score += (factors[key] || 0) * weight;
    }

    return Math.round(score * 100);
  }

  private calculateCompleteness(factors: Record<string, number>): number {
    const present = Object.values(factors).filter(
      (v) => v !== undefined && v !== null,
    ).length;
    return present / Object.keys(factors).length;
  }

  async getLatestScore(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.safetyScore.findFirst({
      where: { childId },
      orderBy: { calculatedAt: "desc" },
    });
  }

  async getScoreHistory(childId: string, userId: string, days = 30) {
    await this.validateChildAccess(childId, userId);

    const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000);

    return this.prisma.safetyScore.findMany({
      where: { childId, calculatedAt: { gte: startDate } },
      orderBy: { calculatedAt: "asc" },
    });
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
