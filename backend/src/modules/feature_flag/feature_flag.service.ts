import { Injectable, NotFoundException } from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";

@Injectable()
export class FeatureFlagService {
  constructor(private prisma: PrismaService) {}

  async getAllFlags() {
    return this.prisma.featureFlag.findMany({
      orderBy: { key: "asc" },
    });
  }

  async getFlag(key: string) {
    return this.prisma.featureFlag.findUnique({
      where: { key },
    });
  }

  async isEnabled(
    key: string,
    context?: { userId?: string; familyId?: string },
  ): Promise<boolean> {
    const flag = await this.prisma.featureFlag.findUnique({
      where: { key },
    });

    if (!flag || !flag.enabled) return false;

    // Check rollout percentage
    if (flag.rollout < 100 && context?.userId) {
      const hash = this.hashString(key + context.userId);
      if (hash % 100 >= flag.rollout) return false;
    }

    // Check custom rules
    if (flag.rules && Object.keys(flag.rules).length > 0) {
      // Implement custom rule evaluation
      // For now, return true if enabled
    }

    return true;
  }

  async createFlag(data: {
    key: string;
    name: string;
    description?: string;
    enabled?: boolean;
    rollout?: number;
    rules?: Record<string, any>;
  }) {
    return this.prisma.featureFlag.create({
      data: {
        key: data.key,
        name: data.name,
        description: data.description,
        enabled: data.enabled ?? false,
        rollout: data.rollout ?? 0,
        rules: (data.rules as any) ?? {},
      },
    });
  }

  async updateFlag(
    key: string,
    data: {
      enabled?: boolean;
      rollout?: number;
      rules?: Record<string, any>;
    },
  ) {
    const flag = await this.prisma.featureFlag.findUnique({
      where: { key },
    });

    if (!flag) {
      throw new NotFoundException("Feature flag not found");
    }

    return this.prisma.featureFlag.update({
      where: { key },
      data: {
        enabled: data.enabled ?? flag.enabled,
        rollout: data.rollout ?? flag.rollout,
        rules: (data.rules as any) ?? flag.rules,
      },
    });
  }

  async deleteFlag(key: string) {
    return this.prisma.featureFlag.delete({
      where: { key },
    });
  }

  private hashString(str: string): number {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = (hash << 5) - hash + char;
      hash = hash & hash;
    }
    return Math.abs(hash);
  }
}
