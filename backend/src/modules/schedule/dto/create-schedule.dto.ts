import {
  IsString,
  IsNumber,
  IsOptional,
  IsIn,
  IsBoolean,
  IsArray,
  Min,
  Max,
  MinLength,
  MaxLength,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateScheduleDto {
  @ApiProperty({ example: "Bedtime" })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  name: string;

  @ApiProperty({ example: "BEDTIME", enum: ["BEDTIME", "SCHOOL", "CUSTOM"] })
  @IsIn(["BEDTIME", "SCHOOL", "CUSTOM"])
  scheduleType: "BEDTIME" | "SCHOOL" | "CUSTOM";

  @ApiProperty({ example: "21:00" })
  @IsString()
  startTime: string;

  @ApiProperty({ example: "07:00" })
  @IsString()
  endTime: string;

  @ApiProperty({ example: [1, 2, 3, 4, 5, 6, 7] })
  @IsArray()
  @IsNumber({}, { each: true })
  @Min(1, { each: true })
  @Max(7, { each: true })
  days: number[];

  @ApiProperty({ example: "Asia/Kolkata" })
  @IsString()
  timezone: string;

  @ApiPropertyOptional({
    example: ["com.whatsapp", "com.google.android.dialer"],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  allowedApps?: string[];
}
