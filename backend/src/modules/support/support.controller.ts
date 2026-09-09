import {
  Controller,
  Get,
  Post,
  Body,
  Param,
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
import { SupportService } from "./support.service";
import { CreateTicketDto } from "./dto/create-ticket.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Support")
@Controller("support")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SupportController {
  constructor(private supportService: SupportService) {}

  @Get("faqs")
  @ApiOperation({ summary: "Get frequently asked questions" })
  async getFAQs() {
    const faqs = await this.supportService.getFAQs();
    return { success: true, data: faqs };
  }

  @Get("troubleshooting")
  @ApiOperation({ summary: "Get troubleshooting guides" })
  async getTroubleshooting() {
    const guides = await this.supportService.getTroubleshootingGuides();
    return { success: true, data: guides };
  }

  @Post("tickets")
  @ApiOperation({ summary: "Create support ticket" })
  async createTicket(
    @CurrentUser("sub") userId: string,
    @Query("familyId") familyId: string,
    @Body() createTicketDto: CreateTicketDto,
  ) {
    const ticket = await this.supportService.createTicket(
      familyId,
      userId,
      createTicketDto,
    );
    return { success: true, data: ticket };
  }

  @Get("tickets")
  @ApiOperation({ summary: "Get support tickets" })
  async getTickets(
    @CurrentUser("sub") userId: string,
    @Query("familyId") familyId: string,
  ) {
    const tickets = await this.supportService.getTickets(familyId, userId);
    return { success: true, data: tickets };
  }
}
