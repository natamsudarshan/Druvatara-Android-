import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { InviteCoParentDto } from "./dto/invite-co-parent.dto";
import { UpdateCoParentPermissionsDto } from "./dto/update-co-parent-permissions.dto";
import * as crypto from "crypto";

@Injectable()
export class CoParentService {
  constructor(private prisma: PrismaService) {}

  async getCoParents(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    return this.prisma.coParentPermission.findMany({
      where: { familyId },
      include: {
        parent: {
          select: { id: true, name: true, email: true, avatarUrl: true },
        },
        child: { select: { id: true, displayName: true } },
      },
    });
  }

  async inviteCoParent(
    familyId: string,
    userId: string,
    inviteCoParentDto: InviteCoParentDto,
  ) {
    await this.validateFamilyAccess(familyId, userId, ["OWNER", "ADMIN"]);

    const existingMember = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId: inviteCoParentDto.email } },
    });

    if (existingMember) {
      throw new ForbiddenException("User is already a member of this family");
    }

    const existingPermission = await this.prisma.coParentPermission.findFirst({
      where: { familyId, parent: { email: inviteCoParentDto.email } },
    });

    if (existingPermission) {
      throw new ForbiddenException("Invitation already pending for this email");
    }

    const invitation = await this.prisma.invitation.create({
      data: {
        familyId,
        senderId: userId,
        email: inviteCoParentDto.email,
        role: "MEMBER",
        token: crypto.randomBytes(32).toString("hex"),
        expiresAt: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      },
    });

    // Create co-parent permission (will be linked when user accepts)
    await this.prisma.coParentPermission.create({
      data: {
        familyId,
        childId: inviteCoParentDto.childId,
        parentId: invitation.id, // Temporary, will be updated on acceptance
        viewAlerts: inviteCoParentDto.viewAlerts ?? true,
        viewLocation: inviteCoParentDto.viewLocation ?? true,
        approveRequests: inviteCoParentDto.approveRequests ?? true,
        modifyPolicies: inviteCoParentDto.modifyPolicies ?? false,
        viewReports: inviteCoParentDto.viewReports ?? true,
        manageDevices: inviteCoParentDto.manageDevices ?? false,
      },
    });

    return invitation;
  }

  async updatePermissions(
    permissionId: string,
    userId: string,
    updatePermissionsDto: UpdateCoParentPermissionsDto,
  ) {
    const permission = await this.prisma.coParentPermission.findUnique({
      where: { id: permissionId },
    });

    if (!permission) {
      throw new NotFoundException("Co-parent permission not found");
    }

    await this.validateFamilyAccess(permission.familyId, userId, [
      "OWNER",
      "ADMIN",
    ]);

    return this.prisma.coParentPermission.update({
      where: { id: permissionId },
      data: {
        viewAlerts: updatePermissionsDto.viewAlerts,
        viewLocation: updatePermissionsDto.viewLocation,
        approveRequests: updatePermissionsDto.approveRequests,
        modifyPolicies: updatePermissionsDto.modifyPolicies,
        viewReports: updatePermissionsDto.viewReports,
        manageDevices: updatePermissionsDto.manageDevices,
      },
    });
  }

  async removeCoParent(permissionId: string, userId: string) {
    const permission = await this.prisma.coParentPermission.findUnique({
      where: { id: permissionId },
    });

    if (!permission) {
      throw new NotFoundException("Co-parent permission not found");
    }

    await this.validateFamilyAccess(permission.familyId, userId, [
      "OWNER",
      "ADMIN",
    ]);

    await this.prisma.coParentPermission.delete({
      where: { id: permissionId },
    });

    // Also remove family membership if no other children
    const otherPermissions = await this.prisma.coParentPermission.count({
      where: { familyId: permission.familyId, parentId: permission.parentId },
    });

    if (otherPermissions === 0) {
      await this.prisma.familyMember.deleteMany({
        where: { familyId: permission.familyId, userId: permission.parentId },
      });
    }

    return { success: true, message: "Co-parent removed" };
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
