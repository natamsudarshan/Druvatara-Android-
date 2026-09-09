import { Injectable, UnauthorizedException } from "@nestjs/common";
import { PassportStrategy } from "@nestjs/passport";
import { ExtractJwt, Strategy } from "passport-jwt";
import { ConfigService } from "@nestjs/config";
import { AuthService } from "../auth.service";
import { TokenPayload } from "../interfaces/token-payload.interface";

@Injectable()
export class AdminStrategy extends PassportStrategy(Strategy, "admin") {
  constructor(
    configService: ConfigService,
    private authService: AuthService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get("JWT_SECRET"),
    });
  }

  async validate(payload: TokenPayload) {
    const user = await this.authService.validateUser(payload);
    if (user.role !== "ADMIN" && user.role !== "SUPPORT") {
      throw new UnauthorizedException("Admin access required");
    }
    return user;
  }
}
