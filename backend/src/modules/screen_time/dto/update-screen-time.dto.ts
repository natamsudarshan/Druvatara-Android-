import { IsOptional, IsArray, IsNumber, IsString } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateScreenTimeDto {
  @ApiPropertyOptional({ example: 10800000 })
  @IsOptional()
  @IsNumber()
  dailyLimitMs?: number;

  @ApiPropertyOptional({
    example: ["com.whatsapp", "com.google.android.dialer"],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  essentialApps?: string[];

  @ApiPropertyOptional({ example: [900000, 300000, 60000] })
  @IsOptional()
  @IsArray()
  @IsNumber({}, { each: true })
  warningThresholds?: number[];
}
