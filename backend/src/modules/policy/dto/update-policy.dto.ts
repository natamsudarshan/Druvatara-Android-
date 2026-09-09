import { IsObject, IsOptional } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdatePolicyDto {
  @ApiPropertyOptional({ example: '{ "dailyLimitMs": 10800000 }' })
  @IsOptional()
  @IsObject()
  screenTime?: Record<string, any>;

  @ApiPropertyOptional({ example: '{ "rules": [] }' })
  @IsOptional()
  @IsObject()
  applications?: Record<string, any>;

  @ApiPropertyOptional({ example: "[]" })
  @IsOptional()
  @IsObject()
  schedules?: Record<string, any>;

  @ApiPropertyOptional({ example: '{ "mode": "STRICT" }' })
  @IsOptional()
  @IsObject()
  webSafety?: Record<string, any>;

  @ApiPropertyOptional({ example: '{ "enabled": true }' })
  @IsOptional()
  @IsObject()
  location?: Record<string, any>;

  @ApiPropertyOptional({ example: "[]" })
  @IsOptional()
  @IsObject()
  safeZones?: Record<string, any>;

  @ApiPropertyOptional({ example: "[]" })
  @IsOptional()
  @IsObject()
  essentialApps?: Record<string, any>;

  @ApiPropertyOptional({ example: "[]" })
  @IsOptional()
  @IsObject()
  temporaryOverrides?: Record<string, any>;
}
