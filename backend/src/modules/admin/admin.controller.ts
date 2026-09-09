import {
  Controller,
  Get,
  Patch,
  Param,
  Body,
  UseGuards,
  Query,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { AdminService } from "./admin.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { AdminAuthGuard } from "../../common/guards/jwt-auth.guard";
import {
  AdminQueryDto,
  ToggleStatusDto,
  UpdateFeatureFlagAdminDto,
} from "./dto";

@ApiTags("Admin")
@Controller("admin")
@UseGuards(AdminAuthGuard)
@ApiBearerAuth()
export class AdminController {
  constructor(private adminService: AdminService) {}

  @Get("dashboard")
  @ApiOperation({ summary: "Get admin dashboard stats" })
  async getDashboard() {
    const stats = await this.adminService.getDashboardStats();
    return { success: true, data: stats };
  }

  @Get("users")
  @ApiOperation({ summary: "Get all users" })
  async getUsers(@Query() query: AdminQueryDto) {
    const users = await this.adminService.getUsers(
      query.page ?? 1,
      query.limit ?? 20,
    );
    return { success: true, data: users };
  }

  @Get("families")
  @ApiOperation({ summary: "Get all families" })
  async getFamilies(@Query() query: AdminQueryDto) {
    const families = await this.adminService.getFamilies(
      query.page ?? 1,
      query.limit ?? 20,
    );
    return { success: true, data: families };
  }

  @Get("devices")
  @ApiOperation({ summary: "Get all devices" })
  async getDevices(@Query() query: AdminQueryDto) {
    const devices = await this.adminService.getDevices(
      query.page ?? 1,
      query.limit ?? 20,
    );
    return { success: true, data: devices };
  }

  @Get("audit-logs")
  @ApiOperation({ summary: "Get audit logs" })
  async getAuditLogs(@Query() query: AdminQueryDto) {
    const logs = await this.adminService.getAuditLogs(
      query.page ?? 1,
      query.limit ?? 50,
    );
    return { success: true, data: logs };
  }

  @Patch("users/:userId/status")
  @ApiOperation({ summary: "Toggle user status" })
  async toggleUserStatus(
    @Param("userId") userId: string,
    @Body() toggleStatusDto: ToggleStatusDto,
  ) {
    const user = await this.adminService.toggleUserStatus(
      userId,
      toggleStatusDto.isActive,
    );
    return { success: true, data: user };
  }

  @Patch("families/:familyId/status")
  @ApiOperation({ summary: "Toggle family status" })
  async toggleFamilyStatus(
    @Param("familyId") familyId: string,
    @Body() toggleStatusDto: ToggleStatusDto,
  ) {
    const family = await this.adminService.toggleFamilyStatus(
      familyId,
      toggleStatusDto.isActive,
    );
    return { success: true, data: family };
  }

  @Get("feature-flags")
  @ApiOperation({ summary: "Get all feature flags" })
  async getFeatureFlags() {
    const flags = await this.adminService.getFeatureFlags();
    return { success: true, data: flags };
  }

  @Patch("feature-flags/:key")
  @ApiOperation({ summary: "Update feature flag" })
  async updateFeatureFlag(
    @Param("key") key: string,
    @Body() updateFeatureFlagAdminDto: UpdateFeatureFlagAdminDto,
  ) {
    const flag = await this.adminService.updateFeatureFlag(
      key,
      updateFeatureFlagAdminDto.enabled ?? false,
      updateFeatureFlagAdminDto.rollout,
    );
    return { success: true, data: flag };
  }
}
