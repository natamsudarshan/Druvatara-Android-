import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { UserService } from "./user.service";
import { UpdateUserDto } from "./dto/update-user.dto";
import { UpdatePreferencesDto } from "./dto/update-preferences.dto";
import * as bcrypt from "bcrypt";

jest.mock("bcrypt");

describe("UserService", () => {
  let service: UserService;
  let prisma: PrismaService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      update: jest.fn(),
    },
    session: {
      findMany: jest.fn(),
      updateMany: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        UserService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<UserService>(UserService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  describe("findMe", () => {
    it("should return user profile", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        name: "Test User",
        country: "US",
        timezone: "UTC",
        language: "en",
        avatarUrl: null,
        role: "PARENT",
        createdAt: new Date(),
        lastLoginAt: new Date(),
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      const result = await service.findMe("user-1");

      expect(result).toEqual(mockUser);
    });
  });

  describe("updateMe", () => {
    it("should update user profile", async () => {
      const updateUserDto: UpdateUserDto = { name: "Updated Name" };
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        name: "Updated Name",
      };
      mockPrismaService.user.update.mockResolvedValue(mockUser);

      const result = await service.updateMe("user-1", updateUserDto);

      expect(result).toEqual(mockUser);
    });
  });

  describe("updatePreferences", () => {
    it("should merge preferences", async () => {
      const updatePreferencesDto: UpdatePreferencesDto = {
        preferences: { theme: "dark" },
      };
      mockPrismaService.user.findUnique.mockResolvedValue({
        preferences: { notifications: true },
      });
      mockPrismaService.user.update.mockResolvedValue({
        preferences: { notifications: true, theme: "dark" },
      });

      const result = await service.updatePreferences(
        "user-1",
        updatePreferencesDto,
      );

      expect(result.preferences).toEqual({
        notifications: true,
        theme: "dark",
      });
    });
  });

  describe("getSecurityStatus", () => {
    it("should return security status", async () => {
      const mockSessions = [{ id: "session-1", deviceName: "iPhone" }];
      mockPrismaService.session.findMany.mockResolvedValue(mockSessions);
      mockPrismaService.user.findUnique.mockResolvedValue({ mfaEnabled: true });

      const result = await service.getSecurityStatus("user-1");

      expect(result.activeSessions).toBe(1);
      expect(result.mfaEnabled).toBe(true);
    });
  });

  describe("changePassword", () => {
    it("should change password successfully", async () => {
      const mockUser = { id: "user-1", passwordHash: "hashedPassword" };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      (bcrypt.hash as jest.Mock).mockResolvedValue("newHashedPassword");
      mockPrismaService.session.findMany.mockResolvedValue([]);
      mockPrismaService.session.updateMany.mockResolvedValue({});
      mockPrismaService.user.update.mockResolvedValue({});

      const result = await service.changePassword(
        "user-1",
        "currentPassword",
        "newPassword",
      );

      expect(result).toEqual({
        success: true,
        message: "Password changed successfully",
      });
      expect(bcrypt.hash).toHaveBeenCalledWith("newPassword", 12);
    });

    it("should throw NotFoundException if user not found", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(
        service.changePassword("user-1", "current", "new"),
      ).rejects.toThrow(NotFoundException);
    });

    it("should throw ForbiddenException for wrong current password", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        passwordHash: "hashedPassword",
      });
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(
        service.changePassword("user-1", "wrong", "new"),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("getSessions", () => {
    it("should return user sessions", async () => {
      const mockSessions = [{ id: "session-1" }, { id: "session-2" }];
      mockPrismaService.session.findMany.mockResolvedValue(mockSessions);

      const result = await service.getSessions("user-1");

      expect(result).toEqual(mockSessions);
    });
  });

  describe("revokeSession", () => {
    it("should revoke session if owned by user", async () => {
      const mockSession = { id: "session-1", userId: "user-1" };
      mockPrismaService.session.findUnique.mockResolvedValue(mockSession);
      mockPrismaService.session.update.mockResolvedValue({});

      const result = await service.revokeSession("user-1", "session-1");

      expect(result).toEqual({ success: true });
    });

    it("should throw NotFoundException for session not owned by user", async () => {
      const mockSession = { id: "session-1", userId: "user-2" };
      mockPrismaService.session.findUnique.mockResolvedValue(mockSession);

      await expect(
        service.revokeSession("user-1", "session-1"),
      ).rejects.toThrow(NotFoundException);
    });
  });
});
