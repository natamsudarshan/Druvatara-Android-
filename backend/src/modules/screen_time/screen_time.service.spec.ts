import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { ScreenTimeService } from "./screen_time.service";
import { UpdateScreenTimeDto } from "./dto/update-screen-time.dto";

describe("ScreenTimeService", () => {
  let service: ScreenTimeService;
  let prisma: PrismaService;

  const mockPrismaService = {
    policy: {
      findFirst: jest.fn(),
      create: jest.fn(),
    },
    usageSummary: {
      findMany: jest.fn(),
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
    coParentPermission: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ScreenTimeService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ScreenTimeService>(ScreenTimeService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  const mockChild = { id: "child-1", familyId: "family-1" };
  const mockMembership = {
    familyId: "family-1",
    userId: "user-1",
    isActive: true,
    role: "OWNER",
  };

  beforeEach(() => {
    mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
    mockPrismaService.familyMember.findUnique.mockResolvedValue(mockMembership);
  });

  describe("getScreenTimeConfig", () => {
    it("should return policy screenTime if policy exists", async () => {
      const mockPolicy = {
        screenTime: {
          dailyLimitMs: 3600000,
          essentialApps: ["com.phone"],
          warningThresholds: [1800000],
        },
      };

      mockPrismaService.policy.findFirst.mockResolvedValue(mockPolicy);

      const result = await service.getScreenTimeConfig("child-1", "user-1");

      expect(mockPrismaService.policy.findFirst).toHaveBeenCalledWith({
        where: { childId: "child-1", isActive: true },
        orderBy: { version: "desc" },
        select: { screenTime: true },
      });
      expect(result).toEqual(mockPolicy.screenTime);
    });

    it("should return default config if no policy exists", async () => {
      mockPrismaService.policy.findFirst.mockResolvedValue(null);

      const result = await service.getScreenTimeConfig("child-1", "user-1");

      expect(result).toEqual({
        dailyLimitMs: 7200000,
        essentialApps: [],
        warningThresholds: [900000, 300000, 60000],
      });
    });
  });

  describe("updateScreenTimeConfig", () => {
    it("should create new policy version with updated screenTime", async () => {
      const mockPolicy = {
        familyId: "family-1",
        childId: "child-1",
        version: 1,
        applications: {},
        schedules: {},
        webSafety: {},
        location: {},
        safeZones: {},
        essentialApps: [],
        temporaryOverrides: {},
      };

      const updateDto: UpdateScreenTimeDto = {
        dailyLimitMs: 5400000,
        essentialApps: ["com.whatsapp"],
        warningThresholds: [2700000, 900000, 300000],
      };

      const mockNewPolicy = {
        ...mockPolicy,
        version: 2,
        screenTime: updateDto,
      };

      mockPrismaService.policy.findFirst.mockResolvedValue(mockPolicy);
      mockPrismaService.policy.create.mockResolvedValue(mockNewPolicy);

      const result = await service.updateScreenTimeConfig(
        "child-1",
        "user-1",
        updateDto,
      );

      expect(mockPrismaService.policy.create).toHaveBeenCalledWith({
        data: {
          familyId: "family-1",
          childId: "child-1",
          version: 2,
          screenTime: updateDto,
          applications: mockPolicy.applications,
          schedules: mockPolicy.schedules,
          webSafety: mockPolicy.webSafety,
          location: mockPolicy.location,
          safeZones: mockPolicy.safeZones,
          essentialApps: mockPolicy.essentialApps,
          temporaryOverrides: mockPolicy.temporaryOverrides,
        },
      });
      expect(result).toEqual(mockNewPolicy);
    });

    it("should throw NotFoundException if no active policy", async () => {
      mockPrismaService.policy.findFirst.mockResolvedValue(null);

      const updateDto: UpdateScreenTimeDto = { dailyLimitMs: 3600000 };

      await expect(
        service.updateScreenTimeConfig("child-1", "user-1", updateDto),
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

      expect(mockPrismaService.usageSummary.findMany).toHaveBeenCalledWith({
        where: { childId: "child-1", date: today },
      });
      expect(result).toEqual({
        date: today.toISOString().split("T")[0],
        totalMs: 5400000,
        byApp: [
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
        ],
      });
    });

    it("should return zero usage if no summaries", async () => {
      const today = new Date();
      today.setHours(0, 0, 0, 0);

      mockPrismaService.usageSummary.findMany.mockResolvedValue([]);

      const result = await service.getTodayUsage("child-1", "user-1");

      expect(result).toEqual({
        date: today.toISOString().split("T")[0],
        totalMs: 0,
        byApp: [],
      });
    });
  });

  describe("getWeeklyUsage", () => {
    it("should return daily usage for last 7 days", async () => {
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      weekAgo.setHours(0, 0, 0, 0);

      const mockSummaries = [
        { date: new Date(Date.now() - 2 * 86400000), durationMs: 3600000n },
        { date: new Date(Date.now() - 2 * 86400000), durationMs: 1800000n },
        { date: new Date(Date.now() - 1 * 86400000), durationMs: 5400000n },
      ];

      mockPrismaService.usageSummary.findMany.mockResolvedValue(mockSummaries);

      const result = await service.getWeeklyUsage("child-1", "user-1");

      expect(result).toHaveLength(2);
      const day2 = result.find(
        (d) =>
          d.date ===
          new Date(Date.now() - 2 * 86400000).toISOString().split("T")[0],
      );
      expect(day2?.totalMs).toBe(5400000);
    });

    it("should return empty array if no summaries", async () => {
      mockPrismaService.usageSummary.findMany.mockResolvedValue([]);

      const result = await service.getWeeklyUsage("child-1", "user-1");

      expect(result).toEqual([]);
    });
  });

  describe("getScreenTimeEvents", () => {
    it("should return recent screen time events", async () => {
      const mockEvents = [
        {
          id: "evt-1",
          childId: "child-1",
          eventType: "LIMIT_REACHED",
          triggeredAt: new Date(),
        },
        {
          id: "evt-2",
          childId: "child-1",
          eventType: "WARNING",
          triggeredAt: new Date(),
        },
      ];

      mockPrismaService.screenTimeEvent.findMany.mockResolvedValue(mockEvents);

      const result = await service.getScreenTimeEvents("child-1", "user-1", 50);

      expect(mockPrismaService.screenTimeEvent.findMany).toHaveBeenCalledWith({
        where: { childId: "child-1" },
        orderBy: { triggeredAt: "desc" },
        take: 50,
      });
      expect(result).toEqual(mockEvents);
    });

    it("should default limit to 50", async () => {
      mockPrismaService.screenTimeEvent.findMany.mockResolvedValue([]);

      await service.getScreenTimeEvents("child-1", "user-1");

      expect(mockPrismaService.screenTimeEvent.findMany).toHaveBeenCalledWith(
        expect.objectContaining({ take: 50 }),
      );
    });
  });

  describe("validateChildAccess", () => {
    it("should allow OWNER role to modify", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "OWNER",
      });

      const updateDto: UpdateScreenTimeDto = { dailyLimitMs: 3600000 };

      mockPrismaService.policy.findFirst.mockResolvedValue({
        version: 1,
        familyId: "family-1",
        applications: {},
        schedules: {},
        webSafety: {},
        location: {},
        safeZones: {},
        essentialApps: [],
        temporaryOverrides: {},
      });
      mockPrismaService.policy.create.mockResolvedValue({});

      await expect(
        service.updateScreenTimeConfig("child-1", "user-1", updateDto),
      ).resolves.toBeDefined();
    });

    it("should deny co-parent without modifyPolicies", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue({
        modifyPolicies: false,
      });

      const updateDto: UpdateScreenTimeDto = { dailyLimitMs: 3600000 };

      await expect(
        service.updateScreenTimeConfig("child-1", "user-1", updateDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
