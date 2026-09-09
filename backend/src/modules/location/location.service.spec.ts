import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { LocationService } from "./location.service";

describe("LocationService", () => {
  let service: LocationService;
  let prisma: PrismaService;

  const mockPrismaService = {
    device: {
      findUnique: jest.fn(),
    },
    location: {
      create: jest.fn(),
      findFirst: jest.fn(),
      findMany: jest.fn(),
    },
    geofence: {
      findMany: jest.fn(),
    },
    geofenceEvent: {
      findFirst: jest.fn(),
      create: jest.fn(),
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
        LocationService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<LocationService>(LocationService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("updateLocation", () => {
    it("should create location and check geofences", async () => {
      const mockDevice = {
        id: "device-1",
        familyId: "family-1",
        childId: "child-1",
      };

      const mockLocation = {
        id: "location-1",
        childId: "child-1",
        deviceId: "device-1",
        latitude: 12.9716,
        longitude: 77.5946,
        accuracyMeters: 10,
        source: "GPS",
        capturedAt: new Date(),
      };

      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.location.create.mockResolvedValue(mockLocation);
      mockPrismaService.geofence.findMany.mockResolvedValue([]);

      const result = await service.updateLocation(
        "device-1",
        12.9716,
        77.5946,
        10,
      );

      expect(mockPrismaService.device.findUnique).toHaveBeenCalledWith({
        where: { id: "device-1" },
        select: { id: true, familyId: true, childId: true },
      });
      expect(mockPrismaService.location.create).toHaveBeenCalledWith({
        data: {
          childId: "child-1",
          deviceId: "device-1",
          latitude: 12.9716,
          longitude: 77.5946,
          accuracyMeters: 10,
          source: "GPS",
          capturedAt: expect.any(Date),
        },
      });
      expect(result).toEqual(mockLocation);
    });

    it("should throw NotFoundException if device not found", async () => {
      mockPrismaService.device.findUnique.mockResolvedValue(null);

      await expect(
        service.updateLocation("non-existent", 12.9716, 77.5946),
      ).rejects.toThrow(NotFoundException);
    });

    it("should use default accuracy of 0 when not provided", async () => {
      const mockDevice = {
        id: "device-1",
        familyId: "family-1",
        childId: "child-1",
      };
      const mockLocation = {
        id: "location-1",
        childId: "child-1",
        deviceId: "device-1",
        latitude: 12.9716,
        longitude: 77.5946,
        accuracyMeters: 0,
        source: "GPS",
        capturedAt: new Date(),
      };

      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.location.create.mockResolvedValue(mockLocation);
      mockPrismaService.geofence.findMany.mockResolvedValue([]);

      await service.updateLocation("device-1", 12.9716, 77.5946);

      expect(mockPrismaService.location.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ accuracyMeters: 0 }),
        }),
      );
    });
  });

  describe("getCurrentLocation", () => {
    it("should return latest location for child", async () => {
      const mockChild = { id: "child-1", familyId: "family-1" };
      const mockMembership = {
        familyId: "family-1",
        userId: "user-1",
        isActive: true,
      };
      const mockLocation = {
        id: "location-1",
        childId: "child-1",
        latitude: 12.9716,
        longitude: 77.5946,
        capturedAt: new Date(),
      };

      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue(
        mockMembership,
      );
      mockPrismaService.location.findFirst.mockResolvedValue(mockLocation);

      const result = await service.getCurrentLocation("child-1", "user-1");

      expect(mockPrismaService.location.findFirst).toHaveBeenCalledWith({
        where: { childId: "child-1" },
        orderBy: { capturedAt: "desc" },
      });
      expect(result).toEqual(mockLocation);
    });

    it("should throw NotFoundException if child not found", async () => {
      mockPrismaService.child.findUnique.mockResolvedValue(null);

      await expect(
        service.getCurrentLocation("non-existent", "user-1"),
      ).rejects.toThrow(NotFoundException);
    });

    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.child.findUnique.mockResolvedValue({
        id: "child-1",
        familyId: "family-1",
      });
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(
        service.getCurrentLocation("child-1", "user-1"),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("getLocationHistory", () => {
    it("should return location history for specified hours", async () => {
      const mockChild = { id: "child-1", familyId: "family-1" };
      const mockMembership = {
        familyId: "family-1",
        userId: "user-1",
        isActive: true,
      };
      const mockLocations = [
        { id: "loc-1", childId: "child-1", capturedAt: new Date() },
        {
          id: "loc-2",
          childId: "child-1",
          capturedAt: new Date(Date.now() - 3600000),
        },
      ];

      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue(
        mockMembership,
      );
      mockPrismaService.location.findMany.mockResolvedValue(mockLocations);

      const result = await service.getLocationHistory("child-1", "user-1", 24);

      expect(mockPrismaService.location.findMany).toHaveBeenCalledWith({
        where: {
          childId: "child-1",
          capturedAt: { gte: expect.any(Date) },
        },
        orderBy: { capturedAt: "desc" },
        take: 1000,
      });
      expect(result).toEqual(mockLocations);
    });

    it("should default to 24 hours when not specified", async () => {
      const mockChild = { id: "child-1", familyId: "family-1" };
      const mockMembership = {
        familyId: "family-1",
        userId: "user-1",
        isActive: true,
      };

      mockPrismaService.child.findUnique.mockResolvedValue(mockChild);
      mockPrismaService.familyMember.findUnique.mockResolvedValue(
        mockMembership,
      );
      mockPrismaService.location.findMany.mockResolvedValue([]);

      await service.getLocationHistory("child-1", "user-1");

      const callArgs = mockPrismaService.location.findMany.mock.calls[0][0];
      const oneDayAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
      expect(callArgs.where.capturedAt.gte.getTime()).toBeCloseTo(
        oneDayAgo.getTime(),
        -3,
      );
    });
  });

  describe("calculateDistance", () => {
    it("should calculate distance between two coordinates", async () => {
      // Test the private method through geofence checking
      const mockChild = { id: "child-1", familyId: "family-1" };
      const mockMembership = {
        familyId: "family-1",
        userId: "user-1",
        isActive: true,
      };
      const mockGeofence = {
        id: "geo-1",
        childId: "child-1",
        latitude: 12.9716,
        longitude: 77.5946,
        radiusMeters: 1000,
        isActive: true,
      };

      mockPrismaService.device.findUnique.mockResolvedValue({
        id: "device-1",
        familyId: "family-1",
        childId: "child-1",
      });
      mockPrismaService.location.create.mockResolvedValue({ id: "loc-1" });
      mockPrismaService.geofence.findMany.mockResolvedValue([mockGeofence]);
      mockPrismaService.geofenceEvent.findFirst.mockResolvedValue(null);

      await service.updateLocation("device-1", 12.9716, 77.5946);

      // Should create geofence event for ENTER since distance is 0
      expect(mockPrismaService.geofenceEvent.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            eventType: "ENTER",
          }),
        }),
      );
    });
  });
});
