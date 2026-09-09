import { Controller, Get, Post, Body, Param, UseGuards } from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { PrivacyService } from "./privacy.service";
import { CreatePrivacyRequestDto } from "./dto/create-privacy-request.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Privacy")
@Controller("privacy")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PrivacyController {
  constructor(private privacyService: PrivacyService) {}

  @Get("policy")
  @ApiOperation({ summary: "Get privacy policy" })
  async getPolicy() {
    const policy = await this.privacyService.getPrivacyPolicy();
    return { success: true, data: policy };
  }

  @Post("requests")
  @ApiOperation({ summary: "Create privacy request" })
  async createRequest(
    @CurrentUser("sub") userId: string,
    @Body() createPrivacyRequestDto: CreatePrivacyRequestDto,
  ) {
    const request = await this.privacyService.createRequest(
      userId,
      createPrivacyRequestDto,
    );
    return { success: true, data: request };
  }

  @Get("requests")
  @ApiOperation({ summary: "Get privacy requests" })
  async getRequests(@CurrentUser("sub") userId: string) {
    const requests = await this.privacyService.getRequests(userId);
    return { success: true, data: requests };
  }

  @Get("export")
  @ApiOperation({ summary: "Export all user data" })
  async exportData(@CurrentUser("sub") userId: string) {
    const data = await this.privacyService.exportUserData(userId);
    return { success: true, data };
  }

  @Post("delete-account")
  @ApiOperation({ summary: "Request account deletion" })
  async deleteAccount(@CurrentUser("sub") userId: string) {
    const result = await this.privacyService.deleteAccount(userId);
    return { success: true, data: result };
  }
}
