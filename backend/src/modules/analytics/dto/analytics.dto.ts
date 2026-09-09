import { IsOptional, IsString, IsDateString } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class TrackEventDto {
  @ApiProperty({ example: "screen_view" })
  @IsString()
  eventName: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  familyId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  childId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  deviceId?: string;

  @ApiPropertyOptional({ example: { screen: "dashboard" } })
  @IsOptional()
  properties?: Record<string, any>;
}

export class AnalyticsMetricsQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  eventName?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  familyId?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  childId?: string;

  @ApiPropertyOptional({ example: "2024-01-01T00:00:00.000Z" })
  @IsOptional()
  @IsDateString()
  startDate?: string;

  @ApiPropertyOptional({ example: "2024-01-31T23:59:59.999Z" })
  @IsOptional()
  @IsDateString()
  endDate?: string;
}

export class FunnelQueryDto {
  @ApiProperty({ example: "signup,onboarding,first_login" })
  @IsString()
  events: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  familyId?: string;

  @ApiPropertyOptional({ minimum: 1, maximum: 365 })
  @IsOptional()
  days?: number = 30;
}

export class RetentionQueryDto {
  @ApiProperty({ example: "2024-01-01T00:00:00.000Z" })
  @IsDateString()
  cohortDate: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  familyId?: string;
}
