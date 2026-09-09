import { Injectable } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { subDays } from "date-fns";
import { User, Family, Device, AuditLog, FeatureFlag } from "@prisma/client";

@Injectable()
export class AdminService {
  constructor(private prisma: PrismaService) {}

  async getDashboardStats() {
    const [
      totalUsers,
      totalFamilies,
      totalDevices,
      totalChildren,
      activeSubscriptions,
      revenue,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.family.count(),
      this.prisma.device.count({ where: { isActive: true } }),
      this.prisma.child.count(),
      this.prisma.subscription.count({ where: { status: "ACTIVE" } }),
      this.prisma.payment.aggregate({
        where: { status: "COMPLETED" },
        _sum: { amount: true },
      }),
    ]);

    const recentUsers = await this.prisma.user.count({
      where: { createdAt: { gte: subDays(new Date(), 7) } },
    });

    const recentFamilies = await this.prisma.family.count({
      where: { createdAt: { gte: subDays(new Date(), 7) } },
    });

    return {
      totalUsers,
      totalFamilies,
      totalDevices,
      totalChildren,
      activeSubscriptions,
      totalRevenue: revenue._sum.amount || 0,
      recentUsers,
      recentFamilies,
    };
  }

  async getUsers(page: number, limit: number) {
    const [users, total] = await Promise.all([
      this.prisma.user.findMany({
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
        select: {
          id: true,
          email: true,
          name: true,
          country: true,
          isActive: true,
          role: true,
          lastLoginAt: true,
          createdAt: true,
        },
      }),
      this.prisma.user.count(),
    ]);

    return { users, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async getFamilies(page: number, limit: number) {
    const [families, total] = await Promise.all([
      this.prisma.family.findMany({
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          owner: { select: { id: true, name: true, email: true } },
          _count: { select: { members: true, children: true, devices: true } },
        },
      }),
      this.prisma.family.count(),
    ]);

    return {
      families,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getDevices(page: number, limit: number) {
    const [devices, total] = await Promise.all([
      this.prisma.device.findMany({
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
        include: {
          family: { select: { id: true, name: true } },
          child: { select: { id: true, name: true } },
        },
      }),
      this.prisma.device.count(),
    ]);

    return {
      devices,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getAuditLogs(page: number, limit: number) {
    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: "desc" },
      }),
      this.prisma.auditLog.count(),
    ]);

    return { logs, total, page, limit, totalPages: Math.ceil(total / limit) };
  }

  async toggleUserStatus(userId: string, isActive: boolean) {
    return this.prisma.user.update({
      where: { id: userId },
      data: { isActive },
      select: { id: true, email: true, name: true, isActive: true },
    });
  }

  async toggleFamilyStatus(familyId: string, isActive: boolean) {
    return this.prisma.family.update({
      where: { id: familyId },
      data: { isActive },
      select: { id: true, name: true, isActive: true },
    });
  }

  async getFeatureFlags() {
    return this.prisma.featureFlag.findMany({ orderBy: { key: "asc" } });
  }

  async updateFeatureFlag(key: string, enabled: boolean, rollout?: number) {
    return this.prisma.featureFlag.upsert({
      where: { key },
      update: { enabled, ...(rollout !== undefined && { rollout }) },
      create: { key, name: key, enabled, rollout: rollout || 100 },
    });
  }
}
