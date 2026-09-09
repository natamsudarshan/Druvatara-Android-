import {
  Controller,
  Get,
  Post,
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
import { ThreatIntelService } from "./threat_intel.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { CheckUrlDto } from "./dto/check-url.dto";

@ApiTags("Threat Intelligence")
@Controller("threat-intel")
export class ThreatIntelController {
  constructor(private threatIntelService: ThreatIntelService) {}

  @Post("check-url")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Check URL for threats" })
  async checkUrl(
    @CurrentUser("sub") userId: string,
    @Body() checkUrlDto: CheckUrlDto,
  ) {
    const result = await this.threatIntelService.checkUrl(checkUrlDto.url);
    return { success: true, data: result };
  }

  @Get("children/:childId/stats")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get threat statistics for child" })
  async getStats(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const stats = await this.threatIntelService.getThreatStats(childId, userId);
    return { success: true, data: stats };
  }
}
