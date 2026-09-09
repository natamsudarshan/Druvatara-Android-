import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class NotificationService {
  constructor(private prisma: PrismaService) {}

  async getNotifications(
    familyId: string,
    userId: string,
    status?: string,
    limit = 50,
  ) {
    await this.validateFamilyAccess(familyId, userId);

    return this.prisma.notification.findMany({
      where: { familyId, userId, ...(status ? { status } : {}) },
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }

  async markAsRead(notificationId: string, userId: string) {
    const notification = await this.prisma.notification.findUnique({
      where: { id: notificationId },
    });

    if (!notification) throw new NotFoundException("Notification not found");

    await this.validateFamilyAccess(notification.familyId, userId);

    return this.prisma.notification.update({
      where: { id: notificationId },
      data: { status: "READ", openedAt: new Date() },
    });
  }

  async markAllAsRead(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    await this.prisma.notification.updateMany({
      where: { familyId, userId, status: { in: ["PENDING", "DELIVERED"] } },
      data: { status: "READ", openedAt: new Date() },
    });

    return { success: true };
  }

  async getUnreadCount(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    return this.prisma.notification.count({
      where: { familyId, userId, status: { in: ["PENDING", "DELIVERED"] } },
    });
  }

  async sendPushNotification(data: {
    familyId: string;
    childId?: string;
    userId?: string;
    deviceId?: string;
    type: string;
    title: string;
    body: string;
    payload?: Record<string, any>;
  }) {
    const notification = await this.prisma.notification.create({
      data: {
        familyId: data.familyId,
        childId: data.childId,
        userId: data.userId,
        deviceId: data.deviceId,
        type: data.type,
        channel: "PUSH",
        title: data.title,
        body: data.body,
        data: data.payload || {},
        status: "PENDING",
      },
    });

    // In production, send via Firebase Cloud Messaging / APNs
    // await this.fcmService.sendToDevice(notification);

    return notification;
  }

  private async validateFamilyAccess(familyId: string, userId: string) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }
}
