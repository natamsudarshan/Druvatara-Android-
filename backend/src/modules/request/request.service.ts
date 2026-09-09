import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { RequestStatus, Prisma } from "@prisma/client";

@Injectable()
export class RequestService {
  constructor(private prisma: PrismaService) {}

  async getRequests(childId: string, userId: string, status?: RequestStatus) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.childRequest.findMany({
      where: { childId, ...(status ? { status } : {}) },
      orderBy: { createdAt: "desc" },
    });
  }

  async createRequest(
    childId: string,
    userId: string,
    data: {
      type: string;
      resource: string;
      resourceName?: string;
      requestedValue: Prisma.InputJsonValue;
      currentValue?: Prisma.InputJsonValue;
      childMessage?: string;
    },
  ) {
    await this.validateChildAccess(childId, userId);

    const expiresAt = new Date(Date.now() + 24 * 60 * 60 * 1000);

    return this.prisma.childRequest.create({
      data: {
        childId,
        type: data.type as any,
        resource: data.resource,
        resourceName: data.resourceName,
        requestedValue: data.requestedValue as any,
        currentValue: data.currentValue as any,
        childMessage: data.childMessage,
        expiresAt,
      },
    });
  }

  async decideRequest(
    requestId: string,
    userId: string,
    decision: {
      status: "APPROVED" | "MODIFIED" | "REJECTED";
      parentMessage?: string;
      modifiedValue?: Prisma.InputJsonValue;
    },
  ) {
    const request = await this.prisma.childRequest.findUnique({
      where: { id: requestId },
      include: { child: { select: { familyId: true } } },
    });

    if (!request) {
      throw new NotFoundException("Request not found");
    }

    await this.validateChildAccess(request.childId, userId, true);

    if (request.status !== "PENDING") {
      throw new BadRequestException("Request already decided");
    }

    if (request.expiresAt < new Date()) {
      await this.prisma.childRequest.update({
        where: { id: requestId },
        data: { status: "EXPIRED" },
      });
      throw new BadRequestException("Request has expired");
    }

    const updateData: any = {
      status: decision.status,
      parentMessage: decision.parentMessage,
      decidedAt: new Date(),
    };

    if (decision.status === "MODIFIED" && decision.modifiedValue) {
      updateData.requestedValue = decision.modifiedValue as any;
    }

    return this.prisma.childRequest.update({
      where: { id: requestId },
      data: updateData,
    });
  }

  async getPendingCount(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    return this.prisma.childRequest.count({
      where: { childId, status: "PENDING" },
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
      if (!coParentPerm?.approveRequests) {
        throw new ForbiddenException("Insufficient permissions");
      }
    }
  }
}
