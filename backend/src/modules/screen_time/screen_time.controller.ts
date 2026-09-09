import {
  Controller,
  Get,
  Patch,
  Param,
  Query,
  UseGuards,
  Body,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { ScreenTimeService } from "./screen_time.service";
import { UpdateScreenTimeDto } from "./dto/update-screen-time.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Screen Time")
@Controller("children/:childId/screen-time")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ScreenTimeController {
  constructor(private screenTimeService: ScreenTimeService) {}

  @Get("config")
  @ApiOperation({ summary: "Get screen time configuration" })
  async getConfig(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const config = await this.screenTimeService.getScreenTimeConfig(
      childId,
      userId,
    );
    return { success: true, data: config };
  }

  @Patch("config")
  @ApiOperation({ summary: "Update screen time configuration" })
  async updateConfig(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() updateScreenTimeDto: UpdateScreenTimeDto,
  ) {
    const policy = await this.screenTimeService.updateScreenTimeConfig(
      childId,
      userId,
      updateScreenTimeDto,
    );
    return { success: true, data: policy };
  }

  @Get("today")
  @ApiOperation({ summary: "Get today usage" })
  async getTodayUsage(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const usage = await this.screenTimeService.getTodayUsage(childId, userId);
    return { success: true, data: usage };
  }

  @Get("weekly")
  @ApiOperation({ summary: "Get weekly usage" })
  async getWeeklyUsage(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const usage = await this.screenTimeService.getWeeklyUsage(childId, userId);
    return { success: true, data: usage };
  }

  @Get("events")
  @ApiOperation({ summary: "Get screen time events" })
  @ApiQuery({ name: "limit", required: false, type: Number })
  async getEvents(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query("limit") limit?: number,
  ) {
    const events = await this.screenTimeService.getScreenTimeEvents(
      childId,
      userId,
      limit || 50,
    );
    return { success: true, data: events };
  }
}
