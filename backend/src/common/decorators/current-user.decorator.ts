import { createParamDecorator, ExecutionContext } from "@nestjs/common";
import { TokenPayload } from "../../modules/auth/interfaces/token-payload.interface";

export const CurrentUser = createParamDecorator(
  (
    data: keyof TokenPayload | undefined,
    ctx: ExecutionContext,
  ): TokenPayload | any => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;
    return data ? user?.[data] : user;
  },
);

export const CurrentDevice = createParamDecorator(
  (data: keyof any | undefined, ctx: ExecutionContext): any => {
    const request = ctx.switchToHttp().getRequest();
    const device = request.user;
    return data ? device?.[data] : device;
  },
);
