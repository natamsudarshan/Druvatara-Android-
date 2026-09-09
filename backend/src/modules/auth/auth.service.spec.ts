import { Test, TestingModule } from "@nestjs/testing";
import { JwtService } from "@nestjs/jwt";
import { ConfigService } from "@nestjs/config";
import {
  UnauthorizedException,
  ConflictException,
  BadRequestException,
} from "@nestjs/common";
import * as bcrypt from "bcrypt";
import { PrismaService } from "../../prisma/prisma.service";
import { AuthService } from "./auth.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";

jest.mock("bcrypt");

describe("AuthService", () => {
  let service: AuthService;
  let prisma: PrismaService;
  let jwtService: JwtService;

  const mockPrismaService = {
    user: {
      findUnique: jest.fn(),
      create: jest.fn(),
    },
    family: {
      create: jest.fn(),
    },
    familyMember: {
      create: jest.fn(),
      findFirst: jest.fn(),
    },
    session: {
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
      findMany: jest.fn(),
    },
    device: {
      findUnique: jest.fn(),
    },
  };

  const mockJwtService = {
    sign: jest.fn(),
    verify: jest.fn(),
  };

  const mockConfigService = {
    get: jest.fn((key: string) => {
      if (key === "JWT_SECRET") return "test-secret";
      if (key === "JWT_REFRESH_SECRET") return "test-refresh-secret";
      if (key === "DEVICE_JWT_SECRET") return "test-device-secret";
      return null;
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AuthService,
        { provide: PrismaService, useValue: mockPrismaService },
        { provide: JwtService, useValue: mockJwtService },
        { provide: ConfigService, useValue: mockConfigService },
      ],
    }).compile();

    service = module.get<AuthService>(AuthService);
    prisma = module.get<PrismaService>(PrismaService);
    jwtService = module.get<JwtService>(JwtService);

    jest.clearAllMocks();
  });

  describe("register", () => {
    const registerDto: RegisterDto = {
      email: "test@example.com",
      password: "password123",
      name: "Test User",
      country: "US",
    };

    it("should register a new user successfully", async () => {
      const hashedPassword = "hashedPassword";
      const mockUser = {
        id: "user-1",
        email: registerDto.email,
        name: registerDto.name,
        country: registerDto.country,
        createdAt: new Date(),
      };
      const mockFamily = { id: "family-1" };
      const mockTokens = {
        accessToken: "access-token",
        refreshToken: "refresh-token",
        expiresIn: 900,
      };

      (bcrypt.hash as jest.Mock).mockResolvedValue(hashedPassword);
      mockPrismaService.user.findUnique.mockResolvedValue(null);
      mockPrismaService.user.create.mockResolvedValue(mockUser);
      mockPrismaService.family.create.mockResolvedValue(mockFamily);
      mockPrismaService.familyMember.create.mockResolvedValue({});
      jest
        .spyOn(service as any, "generateTokens")
        .mockResolvedValue(mockTokens);

      const result = await service.register(registerDto);

      expect(bcrypt.hash).toHaveBeenCalledWith(registerDto.password, 12);
      expect(mockPrismaService.user.create).toHaveBeenCalled();
      expect(mockPrismaService.family.create).toHaveBeenCalled();
      expect(result).toEqual({
        user: mockUser,
        familyId: mockFamily.id,
        ...mockTokens,
      });
    });

    it("should throw ConflictException if email already exists", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue({
        id: "existing-user",
      });

      await expect(service.register(registerDto)).rejects.toThrow(
        ConflictException,
      );
    });
  });

  describe("login", () => {
    const loginDto: LoginDto = {
      email: "test@example.com",
      password: "password123",
    };

    it("should login successfully with valid credentials", async () => {
      const mockUser = {
        id: "user-1",
        email: loginDto.email,
        name: "Test User",
        passwordHash: "hashedPassword",
        country: "US",
        timezone: "UTC",
        language: "en",
        isActive: true,
      };
      const mockFamilyMember = {
        familyId: "family-1",
        family: { id: "family-1" },
      };
      const mockTokens = {
        accessToken: "access-token",
        refreshToken: "refresh-token",
        expiresIn: 900,
      };

      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      mockPrismaService.familyMember.findFirst.mockResolvedValue(
        mockFamilyMember,
      );
      jest
        .spyOn(service as any, "generateTokens")
        .mockResolvedValue(mockTokens);

      const result = await service.login(loginDto);

      expect(bcrypt.compare).toHaveBeenCalledWith(
        loginDto.password,
        mockUser.passwordHash,
      );
      expect(result).toEqual({
        user: expect.objectContaining({ id: mockUser.id }),
        familyId: mockFamilyMember.familyId,
        ...mockTokens,
      });
    });

    it("should throw UnauthorizedException for invalid email", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it("should throw UnauthorizedException for invalid password", async () => {
      const mockUser = {
        ...loginDto,
        passwordHash: "hashedPassword",
        isActive: true,
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(false);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it("should throw UnauthorizedException for inactive user", async () => {
      const mockUser = {
        ...loginDto,
        passwordHash: "hashedPassword",
        isActive: false,
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);

      await expect(service.login(loginDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it("should throw BadRequestException if no active family", async () => {
      const mockUser = {
        ...loginDto,
        passwordHash: "hashedPassword",
        isActive: true,
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      (bcrypt.compare as jest.Mock).mockResolvedValue(true);
      mockPrismaService.familyMember.findFirst.mockResolvedValue(null);

      await expect(service.login(loginDto)).rejects.toThrow(
        BadRequestException,
      );
    });
  });

  describe("refreshToken", () => {
    const refreshTokenDto: RefreshTokenDto = {
      refreshToken: "valid-refresh-token",
    };

    it("should refresh token successfully", async () => {
      const mockPayload = { sub: "user-1", familyId: "family-1", type: "user" };
      const mockSession = {
        id: "session-1",
        refreshToken: "valid-refresh-token",
        expiresAt: new Date(Date.now() + 86400000),
        revokedAt: null,
      };
      const mockUser = { id: "user-1", isActive: true };
      const mockFamilyMember = { familyId: "family-1" };
      const mockTokens = {
        accessToken: "new-access-token",
        refreshToken: "new-refresh-token",
        expiresIn: 900,
      };

      mockJwtService.verify.mockReturnValue(mockPayload);
      mockPrismaService.session.findUnique.mockResolvedValue(mockSession);
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      mockPrismaService.familyMember.findFirst.mockResolvedValue(
        mockFamilyMember,
      );
      mockPrismaService.session.update.mockResolvedValue({});
      jest
        .spyOn(service as any, "generateTokens")
        .mockResolvedValue(mockTokens);

      const result = await service.refreshToken(refreshTokenDto);

      expect(result).toEqual(mockTokens);
    });

    it("should throw UnauthorizedException for invalid token", async () => {
      mockJwtService.verify.mockImplementation(() => {
        throw new Error("Invalid token");
      });

      await expect(service.refreshToken(refreshTokenDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it("should throw UnauthorizedException for revoked session", async () => {
      const mockPayload = { sub: "user-1", familyId: "family-1", type: "user" };
      const mockSession = {
        id: "session-1",
        refreshToken: "valid-refresh-token",
        expiresAt: new Date(Date.now() + 86400000),
        revokedAt: new Date(),
      };

      mockJwtService.verify.mockReturnValue(mockPayload);
      mockPrismaService.session.findUnique.mockResolvedValue(mockSession);

      await expect(service.refreshToken(refreshTokenDto)).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe("logout", () => {
    it("should logout by sessionId", async () => {
      mockPrismaService.session.update.mockResolvedValue({});

      await service.logout("user-1", "session-1");

      expect(mockPrismaService.session.update).toHaveBeenCalledWith({
        where: { id: "session-1", userId: "user-1" },
        data: { revokedAt: expect.any(Date) },
      });
    });

    it("should logout by accessToken", async () => {
      mockPrismaService.session.updateMany.mockResolvedValue({});

      await service.logout("user-1", undefined, "access-token");

      expect(mockPrismaService.session.updateMany).toHaveBeenCalledWith({
        where: {
          userId: "user-1",
          accessToken: "access-token",
          revokedAt: null,
        },
        data: { revokedAt: expect.any(Date) },
      });
    });
  });

  describe("validateUser", () => {
    it("should return user if valid", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        name: "Test",
        isActive: true,
        role: "PARENT",
      };
      const mockFamilyMember = {
        familyId: "family-1",
        family: { id: "family-1" },
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      mockPrismaService.familyMember.findFirst.mockResolvedValue(mockFamilyMember);

      const result = await service.validateUser({ sub: "user-1" });

      expect(result).toEqual({
        sub: "user-1",
        familyId: "family-1",
        type: "user",
        email: "test@example.com",
        name: "Test",
        isActive: true,
        role: "PARENT",
      });
    });

    it("should throw UnauthorizedException if user not found", async () => {
      mockPrismaService.user.findUnique.mockResolvedValue(null);

      await expect(service.validateUser({ sub: "user-1" })).rejects.toThrow(
        UnauthorizedException,
      );
    });

    it("should throw UnauthorizedException if no active family", async () => {
      const mockUser = {
        id: "user-1",
        email: "test@example.com",
        name: "Test",
        isActive: true,
        role: "PARENT",
      };
      mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
      mockPrismaService.familyMember.findFirst.mockResolvedValue(null);

      await expect(service.validateUser({ sub: "user-1" })).rejects.toThrow(
        UnauthorizedException,
      );
    });
  });

  describe("validateDevice", () => {
    it("should return device if valid", async () => {
      const mockDevice = {
        id: "device-1",
        familyId: "family-1",
        childId: "child-1",
        credentialVersion: 1,
        isActive: true,
        status: "ACTIVE",
      };
      mockPrismaService.device.findUnique.mockResolvedValue(mockDevice);

      const result = await service.validateDevice({
        deviceId: "device-1",
        credentialVersion: 1,
      });

      expect(result).toEqual(mockDevice);
    });

    it("should throw UnauthorizedException if device not found", async () => {
      mockPrismaService.device.findUnique.mockResolvedValue(null);

      await expect(
        service.validateDevice({ deviceId: "device-1", credentialVersion: 1 }),
      ).rejects.toThrow(UnauthorizedException);
    });
  });
});
