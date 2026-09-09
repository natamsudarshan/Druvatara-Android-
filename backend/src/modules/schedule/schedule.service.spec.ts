import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { ScheduleService } from "./schedule.service";
import { CreateScheduleDto } from "./dto/create-schedule.dto";
import { UpdateScheduleDto } from "./dto/update-schedule.dto";

describe("ScheduleService", () => {
  let service: ScheduleService;
  let prisma: PrismaService;

  const mockPrismaService = {
    schedule: {
      findMany: jest.fn(),
      create: jest.fn(),
      findUnique: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
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
        ScheduleService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<ScheduleService>(ScheduleService);
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

  describe("getSchedules", () => {
    it("should return schedules for child", async () => {
      const mockSchedules = [
        {
          id: "sch-1",
          childId: "child-1",
          name: "Bedtime",
          scheduleType: "BEDTIME",
        },
        {
          id: "sch-2",
          childId: "child-1",
          name: "School",
          scheduleType: "SCHOOL",
        },
      ];

      mockPrismaService.schedule.findMany.mockResolvedValue(mockSchedules);

      const result = await service.getSchedules("child-1", "user-1");

      expect(mockPrismaService.schedule.findMany).toHaveBeenCalledWith({
        where: { childId: "child-1" },
        orderBy: { createdAt: "desc" },
      });
      expect(result).toEqual(mockSchedules);
    });

    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(service.getSchedules("child-1", "user-1")).rejects.toThrow(
        ForbiddenException,
      );
    });
  });

  describe("createSchedule", () => {
    it("should create schedule with all fields", async () => {
      const createDto: CreateScheduleDto = {
        name: "Bedtime",
        scheduleType: "BEDTIME",
        startTime: "21:00",
        endTime: "07:00",
        days: [1, 2, 3, 4, 5, 6, 7],
        timezone: "Asia/Kolkata",
        allowedApps: ["com.whatsapp", "com.phone"],
      };

      const mockSchedule = {
        id: "sch-1",
        childId: "child-1",
        ...createDto,
        isActive: true,
        createdAt: new Date(),
      };

      mockPrismaService.schedule.create.mockResolvedValue(mockSchedule);

      const result = await service.createSchedule(
        "child-1",
        "user-1",
        createDto,
      );

      expect(mockPrismaService.schedule.create).toHaveBeenCalledWith({
        data: {
          childId: "child-1",
          name: createDto.name,
          scheduleType: createDto.scheduleType,
          startTime: createDto.startTime,
          endTime: createDto.endTime,
          days: createDto.days,
          timezone: createDto.timezone,
          allowedApps: createDto.allowedApps,
        },
      });
      expect(result).toEqual(mockSchedule);
    });

    it("should default allowedApps to empty array", async () => {
      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      const mockSchedule = {
        id: "sch-1",
        childId: "child-1",
        ...createDto,
        allowedApps: [],
      };

      mockPrismaService.schedule.create.mockResolvedValue(mockSchedule);

      await service.createSchedule("child-1", "user-1", createDto);

      expect(mockPrismaService.schedule.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({ allowedApps: [] }),
        }),
      );
    });

    it("should require modify permission", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.coParentPermission.findUnique.mockResolvedValue(null);

      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      await expect(
        service.createSchedule("child-1", "user-1", createDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("updateSchedule", () => {
    it("should update schedule with new data", async () => {
      const updateDto: UpdateScheduleDto = {
        name: "Updated Bedtime",
        endTime: "08:00",
        isActive: false,
      };

      const mockExistingSchedule = { id: "sch-1", childId: "child-1" };
      const mockUpdatedSchedule = { ...mockExistingSchedule, ...updateDto };

      mockPrismaService.schedule.findUnique.mockResolvedValue(
        mockExistingSchedule,
      );
      mockPrismaService.schedule.update.mockResolvedValue(mockUpdatedSchedule);

      const result = await service.updateSchedule("sch-1", "user-1", updateDto);

      expect(mockPrismaService.schedule.update).toHaveBeenCalledWith({
        where: { id: "sch-1" },
        data: {
          name: updateDto.name,
          startTime: undefined,
          endTime: updateDto.endTime,
          days: undefined,
          timezone: undefined,
          allowedApps: undefined,
          isActive: updateDto.isActive,
        },
      });
      expect(result).toEqual(mockUpdatedSchedule);
    });

    it("should throw NotFoundException if schedule not found", async () => {
      mockPrismaService.schedule.findUnique.mockResolvedValue(null);

      await expect(
        service.updateSchedule("non-existent", "user-1", { name: "Test" }),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("deleteSchedule", () => {
    it("should delete schedule and return success", async () => {
      const mockSchedule = { id: "sch-1", childId: "child-1" };

      mockPrismaService.schedule.findUnique.mockResolvedValue(mockSchedule);
      mockPrismaService.schedule.delete.mockResolvedValue({});

      const result = await service.deleteSchedule("sch-1", "user-1");

      expect(mockPrismaService.schedule.delete).toHaveBeenCalledWith({
        where: { id: "sch-1" },
      });
      expect(result).toEqual({ success: true, message: "Schedule deleted" });
    });
  });

  describe("getScheduleTemplates", () => {
    it("should return predefined schedule templates", async () => {
      const templates = await service.getScheduleTemplates();

      expect(templates).toHaveLength(4);
      expect(templates[0]).toEqual(
        expect.objectContaining({
          id: "bedtime",
          name: "Bedtime",
          scheduleType: "BEDTIME",
        }),
      );
      expect(templates[1]).toEqual(
        expect.objectContaining({
          id: "school",
          name: "School Time",
          scheduleType: "SCHOOL",
        }),
      );
    });
  });

  describe("validateChildAccess", () => {
    it("should allow OWNER role to modify", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "OWNER",
      });

      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      await expect(
        service.createSchedule("child-1", "user-1", createDto),
      ).resolves.toBeDefined();
    });

    it("should allow ADMIN role to modify", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "ADMIN",
      });

      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      await expect(
        service.createSchedule("child-1", "user-1", createDto),
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

      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      await expect(
        service.createSchedule("child-1", "user-1", createDto),
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

      const createDto: CreateScheduleDto = {
        name: "Test",
        scheduleType: "CUSTOM",
        startTime: "10:00",
        endTime: "11:00",
        days: [1],
        timezone: "UTC",
      };

      await expect(
        service.createSchedule("child-1", "user-1", createDto),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
