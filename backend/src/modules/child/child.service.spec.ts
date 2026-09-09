import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { ChildService } from "./child.service";
import { CreateChildDto } from "./dto/create-child.dto";
import { UpdateChildDto } from "./dto/update-child.dto";

describe("ChildService", () => {
  let service: ChildService;
  let prisma: PrismaService;

  const mockPrismaService = {
    child: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
      count: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
    },
    subscription: {
      findFirst: jest.fn(),
    },
    policy: {
      create: jest.fn(),
      findFirst: jest.fn(),
    },
    usageSummary: {
      findMany: jest.fn(),
    },
    screenTimeEvent: {
      findMany: jest.fn(),
    },
    safetyScore: {
      findFirst: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ChildService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ChildService>(ChildService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("create", () => {
    it("should create child profile with default settings", async () => {
      const createChildDto: CreateChildDto = {
        displayName: "Child",
        ageGroup: "YOUNG_CHILD",
      };
      const mockChild = {
        id: "child-1",
        familyId: "family-1",
        displayName: "Child",
        ageGroup: "YOUNG_CHILD",
      };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);
      mockPrismaService.child.count.mockResolvedValue(0);
      mockPrismaService.child.create.mockResolvedValue(mockChild);
      mockPrismaService.policy.create.mockResolvedValue({});

      const result = await service.create("family-1", "user-1", createChildDto);

      expect(result).toEqual(mockChild);
    });

    it("should throw ForbiddenException if max children reached", async () => {
      const createChildDto: CreateChildDto = {
        displayName: "Child",
        ageGroup: "YOUNG_CHILD",
      };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.subscription.findFirst.mockResolvedValue({
        tier: "FREE",
      });
      mockPrismaService.child.count.mockResolvedValue(1);

      await expect(
        service.create("family-1", "user-1", createChildDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("findById", () => {
    it("should return child if user has family access", async () => {
      const mockChild = {
        id: "child-1",
        familyId: "family-1",
        displayName: "Child",
      };
      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });

      const result = await service.findById("child-1", "user-1");

      expect(result).toEqual(mockChild);
    });

    it("should throw NotFoundException if child not found", async () => {
      mockPrismaService.child.findUnique.mockResolvedValue(null);

      await expect(service.findById("child-1", "user-1")).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe("findAll", () => {
    it("should return all children for family", async () => {
      const mockChildren = [{ id: "child-1" }, { id: "child-2" }];
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.findMany.mockResolvedValue(mockChildren);

      const result = await service.findAll("family-1", "user-1");

      expect(result).toEqual(mockChildren);
    });
  });

  describe("getSummary", () => {
    it("should return child summary with usage and safety score", async () => {
      const mockChild = {
        id: "child-1",
        familyId: "family-1",
        displayName: "Child",
        ageGroup: "YOUNG_CHILD",
        avatarId: "avatar-1",
        devices: [],
        _count: { alerts: 0, requests: 0 },
      };
      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.usageSummary.findMany.mockResolvedValue([]);
      mockPrismaService.screenTimeEvent.findMany.mockResolvedValue([]);
      mockPrismaService.safetyScore.findFirst.mockResolvedValue(null);
      mockPrismaService.policy.findFirst.mockResolvedValue(null);

      const result = await service.getSummary("child-1", "user-1");

      expect(result.child.id).toBe("child-1");
      expect(result.todayUsage.totalMs).toBe(0);
    });
  });

  describe("update", () => {
    it("should update child profile", async () => {
      const updateChildDto: UpdateChildDto = { displayName: "Updated Child" };
      const mockChild = {
        id: "child-1",
        familyId: "family-1",
        displayName: "Updated Child",
      };
      mockPrismaService.child.findUnique.mockResolvedValue({
        ...mockChild,
        familyId: "family-1",
      });
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.update.mockResolvedValue(mockChild);

      const result = await service.update("child-1", "user-1", updateChildDto);

      expect(result.displayName).toBe("Updated Child");
    });
  });

  describe("delete", () => {
    it("should soft delete child", async () => {
      const mockChild = { id: "child-1", familyId: "family-1" };
      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.update.mockResolvedValue({});

      const result = await service.delete("child-1", "user-1");

      expect(result).toEqual({
        success: true,
        message: "Child profile deactivated",
      });
    });
  });
});
