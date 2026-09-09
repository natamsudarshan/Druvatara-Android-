import {
  IsString,
  IsIn,
  IsOptional,
  IsBoolean,
  IsArray,
} from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateWebSafetyDto {
  @ApiPropertyOptional({
    example: "STRICT",
    enum: ["STRICT", "MODERATE", "BASIC", "OFF"],
  })
  @IsOptional()
  @IsIn(["STRICT", "MODERATE", "BASIC", "OFF"])
  mode?: "STRICT" | "MODERATE" | "BASIC" | "OFF";

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  safeSearch?: boolean;

  @ApiPropertyOptional({ example: ["ADULT", "GAMBLING", "VIOLENCE"] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  categories?: string[];

  @ApiPropertyOptional({ example: ["example.com", "trusted.org"] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  allowlist?: string[];

  @ApiPropertyOptional({ example: ["blocked.com", "malicious.net"] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  blocklist?: string[];
}
