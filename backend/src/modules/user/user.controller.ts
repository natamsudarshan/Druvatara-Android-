import {
  Controller,
  Get,
  Post,
  Patch,
  Body,
  UseGuards,
  Delete,
  Param,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { UserService } from "./user.service";
import { UpdateUserDto } from "./dto/update-user.dto";
import { UpdatePreferencesDto } from "./dto/update-preferences.dto";
import { ChangePasswordDto } from "./dto/change-password.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("User")
@Controller("users/me")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserController {
  constructor(private userService: UserService) {}

  @Get()
  @ApiOperation({ summary: "Get current user profile" })
  async findMe(@CurrentUser("sub") userId: string) {
    const user = await this.userService.findMe(userId);
    return { success: true, data: user };
  }

  @Patch()
  @ApiOperation({ summary: "Update user profile" })
  async updateMe(
    @CurrentUser("sub") userId: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    const user = await this.userService.updateMe(userId, updateUserDto);
    return { success: true, data: user };
  }

  @Patch("preferences")
  @ApiOperation({ summary: "Update user preferences" })
  async updatePreferences(
    @CurrentUser("sub") userId: string,
    @Body() updatePreferencesDto: UpdatePreferencesDto,
  ) {
    const preferences = await this.userService.updatePreferences(
      userId,
      updatePreferencesDto,
    );
    return { success: true, data: preferences };
  }

  @Get("security")
  @ApiOperation({ summary: "Get security status" })
  async getSecurityStatus(@CurrentUser("sub") userId: string) {
    const status = await this.userService.getSecurityStatus(userId);
    return { success: true, data: status };
  }

  @Post("password")
  @ApiOperation({ summary: "Change password" })
  async changePassword(
    @CurrentUser("sub") userId: string,
    @Body() changePasswordDto: ChangePasswordDto,
  ) {
    const result = await this.userService.changePassword(
      userId,
      changePasswordDto.currentPassword,
      changePasswordDto.newPassword,
    );
    return { success: true, data: result };
  }

  @Get("sessions")
  @ApiOperation({ summary: "List active sessions" })
  async getSessions(@CurrentUser("sub") userId: string) {
    const sessions = await this.userService.getSessions(userId);
    return { success: true, data: sessions };
  }

  @Delete("sessions/:sessionId")
  @ApiOperation({ summary: "Revoke a session" })
  async revokeSession(
    @CurrentUser("sub") userId: string,
    @Param("sessionId") sessionId: string,
  ) {
    await this.userService.revokeSession(userId, sessionId);
    return { success: true, message: "Session revoked" };
  }
}
