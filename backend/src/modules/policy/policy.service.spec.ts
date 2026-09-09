import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { PolicyService } from "./policy.service";
import { CreatePolicyDto } from "./dto/create-policy.dto";
import { UpdatePolicyDto } from "./dto/update-policy.dto";

describe("PolicyService", () => {
  let service: PolicyService;
  let prisma: PrismaService;

  const mockPrismaService = {
    policy: {
      findFirst: jest.fn(),
      create: jest.fn(),
      findMany: jest.fn(),
    },
    child: {
      findUnique: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
    },
    device: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    deviceCommand: {
      create: jest.fn(),
      findMany: jest.fn(),
    },
    coParentPermission: {
      findUnique: jest.fn(),
    },
  };

  const baseCreatePolicyDto: CreatePolicyDto = {
    screenTime: { dailyLimitMs: 7200000 },
    webSafety: { mode: "MODERATE", safeSearch: true, categories: [] },
    location: { enabled: true, backgroundLocation: false },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PolicyService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<PolicyService>(PolicyService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("create", () => {
    it("should create new policy with incremented version", async () => {
      const mockChild = { id: "child-1", familyId: "family-1", isActive: true };
      const mockPolicy = { id: "policy-1", version: 1, childId: "child-1" };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        role: "OWNER",
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.policy.findFirst.mockResolvedValue(null);
      mockPrismaService.policy.create.mockResolvedValue(mockPolicy);
      mockPrismaService.device.findMany.mockResolvedValue([]);
      mockPrismaService.deviceCommand.create.mockResolvedValue({});

      const result = await service.create(
        "family-1",
        "child-1",
        "user-1",
        baseCreatePolicyDto,
      );

      expect(result).toEqual(mockPolicy);
      expect(mockPrismaService.policy.create).toHaveBeenCalled();
    });

    it("should throw ForbiddenException if insufficient permissions", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        role: "MEMBER",
        isActive: true,
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue(null);

      await expect(
        service.create("family-1", "child-1", "user-1", baseCreatePolicyDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("findLatest", () => {
    it("should return latest policy", async () => {
      const mockPolicy = {
        id: "policy-1",
        version: 1,
        childId: "child-1",
        isActive: true,
      };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue({
        familyId: "family-1",
        isActive: true,
      });
      mockPrismaService.policy.findFirst.mockResolvedValue(mockPolicy);

      const result = await service.findLatest("family-1", "child-1", "user-1");

      expect(result).toEqual(mockPolicy);
    });
  });

  describe("findByVersion", () => {
    it("should return policy by version", async () => {
      const mockPolicy = {
        id: "policy-1",
        version: 1,
        childId: "child-1",
        isActive: true,
      };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue({
        familyId: "family-1",
        isActive: true,
      });
      mockPrismaService.policy.findFirst.mockResolvedValue(mockPolicy);

      const result = await service.findByVersion(
        "family-1",
        "child-1",
        1,
        "user-1",
      );

      expect(result).toEqual(mockPolicy);
    });
  });

  describe("findAll", () => {
    it("should return all policies for child", async () => {
      const mockPolicies = [
        { id: "policy-1", version: 1 },
        { id: "policy-2", version: 2 },
      ];
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue({
        familyId: "family-1",
        isActive: true,
      });
      mockPrismaService.policy.findMany.mockResolvedValue(mockPolicies);

      const result = await service.findAll("family-1", "child-1", "user-1");

      expect(result).toEqual(mockPolicies);
    });
  });

  describe("update", () => {
    it("should create new policy version", async () => {
      const updatePolicyDto: UpdatePolicyDto = {
        screenTime: { dailyLimitMs: 3600000 },
      };
      const latestPolicy = {
        id: "policy-1",
        version: 1,
        childId: "child-1",
        deviceId: null,
        screenTime: { dailyLimitMs: 7200000 },
      };
      const newPolicy = { id: "policy-2", version: 2, ...updatePolicyDto };
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        role: "OWNER",
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue({
        familyId: "family-1",
        isActive: true,
      });
      mockPrismaService.policy.findFirst.mockResolvedValue(latestPolicy);
      mockPrismaService.policy.create.mockResolvedValue(newPolicy);
      mockPrismaService.device.findMany.mockResolvedValue([]);
      mockPrismaService.deviceCommand.create.mockResolvedValue({});

      const result = await service.update(
        "family-1",
        "child-1",
        "user-1",
        updatePolicyDto,
      );

      expect(result.version).toBe(2);
    });

    it("should throw NotFoundException if no active policy", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        role: "OWNER",
        isActive: true,
      });
      mockPrismaService.child.findUnique.mockResolvedValue({
        familyId: "family-1",
        isActive: true,
      });
      mockPrismaService.policy.findFirst.mockResolvedValue(null);

      await expect(
        service.update("family-1", "child-1", "user-1", {
          screenTime: { dailyLimitMs: 3600000 },
        }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("acknowledgePolicy", () => {
    it("should update device policy version on success", async () => {
      const mockDevice = { id: "device-1", policyVersion: 0 };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.device.update.mockResolvedValue({
        ...mockDevice,
        policyVersion: 1,
      });

      const result = await service.acknowledgePolicy("device-1", 1, true);

      expect(result).toEqual({ success: true, policyVersion: 0 });
    });
  });

  describe("getPendingCommands", () => {
    it("should return queued policy commands", async () => {
      const mockCommands = [{ id: "cmd-1", type: "POLICY_UPDATE" }];
      mockPrismaService.deviceCommand.findMany.mockResolvedValue(mockCommands);

      const result = await service.getPendingCommands("device-1");

      expect(result).toEqual(mockCommands);
    });
  });
});
