import {
  IsString,
  IsIn,
  IsOptional,
  IsObject,
  IsBoolean,
} from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateAppRuleDto {
  @ApiPropertyOptional({
    example: "LIMIT",
    enum: ["BLOCK", "LIMIT", "ALLOW", "ESSENTIAL"],
  })
  @IsOptional()
  @IsIn(["BLOCK", "LIMIT", "ALLOW", "ESSENTIAL"])
  ruleType?: "BLOCK" | "LIMIT" | "ALLOW" | "ESSENTIAL";

  @ApiPropertyOptional({ example: "BLOCK", enum: ["BLOCK", "ALLOW", "WARN"] })
  @IsOptional()
  @IsIn(["BLOCK", "ALLOW", "WARN"])
  action?: "BLOCK" | "ALLOW" | "WARN";

  @ApiPropertyOptional({ example: '{ "limitMs": 7200000 }' })
  @IsOptional()
  @IsObject()
  config?: Record<string, any>;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
