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
import { NotificationService } from "./notification.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { NotificationQueryDto } from "./dto/notification-query.dto";

@ApiTags("Notifications")
@Controller("families/:familyId/notifications")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class NotificationController {
  constructor(private notificationService: NotificationService) {}

  @Get()
  @ApiOperation({ summary: "Get notifications" })
  async getNotifications(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Query() query: NotificationQueryDto,
  ) {
    const notifications = await this.notificationService.getNotifications(
      familyId,
      userId,
      query.status,
      query.limit,
    );
    return { success: true, data: notifications };
  }

  @Get("unread-count")
  @ApiOperation({ summary: "Get unread notification count" })
  async getUnreadCount(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const count = await this.notificationService.getUnreadCount(
      familyId,
      userId,
    );
    return { success: true, data: { count } };
  }

  @Patch(":notificationId/read")
  @ApiOperation({ summary: "Mark notification as read" })
  async markAsRead(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("notificationId") notificationId: string,
  ) {
    const notification = await this.notificationService.markAsRead(
      notificationId,
      userId,
    );
    return { success: true, data: notification };
  }

  @Patch("read-all")
  @ApiOperation({ summary: "Mark all notifications as read" })
  async markAllAsRead(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    await this.notificationService.markAllAsRead(familyId, userId);
    return { success: true, message: "All notifications marked as read" };
  }
}
