import { Controller, Get, Post, Body, UseGuards, Query } from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { AnalyticsService } from "./analytics.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { AdminAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import {
  TrackEventDto,
  AnalyticsMetricsQueryDto,
  FunnelQueryDto,
  RetentionQueryDto,
} from "./dto/analytics.dto";

@ApiTags("Analytics")
@Controller("analytics")
@UseGuards(AdminAuthGuard)
@ApiBearerAuth()
export class AnalyticsController {
  constructor(private analyticsService: AnalyticsService) {}

  @Get("metrics")
  @ApiOperation({ summary: "Get analytics metrics" })
  async getMetrics(
    @CurrentUser("sub") userId: string,
    @Query() query: AnalyticsMetricsQueryDto,
  ) {
    const metrics = await this.analyticsService.getMetrics({
      ...query,
      startDate: query.startDate ? new Date(query.startDate) : undefined,
      endDate: query.endDate ? new Date(query.endDate) : undefined,
    });
    return { success: true, data: metrics };
  }

  @Get("funnel")
  @ApiOperation({ summary: "Get funnel analytics" })
  async getFunnel(
    @CurrentUser("sub") userId: string,
    @Query() query: FunnelQueryDto,
  ) {
    const funnel = await this.analyticsService.getFunnel(
      query.events.split(","),
      query.familyId,
      query.days,
    );
    return { success: true, data: funnel };
  }

  @Get("retention")
  @ApiOperation({ summary: "Get retention analytics" })
  async getRetention(
    @CurrentUser("sub") userId: string,
    @Query() query: RetentionQueryDto,
  ) {
    const retention = await this.analyticsService.getRetention(
      new Date(query.cohortDate),
      query.familyId,
    );
    return { success: true, data: retention };
  }

  @Post("track")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Track analytics event" })
  async trackEvent(
    @CurrentUser("sub") userId: string,
    @Body() trackEventDto: TrackEventDto,
  ) {
    await this.analyticsService.trackEvent({ ...trackEventDto, userId });
    return { success: true };
  }
}
