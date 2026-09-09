import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { Prisma, Alert, AlertSeverity, AlertStatus } from "@prisma/client";

@Injectable()
export class AlertService {
  constructor(private prisma: PrismaService) {}

  async create(data: {
    familyId: string;
    childId: string;
    deviceId?: string;
    type: string;
    severity: AlertSeverity;
    title: string;
    message: string;
    metadata?: Prisma.InputJsonValue;
  }) {
    return this.prisma.alert.create({
      data: {
        familyId: data.familyId,
        childId: data.childId,
        deviceId: data.deviceId,
        type: data.type,
        severity: data.severity,
        title: data.title,
        message: data.message,
        metadata: data.metadata as any,
        status: AlertStatus.OPEN,
      },
    });
  }

  async getAlerts(filters: {
    familyId: string;
    childId?: string;
    deviceId?: string;
    status?: AlertStatus;
    severity?: AlertSeverity;
    type?: string;
    startDate?: Date;
    endDate?: Date;
    page?: number;
    limit?: number;
  }) {
    const where: any = { familyId: filters.familyId };

    if (filters.childId) where.childId = filters.childId;
    if (filters.deviceId) where.deviceId = filters.deviceId;
    if (filters.status) where.status = filters.status;
    if (filters.severity) where.severity = filters.severity;
    if (filters.type) where.type = filters.type;
    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;

    const [alerts, total] = await Promise.all([
      this.prisma.alert.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.alert.count({ where }),
    ]);

    return { alerts, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getAlertById(id: string) {
    const alert = await this.prisma.alert.findUnique({ where: { id } });
    if (!alert) throw new NotFoundException("Alert not found");
    return alert;
  }

  async acknowledgeAlert(id: string, userId: string) {
    return this.prisma.alert.update({
      where: { id },
      data: {
        status: AlertStatus.ACKNOWLEDGED,
        acknowledgedAt: new Date(),
        acknowledgedById: userId,
      },
    });
  }

  async resolveAlert(id: string, userId: string) {
    return this.prisma.alert.update({
      where: { id },
      data: {
        status: AlertStatus.RESOLVED,
        resolvedAt: new Date(),
        resolvedById: userId,
      },
    });
  }

  async dismissAlert(id: string) {
    return this.prisma.alert.update({
      where: { id },
      data: { status: AlertStatus.DISMISSED, dismissedAt: new Date() },
    });
  }

  async getUnreadCount(familyId: string) {
    return this.prisma.alert.count({
      where: { familyId, status: AlertStatus.OPEN },
    });
  }
}
