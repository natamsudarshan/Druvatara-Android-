import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { GeofenceService } from "./geofence.service";
import { CreateGeofenceDto } from "./dto/create-geofence.dto";
import { UpdateGeofenceDto } from "./dto/update-geofence.dto";

describe("GeofenceService", () => {
  let service: GeofenceService;
  let prisma: PrismaService;

  const mockPrismaService = {
    geofence: {
      findMany: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    geofenceEvent: {
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
        GeofenceService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<GeofenceService>(GeofenceService);
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

  describe("getGeofences", () => {
    it("should return geofences with recent events", async () => {
      const mockGeofences = [
        { id: "geo-1", childId: "child-1", name: "Home", events: [] },
        { id: "geo-2", childId: "child-1", name: "School", events: [] },
      ];

      mockPrismaService.geofence.findMany.mockResolvedValue(mockGeofences);

      const result = await service.getGeofences("child-1", "user-1");

      expect(mockPrismaService.geofence.findMany).toHaveBeenCalledWith({
        where: { childId: "child-1" },
        include: { events: { orderBy: { triggeredAt: "desc" }, take: 5 } },
        orderBy: { createdAt: "desc" },
      });
      expect(result).toEqual(mockGeofences);
    });

    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(service.getGeofences("child-1", "user-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe("createGeofence", () => {
    it("should create geofence with defaults", async () => {
      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      const mockGeofence = {
        id: "geo-1",
        childId: "child-1",
        ...createDto,
        type: "CIRCLE",
        alertOnEnter: true,
        alertOnExit: true,
        isActive: true,
        createdAt: new Date(),
      };

      mockPrismaService.geofence.create.mockResolvedValue(mockGeofence);

      const result = await service.createGeofence(
        "child-1",
        "user-1",
        createDto,
      );

      expect(mockPrismaService.geofence.create).toHaveBeenCalledWith({
        data: {
          childId: "child-1",
          name: createDto.name,
          latitude: createDto.latitude,
          longitude: createDto.longitude,
          radiusMeters: createDto.radiusMeters,
          type: "CIRCLE",
          alertOnEnter: true,
          alertOnExit: true,
        },
      });
      expect(result).toEqual(mockGeofence);
    });

    it("should require modify permission", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue(null);

      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      await expect(
        service.createGeofence("child-1", "user-1", createDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("updateGeofence", () => {
    it("should update geofence with new data", async () => {
      const updateDto: UpdateGeofenceDto = {
        name: "Updated Home",
        radiusMeters: 1000,
        isActive: false,
      };

      const mockExistingGeofence = { id: "geo-1", childId: "child-1" };
      const mockUpdatedGeofence = { ...mockExistingGeofence, ...updateDto };

      mockPrismaService.geofence.findUnique.mockResolvedValue(
        mockExistingGeofence,
      );
      mockPrismaService.geofence.update.mockResolvedValue(mockUpdatedGeofence);

      const result = await service.updateGeofence("geo-1", "user-1", updateDto);

      expect(mockPrismaService.geofence.update).toHaveBeenCalledWith({
        where: { id: "geo-1" },
        data: {
          name: updateDto.name,
          latitude: undefined,
          longitude: undefined,
          radiusMeters: updateDto.radiusMeters,
          alertOnEnter: undefined,
          alertOnExit: undefined,
          isActive: updateDto.isActive,
        },
      });
      expect(result).toEqual(mockUpdatedGeofence);
    });

    it("should throw NotFoundException if geofence not found", async () => {
      mockPrismaService.geofence.findUnique.mockResolvedValue(null);

      await expect(
        service.updateGeofence("non-existent", "user-1", { name: "Test" }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("deleteGeofence", () => {
    it("should delete geofence and return success", async () => {
      const mockGeofence = { id: "geo-1", childId: "child-1" };

      mockPrismaService.geofence.findUnique.mockResolvedValue(mockGeofence);
      mockPrismaService.geofence.delete.mockResolvedValue({});

      const result = await service.deleteGeofence("geo-1", "user-1");

      expect(mockPrismaService.geofence.delete).toHaveBeenCalledWith({
        where: { id: "geo-1" },
      });
      expect(result).toEqual({ success: true, message: "Geofence deleted" });
    });

    it("should throw NotFoundException if geofence not found", async () => {
      mockPrismaService.geofence.findUnique.mockResolvedValue(null);

      await expect(
        service.deleteGeofence("non-existent", "user-1"),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("getGeofenceEvents", () => {
    it("should return geofence events with geofence details", async () => {
      const mockEvents = [
        {
          id: "event-1",
          childId: "child-1",
          geofence: { id: "geo-1", name: "Home" },
        },
        {
          id: "event-2",
          childId: "child-1",
          geofence: { id: "geo-2", name: "School" },
        },
      ];

      mockPrismaService.geofenceEvent.findMany.mockResolvedValue(mockEvents);

      const result = await service.getGeofenceEvents("child-1", "user-1", 50);

      expect(mockPrismaService.geofenceEvent.findMany).toHaveBeenCalledWith({
        where: { childId: "child-1" },
        include: { geofence: { select: { id: true, name: true } } },
        orderBy: { triggeredAt: "desc" },
        take: 50,
      });
      expect(result).toEqual(mockEvents);
    });
  });

  describe("validateChildAccess", () => {
    it("should allow OWNER role to modify", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "OWNER",
      });

      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      await expect(
        service.createGeofence("child-1", "user-1", createDto),
      ).resolves.toBeDefined();
    });

    it("should allow ADMIN role to modify", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "ADMIN",
      });

      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      await expect(
        service.createGeofence("child-1", "user-1", createDto),
      ).resolves.toBeDefined();
    });

    it("should allow co-parent with modifyPolicies permission", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue({
        modifyPolicies: true,
      });

      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      await expect(
        service.createGeofence("child-1", "user-1", createDto),
      ).resolves.toBeDefined();
    });

    it("should deny co-parent without modifyPolicies permission", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue({
        modifyPolicies: false,
      });

      const createDto: CreateGeofenceDto = {
        name: "Home",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 500,
      };

      await expect(
        service.createGeofence("child-1", "user-1", createDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
