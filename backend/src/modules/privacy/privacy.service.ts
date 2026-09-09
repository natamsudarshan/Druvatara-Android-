import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreatePrivacyRequestDto } from "./dto/create-privacy-request.dto";

@Injectable()
export class PrivacyService {
  constructor(private prisma: PrismaService) {}

  async createRequest(
    userId: string,
    createPrivacyRequestDto: CreatePrivacyRequestDto,
  ) {
    return this.prisma.privacyRequest.create({
      data: {
        userId,
        type: createPrivacyRequestDto.type,
        description: createPrivacyRequestDto.description,
        childId: createPrivacyRequestDto.childId,
        status: "PENDING",
      },
    });
  }

  async getRequests(userId: string) {
    return this.prisma.privacyRequest.findMany({
      where: { userId },
      orderBy: { requestedAt: "desc" },
    });
  }

  async exportUserData(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: {
        familyMembers: {
          include: {
            family: {
              include: {
                children: {
                  include: {
                    devices: true,
                    policies: {
                      where: { isActive: true },
                      orderBy: { version: "desc" },
                      take: 1,
                    },
                    usageSummaries: { orderBy: { date: "desc" }, take: 30 },
                    screenTimeEvents: {
                      orderBy: { triggeredAt: "desc" },
                      take: 50,
                    },
                    alerts: { orderBy: { createdAt: "desc" }, take: 50 },
                    requests: { orderBy: { createdAt: "desc" }, take: 50 },
                    locations: { orderBy: { capturedAt: "desc" }, take: 100 },
                    geofences: {
                      include: {
                        events: { orderBy: { triggeredAt: "desc" }, take: 10 },
                      },
                    },
                    safetyScores: {
                      orderBy: { calculatedAt: "desc" },
                      take: 30,
                    },
                  },
                },
              },
            },
          },
        },
        sessions: true,
        privacyRequests: true,
      },
    });

    if (!user) throw new NotFoundException("User not found");

    // Remove sensitive fields
    const { passwordHash, ...safeUser } = user;

    return safeUser;
  }

  async deleteAccount(userId: string) {
    // Soft delete - anonymize data
    await this.prisma.user.update({
      where: { id: userId },
      data: {
        email: `deleted_${userId}@druvatara.com`,
        name: "Deleted User",
        passwordHash: "",
        isActive: false,
        deletedAt: new Date(),
      },
    });

    // Anonymize related data
    await this.prisma.familyMember.updateMany({
      where: { userId },
      data: { isActive: false },
    });

    await this.prisma.session.updateMany({
      where: { userId },
      data: { revokedAt: new Date() },
    });

    return { success: true, message: "Account deletion initiated" };
  }

  async getPrivacyPolicy() {
    return {
      version: "1.0",
      lastUpdated: "2026-08-01",
      sections: [
        {
          title: "Data We Collect",
          content:
            "We collect minimal data necessary for child safety features...",
        },
        {
          title: "How We Use Your Data",
          content: "Data is used solely for safety features and never sold...",
        },
        {
          title: "Data Sharing",
          content: "We do not share child data with third parties...",
        },
        {
          title: "Your Rights",
          content: "You can access, export, or delete your data at any time...",
        },
        {
          title: "Data Retention",
          content: "We retain data only as long as necessary...",
        },
        { title: "Children's Privacy", content: "COPPA/GDPR compliant..." },
      ],
    };
  }
}
