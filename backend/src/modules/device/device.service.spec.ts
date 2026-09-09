import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, BadRequestException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { DeviceService } from "./device.service";
import { RegisterDeviceDto } from "./dto/register-device.dto";
import { DevicePlatform, DeviceStatus } from "@prisma/client";

describe("DeviceService", () => {
  let service: DeviceService;
  let prisma: PrismaService;

  const mockPrismaService = {
    device: {
      create: jest.fn(),
      findUnique: jest.fn(),
      findMany: jest.fn(),
      update: jest.fn(),
    },
    pairingSession: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    deviceEvent: {
      count: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        DeviceService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<DeviceService>(DeviceService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("registerDevice", () => {
    const registerDeviceDto: RegisterDeviceDto = {
      installationId: "install-1",
      platform: DevicePlatform.ANDROID,
      appVersion: "1.0.0",
    };

    it("should register new device with pairing code", async () => {
      const mockPairing = {
        id: "pair-1",
        pairingCode: "123456",
        familyId: "family-1",
        childId: "child-1",
        deviceInternalId: "internal-1",
        expiresAt: new Date(Date.now() + 86400000),
        usedAt: null,
      };
      const mockDevice = {
        id: "device-1",
        internalId: "internal-1",
        installationId: "install-1",
      };
      mockPrismaService.pairingSession.findUnique.mockResolvedValue(
        mockPairing,
      );
      mockPrismaService.device.create.mockResolvedValue(mockDevice);
      mockPrismaService.pairingSession.update.mockResolvedValue({});

      const result = await service.registerDevice(
        "family-1",
        null,
        registerDeviceDto,
        "123456",
      );

      expect(result).toEqual(mockDevice);
    });

    it("should throw BadRequestException for invalid pairing code", async () => {
      mockPrismaService.pairingSession.findUnique.mockResolvedValue(null);

      await expect(
        service.registerDevice("family-1", null, registerDeviceDto, "invalid"),
      ).rejects.toThrow(BadRequestException);
    });

    it("should throw BadRequestException for expired pairing code", async () => {
      const mockPairing = { expiresAt: new Date(Date.now() - 86400000) };
      mockPrismaService.pairingSession.findUnique.mockResolvedValue(
        mockPairing,
      );

      await expect(
        service.registerDevice("family-1", null, registerDeviceDto, "123456"),
      ).rejects.toThrow(BadRequestException);
    });

    it("should register device without pairing code", async () => {
      const mockDevice = { id: "device-1" };
      mockPrismaService.device.create.mockResolvedValue(mockDevice);

      const result = await service.registerDevice(
        "family-1",
        "child-1",
        registerDeviceDto,
      );

      expect(result).toEqual(mockDevice);
    });
  });

  describe("getDevice", () => {
    it("should return device if found", async () => {
      const mockDevice = { id: "device-1", familyId: "family-1" };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);

      const result = await service.getDevice("device-1");

      expect(result).toEqual(mockDevice);
    });

    it("should throw NotFoundException if device not found", async () => {
      mockPrismaService.device.findUnique.mockResolvedValue(null);

      await expect(service.getDevice("device-1")).rejects.toThrow(
        NotFoundException,
      );
    });
  });

  describe("getFamilyDevices", () => {
    it("should return all devices for family", async () => {
      const mockDevices = [{ id: "device-1" }, { id: "device-2" }];
      mockPrismaService.device.findMany.mockResolvedValue(mockDevices);

      const result = await service.getFamilyDevices("family-1");

      expect(result).toEqual(mockDevices);
    });
  });

  describe("updateDevice", () => {
    it("should update device", async () => {
      const mockDevice = { id: "device-1" };
      const updateData = { status: DeviceStatus.OFFLINE };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.device.update.mockResolvedValue({
        ...mockDevice,
        ...updateData,
      });

      const result = await service.updateDevice("device-1", updateData);

      expect(result.status).toBe(DeviceStatus.OFFLINE);
    });
  });

  describe("updateDeviceStatus", () => {
    it("should update device status", async () => {
      const mockDevice = { id: "device-1" };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.device.update.mockResolvedValue({
        ...mockDevice,
        status: DeviceStatus.OFFLINE,
      });

      await service.updateDeviceStatus("device-1", DeviceStatus.OFFLINE);

      expect(mockPrismaService.device.update).toHaveBeenCalledWith({
        where: { id: "device-1" },
        data: { status: DeviceStatus.OFFLINE },
      });
    });
  });

  describe("updateDeviceHeartbeat", () => {
    it("should update last seen and IP", async () => {
      mockPrismaService.device.update.mockResolvedValue({});

      await service.updateDeviceHeartbeat("device-1", "192.168.1.1");

      expect(mockPrismaService.device.update).toHaveBeenCalledWith({
        where: { id: "device-1" },
        data: { lastSeenAt: expect.any(Date), lastIp: "192.168.1.1" },
      });
    });
  });

  describe("updatePublicKey", () => {
    it("should update public key and credential version", async () => {
      mockPrismaService.device.update.mockResolvedValue({});

      await service.updatePublicKey("device-1", "public-key", 2);

      expect(mockPrismaService.device.update).toHaveBeenCalledWith({
        where: { id: "device-1" },
        data: { publicKey: "public-key", credentialVersion: 2 },
      });
    });
  });

  describe("deleteDevice", () => {
    it("should soft delete device", async () => {
      const mockDevice = { id: "device-1" };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.device.update.mockResolvedValue({});

      const result = await service.deleteDevice("device-1");

      expect(result).toEqual({ success: true });
      expect(mockPrismaService.device.update).toHaveBeenCalledWith({
        where: { id: "device-1" },
        data: { isActive: false, status: DeviceStatus.REMOVED },
      });
    });
  });

  describe("getDeviceHealth", () => {
    it("should return device health status", async () => {
      const mockDevice = {
        id: "device-1",
        lastSeenAt: new Date(),
        status: DeviceStatus.ACTIVE,
        lastIp: "192.168.1.1",
        batteryLevel: 80,
        storageUsed: 1000,
        storageTotal: 5000,
      };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);
      mockPrismaService.deviceEvent.count.mockResolvedValue(5);

      const result = await service.getDeviceHealth("device-1");

      expect(result).toEqual({
        deviceId: "device-1",
        isOnline: true,
        status: DeviceStatus.ACTIVE,
        lastSeenAt: mockDevice.lastSeenAt,
        lastIp: "192.168.1.1",
        batteryLevel: 80,
        storageUsed: 1000,
        storageTotal: 5000,
        recentEventCount: 5,
      });
    });
  });

  describe("getDevicesByChild", () => {
    it("should return devices for child", async () => {
      const mockDevices = [{ id: "device-1" }];
      mockPrismaService.device.findMany.mockResolvedValue(mockDevices);

      const result = await service.getDevicesByChild("child-1");

      expect(result).toEqual(mockDevices);
    });
  });
});
