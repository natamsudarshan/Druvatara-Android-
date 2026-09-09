import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { UsageService } from "./usage.service";

describe("UsageService", () => {
  let service: UsageService;
  let prisma: PrismaService;

  const mockPrismaService = {
    device: {
      findUnique: jest.fn(),
    },
    usageSummary: {
      upsert: jest.fn(),
      findMany: jest.fn(),
      groupBy: jest.fn(),
    },
    screenTimeEvent: {
      findMany: jest.fn(),
    },
    child: {
      findUnique: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UsageService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<UsageService>(UsageService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  const mockChild = { id: "child-1", familyId: "family-1", isActive: true };
  const mockMembership = {
    familyId: "family-1",
    userId: "user-1",
    isActive: true,
  };

  beforeEach(() => {
    mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
    mockPrismaService.familyMember.findUnique.mockResolvedValue(mockMembership);
  });

  describe("recordUsage", () => {
    it("should upsert usage data for device", async () => {
      const mockDevice = {
        id: "device-1",
        childId: "child-1",
        familyId: "family-1",
      };
      const usageData = [
        {
          packageName: "com.app1",
          appName: "App 1",
          durationMs: 3600000,
          launchCount: 5,
        },
        {
          packageName: "com.app2",
          appName: "App 2",
          durationMs: 1800000,
          launchCount: 3,
        },
      ];

      const mockResults = usageData.map((u) => ({
        ...u,
        id: `usage-${u.packageName}`,
        deviceId: "device-1",
        childId: "child-1",
        date: new Date(),
        durationMs: BigInt(u.durationMs),
      }));

      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.usageSummary.upsert
        .mockResolvedValueOnce(mockResults[0])
        .mockResolvedValueOnce(mockResults[1]);

      const results = await service.recordUsage("device-1", usageData);

      expect(mockPrismaService.usageSummary.upsert).toHaveBeenCalledTimes(2);
      expect(results).toHaveLength(2);
    });

    it("should throw NotFoundException if device not found", async () => {
      mockPrismaService.device.findUnique.mockResolvedValue(null);

      await expect(
        service.recordUsage("non-existent", [{ packageName: "com.app1" }]),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("getTodayUsage", () => {
    it("should return aggregated usage for today", async () => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const mockSummaries = [
        {
          packageName: "com.app1",
          appName: "App 1",
          durationMs: 3600000n,
          launchCount: 5,
        },
        {
          packageName: "com.app2",
          appName: "App 2",
          durationMs: 1800000n,
          launchCount: 3,
        },
      ];

      mockPrismaService.usageSummary.findMany.mockResolvedValue(mockSummaries);

      const result = await service.getTodayUsage("child-1", "user-1");

      // Use the actual date format from the service (uses date-fns format)
      expect(result.date).toBeDefined();
      expect(result.totalMs).toBe(5400000);
      expect(result.byApp).toHaveLength(2);
    });
  });

  describe("getWeeklyUsage", () => {
    it("should return daily usage grouped by day", async () => {
      const day1 = new Date();
      day1.setHours(0, 0, 0, 0);
      const day2 = new Date(day1);
      day2.setDate(day2.getDate() - 1);

      const mockSummaries = [
        {
          date: day1,
          packageName: "com.app1",
          appName: "App 1",
          durationMs: 3600000n,
          launchCount: 5,
        },
        {
          date: day1,
          packageName: "com.app2",
          appName: "App 2",
          durationMs: 1800000n,
          launchCount: 3,
        },
        {
          date: day2,
          packageName: "com.app1",
          appName: "App 1",
          durationMs: 2700000n,
          launchCount: 4,
        },
      ];

      mockPrismaService.usageSummary.findMany.mockResolvedValue(mockSummaries);

      const result = await service.getWeeklyUsage("child-1", "user-1");

      expect(result).toHaveLength(2);
      // Total for day1: 3600000 + 1800000 = 5400000
      // Total for day2: 2700000
      const day1Result = result.find((d) => d.totalMs === 5400000);
      expect(day1Result).toBeDefined();
      expect(day1Result?.apps).toHaveLength(2);
    });
  });

  describe("getAppUsage", () => {
    it("should return usage for specific app over days", async () => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      const mockSummaries = [
        {
          date: today,
          packageName: "com.app1",
          durationMs: 3600000n,
          launchCount: 5,
        },
        {
          date: new Date(today.getTime() - 86400000),
          packageName: "com.app1",
          durationMs: 1800000n,
          launchCount: 3,
        },
      ];

      mockPrismaService.usageSummary.findMany.mockResolvedValue(mockSummaries);

      const result = await service.getAppUsage(
        "child-1",
        "com.app1",
        "user-1",
        30,
      );

      expect(result).toHaveLength(2);
      // The service formats dates using date-fns format (yyyy-MM-dd)
      expect(result[0]).toHaveProperty("date");
      expect(result[0]).toHaveProperty("durationMs", 3600000);
      expect(result[0]).toHaveProperty("launchCount", 5);
    });
  });

  describe("getTopApps", () => {
    it("should return top apps by duration", async () => {
      const mockGroupBy = [
        {
          packageName: "com.app1",
          appName: "App 1",
          _sum: { durationMs: 7200000n, launchCount: 10 },
        },
        {
          packageName: "com.app2",
          appName: "App 2",
          _sum: { durationMs: 3600000n, launchCount: 5 },
        },
        {
          packageName: "com.app3",
          appName: "App 3",
          _sum: { durationMs: 1800000n, launchCount: 3 },
        },
      ];

      mockPrismaService.usageSummary.groupBy.mockResolvedValue(mockGroupBy);

      const result = await service.getTopApps("child-1", "user-1", 10, 7);

      expect(mockPrismaService.usageSummary.groupBy).toHaveBeenCalledWith({
        by: ["packageName", "appName"],
        where: { childId: "child-1", date: { gte: expect.any(Date) } },
        _sum: { durationMs: true, launchCount: true },
        orderBy: { _sum: { durationMs: "desc" } },
        take: 10,
      });
      expect(result).toHaveLength(3);
      expect(result[0]).toEqual(
        expect.objectContaining({
          packageName: "com.app1",
          totalDurationMs: 7200000,
        }),
      );
    });
  });

  describe("getScreenTimeEvents", () => {
    it("should return screen time events", async () => {
      const mockEvents = [
        { id: "evt-1", childId: "child-1", eventType: "LIMIT_REACHED" },
        { id: "evt-2", childId: "child-1", eventType: "WARNING" },
      ];

      mockPrismaService.screenTimeEvent.findMany.mockResolvedValue(mockEvents);

      const result = await service.getScreenTimeEvents("child-1", "user-1");

      expect(result).toEqual(mockEvents);
    });
  });

  describe("validateChildAccess", () => {
    it("should throw NotFoundException if child not found", async () => {
      mockPrismaService.child.findUnique.mockResolvedValue(null);

      await expect(
        service.getTodayUsage("non-existent", "user-1"),
      ).rejects.toThrow(NotFoundException);
    });

    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(service.getTodayUsage("child-1", "user-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });
});
