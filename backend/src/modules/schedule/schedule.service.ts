import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateScheduleDto } from "./dto/create-schedule.dto";
import { UpdateScheduleDto } from "./dto/update-schedule.dto";

@Injectable()
export class ScheduleService {
  constructor(private prisma: PrismaService) {}

  async getSchedules(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.schedule.findMany({
      where: { childId },
      orderBy: { createdAt: "desc" },
    });
  }

  async createSchedule(
    childId: string,
    userId: string,
    createScheduleDto: CreateScheduleDto,
  ) {
    await this.validateChildAccess(childId, userId, true);

    return this.prisma.schedule.create({
      data: {
        childId,
        name: createScheduleDto.name,
        scheduleType: createScheduleDto.scheduleType,
        startTime: createScheduleDto.startTime,
        endTime: createScheduleDto.endTime,
        days: createScheduleDto.days,
        timezone: createScheduleDto.timezone,
        allowedApps: createScheduleDto.allowedApps || [],
      },
    });
  }

  async updateSchedule(
    scheduleId: string,
    userId: string,
    updateScheduleDto: UpdateScheduleDto,
  ) {
    const schedule = await this.prisma.schedule.findUnique({
      where: { id: scheduleId },
      select: { childId: true },
    });

    if (!schedule) {
      throw new NotFoundException("Schedule not found");
    }

    await this.validateChildAccess(schedule.childId, userId, true);

    return this.prisma.schedule.update({
      where: { id: scheduleId },
      data: {
        name: updateScheduleDto.name,
        startTime: updateScheduleDto.startTime,
        endTime: updateScheduleDto.endTime,
        days: updateScheduleDto.days,
        timezone: updateScheduleDto.timezone,
        allowedApps: updateScheduleDto.allowedApps,
        isActive: updateScheduleDto.isActive,
      },
    });
  }

  async deleteSchedule(scheduleId: string, userId: string) {
    const schedule = await this.prisma.schedule.findUnique({
      where: { id: scheduleId },
      select: { childId: true },
    });

    if (!schedule) {
      throw new NotFoundException("Schedule not found");
    }

    await this.validateChildAccess(schedule.childId, userId, true);

    await this.prisma.schedule.delete({
      where: { id: scheduleId },
    });

    return { success: true, message: "Schedule deleted" };
  }

  async getScheduleTemplates() {
    return [
      {
        id: "bedtime",
        name: "Bedtime",
        scheduleType: "BEDTIME",
        description: "Restrict non-essential apps during sleep hours",
        defaultStartTime: "21:00",
        defaultEndTime: "07:00",
        defaultDays: [1, 2, 3, 4, 5, 6, 7],
      },
      {
        id: "school",
        name: "School Time",
        scheduleType: "SCHOOL",
        description: "Allow only educational apps during school hours",
        defaultStartTime: "08:00",
        defaultEndTime: "15:00",
        defaultDays: [1, 2, 3, 4, 5],
      },
      {
        id: "homework",
        name: "Homework Time",
        scheduleType: "CUSTOM",
        description: "Focus time for homework and study",
        defaultStartTime: "16:00",
        defaultEndTime: "18:00",
        defaultDays: [1, 2, 3, 4, 5],
      },
      {
        id: "family_dinner",
        name: "Family Dinner",
        scheduleType: "CUSTOM",
        description: "Device-free family time",
        defaultStartTime: "19:00",
        defaultEndTime: "20:00",
        defaultDays: [1, 2, 3, 4, 5, 6, 7],
      },
    ];
  }

  private async validateChildAccess(
    childId: string,
    userId: string,
    requireModify = false,
  ) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true },
    });

    if (!child) {
      throw new NotFoundException("Child not found");
    }

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId: child.familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }

    if (requireModify && !["OWNER", "ADMIN"].includes(membership.role)) {
      const coParentPerm = await this.prisma.coParentPermission.findUnique({
        where: {
          familyId_childId_parentId: {
            familyId: child.familyId,
            childId,
            parentId: userId,
          },
        },
      });
      if (!coParentPerm?.modifyPolicies) {
        throw new ForbiddenException("Insufficient permissions");
      }
    }
  }
}
