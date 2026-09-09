import {
  Controller,
  Post,
  Body,
  Param,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { PaymentService } from "./payment.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";

@ApiTags("Payments")
@Controller("payments")
export class PaymentController {
  constructor(private paymentService: PaymentService) {}

  @Post("stripe/webhook")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Stripe webhook handler" })
  async stripeWebhook(@Req() req: any) {
    // In production, verify signature
    // const sig = req.headers['stripe-signature'];
    // const event = this.stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    // await this.handleStripeEvent(event);
    return { received: true };
  }

  @Post("razorpay/webhook")
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: "Razorpay webhook handler" })
  async razorpayWebhook(@Req() req: any) {
    // In production, verify signature
    return { received: true };
  }
}
