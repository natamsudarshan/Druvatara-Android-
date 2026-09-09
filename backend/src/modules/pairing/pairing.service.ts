import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreatePairingDto } from "./dto/create-pairing.dto";
import { v4 as uuidv4 } from "uuid";

@Injectable()
export class PairingService {
  constructor(private prisma: PrismaService) {}

  async create(
    familyId: string,
    childId: string,
    userId: string,
    createPairingDto: CreatePairingDto,
  ) {
    await this.validateFamilyAccess(familyId, userId);

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { familyId: true, isActive: true },
    });

    if (!child || !child.isActive || child.familyId !== familyId) {
      throw new NotFoundException("Child not found in this family");
    }

    const existingPairing = await this.prisma.pairingSession.findFirst({
      where: { familyId, childId, status: "PENDING" },
    });

    if (existingPairing && existingPairing.expiresAt > new Date()) {
      throw new BadRequestException(
        "A pending pairing already exists for this child",
      );
    }

    const pairingCode = this.generatePairingCode();
    const qrPayload = this.generateQRPayload(familyId, childId, pairingCode);

    const pairing = await this.prisma.pairingSession.create({
      data: {
        familyId,
        childId,
        platform: createPairingDto.platform,
        pairingCode,
        qrPayload,
        deviceInternalId: createPairingDto.deviceInternalId,
        expiresAt: new Date(Date.now() + 15 * 60 * 1000),
      },
    });

    return pairing;
  }

  async findById(pairingId: string, userId: string) {
    const pairing = await this.prisma.pairingSession.findUnique({
      where: { id: pairingId },
      include: {
        family: { select: { id: true, name: true } },
        child: { select: { id: true, displayName: true, ageGroup: true } },
      },
    });

    if (!pairing) {
      throw new NotFoundException("Pairing session not found");
    }

    await this.validateFamilyAccess(pairing.familyId, userId);

    return pairing;
  }

  async claimPairing(pairingCode: string, deviceInfo: any) {
    const pairing = await this.prisma.pairingSession.findUnique({
      where: { pairingCode },
    });

    if (
      !pairing ||
      pairing.status !== "PENDING" ||
      pairing.expiresAt < new Date()
    ) {
      throw new NotFoundException("Invalid or expired pairing code");
    }

    await this.prisma.pairingSession.update({
      where: { id: pairing.id },
      data: {
        status: "CLAIMED",
        claimedAt: new Date(),
        deviceInfo,
      },
    });

    return pairing;
  }

  async confirmPairing(pairingId: string, userId: string) {
    const pairing = await this.prisma.pairingSession.findUnique({
      where: { id: pairingId },
    });

    if (!pairing) {
      throw new NotFoundException("Pairing session not found");
    }

    await this.validateFamilyAccess(pairing.familyId, userId, [
      "OWNER",
      "ADMIN",
    ]);

    await this.prisma.pairingSession.update({
      where: { id: pairingId },
      data: { status: "CONFIRMED", confirmedAt: new Date() },
    });

    if (pairing.deviceInternalId) {
      await this.prisma.device.update({
        where: { internalId: pairing.deviceInternalId },
        data: { status: "ACTIVE" },
      });
    }

    return { success: true, pairingId };
  }

  async cancelPairing(pairingId: string, userId: string) {
    const pairing = await this.prisma.pairingSession.findUnique({
      where: { id: pairingId },
    });

    if (!pairing) {
      throw new NotFoundException("Pairing session not found");
    }

    await this.validateFamilyAccess(pairing.familyId, userId);

    await this.prisma.pairingSession.update({
      where: { id: pairingId },
      data: { status: "CANCELLED" },
    });

    return { success: true, message: "Pairing cancelled" };
  }

  private generatePairingCode(): string {
    return Math.floor(1000000 + Math.random() * 9000000).toString();
  }

  private generateQRPayload(
    familyId: string,
    childId: string,
    pairingCode: string,
  ): string {
    return btoa(
      JSON.stringify({
        v: 1,
        f: familyId,
        c: childId,
        p: pairingCode,
        t: Date.now(),
      }),
    );
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
