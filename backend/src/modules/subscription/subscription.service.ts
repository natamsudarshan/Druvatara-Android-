import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import Stripe from "stripe";

@Injectable()
export class SubscriptionService {
  private stripe: Stripe;

  constructor(private prisma: PrismaService) {
    this.stripe = new Stripe(process.env.STRIPE_SECRET_KEY || "sk_test_dummy", {
      apiVersion: "2023-10-16",
    });
  }

  async getPlans() {
    return [
      {
        id: "FREE",
        name: "Free",
        price: 0,
        currency: "INR",
        interval: "month",
        features: {
          maxChildren: 1,
          maxDevices: 1,
          screenTime: true,
          webFiltering: false,
          location: false,
          geofencing: false,
          tara: false,
          reports: "basic",
        },
      },
      {
        id: "BASIC",
        name: "Basic",
        price: 12900, // ₹129/month in paise
        currency: "INR",
        interval: "month",
        features: {
          maxChildren: 2,
          maxDevices: 3,
          screenTime: true,
          webFiltering: true,
          location: true,
          geofencing: true,
          tara: true,
          reports: "standard",
        },
      },
      {
        id: "PREMIUM",
        name: "Premium",
        price: 29900, // ₹299/month in paise
        currency: "INR",
        interval: "month",
        features: {
          maxChildren: 4,
          maxDevices: 6,
          screenTime: true,
          webFiltering: true,
          location: true,
          geofencing: true,
          tara: true,
          reports: "detailed",
        },
      },
      {
        id: "FAMILY",
        name: "Family",
        price: 49900, // ₹499/month in paise
        currency: "INR",
        interval: "month",
        features: {
          maxChildren: 6,
          maxDevices: 10,
          screenTime: true,
          webFiltering: true,
          location: true,
          geofencing: true,
          tara: true,
          reports: "full",
        },
      },
    ];
  }

  async getCurrentSubscription(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    return this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
      orderBy: { createdAt: "desc" },
      include: { payments: { orderBy: { createdAt: "desc" }, take: 5 } },
    });
  }

  async createSubscription(
    familyId: string,
    userId: string,
    tier: string,
    paymentMethodId: string,
  ) {
    await this.validateFamilyAccess(familyId, userId, ["OWNER", "ADMIN"]);

    const existingSubscription = await this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
    });

    if (existingSubscription) {
      throw new ForbiddenException("Active subscription already exists");
    }

    const plans = await this.getPlans();
    const plan = plans.find((p) => p.id === tier);
    if (!plan) throw new ForbiddenException("Invalid plan");

    // Create Stripe customer
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    const customer = await this.stripe.customers.create({
      email: user?.email,
      payment_method: paymentMethodId,
      invoice_settings: { default_payment_method: paymentMethodId },
    });

    // Create Stripe subscription
    const product = await this.stripe.products.create({
      name: `Druvatara Guardian ${plan.name}`,
    });

    const price = await this.stripe.prices.create({
      currency: plan.currency.toLowerCase(),
      unit_amount: plan.price,
      recurring: {
        interval: plan.interval as Stripe.PriceCreateParams.Recurring.Interval,
      },
      product: product.id,
    });

    const stripeSubscription = await this.stripe.subscriptions.create({
      customer: customer.id,
      items: [{ price: price.id }],
      payment_behavior: "default_incomplete",
      payment_settings: { save_default_payment_method: "on_subscription" },
      expand: ["latest_invoice.payment_intent"],
    });

    const subscription = await this.prisma.subscription.create({
      data: {
        familyId,
        userId,
        tier: tier as any,
        status: "ACTIVE",
        provider: "STRIPE",
        providerSubId: stripeSubscription.id,
        providerCustId: customer.id,
        currentPeriodStart: new Date(
          stripeSubscription.current_period_start * 1000,
        ),
        currentPeriodEnd: new Date(
          stripeSubscription.current_period_end * 1000,
        ),
        price: plan.price,
        currency: plan.currency,
      },
    });

    return {
      subscription,
      clientSecret: (stripeSubscription.latest_invoice as any)?.payment_intent
        ?.client_secret,
    };
  }

  async cancelSubscription(
    familyId: string,
    userId: string,
    cancelAtPeriodEnd = true,
  ) {
    await this.validateFamilyAccess(familyId, userId, ["OWNER", "ADMIN"]);

    const subscription = await this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
    });

    if (!subscription) throw new NotFoundException("No active subscription");

    if (subscription.provider === "STRIPE" && subscription.providerSubId) {
      if (cancelAtPeriodEnd) {
        await this.stripe.subscriptions.update(subscription.providerSubId, {
          cancel_at_period_end: true,
        });
      } else {
        await this.stripe.subscriptions.cancel(subscription.providerSubId);
      }
    }

    return this.prisma.subscription.update({
      where: { id: subscription.id },
      data: {
        cancelAtPeriodEnd,
        ...(!cancelAtPeriodEnd
          ? { cancelledAt: new Date(), status: "CANCELLED" }
          : {}),
      },
    });
  }

  async getEntitlements(familyId: string) {
    const subscription = await this.prisma.subscription.findFirst({
      where: { familyId, status: { in: ["ACTIVE", "TRIALING"] } },
      orderBy: { createdAt: "desc" },
    });

    const plans = await this.getPlans();
    const plan = plans.find((p) => p.id === (subscription?.tier || "FREE"));

    return plan?.features || plans[0].features;
  }

  private async validateFamilyAccess(
    familyId: string,
    userId: string,
    allowedRoles: string[] = ["OWNER", "ADMIN", "MEMBER", "VIEWER"],
  ) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }

    if (!allowedRoles.includes(membership.role)) {
      throw new ForbiddenException("Insufficient permissions");
    }
  }
}
