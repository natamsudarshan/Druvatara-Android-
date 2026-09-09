import {
  Controller,
  Get,
  Patch,
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
import { AlertService } from "./alert.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { AlertSeverity, AlertStatus } from "@prisma/client";
import { AlertQueryDto } from "./dto/alert-query.dto";

@ApiTags("Alerts")
@Controller("families/:familyId/alerts")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AlertController {
  constructor(private alertService: AlertService) {}

  @Get()
  @ApiOperation({ summary: "List alerts with filters" })
  async getAlerts(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Query() query: AlertQueryDto,
  ) {
    const result = await this.alertService.getAlerts({ familyId, ...query });
    return { success: true, data: result };
  }

  @Get("unread-count")
  @ApiOperation({ summary: "Get unread alerts count" })
  async getUnreadCount(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const count = await this.alertService.getUnreadCount(familyId);
    return { success: true, data: { count } };
  }

  @Get(":alertId")
  @ApiOperation({ summary: "Get alert details" })
  async getAlertById(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("alertId") alertId: string,
  ) {
    const alert = await this.alertService.getAlertById(alertId);
    return { success: true, data: alert };
  }

  @Patch(":alertId/acknowledge")
  @ApiOperation({ summary: "Acknowledge alert" })
  async acknowledge(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("alertId") alertId: string,
  ) {
    const alert = await this.alertService.acknowledgeAlert(alertId, userId);
    return { success: true, data: alert };
  }

  @Patch(":alertId/resolve")
  @ApiOperation({ summary: "Resolve alert" })
  async resolve(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("alertId") alertId: string,
  ) {
    const alert = await this.alertService.resolveAlert(alertId, userId);
    return { success: true, data: alert };
  }

  @Patch(":alertId/dismiss")
  @ApiOperation({ summary: "Dismiss alert" })
  async dismiss(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("alertId") alertId: string,
  ) {
    const alert = await this.alertService.dismissAlert(alertId);
    return { success: true, data: alert };
  }
}
