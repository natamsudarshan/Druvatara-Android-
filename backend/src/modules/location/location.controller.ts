import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { LocationService } from "./location.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { DeviceAuthGuard } from "../../common/guards/jwt-auth.guard";
import { UpdateLocationDto } from "./dto/update-location.dto";

@ApiTags("Location")
@Controller("location")
export class LocationController {
  constructor(private locationService: LocationService) {}

  @Post("devices/:deviceId/update")
  @UseGuards(DeviceAuthGuard)
  @ApiOperation({ summary: "Update device location (device auth)" })
  async updateLocation(
    @Req() req: any,
    @Param("deviceId") deviceId: string,
    @Body() updateLocationDto: UpdateLocationDto,
  ) {
    const device = req.user;
    if (device.deviceId !== deviceId) {
      return { success: false, error: "Device ID mismatch" };
    }
    const location = await this.locationService.updateLocation(
      deviceId,
      updateLocationDto.latitude,
      updateLocationDto.longitude,
      updateLocationDto.accuracy,
    );
    return { success: true, data: location };
  }

  @Get("children/:childId/current")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get current location for child" })
  async getCurrentLocation(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const location = await this.locationService.getCurrentLocation(
      childId,
      userId,
    );
    return { success: true, data: location };
  }

  @Get("children/:childId/history")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Get location history for child" })
  @ApiQuery({ name: "hours", required: false, type: Number })
  async getLocationHistory(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query("hours") hours?: number,
  ) {
    const history = await this.locationService.getLocationHistory(
      childId,
      userId,
      hours || 24,
    );
    return { success: true, data: history };
  }
}
