import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { NotificationService } from "./notification.service";

describe("NotificationService", () => {
  let service: NotificationService;
  let prisma: PrismaService;

  const mockPrismaService = {
    notification: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      create: jest.fn(),
      count: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        NotificationService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<NotificationService>(NotificationService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  const mockMembership = {
    familyId: "family-1",
    userId: "user-1",
    isActive: true,
  };

  beforeEach(() => {
    mockPrismaService.familyMember.findUnique.mockResolvedValue(mockMembership);
  });

  describe("getNotifications", () => {
    it("should return notifications for family and user", async () => {
      const mockNotifications = [
        {
          id: "notif-1",
          familyId: "family-1",
          userId: "user-1",
          title: "Test 1",
        },
        {
          id: "notif-2",
          familyId: "family-1",
          userId: "user-1",
          title: "Test 2",
        },
      ];

      mockPrismaService.notification.findMany.mockResolvedValue(
        mockNotifications,
      );

      const result = await service.getNotifications("family-1", "user-1");

      expect(mockPrismaService.notification.findMany).toHaveBeenCalledWith({
        where: { familyId: "family-1", userId: "user-1" },
        orderBy: { createdAt: "desc" },
        take: 50,
      });
      expect(result).toEqual(mockNotifications);
    });

    it("should filter by status if provided", async () => {
      mockPrismaService.notification.findMany.mockResolvedValue([]);

      await service.getNotifications("family-1", "user-1", "UNREAD", 20);

      expect(mockPrismaService.notification.findMany).toHaveBeenCalledWith({
        where: { familyId: "family-1", userId: "user-1", status: "UNREAD" },
        orderBy: { createdAt: "desc" },
        take: 20,
      });
    });

    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(
        service.getNotifications("family-1", "user-1"),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("markAsRead", () => {
    it("should mark notification as read", async () => {
      const mockNotification = {
        id: "notif-1",
        familyId: "family-1",
        userId: "user-1",
        status: "PENDING",
      };
      const mockUpdated = {
        ...mockNotification,
        status: "READ",
        openedAt: new Date(),
      };

      mockPrismaService.notification.findUnique.mockResolvedValue(
        mockNotification,
      );
      mockPrismaService.notification.update.mockResolvedValue(mockUpdated);

      const result = await service.markAsRead("notif-1", "user-1");

      expect(mockPrismaService.notification.update).toHaveBeenCalledWith({
        where: { id: "notif-1" },
        data: { status: "READ", openedAt: expect.any(Date) },
      });
      expect(result).toEqual(mockUpdated);
    });

    it("should throw NotFoundException if notification not found", async () => {
      mockPrismaService.notification.findUnique.mockResolvedValue(null);

      await expect(
        service.markAsRead("non-existent", "user-1"),
      ).rejects.toThrow(NotFoundException);
    });

    it("should throw ForbiddenException if not family member", async () => {
      const mockNotification = {
        id: "notif-1",
        familyId: "family-2",
        userId: "user-1",
      };

      mockPrismaService.notification.findUnique.mockResolvedValue(
        mockNotification,
      );
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(service.markAsRead("notif-1", "user-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe("markAllAsRead", () => {
    it("should mark all pending/delivered notifications as read", async () => {
      mockPrismaService.notification.updateMany.mockResolvedValue({ count: 5 });

      const result = await service.markAllAsRead("family-1", "user-1");

      expect(mockPrismaService.notification.updateMany).toHaveBeenCalledWith({
        where: {
          familyId: "family-1",
          userId: "user-1",
          status: { in: ["PENDING", "DELIVERED"] },
        },
        data: { status: "READ", openedAt: expect.any(Date) },
      });
      expect(result).toEqual({ success: true });
    });
  });

  describe("getUnreadCount", () => {
    it("should return count of unread notifications", async () => {
      mockPrismaService.notification.count.mockResolvedValue(7);

      const result = await service.getUnreadCount("family-1", "user-1");

      expect(mockPrismaService.notification.count).toHaveBeenCalledWith({
        where: {
          familyId: "family-1",
          userId: "user-1",
          status: { in: ["PENDING", "DELIVERED"] },
        },
      });
      expect(result).toBe(7);
    });
  });

  describe("sendPushNotification", () => {
    it("should create notification with PUSH channel and PENDING status", async () => {
      const mockNotification = {
        id: "notif-1",
        familyId: "family-1",
        childId: "child-1",
        userId: "user-1",
        type: "ALERT",
        channel: "PUSH",
        title: "Test Alert",
        body: "This is a test",
        data: { key: "value" },
        status: "PENDING",
      };

      mockPrismaService.notification.create.mockResolvedValue(mockNotification);

      const result = await service.sendPushNotification({
        familyId: "family-1",
        childId: "child-1",
        userId: "user-1",
        type: "ALERT",
        title: "Test Alert",
        body: "This is a test",
        payload: { key: "value" },
      });

      expect(mockPrismaService.notification.create).toHaveBeenCalledWith({
        data: {
          familyId: "family-1",
          childId: "child-1",
          userId: "user-1",
          deviceId: undefined,
          type: "ALERT",
          channel: "PUSH",
          title: "Test Alert",
          body: "This is a test",
          data: { key: "value" },
          status: "PENDING",
        },
      });
      expect(result).toEqual(mockNotification);
    });
  });
});
