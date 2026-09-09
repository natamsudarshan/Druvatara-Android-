import { IsObject, IsOptional, IsString, IsInt, Min } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreatePolicyDto {
  @ApiPropertyOptional({ example: "dev_abc123" })
  @IsOptional()
  @IsString()
  deviceId?: string;

  @ApiProperty({ example: '{ "dailyLimitMs": 7200000, "essentialApps": [] }' })
  @IsObject()
  screenTime: Record<string, any>;

  @ApiPropertyOptional({ example: '{ "rules": [] }' })
  @IsOptional()
  @IsObject()
  applications?: Record<string, any>;

  @ApiPropertyOptional({ example: "[]" })
  @IsOptional()
  @IsObject()
  schedules?: Record<string, any>;

  @ApiProperty({
    example: '{ "mode": "MODERATE", "safeSearch": true, "categories": [] }',
  })
  @IsObject()
  webSafety: Record<string, any>;

  @ApiProperty({ example: '{ "enabled": true, "backgroundLocation": false }' })
  @IsObject()
  location: Record<string, any>;

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
