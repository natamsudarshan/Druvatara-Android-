import {
  Controller,
  Get,
  Post,
  Patch,
  Delete,
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
import { ChildService } from "./child.service";
import { CreateChildDto } from "./dto/create-child.dto";
import { UpdateChildDto } from "./dto/update-child.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Children")
@Controller("families/:familyId/children")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ChildController {
  constructor(private childService: ChildService) {}

  @Post()
  @ApiOperation({ summary: "Add a child profile" })
  @ApiResponse({ status: 201, description: "Child created successfully" })
  @ApiResponse({ status: 403, description: "Max children limit reached" })
  async create(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() createChildDto: CreateChildDto,
  ) {
    const child = await this.childService.create(
      familyId,
      userId,
      createChildDto,
    );
    return { success: true, data: child };
  }

  @Get()
  @ApiOperation({ summary: "List all children in family" })
  @ApiResponse({ status: 200, description: "List of children" })
  async findAll(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const children = await this.childService.findAll(familyId, userId);
    return { success: true, data: children };
  }

  @Get(":childId")
  @ApiOperation({ summary: "Get child details" })
  @ApiResponse({ status: 200, description: "Child details" })
  @ApiResponse({ status: 404, description: "Child not found" })
  async findById(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    const child = await this.childService.findById(childId, userId);
    return { success: true, data: child };
  }

  @Get(":childId/summary")
  @ApiOperation({ summary: "Get child dashboard summary" })
  @ApiResponse({
    status: 200,
    description: "Child summary with usage, alerts, devices",
  })
  async getSummary(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    const summary = await this.childService.getSummary(childId, userId);
    return { success: true, data: summary };
  }

  @Patch(":childId")
  @ApiOperation({ summary: "Update child profile" })
  @ApiResponse({ status: 200, description: "Child updated" })
  async update(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
    @Body() updateChildDto: UpdateChildDto,
  ) {
    const child = await this.childService.update(
      childId,
      userId,
      updateChildDto,
    );
    return { success: true, data: child };
  }

  @Delete(":childId")
  @ApiOperation({ summary: "Deactivate child profile" })
  @ApiResponse({ status: 200, description: "Child deactivated" })
  async delete(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    await this.childService.delete(childId, userId);
    return { success: true, message: "Child profile deactivated" };
  }
}
