import { IsString, IsOptional, IsIn, IsObject } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { DevicePlatform } from "@prisma/client";

export class RegisterDeviceDto {
  @ApiProperty({ example: "ANDROID", enum: ["ANDROID", "IOS"] })
  @IsIn(["ANDROID", "IOS"])
  platform: DevicePlatform;

  @ApiPropertyOptional({ example: "34" })
  @IsOptional()
  @IsString()
  platformVersion?: string;

  @ApiPropertyOptional({ example: "Samsung" })
  @IsOptional()
  @IsString()
  manufacturer?: string;

  @ApiPropertyOptional({ example: "SM-G991B" })
  @IsOptional()
  @IsString()
  model?: string;

  @ApiProperty({ example: "1.0.0" })
  @IsString()
  appVersion: string;

  @ApiPropertyOptional({ example: "100" })
  @IsOptional()
  @IsString()
  buildNumber?: string;

  @ApiPropertyOptional({ example: "Alex Phone" })
  @IsOptional()
  @IsString()
  deviceName?: string;

  @ApiProperty({ example: "install_abc123" })
  @IsString()
  installationId: string;

  @ApiPropertyOptional({
    example: '{ "usageStats": true, "vpnFiltering": true }',
  })
  @IsOptional()
  @IsObject()
  capabilities?: Record<string, any>;
}
