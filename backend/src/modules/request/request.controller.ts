import {
  Controller,
  Get,
  Post,
  Patch,
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
import { RequestService } from "./request.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { RequestStatus } from "@prisma/client";
import {
  CreateRequestDto,
  DecideRequestDto,
  RequestQueryDto,
} from "./dto/request.dto";

@ApiTags("Child Requests")
@Controller("children/:childId/requests")
export class RequestController {
  constructor(private requestService: RequestService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get child requests" })
  async getRequests(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query() query: RequestQueryDto,
  ) {
    const requests = await this.requestService.getRequests(
      childId,
      userId,
      query.status,
    );
    return { success: true, data: requests };
  }

  @Get("pending-count")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get pending requests count" })
  async getPendingCount(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const count = await this.requestService.getPendingCount(childId, userId);
    return { success: true, data: { count } };
  }

  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Create request (child app)" })
  async createRequest(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() createRequestDto: CreateRequestDto,
  ) {
    const request = await this.requestService.createRequest(
      childId,
      userId,
      createRequestDto,
    );
    return { success: true, data: request };
  }

  @Patch(":requestId/decide")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Decide on request (parent)" })
  async decideRequest(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("requestId") requestId: string,
    @Body() decideRequestDto: DecideRequestDto,
  ) {
    const request = await this.requestService.decideRequest(
      requestId,
      userId,
      decideRequestDto,
    );
    return { success: true, data: request };
  }
}
