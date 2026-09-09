import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class ThreatIntelService {
  constructor(private prisma: PrismaService) {}

  async checkUrl(url: string) {
    const domain = this.extractDomain(url);
    if (!domain) return { isThreat: false, threatType: null, confidence: 0 };

    // Check local cache first
    // In production, integrate with threat intelligence providers like:
    // - URLhaus, PhishTank, Google Safe Browsing, VirusTotal, etc.

    const knownThreats = [
      "malware.example.com",
      "phishing.example.net",
      "fraud.example.org",
    ];

    const isKnownThreat = knownThreats.some((t) => domain.includes(t));

    if (isKnownThreat) {
      await this.logThreat(domain, "MALWARE", 0.95);
      return {
        isThreat: true,
        threatType: "MALWARE",
        confidence: 0.95,
        source: "local_cache",
      };
    }

    // Check suspicious patterns
    const suspiciousPatterns = [
      /\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/, // IP addresses
      /[a-z0-9-]{20,}\.[a-z]{2,}/, // Long random subdomains
      /(login|verify|secure|account|update|confirm)\./, // Phishing keywords
    ];

    for (const pattern of suspiciousPatterns) {
      if (pattern.test(domain)) {
        return {
          isThreat: false,
          threatType: "SUSPICIOUS",
          confidence: 0.3,
          source: "pattern_analysis",
        };
      }
    }

    return { isThreat: false, threatType: null, confidence: 0 };
  }

  async getThreatStats(childId: string, userId: string) {
    await this.validateChildAccess(childId, userId);

    const threats = await this.prisma.deviceEvent.findMany({
      where: {
        childId,
        eventType: "THREAT_BLOCKED",
      },
      orderBy: { capturedAt: "desc" },
      take: 100,
    });

    const byType = threats.reduce(
      (acc, t) => {
        const type = (t.payload as any)?.threatType || "UNKNOWN";
        acc[type] = (acc[type] || 0) + 1;
        return acc;
      },
      {} as Record<string, number>,
    );

    return {
      totalThreats: threats.length,
      byType,
      recentThreats: threats.slice(0, 10),
    };
  }

  private extractDomain(url: string): string | null {
    try {
      const urlObj = new URL(url);
      let hostname = urlObj.hostname;
      if (hostname.startsWith("www.")) hostname = hostname.substring(4);
      return hostname;
    } catch {
      return null;
    }
  }

  private async logThreat(
    domain: string,
    threatType: string,
    confidence: number,
  ) {
    // Log to database for analytics
    console.log(`Threat detected: ${domain} - ${threatType} (${confidence})`);
  }

  private async validateChildAccess(childId: string, userId: string) {
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
  }
}
