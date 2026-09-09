export interface TaraResponse {
  summary: string;
  riskLevel: "low" | "medium" | "high";
  confidence: number;
  recommendedActions: Array<{ type: string; label: string }>;
  limitations: string;
  safetyCategory: string;
}
