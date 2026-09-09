import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { UsageService } from "./usage.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { DeviceAuthGuard } from "../../common/guards/jwt-auth.guard";
import { RecordUsageDto, UsageQueryDto } from "./dto";

@ApiTags("Usage")
@Controller("usage")
export class UsageController {
  constructor(private usageService: UsageService) {}

  @Post("record")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Record usage data (device auth)" })
  async recordUsage(@Req() req: any, @Body() recordUsageDto: RecordUsageDto) {
    const device = req.user;
    const result = await this.usageService.recordUsage(
      device.deviceId,
      recordUsageDto.usageData,
    );
    return { success: true, data: result };
  }

  @Get("children/:childId/today")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get today usage for child" })
  async getTodayUsage(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const usage = await this.usageService.getTodayUsage(childId, userId);
    return { success: true, data: usage };
  }

  @Get("children/:childId/weekly")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get weekly usage for child" })
  async getWeeklyUsage(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const usage = await this.usageService.getWeeklyUsage(childId, userId);
    return { success: true, data: usage };
  }

  @Get("children/:childId/apps/:packageName")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get app usage history" })
  @ApiQuery({ name: "days", required: false, type: Number })
  async getAppUsage(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("packageName") packageName: string,
    @Query("days") days?: number,
  ) {
    const usage = await this.usageService.getAppUsage(
      childId,
      packageName,
      userId,
      days || 30,
    );
    return { success: true, data: usage };
  }

  @Get("children/:childId/top-apps")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get top used apps" })
  async getTopApps(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query() query: UsageQueryDto,
  ) {
    const apps = await this.usageService.getTopApps(
      childId,
      userId,
      query.limit,
      query.days,
    );
    return { success: true, data: apps };
  }

  @Get("children/:childId/screen-time-events")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get screen time events" })
  @ApiQuery({ name: "limit", required: false, type: Number })
  async getScreenTimeEvents(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query("limit") limit?: number,
  ) {
    const events = await this.usageService.getScreenTimeEvents(
      childId,
      userId,
      limit || 50,
    );
    return { success: true, data: events };
  }
}
