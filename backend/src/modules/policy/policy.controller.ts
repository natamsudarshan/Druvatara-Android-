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
import { PolicyService } from "./policy.service";
import { CreatePolicyDto } from "./dto/create-policy.dto";
import { UpdatePolicyDto } from "./dto/update-policy.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Policies")
@Controller("families/:familyId/children/:childId/policies")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class PolicyController {
  constructor(private policyService: PolicyService) {}

  @Post()
  @ApiOperation({ summary: "Create a new policy version" })
  @ApiResponse({ status: 201, description: "Policy created" })
  async create(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
    @Body() createPolicyDto: CreatePolicyDto,
  ) {
    const policy = await this.policyService.create(
      familyId,
      childId,
      userId,
      createPolicyDto,
    );
    return { success: true, data: policy };
  }

  @Get("latest")
  @ApiOperation({ summary: "Get latest active policy" })
  @ApiResponse({ status: 200, description: "Latest policy" })
  async findLatest(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    const policy = await this.policyService.findLatest(
      familyId,
      childId,
      userId,
    );
    return { success: true, data: policy };
  }

  @Get(":version")
  @ApiOperation({ summary: "Get policy by version" })
  @ApiResponse({ status: 200, description: "Policy version" })
  async findByVersion(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
    @Param("version") version: number,
  ) {
    const policy = await this.policyService.findByVersion(
      familyId,
      childId,
      version,
      userId,
    );
    return { success: true, data: policy };
  }

  @Get()
  @ApiOperation({ summary: "List policy history" })
  @ApiResponse({ status: 200, description: "Policy history" })
  async findAll(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
  ) {
    const policies = await this.policyService.findAll(
      familyId,
      childId,
      userId,
    );
    return { success: true, data: policies };
  }

  @Patch()
  @ApiOperation({ summary: "Update policy (creates new version)" })
  @ApiResponse({ status: 200, description: "Policy updated" })
  async update(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Param("childId") childId: string,
    @Body() updatePolicyDto: UpdatePolicyDto,
  ) {
    const policy = await this.policyService.update(
      familyId,
      childId,
      userId,
      updatePolicyDto,
    );
    return { success: true, data: policy };
  }

  @Post(":deviceId/acknowledge")
  @ApiOperation({ summary: "Acknowledge policy sync (device auth)" })
  async acknowledgePolicy(
    @Param("deviceId") deviceId: string,
    @Body() body: { policyVersion: number; success: boolean; error?: string },
  ) {
    const result = await this.policyService.acknowledgePolicy(
      deviceId,
      body.policyVersion,
      body.success,
      body.error,
    );
    return { success: true, data: result };
  }
}
