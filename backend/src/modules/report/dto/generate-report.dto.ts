import { IsString, IsOptional, IsDateString } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class GenerateReportDto {
  @ApiProperty({ example: "weekly_summary" })
  @IsString()
  type: string;

  @ApiProperty({ example: "2024-01-01T00:00:00.000Z" })
  @IsDateString()
  periodStart: string;

  @ApiProperty({ example: "2024-01-07T23:59:59.999Z" })
  @IsDateString()
  periodEnd: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  format?: "JSON" | "PDF" = "JSON";
}
