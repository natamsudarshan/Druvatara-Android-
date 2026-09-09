import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  Delete,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { PairingService } from "./pairing.service";
import { CreatePairingDto } from "./dto/create-pairing.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Pairing")
@Controller("pairing")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PairingController {
  constructor(private pairingService: PairingService) {}

  @Post("sessions")
  @ApiOperation({ summary: "Create pairing session" })
  @ApiResponse({ status: 201, description: "Pairing session created" })
  async create(
    @CurrentUser("sub") userId: string,
    @Body() createPairingDto: CreatePairingDto,
  ) {
    const pairing = await this.pairingService.create(
      createPairingDto.familyId,
      createPairingDto.childId,
      userId,
      createPairingDto,
    );
    return { success: true, data: pairing };
  }

  @Get("sessions/:id")
  @ApiOperation({ summary: "Get pairing session status" })
  @ApiResponse({ status: 200, description: "Pairing session details" })
  async findById(@CurrentUser("sub") userId: string, @Param("id") id: string) {
    const pairing = await this.pairingService.findById(id, userId);
    return { success: true, data: pairing };
  }

  @Post("sessions/:id/confirm")
  @ApiOperation({ summary: "Confirm pairing" })
  @ApiResponse({ status: 200, description: "Pairing confirmed" })
  async confirm(@CurrentUser("sub") userId: string, @Param("id") id: string) {
    const result = await this.pairingService.confirmPairing(id, userId);
    return { success: true, data: result };
  }

  @Delete("sessions/:id")
  @ApiOperation({ summary: "Cancel pairing" })
  @ApiResponse({ status: 200, description: "Pairing cancelled" })
  async cancel(@CurrentUser("sub") userId: string, @Param("id") id: string) {
    const result = await this.pairingService.cancelPairing(id, userId);
    return { success: true, data: result };
  }

  @Post("device/claim")
  @ApiOperation({ summary: "Device claims pairing code" })
  async claimPairing(
    @Body() body: { pairingCode: string } & Record<string, any>,
  ) {
    const { pairingCode, ...deviceInfo } = body;
    const pairing = await this.pairingService.claimPairing(
      pairingCode,
      deviceInfo,
    );
    return { success: true, data: pairing };
  }
}
