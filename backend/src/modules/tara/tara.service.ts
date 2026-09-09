import {
  Injectable,
  NotFoundException,
  ForbiddenException,
} from "@nestjs/common";
import { PrismaService } from "../../prisma/prisma.service";
import { ConfigService } from "@nestjs/config";
import { TaraResponse } from "./interfaces/tara-response.interface";
import OpenAI from "openai";

@Injectable()
export class TaraService {
  private openai: OpenAI;

  constructor(
    private prisma: PrismaService,
    private configService: ConfigService,
  ) {
    this.openai = new OpenAI({
      apiKey: this.configService.get("OPENAI_API_KEY"),
      baseURL:
        this.configService.get("OPENAI_BASE_URL") ||
        "https://api.openai.com/v1",
    });
  }

  async askQuestion(
    familyId: string,
    parentId: string,
    childId: string | undefined,
    question: string,
  ) {
    await this.validateFamilyAccess(familyId, parentId);

    let child = null;
    if (childId) {
      child = await this.prisma.child.findUnique({
        where: { id: childId },
        select: { id: true, displayName: true, ageGroup: true, familyId: true },
      });
      if (!child || child.familyId !== familyId) {
        throw new NotFoundException("Child not found in this family");
      }
    }

    const context = await this.buildContext(familyId, childId);
    const response = await this.generateResponse(question, context, child);

    const conversation = await this.prisma.taraConversation.create({
      data: {
        familyId,
        parentId,
        childId,
        question,
        response: response as any,
        context: context as any,
        tokensUsed: this.estimateTokens(question + JSON.stringify(context)),
        model:
          this.configService.get("OPENAI_MODEL") ||
          "nvidia/nemotron-3-ultra-550b-a55b",
      },
    });

    return response;
  }

  async getConversationHistory(familyId: string, parentId: string, limit = 20) {
    await this.validateFamilyAccess(familyId, parentId);

    return this.prisma.taraConversation.findMany({
      where: { familyId, parentId },
      orderBy: { createdAt: "desc" },
      take: limit,
    });
  }

  async explainAlert(familyId: string, parentId: string, alertId: string) {
    await this.validateFamilyAccess(familyId, parentId);

    const alert = await this.prisma.alert.findUnique({
      where: { id: alertId },
      include: {
        child: { select: { id: true, displayName: true, ageGroup: true } },
        device: { select: { id: true, deviceName: true } },
      },
    });

    if (!alert || alert.familyId !== familyId) {
      throw new NotFoundException("Alert not found");
    }

    const explanation = await this.generateAlertExplanation(alert);

    await this.prisma.alert.update({
      where: { id: alertId },
      data: { taraExplanation: explanation.summary },
    });

    return explanation;
  }

  async explainSafetyScore(
    familyId: string,
    parentId: string,
    childId: string,
  ) {
    await this.validateFamilyAccess(familyId, parentId);

    const child = await this.prisma.child.findUnique({
      where: { id: childId },
      select: { id: true, displayName: true, ageGroup: true, familyId: true },
    });

    if (!child || child.familyId !== familyId) {
      throw new NotFoundException("Child not found");
    }

    const safetyScore = await this.prisma.safetyScore.findFirst({
      where: { childId },
      orderBy: { calculatedAt: "desc" },
    });

    if (!safetyScore) {
      throw new NotFoundException("No safety score available");
    }

    const explanation = await this.generateSafetyScoreExplanation(
      child,
      safetyScore,
    );

    return explanation;
  }

  private async buildContext(familyId: string, childId?: string) {
    const context: any = { familyId };

    if (childId) {
      const [
        child,
        devices,
        recentAlerts,
        recentUsage,
        safetyScore,
        activePolicy,
      ] = await Promise.all([
        this.prisma.child.findUnique({
          where: { id: childId },
          select: { displayName: true, ageGroup: true, settings: true },
        }),
        this.prisma.device.findMany({
          where: { childId, isActive: true },
          select: {
            id: true,
            deviceName: true,
            platform: true,
            status: true,
            lastSeenAt: true,
          },
        }),
        this.prisma.alert.findMany({
          where: { childId, status: { in: ["NEW", "ACKNOWLEDGED"] } },
          orderBy: { createdAt: "desc" },
          take: 5,
        }),
        this.prisma.usageSummary.findMany({
          where: {
            childId,
            date: { gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) },
          },
          orderBy: { durationMs: "desc" },
          take: 10,
        }),
        this.prisma.safetyScore.findFirst({
          where: { childId },
          orderBy: { calculatedAt: "desc" },
        }),
        this.prisma.policy.findFirst({
          where: { childId, isActive: true },
          orderBy: { version: "desc" },
        }),
      ]);

      context.child = child;
      context.devices = devices;
      context.recentAlerts = recentAlerts;
      context.recentUsage = recentUsage;
      context.safetyScore = safetyScore;
      context.activePolicy = activePolicy;
    }

