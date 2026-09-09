import { Controller, Get, Post, Param, Query, UseGuards } from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { SafetyScoreService } from "./safety_score.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { SafetyScoreQueryDto } from "./dto/safety-score-query.dto";

@ApiTags("Safety Score")
@Controller("children/:childId/safety-score")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SafetyScoreController {
  constructor(private safetyScoreService: SafetyScoreService) {}

  @Get()
  @ApiOperation({ summary: "Get latest safety score" })
  async getLatestScore(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const score = await this.safetyScoreService.getLatestScore(childId, userId);
    return { success: true, data: score };
  }

  @Get("history")
  @ApiOperation({ summary: "Get safety score history" })
  async getHistory(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query() query: SafetyScoreQueryDto,
  ) {
    const history = await this.safetyScoreService.getScoreHistory(
      childId,
      userId,
      query.days,
    );
    return { success: true, data: history };
  }

  @Post("recalculate")
  @ApiOperation({ summary: "Trigger manual score recalculation" })
  async recalculate(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const result = await this.safetyScoreService.calculateScore(childId);
    return { success: true, data: result };
  }
}
