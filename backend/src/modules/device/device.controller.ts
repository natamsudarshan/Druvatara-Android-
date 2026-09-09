import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  Req,
  Query,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { DeviceService } from "./device.service";
import { RegisterDeviceDto } from "./dto/register-device.dto";
import { UpdateDeviceDto } from "./dto/update-device.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { DeviceAuthGuard } from "../../common/guards/jwt-auth.guard";

@ApiTags("Devices")
@Controller("devices")
export class DeviceController {
  constructor(private deviceService: DeviceService) {}

  @Post("register")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Register a child device (device auth)" })
  async register(
    @Req() req: any,
    @Body() registerDeviceDto: RegisterDeviceDto,
  ) {
    const device = req.user;
    const result = await this.deviceService.registerDevice(
      device.familyId,
      device.childId,
      registerDeviceDto,
    );
    return { success: true, data: result };
  }

  @Post("pairing/claim")
  @ApiOperation({ summary: "Claim pairing with code (device auth)" })
  async claimPairing(
    @Body() body: { pairingCode: string } & RegisterDeviceDto,
  ) {
    const { pairingCode, ...deviceInfo } = body;
    const result = await this.deviceService.registerDevice(
      "",
      null,
      deviceInfo,
      pairingCode,
    );
    return { success: true, data: result };
  }

  @Get()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "List all devices in family" })
  @ApiQuery({ name: "familyId", required: true })
  async findAll(
    @CurrentUser("sub") userId: string,
    @Query("familyId") familyId: string,
  ) {
    const devices = await this.deviceService.getFamilyDevices(familyId);
    return { success: true, data: devices };
  }

  @Get(":deviceId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get device details" })
  async findById(
    @CurrentUser("sub") userId: string,
    @Param("deviceId") deviceId: string,
  ) {
    const device = await this.deviceService.getDevice(deviceId);
    return { success: true, data: device };
  }

  @Patch(":deviceId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Update device info" })
  async update(
    @CurrentUser("sub") userId: string,
    @Param("deviceId") deviceId: string,
    @Body() updateDeviceDto: UpdateDeviceDto,
  ) {
    const device = await this.deviceService.updateDevice(
      deviceId,
      updateDeviceDto as any,
    );
    return { success: true, data: device };
  }

  @Delete(":deviceId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Remove device" })
  async remove(
    @CurrentUser("sub") userId: string,
    @Param("deviceId") deviceId: string,
  ) {
    await this.deviceService.deleteDevice(deviceId);
    return { success: true, message: "Device removed" };
  }

  @Post(":deviceId/health")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Update device health (device auth)" })
  async updateHealth(
    @Req() req: any,
    @Param("deviceId") deviceId: string,
    @Body() healthData: any,
  ) {
    const device = req.user;
    if (device.deviceId !== deviceId) {
      return { success: false, error: "Device ID mismatch" };
    }
    const health = await this.deviceService.getDeviceHealth(deviceId);
    return { success: true, data: health };
  }

  @Post(":deviceId/events")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Record device event (device auth)" })
  async recordEvent(
    @Req() req: any,
    @Param("deviceId") deviceId: string,
    @Body() event: any,
  ) {
    const device = req.user;
    if (device.deviceId !== deviceId) {
      return { success: false, error: "Device ID mismatch" };
    }
    return { success: true, message: "Event recorded" };
  }

  @Post(":deviceId/events/batch")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Batch record device events (device auth)" })
  async batchRecordEvents(
    @Req() req: any,
    @Param("deviceId") deviceId: string,
    @Body() events: any[],
  ) {
    const device = req.user;
    if (device.deviceId !== deviceId) {
      return { success: false, error: "Device ID mismatch" };
    }
    return { success: true, message: "Events recorded" };
  }

  @Get(":deviceId/commands")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Get pending commands (device auth)" })
  async getPendingCommands(
    @Req() req: any,
    @Param("deviceId") deviceId: string,
  ) {
    const device = req.user;
    if (device.deviceId !== deviceId) {
      return { success: false, error: "Device ID mismatch" };
    }
    return { success: true, data: [] };
  }

  @Post("commands/:commandId/acknowledge")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Acknowledge command (device auth)" })
  async acknowledgeCommand(
    @Req() req: any,
    @Param("commandId") commandId: string,
    @Body() body: { status: "APPLIED" | "FAILED"; error?: string },
  ) {
    const device = req.user;
    return { success: true, message: "Command acknowledged" };
  }
}
