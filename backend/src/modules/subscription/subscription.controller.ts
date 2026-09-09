import {
  Controller,
  Get,
  Post,
  Patch,
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
import { SubscriptionService } from "./subscription.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Subscriptions")
@Controller("subscriptions")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class SubscriptionController {
  constructor(private subscriptionService: SubscriptionService) {}

  @Get("plans")
  @ApiOperation({ summary: "Get available subscription plans" })
  async getPlans() {
    const plans = await this.subscriptionService.getPlans();
    return { success: true, data: plans };
  }

  @Get("current")
  @ApiOperation({ summary: "Get current subscription" })
  async getCurrent(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const subscription = await this.subscriptionService.getCurrentSubscription(
      familyId,
      userId,
    );
    return { success: true, data: subscription };
  }

  @Get("entitlements")
  @ApiOperation({ summary: "Get subscription entitlements" })
  async getEntitlements(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
  ) {
    const entitlements =
      await this.subscriptionService.getEntitlements(familyId);
    return { success: true, data: entitlements };
  }

  @Post()
  @ApiOperation({ summary: "Create subscription" })
  async createSubscription(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() body: { tier: string; paymentMethodId: string },
  ) {
    const result = await this.subscriptionService.createSubscription(
      familyId,
      userId,
      body.tier,
      body.paymentMethodId,
    );
    return { success: true, data: result };
  }

  @Patch("cancel")
  @ApiOperation({ summary: "Cancel subscription" })
  async cancelSubscription(
    @CurrentUser("sub") userId: string,
    @Param("familyId") familyId: string,
    @Body() body: { cancelAtPeriodEnd?: boolean },
  ) {
    const subscription = await this.subscriptionService.cancelSubscription(
      familyId,
      userId,
      body.cancelAtPeriodEnd ?? true,
    );
    return { success: true, data: subscription };
  }
}
