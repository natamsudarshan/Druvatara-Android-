import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
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
import { GeofenceService } from "./geofence.service";
import { CreateGeofenceDto } from "./dto/create-geofence.dto";
import { UpdateGeofenceDto } from "./dto/update-geofence.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Geofences")
@Controller("children/:childId/geofences")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class GeofenceController {
  constructor(private geofenceService: GeofenceService) {}

  @Get()
  @ApiOperation({ summary: "Get all geofences for child" })
  async getGeofences(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
  ) {
    const geofences = await this.geofenceService.getGeofences(childId, userId);
    return { success: true, data: geofences };
  }

  @Post()
  @ApiOperation({ summary: "Create geofence" })
  async createGeofence(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() createGeofenceDto: CreateGeofenceDto,
  ) {
    const geofence = await this.geofenceService.createGeofence(
      childId,
      userId,
      createGeofenceDto,
    );
    return { success: true, data: geofence };
  }

  @Patch(":geofenceId")
  @ApiOperation({ summary: "Update geofence" })
  async updateGeofence(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("geofenceId") geofenceId: string,
    @Body() updateGeofenceDto: UpdateGeofenceDto,
  ) {
    const geofence = await this.geofenceService.updateGeofence(
      geofenceId,
      userId,
      updateGeofenceDto,
    );
    return { success: true, data: geofence };
  }

  @Delete(":geofenceId")
  @ApiOperation({ summary: "Delete geofence" })
  async deleteGeofence(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("geofenceId") geofenceId: string,
  ) {
    await this.geofenceService.deleteGeofence(geofenceId, userId);
    return { success: true, message: "Geofence deleted" };
  }

  @Get("events")
  @ApiOperation({ summary: "Get geofence events" })
  @ApiQuery({ name: "limit", required: false, type: Number })
  async getEvents(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query("limit") limit?: number,
  ) {
    const events = await this.geofenceService.getGeofenceEvents(
      childId,
      userId,
      limit || 50,
    );
    return { success: true, data: events };
  }
}
