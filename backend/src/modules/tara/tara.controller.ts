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
import { TaraService } from "./tara.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("TARA AI")
@Controller("tara")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class TaraController {
  constructor(private taraService: TaraService) {}

  @Post("ask")
  @ApiOperation({ summary: "Ask TARA a question" })
  async askQuestion(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() body: { question: string; childId?: string },
  ) {
    const response = await this.taraService.askQuestion(
      familyId,
      userId,
      body.childId,
      body.question,
    );
    return { success: true, data: response };
  }

  @Get("history")
  @ApiOperation({ summary: "Get conversation history" })
  @ApiQuery({ name: "limit", required: false, type: Number })
  async getHistory(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Query("limit") limit?: number,
  ) {
    const history = await this.taraService.getConversationHistory(
      familyId,
      userId,
      limit || 20,
    );
    return { success: true, data: history };
  }

  @Post("explain-alert/:alertId")
  @ApiOperation({ summary: "Get TARA explanation for an alert" })
  async explainAlert(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("alertId") alertId: string,
  ) {
    const explanation = await this.taraService.explainAlert(
      familyId,
      userId,
      alertId,
    );
    return { success: true, data: explanation };
  }

  @Get("explain-score/:childId")
  @ApiOperation({ summary: "Get TARA explanation for safety score" })
  async explainScore(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    const explanation = await this.taraService.explainSafetyScore(
      familyId,
      userId,
      childId,
    );
    return { success: true, data: explanation };
  }
}
