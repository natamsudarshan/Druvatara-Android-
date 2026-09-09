import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { FamilyService } from "./family.service";
import { CreateFamilyDto } from "./dto/create-family.dto";
import { UpdateFamilyDto } from "./dto/update-family.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Families")
@Controller("families")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class FamilyController {
  constructor(private familyService: FamilyService) {}

  @Post()
  @ApiOperation({ summary: "Create a new family" })
  @ApiResponse({ status: 201, description: "Family created successfully" })
  async create(
    @CurrentUser("sub") userId: string,
    @Body() createFamilyDto: CreateFamilyDto,
  ) {
    const family = await this.familyService.create(userId, createFamilyDto);
    return { success: true, data: family };
  }

  @Get(":familyId")
  @ApiOperation({ summary: "Get family details" })
  @ApiResponse({ status: 200, description: "Family details" })
  @ApiResponse({ status: 404, description: "Family not found" })
  @ApiResponse({ status: 403, description: "Not a family member" })
  async findById(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const family = await this.familyService.findById(familyId, userId);
    return { success: true, data: family };
  }

  @Get(":familyId/summary")
  @ApiOperation({ summary: "Get family dashboard summary" })
  @ApiResponse({ status: 200, description: "Family summary" })
  async getSummary(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const summary = await this.familyService.getSummary(familyId, userId);
    return { success: true, data: summary };
  }

  @Get(":familyId/entitlements")
  @ApiOperation({ summary: "Get family subscription entitlements" })
  @ApiResponse({ status: 200, description: "Subscription entitlements" })
  async getEntitlements(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const entitlements = await this.familyService.getEntitlements(
      familyId,
      userId,
    );
    return { success: true, data: entitlements };
  }

  @Patch(":familyId")
  @ApiOperation({ summary: "Update family settings" })
  @ApiResponse({ status: 200, description: "Family updated" })
  @ApiResponse({ status: 403, description: "Only owner can update" })
  async update(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() updateFamilyDto: UpdateFamilyDto,
  ) {
    const family = await this.familyService.update(
      familyId,
      userId,
      updateFamilyDto,
    );
    return { success: true, data: family };
  }

  @Delete(":familyId")
  @ApiOperation({ summary: "Request family deletion" })
  @ApiResponse({ status: 200, description: "Deletion requested" })
  @ApiResponse({ status: 403, description: "Only owner can delete" })
  async requestDeletion(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    await this.familyService.requestDeletion(familyId, userId);
    return { success: true, message: "Family deletion requested" };
  }
}
