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
import { ApplicationService } from "./application.service";
import { CreateAppRuleDto } from "./dto/create-app-rule.dto";
import { UpdateAppRuleDto } from "./dto/update-app-rule.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Application Rules")
@Controller("children/:childId/app-rules")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ApplicationController {
  constructor(private applicationService: ApplicationService) {}

  @Get("installed-apps")
  @ApiOperation({ summary: "Get installed apps for device" })
  @ApiQuery({ name: "deviceId", required: true })
  async getInstalledApps(
    @CurrentUser("sub") userId: string,
    @Query("deviceId") deviceId: string,
  ) {
    const apps = await this.applicationService.getInstalledApps(
      deviceId,
      userId,
    );
    return { success: true, data: apps };
  }

  @Get()
  @ApiOperation({ summary: "Get app rules for child" })
  async getAppRules(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const rules = await this.applicationService.getAppRules(childId, userId);
    return { success: true, data: rules };
  }

  @Post()
  @ApiOperation({ summary: "Create app rule" })
  async createAppRule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() createAppRuleDto: CreateAppRuleDto,
  ) {
    const rule = await this.applicationService.createAppRule(
      childId,
      userId,
      createAppRuleDto,
    );
    return { success: true, data: rule };
  }

  @Patch(":ruleId")
  @ApiOperation({ summary: "Update app rule" })
  async updateAppRule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("ruleId") ruleId: string,
    @Body() updateAppRuleDto: UpdateAppRuleDto,
  ) {
    const rule = await this.applicationService.updateAppRule(
      ruleId,
      userId,
      updateAppRuleDto,
    );
    return { success: true, data: rule };
  }

  @Delete(":ruleId")
  @ApiOperation({ summary: "Delete app rule" })
  async deleteAppRule(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("ruleId") ruleId: string,
  ) {
    await this.applicationService.deleteAppRule(ruleId, userId);
    return { success: true, message: "App rule deleted" };
  }

  @Get("categories")
  @ApiOperation({ summary: "Get app categories" })
  async getCategories() {
    const categories = await this.applicationService.getAppCategories();
    return { success: true, data: categories };
  }
}
