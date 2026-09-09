import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { ScheduleService } from "./schedule.service";
import { CreateScheduleDto } from "./dto/create-schedule.dto";
import { UpdateScheduleDto } from "./dto/update-schedule.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Schedules")
@Controller("children/:childId/schedules")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ScheduleController {
  constructor(private scheduleService: ScheduleService) {}

  @Get()
  @ApiOperation({ summary: "Get all schedules for child" })
  async getSchedules(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const schedules = await this.scheduleService.getSchedules(childId, userId);
    return { success: true, data: schedules };
  }

  @Get("templates")
  @ApiOperation({ summary: "Get schedule templates" })
  async getTemplates() {
    const templates = await this.scheduleService.getScheduleTemplates();
    return { success: true, data: templates };
  }

  @Post()
  @ApiOperation({ summary: "Create schedule" })
  async createSchedule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() createScheduleDto: CreateScheduleDto,
  ) {
    const schedule = await this.scheduleService.createSchedule(
      childId,
      userId,
      createScheduleDto,
    );
    return { success: true, data: schedule };
  }

  @Patch(":scheduleId")
  @ApiOperation({ summary: "Update schedule" })
  async updateSchedule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("scheduleId") scheduleId: string,
    @Body() updateScheduleDto: UpdateScheduleDto,
  ) {
    const schedule = await this.scheduleService.updateSchedule(
      scheduleId,
      userId,
      updateScheduleDto,
    );
    return { success: true, data: schedule };
  }

  @Delete(":scheduleId")
  @ApiOperation({ summary: "Delete schedule" })
  async deleteSchedule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("scheduleId") scheduleId: string,
  ) {
    await this.scheduleService.deleteSchedule(scheduleId, userId);
    return { success: true, message: "Schedule deleted" };
  }
}
