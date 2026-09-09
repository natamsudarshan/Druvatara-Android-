import {
  IsArray,
  ValidateNested,
  IsString,
  IsNumber,
  IsOptional,
  Min,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Type } from "class-transformer";

export class UsageRecordItemDto {
  @ApiProperty({ example: "com.example.app" })
  @IsString()
  packageName: string;

  @ApiProperty({ example: 3600000 })
  @IsNumber()
  @Min(0)
  durationMs: number;

  @ApiProperty({ example: 5 })
  @IsNumber()
  @Min(0)
  launchCount: number;

  @ApiProperty({ example: "2024-01-15T10:30:00.000Z" })
  @IsString()
  firstUsedAt: string;

  @ApiProperty({ example: "2024-01-15T14:30:00.000Z" })
  @IsString()
  lastUsedAt: string;
}

export class RecordUsageDto {
  @ApiProperty({ type: [UsageRecordItemDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => UsageRecordItemDto)
  usageData: UsageRecordItemDto[];
}
