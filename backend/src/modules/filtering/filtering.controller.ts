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
import { FilteringService } from "./filtering.service";
import { UpdateWebSafetyDto } from "./dto/update-web-safety.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Web Safety")
@Controller("children/:childId/web-safety")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FilteringController {
  constructor(private filteringService: FilteringService) {}

  @Get("config")
  @ApiOperation({ summary: "Get web safety configuration" })
  async getConfig(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const config = await this.filteringService.getWebSafetyConfig(
      childId,
      userId,
    );
    return { success: true, data: config };
  }

  @Patch("config")
  @ApiOperation({ summary: "Update web safety configuration" })
  async updateConfig(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() updateWebSafetyDto: UpdateWebSafetyDto,
  ) {
    const policy = await this.filteringService.updateWebSafetyConfig(
      childId,
      userId,
      updateWebSafetyDto,
    );
    return { success: true, data: policy };
  }

  @Get("categories")
  @ApiOperation({ summary: "Get web safety categories" })
  async getCategories() {
    const categories = await this.filteringService.getWebCategories();
    return { success: true, data: categories };
  }

  @Get("blocked-attempts")
  @ApiOperation({ summary: "Get blocked website attempts" })
  @ApiQuery({ name: "limit", required: false, type: Number })
  async getBlockedAttempts(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query("limit") limit?: number,
  ) {
    const attempts = await this.filteringService.getBlockedAttempts(
      childId,
      userId,
      limit || 50,
    );
    return { success: true, data: attempts };
  }
}
