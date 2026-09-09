export interface DeviceTokenPayload {
  sub: string;
  deviceId: string;
  familyId: string;
  childId: string;
  credentialVersion: number;
  type: "device";
}
