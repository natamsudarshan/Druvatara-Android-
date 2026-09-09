import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import {
  Prisma,
  Payment,
  PaymentStatus,
  PaymentProvider,
  Subscription,
  SubscriptionStatus,
} from "@prisma/client";

@Injectable()
export class PaymentService {
  constructor(private prisma: PrismaService) {}

  async createPayment(data: {
    subscriptionId: string;
    amount: number;
    currency: string;
    provider: PaymentProvider;
    providerId: string;
    providerData?: Prisma.InputJsonValue;
    description?: string;
  }) {
    return this.prisma.payment.create({
      data: {
        subscriptionId: data.subscriptionId,
        amount: data.amount,
        currency: data.currency,
        provider: data.provider,
        providerId: data.providerId,
        metadata: data.providerData as any,
        description: data.description,
        status: PaymentStatus.PENDING,
      },
    });
  }

  async updatePaymentStatus(
    providerId: string,
    status: PaymentStatus,
    providerData?: Prisma.InputJsonValue,
  ) {
    const payment = await this.prisma.payment.findUnique({
      where: { providerId },
    });

    if (!payment) {
      throw new NotFoundException("Payment not found");
    }

    const updated = await this.prisma.payment.update({
      where: { providerId },
      data: {
        status,
        ...(providerData && { metadata: providerData as any }),
        ...(status === PaymentStatus.COMPLETED && { paidAt: new Date() }),
        ...(status === PaymentStatus.FAILED && { paidAt: new Date() }),
        ...(status === PaymentStatus.REFUNDED && { paidAt: new Date() }),
      },
    });

    if (status === PaymentStatus.COMPLETED && payment.subscriptionId) {
      await this.prisma.subscription.update({
        where: { id: payment.subscriptionId },
        data: { status: SubscriptionStatus.ACTIVE },
      });
    }

    return updated;
  }

  async getPayments(filters: {
    subscriptionId?: string;
    status?: PaymentStatus;
    provider?: PaymentProvider;
    startDate?: Date;
    endDate?: Date;
    page?: number;
    limit?: number;
  }) {
    const where: any = {};

    if (filters.subscriptionId) where.subscriptionId = filters.subscriptionId;
    if (filters.status) where.status = filters.status;
    if (filters.provider) where.provider = filters.provider;
    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) where.createdAt.gte = filters.startDate;
      if (filters.endDate) where.createdAt.lte = filters.endDate;
    }

    const page = filters.page || 1;
    const limit = filters.limit || 20;

    const [payments, total] = await Promise.all([
      this.prisma.payment.findMany({
        where,
        orderBy: { createdAt: "desc" },
        skip: (page - 1) * limit,
        take: limit,
      }),
      this.prisma.payment.count({ where }),
    ]);

    return {
      payments,
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getPaymentById(id: string) {
    const payment = await this.prisma.payment.findUnique({ where: { id } });
    if (!payment) throw new NotFoundException("Payment not found");
    return payment;
  }

  async getSubscriptionPayments(subscriptionId: string, page = 1, limit = 20) {
    return this.getPayments({ subscriptionId, page, limit });
  }
}
