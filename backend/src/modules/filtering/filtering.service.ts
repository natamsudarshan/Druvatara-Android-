import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { UpdateWebSafetyDto } from "./dto/update-web-safety.dto";

@Injectable()
export class FilteringService {
  constructor(private prisma: PrismaService) {}

  async getWebSafetyConfig(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const policy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
      select: { webSafety: true },
    });

    return (
      policy?.webSafety || {
        mode: "MODERATE",
        safeSearch: true,
        categories: [],
        allowlist: [],
        blocklist: [],
      }
    );
  }

  async updateWebSafetyConfig(
    childId: string,
    userId: string,
    updateWebSafetyDto: UpdateWebSafetyDto,
  ) {
    await this.validateChildAccess(childId, userId, true);

    const latestPolicy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
    });

    if (!latestPolicy) {
      throw new NotFoundException("No active policy found");
    }

    const newVersion = latestPolicy.version + 1;

    return this.prisma.policy.create({
      data: {
        familyId: latestPolicy.familyId,
        childId,
        version: newVersion,
        screenTime: latestPolicy.screenTime as any,
        applications: latestPolicy.applications as any,
        schedules: latestPolicy.schedules as any,
        webSafety: updateWebSafetyDto as any,
        location: latestPolicy.location as any,
        safeZones: latestPolicy.safeZones as any,
        essentialApps: latestPolicy.essentialApps as any,
        temporaryOverrides: latestPolicy.temporaryOverrides as any,
      },
    });
  }

  async getWebCategories() {
    return [
      {
        id: "ADULT",
        name: "Adult Content",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN"],
      },
      {
        id: "GAMBLING",
        name: "Gambling",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "VIOLENCE",
        name: "Violence",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD"],
      },
      {
        id: "DRUGS",
        name: "Drugs",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN"],
      },
      {
        id: "WEAPONS",
        name: "Weapons",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD"],
      },
      {
        id: "HATE",
        name: "Hate/Extremism",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN"],
      },
      {
        id: "SELF_HARM",
        name: "Self-Harm",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "MALWARE",
        name: "Malware",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "PHISHING",
        name: "Phishing",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "FRAUD",
        name: "Fraud",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "UNSAFE_DOWNLOADS",
        name: "Unsafe Downloads",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
      {
        id: "ANONYMOUS",
        name: "Anonymous Communication",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN"],
      },
      {
        id: "BYPASS",
        name: "Proxy/VPN Bypass",
        defaultAction: "BLOCK",
        ageGroups: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
      },
    ];
  }

  async getBlockedAttempts(childId: string, userId: string, limit = 50) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.deviceEvent.findMany({
      where: {
        childId,
        eventType: "WEB_CATEGORY_BLOCKED",
      },
      orderBy: { capturedAt: "desc" },
      take: limit,
    });
  }

  private async validateChildAccess(
    childId: string,
    userId: string,
    requireModify = false,
  ) {
    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true },
    });

    if (!child) {
      throw new NotFoundException("Child not found");
    }

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId: child.familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }

    if (requireModify && !["OWNER", "ADMIN"].includes(membership.role)) {
      const coParentPerm = await this.prisma.coParentPermission.findUnique({
        where: {
          familyId_childId_parentId: {
            familyId: child.familyId,
            childId,
            parentId: userId,
          },
        },
      });
      if (!coParentPerm?.modifyPolicies) {
        throw new ForbiddenException("Insufficient permissions");
      }
    }
  }
}
