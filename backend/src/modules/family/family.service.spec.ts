import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { FamilyService } from "./family.service";
import { CreateFamilyDto } from "./dto/create-family.dto";
import { UpdateFamilyDto } from "./dto/update-family.dto";

describe("FamilyService", () => {
  let service: FamilyService;
  let prisma: PrismaService;

  const mockPrismaService = {
    family: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    child: {
      count: jest.fn(),
    },
    device: {
      count: jest.fn(),
    },
    alert: {
      count: jest.fn(),
    },
    childRequest: {
      count: jest.fn(),
    },
    subscription: {
      findFirst: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FamilyService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<FamilyService>(FamilyService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("create", () => {
    it("should create family and add owner as member", async () => {
      const mockFamily = {
        id: "family-1",
        name: "Test Family",
        ownerId: "user-1",
      };
      const createFamilyDto: CreateFamilyDto = { name: "Test Family" };
      mockPrismaService.family.create.mockResolvedValue(mockFamily);
      mockPrismaService.familyMember.create.mockResolvedValue({});

      const result = await service.create("user-1", createFamilyDto);

      expect(result).toEqual(mockFamily);
      expect(mockPrismaService.familyMember.create).toHaveBeenCalledWith({
        data: { familyId: "family-1", userId: "user-1", role: "OWNER" },
      });
    });
  });

  describe("findById", () => {
    it("should return family with details if user is member", async () => {
      const mockFamily = {
        id: "family-1",
        name: "Test Family",
        ownerId: "user-1",
        members: [],
        children: [],
        devices: [],
        _count: { children: 0, devices: 0, alerts: 0 },
      };
      mockPrismaService.family.findUnique.mockResolvedValue(mockFamily);
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });

      const result = await service.findById("family-1", "user-1");

      expect(result).toEqual(mockFamily);
    });

    it("should throw NotFoundException if family not found", async () => {
      mockPrismaService.family.findUnique.mockResolvedValue(null);

      await expect(service.findById("family-1", "user-1")).rejects.toThrow(
        NotFoundException,
      );
    });

    it("should throw ForbiddenException if user not member", async () => {
      mockPrismaService.family.findUnique.mockResolvedValue({ id: "family-1" });
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(service.findById("family-1", "user-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe("getSummary", () => {
    it("should return family summary", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.count.mockResolvedValue(2);
      mockPrismaService.device.count.mockResolvedValue(3);
      mockPrismaService.alert.count.mockResolvedValue(1);
      mockPrismaService.childRequest.count.mockResolvedValue(2);
      jest
        .spyOn(service as any, "getProtectionState")
        .mockResolvedValue("PROTECTED");

      const result = await service.getSummary("family-1", "user-1");

      expect(result).toEqual({
        childrenCount: 2,
        devicesCount: 3,
        unresolvedAlerts: 1,
        pendingRequests: 2,
        protectionState: "PROTECTED",
      });
    });
  });

  describe("update", () => {
    it("should update family if user is owner", async () => {
      const updateFamilyDto: UpdateFamilyDto = { name: "Updated Family" };
      const mockFamily = {
        id: "family-1",
        name: "Updated Family",
        ownerId: "user-1",
      };
      jest.spyOn(service as any, "validateOwner").mockResolvedValue(undefined);
      mockPrismaService.family.update.mockResolvedValue(mockFamily);

      const result = await service.update(
        "family-1",
        "user-1",
        updateFamilyDto,
      );

      expect(result).toEqual(mockFamily);
    });

    it("should throw ForbiddenException if user not owner", async () => {
      jest
        .spyOn(service as any, "validateOwner")
        .mockRejectedValue(new ForbiddenException());

      await expect(
        service.update("family-1", "user-1", { name: "Updated" }),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("requestDeletion", () => {
    it("should soft delete family if user is owner", async () => {
      jest.spyOn(service as any, "validateOwner").mockResolvedValue(undefined);
      mockPrismaService.family.update.mockResolvedValue({});

      await service.requestDeletion("family-1", "user-1");

      expect(mockPrismaService.family.update).toHaveBeenCalledWith({
        where: { id: "family-1" },
        data: { deletedAt: expect.any(Date), isActive: false },
      });
    });
  });

  describe("getEntitlements", () => {
    it("should return tier entitlements", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.subscription.findFirst.mockResolvedValue({
        tier: "PREMIUM",
      });

      const result = await service.getEntitlements("family-1", "user-1");

      expect(result.tier).toBe("PREMIUM");
      expect(result.maxChildren).toBe(4);
    });
  });
});
