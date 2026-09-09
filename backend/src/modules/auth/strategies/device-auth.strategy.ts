import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { ConfigService } from "@nestjs/config";
import { AuthService } from "../auth.service";
import { DeviceTokenPayload } from "../interfaces/device-token-payload.interface";

@Injectable()
export class DeviceAuthStrategy extends PassportStrategy(Strategy, "device") {
  constructor(
    configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey:
        configService.get("DEVICE_JWT_SECRET") ||
        configService.get("JWT_SECRET"),
    });
  }

  async validate(payload: DeviceTokenPayload) {
    return this.authService.validateDevice(payload);
  }
}
