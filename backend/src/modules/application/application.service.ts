import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateAppRuleDto } from "./dto/create-app-rule.dto";
import { UpdateAppRuleDto } from "./dto/update-app-rule.dto";

@Injectable()
export class ApplicationService {
  constructor(private prisma: PrismaService) {}

  async getInstalledApps(deviceId: string, userId: string) {
    await this.validateDeviceAccess(deviceId, userId);

    return this.prisma.appInventory.findMany({
      where: { deviceId, installState: "INSTALLED" },
      orderBy: { lastSeen: "desc" },
    });
  }

  async getAppRules(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.appRule.findMany({
      where: { childId },
      orderBy: { createdAt: "desc" },
    });
  }

  async createAppRule(
    childId: string,
    userId: string,
    createAppRuleDto: CreateAppRuleDto,
  ) {
    await this.validateChildAccess(childId, userId, true);

    return this.prisma.appRule.create({
      data: {
        childId,
        packageName: createAppRuleDto.packageName,
        ruleType: createAppRuleDto.ruleType,
        action: createAppRuleDto.action,
        config: createAppRuleDto.config || {},
      },
    });
  }

  async updateAppRule(
    ruleId: string,
    userId: string,
    updateAppRuleDto: UpdateAppRuleDto,
  ) {
    const rule = await this.prisma.appRule.findUnique({
      where: { id: ruleId },
      select: { childId: true },
    });

    if (!rule) {
      throw new NotFoundException("App rule not found");
    }

    await this.validateChildAccess(rule.childId, userId, true);

    return this.prisma.appRule.update({
      where: { id: ruleId },
      data: {
        ruleType: updateAppRuleDto.ruleType,
        action: updateAppRuleDto.action,
        config: updateAppRuleDto.config,
        isActive: updateAppRuleDto.isActive,
      },
    });
  }

  async deleteAppRule(ruleId: string, userId: string) {
    const rule = await this.prisma.appRule.findUnique({
      where: { id: ruleId },
      select: { childId: true },
    });

    if (!rule) {
      throw new NotFoundException("App rule not found");
    }

    await this.validateChildAccess(rule.childId, userId, true);

    await this.prisma.appRule.delete({
      where: { id: ruleId },
    });

    return { success: true, message: "App rule deleted" };
  }

  async getAppCategories() {
    return [
      { id: "SOCIAL", name: "Social Media", icon: "chat" },
      { id: "GAMES", name: "Games", icon: "games" },
      { id: "ENTERTAINMENT", name: "Entertainment", icon: "movie" },
      { id: "EDUCATION", name: "Education", icon: "school" },
      { id: "PRODUCTIVITY", name: "Productivity", icon: "work" },
      { id: "COMMUNICATION", name: "Communication", icon: "message" },
      { id: "SHOPPING", name: "Shopping", icon: "shopping_cart" },
      { id: "FINANCE", name: "Finance", icon: "attach_money" },
      { id: "HEALTH", name: "Health & Fitness", icon: "favorite" },
      { id: "NEWS", name: "News", icon: "article" },
      { id: "SYSTEM", name: "System", icon: "settings" },
      { id: "OTHER", name: "Other", icon: "apps" },
    ];
  }

  private async validateDeviceAccess(deviceId: string, userId: string) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      select: { familyId: true },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId: device.familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
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
