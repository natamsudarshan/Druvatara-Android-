export interface TokenPayload {
  sub: string;
  familyId: string;
  type: "user" | "device" | "admin";
  sessionId?: string;
}
