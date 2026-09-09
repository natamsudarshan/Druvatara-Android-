import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { AlertService } from "./alert.service";
import { AlertSeverity, AlertStatus } from "@prisma/client";

describe("AlertService", () => {
  let service: AlertService;
  let prisma: PrismaService;

  const mockPrismaService = {
    alert: {
      create: jest.fn(),
      findMany: jest.fn(),
      count: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AlertService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<AlertService>(AlertService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("create", () => {
    it("should create an alert successfully", async () => {
      const createData = {
        familyId: "family-1",
        childId: "child-1",
        type: "SCREEN_TIME_EXCEEDED",
        severity: AlertSeverity.HIGH,
        title: "Screen time exceeded",
        message: "Child has exceeded daily screen time limit",
      };

      const mockAlert = {
        id: "alert-1",
        ...createData,
        deviceId: null,
        metadata: {},
        status: AlertStatus.OPEN,
        createdAt: new Date(),
      };

      mockPrismaService.alert.create.mockResolvedValue(mockAlert);

      const result = await service.create(createData);

      expect(mockPrismaService.alert.create).toHaveBeenCalledWith({
        data: {
          familyId: createData.familyId,
          childId: createData.childId,
          deviceId: undefined,
          type: createData.type,
          severity: createData.severity,
          title: createData.title,
          message: createData.message,
          metadata: undefined,
          status: AlertStatus.OPEN,
        },
      });
      expect(result).toEqual(mockAlert);
    });
  });

  describe("getAlerts", () => {
    it("should return paginated alerts with filters", async () => {
      const mockAlerts = [
        {
          id: "alert-1",
          familyId: "family-1",
          childId: "child-1",
          status: AlertStatus.OPEN,
        },
        {
          id: "alert-2",
          familyId: "family-1",
          childId: "child-1",
          status: AlertStatus.ACKNOWLEDGED,
        },
      ];

      mockPrismaService.alert.findMany.mockResolvedValue(mockAlerts);
      mockPrismaService.alert.count.mockResolvedValue(2);

      const result = await service.getAlerts({
        familyId: "family-1",
        childId: "child-1",
        status: AlertStatus.OPEN,
        page: 1,
        limit: 10,
      });

      expect(mockPrismaService.alert.findMany).toHaveBeenCalledWith({
        where: {
          familyId: "family-1",
          childId: "child-1",
          status: AlertStatus.OPEN,
        },
        orderBy: { createdAt: "desc" },
        skip: 0,
        take: 10,
      });
      expect(result).toEqual({
        alerts: mockAlerts,
        total: 2,
        page: 1,
        limit: 10,
        totalPages: 1,
      });
    });

    it("should apply date range filters", async () => {
      const startDate = new Date("2024-01-01");
      const endDate = new Date("2024-12-31");

      mockPrismaService.alert.findMany.mockResolvedValue([]);
      mockPrismaService.alert.count.mockResolvedValue(0);

      await service.getAlerts({
        familyId: "family-1",
        startDate,
        endDate,
      });

      expect(mockPrismaService.alert.findMany).toHaveBeenCalledWith(
        expect.objectContaining({
          where: expect.objectContaining({
            createdAt: {
              gte: startDate,
              lte: endDate,
            },
          }),
        }),
      );
    });
  });

  describe("getAlertById", () => {
    it("should return alert if found", async () => {
      const mockAlert = {
        id: "alert-1",
        familyId: "family-1",
        childId: "child-1",
      };
      mockPrismaService.alert.findUnique.mockResolvedValue(mockAlert);

      const result = await service.getAlertById("alert-1");

      expect(result).toEqual(mockAlert);
    });

    it("should throw NotFoundException if alert not found", async () => {
      mockPrismaService.alert.findUnique.mockResolvedValue(null);

      await expect(service.getAlertById("non-existent")).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe("acknowledgeAlert", () => {
    it("should acknowledge alert with user ID", async () => {
      const mockUpdatedAlert = {
        id: "alert-1",
        status: AlertStatus.ACKNOWLEDGED,
        acknowledgedAt: new Date(),
        acknowledgedById: "user-1",
      };

      mockPrismaService.alert.update.mockResolvedValue(mockUpdatedAlert);

      const result = await service.acknowledgeAlert("alert-1", "user-1");

      expect(mockPrismaService.alert.update).toHaveBeenCalledWith({
        where: { id: "alert-1" },
        data: {
          status: AlertStatus.ACKNOWLEDGED,
          acknowledgedAt: expect.any(Date),
          acknowledgedById: "user-1",
        },
      });
      expect(result).toEqual(mockUpdatedAlert);
    });
  });

  describe("resolveAlert", () => {
    it("should resolve alert with user ID", async () => {
      const mockUpdatedAlert = {
        id: "alert-1",
        status: AlertStatus.RESOLVED,
        resolvedAt: new Date(),
        resolvedById: "user-1",
      };

      mockPrismaService.alert.update.mockResolvedValue(mockUpdatedAlert);

      const result = await service.resolveAlert("alert-1", "user-1");

      expect(mockPrismaService.alert.update).toHaveBeenCalledWith({
        where: { id: "alert-1" },
        data: {
          status: AlertStatus.RESOLVED,
          resolvedAt: expect.any(Date),
          resolvedById: "user-1",
        },
      });
      expect(result).toEqual(mockUpdatedAlert);
    });
  });

  describe("dismissAlert", () => {
    it("should dismiss alert", async () => {
      const mockUpdatedAlert = {
        id: "alert-1",
        status: AlertStatus.DISMISSED,
        dismissedAt: new Date(),
      };

      mockPrismaService.alert.update.mockResolvedValue(mockUpdatedAlert);

      const result = await service.dismissAlert("alert-1");

      expect(mockPrismaService.alert.update).toHaveBeenCalledWith({
        where: { id: "alert-1" },
        data: { status: AlertStatus.DISMISSED, dismissedAt: expect.any(Date) },
      });
      expect(result).toEqual(mockUpdatedAlert);
    });
  });

  describe("getUnreadCount", () => {
    it("should return count of OPEN alerts for family", async () => {
      mockPrismaService.alert.count.mockResolvedValue(5);

      const result = await service.getUnreadCount("family-1");

      expect(mockPrismaService.alert.count).toHaveBeenCalledWith({
        where: { familyId: "family-1", status: AlertStatus.OPEN },
      });
      expect(result).toBe(5);
    });
  });
});
