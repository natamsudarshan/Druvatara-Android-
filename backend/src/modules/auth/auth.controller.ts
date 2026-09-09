import {
  Controller,
  Post,
  Body,
  Get,
  UseGuards,
  Delete,
  Param,
  HttpCode,
  HttpStatus,
  Request,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";
import { AuthService } from "./auth.service";
import { RegisterDto } from "./dto/register.dto";
import { LoginDto } from "./dto/login.dto";
import { RefreshTokenDto } from "./dto/refresh-token.dto";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { TokenPayload } from "./interfaces/token-payload.interface";

@ApiTags("Authentication")
@Controller("auth")
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post("register")
  @ApiOperation({ summary: "Register a new parent user" })
  @ApiResponse({ status: 201, description: "User registered successfully" })
  @ApiResponse({ status: 409, description: "Email already registered" })
  async register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @Post("login")
  @ApiOperation({ summary: "Login user" })
  @ApiResponse({ status: 200, description: "Login successful" })
  @ApiResponse({ status: 401, description: "Invalid credentials" })
  async login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Post("refresh")
  @ApiOperation({ summary: "Refresh access token" })
  @ApiResponse({ status: 200, description: "Token refreshed successfully" })
  @ApiResponse({ status: 401, description: "Invalid refresh token" })
  async refreshToken(@Body() refreshTokenDto: RefreshTokenDto) {
    return this.authService.refreshToken(refreshTokenDto);
  }

  @Post("logout")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Logout current session" })
  @HttpCode(HttpStatus.OK)
  async logout(@CurrentUser() user: TokenPayload, @Request() req: Request) {
    const accessToken = req.headers
      .get("authorization")
      ?.replace("Bearer ", "");
    await this.authService.logout(user.sub, undefined, accessToken);
    return { success: true, message: "Logged out successfully" };
  }

  @Post("logout-all")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Logout all sessions" })
  @HttpCode(HttpStatus.OK)
  async logoutAll(@CurrentUser() user: TokenPayload) {
    await this.authService.logoutAll(user.sub);
    return { success: true, message: "Logged out from all sessions" };
  }

  @Get("sessions")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "List active sessions" })
  async getSessions(@CurrentUser() user: TokenPayload) {
    const sessions = await this.authService.getSessions(user.sub);
    return { success: true, data: sessions };
  }

  @Delete("sessions/:sessionId")
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: "Revoke a specific session" })
  @HttpCode(HttpStatus.OK)
  async revokeSession(
    @CurrentUser() user: TokenPayload,
    @Param("sessionId") sessionId: string,
  ) {
    await this.authService.revokeSession(user.sub, sessionId);
    return { success: true, message: "Session revoked" };
  }
}
