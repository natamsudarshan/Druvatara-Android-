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
import { CoParentService } from "./co_parent.service";
import { InviteCoParentDto } from "./dto/invite-co-parent.dto";
import { UpdateCoParentPermissionsDto } from "./dto/update-co-parent-permissions.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Co-Parents")
@Controller("families/:familyId/co-parents")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class CoParentController {
  constructor(private coParentService: CoParentService) {}

  @Get()
  @ApiOperation({ summary: "Get co-parents for family" })
  async getCoParents(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const coParents = await this.coParentService.getCoParents(familyId, userId);
    return { success: true, data: coParents };
  }

  @Post()
  @ApiOperation({ summary: "Invite co-parent" })
  async inviteCoParent(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() inviteCoParentDto: InviteCoParentDto,
  ) {
    const invitation = await this.coParentService.inviteCoParent(
      familyId,
      userId,
      inviteCoParentDto,
    );
    return { success: true, data: invitation };
  }

  @Patch(":permissionId")
  @ApiOperation({ summary: "Update co-parent permissions" })
  async updatePermissions(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("permissionId") permissionId: string,
    @Body() updatePermissionsDto: UpdateCoParentPermissionsDto,
  ) {
    const permission = await this.coParentService.updatePermissions(
      permissionId,
      userId,
      updatePermissionsDto,
    );
    return { success: true, data: permission };
  }

  @Delete(":permissionId")
  @ApiOperation({ summary: "Remove co-parent" })
  async removeCoParent(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("permissionId") permissionId: string,
  ) {
    await this.coParentService.removeCoParent(permissionId, userId);
    return { success: true, message: "Co-parent removed" };
  }
}
