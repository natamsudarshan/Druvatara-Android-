import { Injectable } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { Prisma, AuditLog, AuditAction } from "@prisma/client";

@Injectable()
export class AuditService {
  constructor(private prisma: PrismaService) {}

  async log(data: {
    action: AuditAction;
    userId?: string;
    familyId?: string;
    childId?: string;
    deviceId?: string;
    resourceType?: string;
    resourceId?: string;
    oldValue?: Prisma.InputJsonValue;
    newValue?: Prisma.InputJsonValue;
    ipAddress?: string;
    userAgent?: string;
  }) {
    return this.prisma.auditLog.create({
      data: {
        action: data.action,
        userId: data.userId,
        familyId: data.familyId,
        childId: data.childId,
        deviceId: data.deviceId,
        resourceType: data.resourceType || "UNKNOWN",
        resourceId: data.resourceId,
        oldValue: data.oldValue as any,
        newValue: data.newValue as any,
        ipAddress: data.ipAddress,
        userAgent: data.userAgent,
      },
    });
  }

  async getLogs(filters: {
    action?: AuditAction;
    userId?: string;
    familyId?: string;
    childId?: string;
    deviceId?: string;
    resourceType?: string;
    startDate?: Date;
    endDate?: Date;
    page?: number;
    limit?: number;
  }) {
    const where: any = {};

    if (filters.action) where.action = filters.action;
    if (filters.userId) where.userId = filters.userId;
    if (filters.familyId) where.familyId = filters.familyId;
    if (filters.childId) where.childId = filters.childId;
    if (filters.deviceId) where.deviceId = filters.deviceId;
    if (filters.resourceType) where.resourceType = filters.resourceType;
    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const page = filters.page || 1;
    const limit = filters.limit || 50;

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return { logs, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getLogById(id: string) {
    return this.prisma.auditLog.findUnique({ where: { id } });
  }
}
