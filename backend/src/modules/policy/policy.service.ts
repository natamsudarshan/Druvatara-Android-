import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreatePolicyDto } from "./dto/create-policy.dto";
import { UpdatePolicyDto } from "./dto/update-policy.dto";

@Injectable()
export class PolicyService {
  constructor(private prisma: PrismaService) {}

  async create(
    familyId: string,
    childId: string,
    userId: string,
    createPolicyDto: CreatePolicyDto,
  ) {
    await this.validatePolicyAccess(familyId, childId, userId, true);

    const latestPolicy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
    });

    const newVersion = (latestPolicy?.version || 0) + 1;

    const policy = await this.prisma.policy.create({
      data: {
        familyId,
        childId,
        deviceId: createPolicyDto.deviceId,
        version: newVersion,
        screenTime: createPolicyDto.screenTime,
        applications: createPolicyDto.applications,
        schedules: createPolicyDto.schedules,
        webSafety: createPolicyDto.webSafety,
        location: createPolicyDto.location,
        safeZones: createPolicyDto.safeZones,
        essentialApps: createPolicyDto.essentialApps,
        temporaryOverrides: createPolicyDto.temporaryOverrides,
      },
    });

    if (createPolicyDto.deviceId) {
      await this.queuePolicySync(createPolicyDto.deviceId, newVersion);
    } else {
      const devices = await this.prisma.device.findMany({
        where: { childId, isActive: true, status: { not: "REMOVED" } },
        select: { id: true },
      });
      for (const device of devices) {
        await this.queuePolicySync(device.id, newVersion);
      }
    }

    return policy;
  }

  async findLatest(familyId: string, childId: string, userId: string) {
    await this.validatePolicyAccess(familyId, childId, userId);

    return this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
    });
  }

  async findByVersion(
    familyId: string,
    childId: string,
    version: number,
    userId: string,
  ) {
    await this.validatePolicyAccess(familyId, childId, userId);

    return this.prisma.policy.findFirst({
      where: { childId, version, isActive: true },
    });
  }

  async findAll(familyId: string, childId: string, userId: string) {
    await this.validatePolicyAccess(familyId, childId, userId);

    return this.prisma.policy.findMany({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
      take: 20,
    });
  }

  async update(
    familyId: string,
    childId: string,
    userId: string,
    updatePolicyDto: UpdatePolicyDto,
  ) {
    await this.validatePolicyAccess(familyId, childId, userId, true);

    const latestPolicy = await this.prisma.policy.findFirst({
      where: { childId, isActive: true },
      orderBy: { version: "desc" },
    });

    if (!latestPolicy) {
      throw new NotFoundException("No active policy found");
    }

    const newVersion = latestPolicy.version + 1;

    const policy = await this.prisma.policy.create({
      data: {
        familyId,
        childId,
        deviceId: latestPolicy.deviceId,
        version: newVersion,
        screenTime: (updatePolicyDto.screenTime ??
          latestPolicy.screenTime) as any,
        applications: (updatePolicyDto.applications ??
          latestPolicy.applications) as any,
        schedules: (updatePolicyDto.schedules ?? latestPolicy.schedules) as any,
        webSafety: (updatePolicyDto.webSafety ?? latestPolicy.webSafety) as any,
        location: (updatePolicyDto.location ?? latestPolicy.location) as any,
        safeZones: (updatePolicyDto.safeZones ?? latestPolicy.safeZones) as any,
        essentialApps: (updatePolicyDto.essentialApps ??
          latestPolicy.essentialApps) as any,
        temporaryOverrides: (updatePolicyDto.temporaryOverrides ??
          latestPolicy.temporaryOverrides) as any,
      },
    });

    const devices = await this.prisma.device.findMany({
      where: { childId, isActive: true, status: { not: "REMOVED" } },
      select: { id: true },
    });

    for (const device of devices) {
      await this.queuePolicySync(device.id, newVersion);
    }

    return policy;
  }

  async acknowledgePolicy(
    deviceId: string,
    policyVersion: number,
    success: boolean,
    error?: string,
  ) {
    const device = await this.prisma.device.findUnique({
      where: { id: deviceId },
      select: { policyVersion: true },
    });

    if (!device) {
      throw new NotFoundException("Device not found");
    }

    if (success) {
      await this.prisma.device.update({
        where: { id: deviceId },
        data: { policyVersion, lastSyncAt: new Date() },
      });
    }

    return { success: true, policyVersion: device.policyVersion };
  }

  async getPendingCommands(deviceId: string) {
    return this.prisma.deviceCommand.findMany({
      where: { deviceId, status: "QUEUED", type: "POLICY_UPDATE" },
      orderBy: { createdAt: "asc" },
    });
  }

  private async queuePolicySync(deviceId: string, policyVersion: number) {
    await this.prisma.deviceCommand.create({
      data: {
        deviceId,
        commandId: `cmd_policy_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
        type: "POLICY_UPDATE",
        payload: { policyVersion, action: "SYNC_POLICY" },
        status: "QUEUED",
        expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
      },
    });
  }

  private async validatePolicyAccess(
    familyId: string,
    childId: string,
    userId: string,
    requireModify = false,
  ) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true, isActive: true },
    });

    if (!child || !child.isActive || child.familyId !== familyId) {
      throw new NotFoundException("Child not found in this family");
    }

    if (requireModify && !["OWNER", "ADMIN"].includes(membership.role)) {
      const coParentPerm = await this.prisma.coParentPermission.findUnique({
        where: {
          familyId_childId_parentId: { familyId, childId, parentId: userId },
        },
      });
      if (!coParentPerm?.modifyPolicies) {
        throw new ForbiddenException(
          "Insufficient permissions to modify policies",
        );
      }
    }
  }
}