    return context;
  }

  private async generateResponse(
    question: string,
    context: any,
    child: any,
  ): Promise<TaraResponse> {
    const systemPrompt = this.buildSystemPrompt(context, child);

    try {
      const completion = await this.openai.chat.completions.create({
        model:
          this.configService.get("OPENAI_MODEL") ||
          "nvidia/nemotron-3-ultra-550b-a55b",
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: question },
        ],
        temperature: 0.7,
        top_p: 0.95,
        max_tokens: 2048,
        stream: false,
      });

      const aiResponse = completion.choices[0]?.message?.content || "";
      return this.parseAIResponse(aiResponse, context, child);
    } catch (error) {
      console.error("TARA AI error:", error);
      // Fallback to template responses
      return this.generateFallbackResponse(question, context, child);
    }
  }

  private buildSystemPrompt(context: any, child: any): string {
    const childName = child?.displayName || "your child";
    const childAgeGroup = child?.ageGroup || "unknown";

    let prompt = `You are TARA, an AI digital safety assistant for parents. You help parents understand their child's digital wellbeing and safety.

Current context:
- Child: ${childName} (Age group: ${childAgeGroup})
`;

    if (context.devices?.length) {
      prompt += `\nDevices: ${context.devices.map((d: any) => `${d.deviceName} (${d.platform}, ${d.status})`).join(", ")}`;
    }

    if (context.recentUsage?.length) {
      const totalWeek = context.recentUsage.reduce(
        (acc: number, u: any) => acc + Number(u.durationMs),
        0,
      );
      const hours = Math.floor(totalWeek / (1000 * 60 * 60));
      prompt += `\nWeekly screen time: ~${hours}h`;
      prompt += `\nTop apps: ${context.recentUsage
        .slice(0, 3)
        .map(
          (u: any) =>
            `${u.appName || u.packageName}: ${Math.floor(Number(u.durationMs) / (1000 * 60))}min`,
        )
        .join(", ")}`;
    }

    if (context.recentAlerts?.length) {
      prompt += `\nRecent alerts: ${context.recentAlerts.map((a: any) => `${a.type} (${a.severity})`).join(", ")}`;
    }

    if (context.safetyScore) {
      prompt += `\nSafety score: ${context.safetyScore.score}/100`;
    }

    if (context.activePolicy) {
      prompt += `\nActive policy: Screen time=${context.activePolicy.screenTime?.dailyLimitMs ? Math.floor(context.activePolicy.screenTime.dailyLimitMs / (1000 * 60 * 60)) + "h" : "unset"}, Web filtering=${context.activePolicy.webSafety?.enabled ? "on" : "off"}`;
    }

    prompt += `

Respond in this JSON format only:
{
  "summary": "Brief 2-3 sentence summary",
  "riskLevel": "low|medium|high",
  "confidence": 0.85,
  "recommendedActions": [
    {"type": "action_type", "label": "User-friendly label"}
  ],
  "limitations": "Any limitations or caveats",
  "safetyCategory": "screen_time|apps|alerts|location|safety_score|schedules|web_safety|general"
}`;

    return prompt;
  }

  private parseAIResponse(
    aiResponse: string,
    context: any,
    child: any,
  ): TaraResponse {
    try {
      // Try to extract JSON from the response
      const jsonMatch = aiResponse.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        return {
          summary: parsed.summary || aiResponse.slice(0, 200),
          riskLevel: parsed.riskLevel || "low",
          confidence: parsed.confidence || 0.8,
          recommendedActions: parsed.recommendedActions || [],
          limitations: parsed.limitations || "AI-generated response",
          safetyCategory: parsed.safetyCategory || "general",
        };
      }
    } catch (e) {
      // JSON parsing failed
    }

    // Fallback: treat entire response as summary
    return {
      summary: aiResponse.slice(0, 300),
      riskLevel: "low",
      confidence: 0.7,
      recommendedActions: [
        { type: "ask_followup", label: "Ask follow-up question" },
      ],
      limitations: "Response parsed from AI text output",
      safetyCategory: "general",
    };
  }

  private generateFallbackResponse(
    question: string,
    context: any,
    child: any,
  ): TaraResponse {
    const lowerQuestion = question.toLowerCase();

    if (
      lowerQuestion.includes("screen time") ||
      lowerQuestion.includes("usage")
    ) {
      return this.generateScreenTimeResponse(context, child);
    }
    if (lowerQuestion.includes("alert") || lowerQuestion.includes("warning")) {
      return this.generateAlertsResponse(context, child);
    }
    if (
      lowerQuestion.includes("app") ||
      lowerQuestion.includes("application")
    ) {
      return this.generateAppsResponse(context, child);
    }
    if (
      lowerQuestion.includes("location") ||
      lowerQuestion.includes("where") ||
      lowerQuestion.includes("geofence")
    ) {
      return this.generateLocationResponse(context, child);
    }
    if (
      lowerQuestion.includes("safety score") ||
      lowerQuestion.includes("score")
    ) {
      return this.generateSafetyScoreResponse(context, child);
    }
    if (
      lowerQuestion.includes("schedule") ||
      lowerQuestion.includes("bedtime") ||
      lowerQuestion.includes("school time")
    ) {
      return this.generateScheduleResponse(context, child);
    }
    if (
      lowerQuestion.includes("web") ||
      lowerQuestion.includes("website") ||
      lowerQuestion.includes("internet") ||
      lowerQuestion.includes("filter")
    ) {
      return this.generateWebSafetyResponse(context, child);
    }

    return this.generateGeneralResponse(question, context, child);
  }

  // Template-based fallback responses (unchanged from before)
  private generateScreenTimeResponse(context: any, child: any): TaraResponse {
    const todayUsage = context.recentUsage?.find(
      (u: any) => new Date(u.date).toDateString() === new Date().toDateString(),
    );
    const totalToday = todayUsage ? todayUsage.durationMs : 0;
    const hours = Math.floor(totalToday / (1000 * 60 * 60));
    const minutes = Math.floor((totalToday % (1000 * 60 * 60)) / (1000 * 60));

    return {
      summary: `${child?.displayName || "Your child"} has used their device for ${hours}h ${minutes}m today.`,
      riskLevel:
        totalToday > 10800000
          ? "high"
          : totalToday > 7200000
            ? "medium"
            : "low",
      confidence: 0.85,
      recommendedActions: [
        { type: "review_usage", label: "View detailed usage breakdown" },
        { type: "set_limit", label: "Adjust daily screen time limit" },
      ],
      limitations:
        "Based on today's usage data only. Weekly patterns may differ.",
      safetyCategory: "screen_time",
    };
  }

  private generateAlertsResponse(context: any, child: any): TaraResponse {
    const alerts = context.recentAlerts || [];
    const criticalAlerts = alerts.filter(
      (a: any) => a.severity === "CRITICAL" || a.severity === "HIGH",
    );

    if (criticalAlerts.length > 0) {
      return {
        summary: `There are ${criticalAlerts.length} high-priority alerts requiring attention. Most recent: ${criticalAlerts[0].title}.`,
        riskLevel: "high",
        confidence: 0.9,
        recommendedActions: [
          { type: "review_alerts", label: "Review all alerts" },
          { type: "check_device", label: "Check device status" },
        ],
        limitations:
          "Alert explanations are based on automated classification.",
        safetyCategory: "alerts",
      };
    }

    return {
      summary: `There are ${alerts.length} active alerts. Most are informational or low severity.`,
      riskLevel: "low",
      confidence: 0.8,
      recommendedActions: [
        { type: "review_alerts", label: "Review all alerts" },
      ],
      limitations: "Some alerts may resolve automatically.",
      safetyCategory: "alerts",
    };
  }

  private generateAppsResponse(context: any, child: any): TaraResponse {
    const topApps = context.recentUsage?.slice(0, 5) || [];

    if (topApps.length === 0) {
      return {
        summary: "No recent app usage data available.",
        riskLevel: "low",
        confidence: 0.5,
        recommendedActions: [],
        limitations: "Device may be offline or usage access not granted.",
        safetyCategory: "apps",
      };
    }

    const topApp = topApps[0];
    const hours = Math.floor(topApp.durationMs / (1000 * 60 * 60));
    const minutes = Math.floor(
      (topApp.durationMs % (1000 * 60 * 60)) / (1000 * 60),
    );

    return {
      summary: `Most used app: ${topApp.appName || topApp.packageName} (${hours}h ${minutes}m this week). ${topApps.length} apps used recently.`,
      riskLevel: "low",
      confidence: 0.8,
      recommendedActions: [
        { type: "review_apps", label: "Review all app usage" },
        { type: "set_app_limit", label: "Set limits for specific apps" },
      ],
      limitations:
        "Only shows apps with usage data. Some system apps may be hidden.",
      safetyCategory: "apps",
    };
  }

  private generateLocationResponse(context: any, child: any): TaraResponse {
    const devices = context.devices || [];
    const onlineDevices = devices.filter(
      (d: any) =>
        d.status === "ACTIVE" &&
        d.lastSeenAt &&
        new Date(d.lastSeenAt) > new Date(Date.now() - 30 * 60 * 1000),
    );

    if (onlineDevices.length === 0) {
      return {
        summary: "No devices currently reporting location.",
        riskLevel: "medium",
        confidence: 0.7,
        recommendedActions: [
          { type: "check_device", label: "Check device connectivity" },
        ],
        limitations: "Location requires active device with permissions.",
        safetyCategory: "location",
      };
    }

    return {
      summary: `${onlineDevices.length} device(s) online and reporting location. Last update: ${new Date(onlineDevices[0].lastSeenAt).toLocaleTimeString()}.`,
      riskLevel: "low",
      confidence: 0.8,
      recommendedActions: [
        { type: "view_location", label: "View current location on map" },
        { type: "manage_geofences", label: "Manage safe zones" },
      ],
      limitations: "Location accuracy depends on device GPS and network.",
      safetyCategory: "location",
    };
  }

  private generateSafetyScoreResponse(context: any, child: any): TaraResponse {
    const score = context.safetyScore;

    if (!score) {
      return {
        summary:
          "No safety score calculated yet. Score requires at least 24 hours of data.",
        riskLevel: "low",
        confidence: 0.5,
        recommendedActions: [],
        limitations: "Score is calculated daily based on multiple factors.",
        safetyCategory: "safety_score",
      };
    }

    const riskLevel =
      score.score >= 80 ? "low" : score.score >= 60 ? "medium" : "high";

    return {
      summary: `${child?.displayName || "Your child"}'s digital safety score is ${score.score}/100. ${score.factors?.protectionStatus ? "Protection is active." : "Some protection features need attention."}`,
      riskLevel,
      confidence: 0.85,
      recommendedActions: [
        { type: "view_score_details", label: "View score breakdown" },
        {
          type: "improve_score",
          label: "Get recommendations to improve score",
        },
      ],
      limitations: "Score is a guideline, not a guarantee of safety.",
      safetyCategory: "safety_score",
    };
  }

  private generateScheduleResponse(context: any, child: any): TaraResponse {
    const policy = context.activePolicy;
    const schedules = policy?.schedules || [];

    if (schedules.length === 0) {
      return {
        summary: "No schedules currently configured.",
        riskLevel: "low",
        confidence: 0.8,
        recommendedActions: [
          {
            type: "create_schedule",
            label: "Create bedtime or school schedule",
          },
        ],
        limitations: "Schedules help automate screen time limits.",
        safetyCategory: "schedules",
      };
    }

    const activeSchedules = schedules.filter((s: any) => s.isActive);
    return {
      summary: `${activeSchedules.length} active schedule(s) configured. Next: ${activeSchedules[0]?.name || "Unknown"}.`,
      riskLevel: "low",
      confidence: 0.85,
      recommendedActions: [
        { type: "view_schedules", label: "View all schedules" },
        { type: "edit_schedule", label: "Modify schedule times" },
      ],
      limitations: "Schedules apply to non-essential apps only.",
      safetyCategory: "schedules",
    };
  }

  private generateWebSafetyResponse(context: any, child: any): TaraResponse {
    const policy = context.activePolicy;
    const webSafety = policy?.webSafety;

    if (!webSafety) {
      return {
        summary: "Web safety settings not configured.",
        riskLevel: "medium",
        confidence: 0.7,
        recommendedActions: [
          { type: "configure_web_safety", label: "Set up web filtering" },
        ],
        limitations: "Web filtering requires VPN permission on child device.",
        safetyCategory: "web_safety",
      };
    }

    return {
      summary: `Web filtering is ${webSafety.mode || "active"}. SafeSearch: ${webSafety.safeSearch ? "On" : "Off"}. ${webSafety.categories?.length || 0} categories blocked.`,
      riskLevel: "low",
      confidence: 0.8,
      recommendedActions: [
        { type: "view_blocked_sites", label: "View blocked website attempts" },
        { type: "adjust_categories", label: "Adjust blocked categories" },
      ],
      limitations: "Cannot filter encrypted content within apps.",
      safetyCategory: "web_safety",
    };
  }

  private generateGeneralResponse(
    question: string,
    context: any,
    child: any,
  ): TaraResponse {
    return {
      summary: `I understand you're asking about "${question}". I can help with screen time, app usage, alerts, location, safety scores, schedules, and web safety. What specific area would you like guidance on?`,
      riskLevel: "low",
      confidence: 0.6,
      recommendedActions: [
        { type: "ask_specific", label: "Ask about screen time" },
        { type: "ask_specific", label: "Ask about alerts" },
        { type: "ask_specific", label: "Ask about location" },
      ],
      limitations:
        "I provide guidance based on available data. For urgent concerns, please review alerts directly.",
      safetyCategory: "general",
    };
  }

  private async generateAlertExplanation(alert: any): Promise<TaraResponse> {
    const explanations: Record<string, string> = {
      APP_LIMIT_REACHED: `${alert.child.displayName} reached the time limit for an app. This is a normal enforcement of the screen time policy you set.`,
      SCREEN_TIME_LIMIT_REACHED: `${alert.child.displayName} has used their daily screen time allowance. Non-essential apps are now restricted.`,
      WEB_CATEGORY_BLOCKED: `An attempt to access a ${alert.metadata?.category || "restricted"} website was blocked. This follows your web safety settings.`,
      THREAT_BLOCKED: `A potential security threat (${alert.metadata?.threatType || "phishing/malware"}) was detected and blocked. No action needed unless this repeats.`,
      GEOFENCE_EXITED: `${alert.child.displayName} left the safe zone "${alert.metadata?.geofenceName || "Unknown"}". Please check if this was expected.`,
      GEOFENCE_ENTERED: `${alert.child.displayName} entered the safe zone "${alert.metadata?.geofenceName || "Unknown"}".`,
      VPN_DISABLED: `The web filtering VPN was turned off on ${alert.device?.deviceName || "the device"}. Web protection is currently inactive.`,
      PERMISSION_REVOKED: `A required permission (${alert.metadata?.permission || "unknown"}) was revoked. Some protection features may not work.`,
      DEVICE_OFFLINE: `The device hasn't checked in for over 30 minutes. It may be powered off, have no internet, or the app was stopped.`,
    };

    const explanation =
      explanations[alert.type] || `${alert.title}: ${alert.message}`;

    return {
      summary: explanation,
      riskLevel:
        alert.severity === "CRITICAL" || alert.severity === "HIGH"
          ? "high"
          : alert.severity === "MEDIUM"
            ? "medium"
            : "low",
      confidence: 0.85,
      recommendedActions: [
        { type: "view_alert", label: "View alert details" },
        { type: "check_device", label: "Check device status" },
      ],
      limitations:
        "Explanation is based on alert type and metadata. Context may be limited.",
      safetyCategory: "alert_explanation",
    };
  }

  private async generateSafetyScoreExplanation(
    child: any,
    score: any,
  ): Promise<TaraResponse> {
    const factors = score.factors || {};
    const weakAreas = Object.entries(factors)
      .filter(([, v]: [string, any]) => v < 0.7)
      .map(([k]) => k)
      .slice(0, 3);

    return {
      summary: `${child.displayName}'s safety score is ${score.score}/100. ${weakAreas.length > 0 ? `Areas to improve: ${weakAreas.join(", ")}.` : "All protection areas are performing well."}`,
      riskLevel:
        score.score >= 80 ? "low" : score.score >= 60 ? "medium" : "high",
      confidence: 0.9,
      recommendedActions: [
        { type: "view_score_details", label: "View detailed factor breakdown" },
        ...weakAreas.map((area) => ({
          type: `improve_${area}`,
          label: `Improve ${area}`,
        })),
      ],
      limitations:
        "Score reflects configuration and usage patterns, not absolute safety.",
      safetyCategory: "safety_score_explanation",
    };
  }

  private estimateTokens(text: string): number {
    return Math.ceil(text.length / 4);
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
