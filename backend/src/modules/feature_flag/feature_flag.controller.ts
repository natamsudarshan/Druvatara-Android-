import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { FeatureFlagService } from "./feature_flag.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { AdminAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { CreateFeatureFlagDto, UpdateFeatureFlagDto } from "./dto";

@ApiTags("Feature Flags")
@Controller("feature-flags")
export class FeatureFlagController {
  constructor(private featureFlagService: FeatureFlagService) {}

  @Get()
  @UseGuards(AdminAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get all feature flags" })
  async getAll() {
    const flags = await this.featureFlagService.getAllFlags();
    return { success: true, data: flags };
  }

  @Get(":key")
  @UseGuards(AdminAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get feature flag by key" })
  async getByKey(@Param("key") key: string) {
    const flag = await this.featureFlagService.getFlag(key);
    return { success: true, data: flag };
  }

  @Post()
  @UseGuards(AdminAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create feature flag" })
  async create(@Body() createFeatureFlagDto: CreateFeatureFlagDto) {
    const flag = await this.featureFlagService.createFlag(createFeatureFlagDto);
    return { success: true, data: flag };
  }

  @Patch(":key")
  @UseGuards(AdminAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update feature flag" })
  async update(
    @Param("key") key: string,
    @Body() updateFeatureFlagDto: UpdateFeatureFlagDto,
  ) {
    const flag = await this.featureFlagService.updateFlag(
      key,
      updateFeatureFlagDto,
    );
    return { success: true, data: flag };
  }

  @Delete(":key")
  @UseGuards(AdminAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Delete feature flag" })
  async delete(@Param("key") key: string) {
    await this.featureFlagService.deleteFlag(key);
    return { success: true, message: "Feature flag deleted" };
  }

  @Get("check/:key")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({
    summary: "Check if feature flag is enabled for current user",
  })
  async check(
    @Param("key") key: string,
    @CurrentUser("sub") userId: string,
    @CurrentUser("familyId") familyId: string,
  ) {
    const enabled = await this.featureFlagService.isEnabled(key, {
      userId,
      familyId,
    });
    return { success: true, data: { enabled } };
  }
}
