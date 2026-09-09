import { Test, TestingModule } from "@nestjs/testing";
import { NotFoundException, ForbiddenException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { SubscriptionService } from "./subscription.service";

describe("SubscriptionService", () => {
  let service: SubscriptionService;
  let prisma: PrismaService;

  const mockPrismaService = {
    subscription: {
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
    user: {
      findUnique: jest.fn(),
    },
    familyMember: {
      findUnique: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        SubscriptionService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<SubscriptionService>(SubscriptionService);
    prisma = module.get<PrismaService>(PrismaService);

    jest.clearAllMocks();
  });

  const mockMembership = {
    familyId: "family-1",
    userId: "user-1",
    isActive: true,
    role: "OWNER",
  };

  beforeEach(() => {
    mockPrismaService.familyMember.findUnique.mockResolvedValue(mockMembership);
  });

  describe("getPlans", () => {
    it("should return all subscription plans", async () => {
      const plans = await service.getPlans();

      expect(plans).toHaveLength(4);
      expect(plans[0]).toEqual(
        expect.objectContaining({ id: "FREE", price: 0 }),
      );
      expect(plans[1]).toEqual(
        expect.objectContaining({ id: "BASIC", price: 12900 }),
      );
      expect(plans[2]).toEqual(
        expect.objectContaining({ id: "PREMIUM", price: 29900 }),
      );
      expect(plans[3]).toEqual(
        expect.objectContaining({ id: "FAMILY", price: 49900 }),
      );
    });

    it("should include features for each plan", async () => {
      const plans = await service.getPlans();

      plans.forEach((plan) => {
        expect(plan.features).toBeDefined();
        expect(plan.features.maxChildren).toBeGreaterThan(0);
        expect(plan.features.maxDevices).toBeGreaterThan(0);
      });
    });
  });

  describe("getCurrentSubscription", () => {
    it("should return active subscription for family", async () => {
      const mockSubscription = {
        id: "sub-1",
        familyId: "family-1",
        tier: "PREMIUM",
        status: "ACTIVE",
        payments: [],
      };

      mockPrismaService.subscription.findFirst.mockResolvedValue(
        mockSubscription,
      );

      const result = await service.getCurrentSubscription("family-1", "user-1");

      expect(mockPrismaService.subscription.findFirst).toHaveBeenCalledWith({
        where: { familyId: "family-1", status: { in: ["ACTIVE", "TRIALING"] } },
        orderBy: { createdAt: "desc" },
        include: { payments: { orderBy: { createdAt: "desc" }, take: 5 } },
      });
      expect(result).toEqual(mockSubscription);
    });

    it("should return null if no active subscription", async () => {
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);

      const result = await service.getCurrentSubscription("family-1", "user-1");

      expect(result).toBeNull();
    });
  });

  describe("createSubscription", () => {
    it("should throw ForbiddenException if active subscription exists", async () => {
      mockPrismaService.subscription.findFirst.mockResolvedValue({
        id: "existing-sub",
        familyId: "family-1",
        status: "ACTIVE",
      });

      await expect(
        service.createSubscription("family-1", "user-1", "BASIC", "pm_test"),
      ).rejects.toThrow(ForbiddenException);
    });

    it("should throw ForbiddenException for invalid plan", async () => {
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);

      await expect(
        service.createSubscription("family-1", "user-1", "INVALID", "pm_test"),
      ).rejects.toThrow(ForbiddenException);
    });

    it("should require OWNER or ADMIN role", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "MEMBER",
      });
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);

      await expect(
        service.createSubscription("family-1", "user-1", "BASIC", "pm_test"),
      ).rejects.toThrow(ForbiddenException);
    });
  });

  describe("cancelSubscription", () => {
    it("should cancel subscription at period end by default", async () => {
      const mockSubscription = {
        id: "sub-1",
        familyId: "family-1",
        provider: "STRIPE",
        providerSubId: "sub_stripe_1",
        status: "ACTIVE",
      };

      mockPrismaService.subscription.findFirst.mockResolvedValue(
        mockSubscription,
      );
      mockPrismaService.subscription.update.mockResolvedValue({
        ...mockSubscription,
        cancelAtPeriodEnd: true,
      });

      // Mock Stripe
      const stripeUpdate = jest.fn().mockResolvedValue({});
      (service as any).stripe = {
        subscriptions: { update: stripeUpdate },
      };

      const result = await service.cancelSubscription(
        "family-1",
        "user-1",
        true,
      );

      expect(stripeUpdate).toHaveBeenCalledWith("sub_stripe_1", {
        cancel_at_period_end: true,
      });
      expect(result.cancelAtPeriodEnd).toBe(true);
    });

    it("should cancel subscription immediately if cancelAtPeriodEnd is false", async () => {
      const mockSubscription = {
        id: "sub-1",
        familyId: "family-1",
        provider: "STRIPE",
        providerSubId: "sub_stripe_1",
        status: "ACTIVE",
      };

      mockPrismaService.subscription.findFirst.mockResolvedValue(
        mockSubscription,
      );
      mockPrismaService.subscription.update.mockResolvedValue({
        ...mockSubscription,
        cancelAtPeriodEnd: false,
        cancelledAt: new Date(),
        status: "CANCELLED",
      });

      const stripeCancel = jest.fn().mockResolvedValue({});
      (service as any).stripe = {
        subscriptions: { cancel: stripeCancel },
      };

      const result = await service.cancelSubscription(
        "family-1",
        "user-1",
        false,
      );

      expect(stripeCancel).toHaveBeenCalledWith("sub_stripe_1");
      expect(result.cancelAtPeriodEnd).toBe(false);
      expect(result.cancelledAt).toBeDefined();
      expect(result.status).toBe("CANCELLED");
    });

    it("should throw NotFoundException if no active subscription", async () => {
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);

      await expect(
        service.cancelSubscription("family-1", "user-1"),
      ).rejects.toThrow(NotFoundException);
    });
  });

  describe("getEntitlements", () => {
    it("should return features for active subscription tier", async () => {
      const mockSubscription = { tier: "PREMIUM", status: "ACTIVE" };

      mockPrismaService.subscription.findFirst.mockResolvedValue(
        mockSubscription,
      );

      const entitlements = await service.getEntitlements("family-1");

      expect(entitlements.maxChildren).toBe(4);
      expect(entitlements.maxDevices).toBe(6);
      expect(entitlements.tara).toBe(true);
    });

    it("should return FREE plan features if no subscription", async () => {
      mockPrismaService.subscription.findFirst.mockResolvedValue(null);

      const entitlements = await service.getEntitlements("family-1");

      expect(entitlements.maxChildren).toBe(1);
      expect(entitlements.maxDevices).toBe(1);
      expect(entitlements.tara).toBe(false);
    });
  });

  describe("validateFamilyAccess", () => {
    it("should throw ForbiddenException if not family member", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue(null);

      await expect(
        service.getCurrentSubscription("family-1", "user-1"),
      ).rejects.toThrow(ForbiddenException);
    });

    it("should throw ForbiddenException if role not allowed", async () => {
      mockPrismaService.familyMember.findUnique.mockResolvedValue({
        ...mockMembership,
        role: "VIEWER",
      });

      await expect(
        service.createSubscription("family-1", "user-1", "BASIC", "pm_test"),
      ).rejects.toThrow(ForbiddenException);
    });
  });
});
