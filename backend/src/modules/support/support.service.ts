import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { CreateTicketDto } from "./dto/create-ticket.dto";
import { UpdateTicketDto } from "./dto/update-ticket.dto";

@Injectable()
export class SupportService {
  constructor(private prisma: PrismaService) {}

  async createTicket(
    familyId: string,
    userId: string,
    createTicketDto: CreateTicketDto,
  ) {
    await this.validateFamilyAccess(familyId, userId);

    // In production, create in support system (Zendesk, Intercom, etc.)
    // For now, just log and return mock response
    const ticket = {
      id: `ticket_${Date.now()}`,
      ...createTicketDto,
      status: "OPEN",
      createdAt: new Date(),
    };

    return ticket;
  }

  async getTickets(familyId: string, userId: string) {
    await this.validateFamilyAccess(familyId, userId);

    // Return from support system
    return [];
  }

  async getFAQs() {
    return [
      {
        id: 1,
        question: "How do I pair a child device?",
        answer:
          "Open the parent app, go to Devices > Add Device, scan the QR code on the child device.",
        category: "Setup",
      },
      {
        id: 2,
        question: "Why is VPN not connecting?",
        answer:
          "Check if VPN permission is granted in Settings > Network > VPN. Some devices require battery optimization to be disabled.",
        category: "Troubleshooting",
      },
      {
        id: 3,
        question: "How do I change screen time limits?",
        answer:
          "Go to Screen Time in the parent app, select the child, and adjust the daily limit.",
        category: "Features",
      },
      {
        id: 4,
        question: "What happens when screen time limit is reached?",
        answer:
          "Non-essential apps are blocked. The child can request more time which you can approve or deny.",
        category: "Features",
      },
      {
        id: 5,
        question: "How do I set up safe zones?",
        answer:
          "Go to Location > Safe Zones, tap Add Zone, set the location and radius.",
        category: "Features",
      },
    ];
  }

  async getTroubleshootingGuides() {
    return [
      {
        id: "device_offline",
        title: "Device Shows Offline",
        steps: [
          "Check internet connection",
          "Restart Guardian app",
          "Check battery optimization settings",
          "Re-pair device if needed",
        ],
      },
      {
        id: "vpn_not_working",
        title: "Web Filtering Not Working",
        steps: [
          "Verify VPN permission granted",
          "Check for conflicting VPN apps",
          "Restart VPN from app",
          "Reinstall if persistent",
        ],
      },
      {
        id: "location_not_updating",
        title: "Location Not Updating",
        steps: [
          "Check location permission",
          "Verify background location enabled",
          "Check GPS signal",
          "Restart location services",
        ],
      },
    ];
  }

  private async validateFamilyAccess(familyId: string, userId: string) {
    const membership = await this.prisma.familyMember.findUnique({
      where: { familyId_userId: { familyId, userId } },
    });

    if (!membership || !membership.isActive) {
      throw new ForbiddenException("Not a member of this family");
    }
  }
}
