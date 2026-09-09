import {
  IsString,
  IsIn,
  IsOptional,
  IsObject,
  IsBoolean,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateAppRuleDto {
  @ApiProperty({ example: "com.instagram.android" })
  @IsString()
  packageName: string;

  @ApiProperty({
    example: "LIMIT",
    enum: ["BLOCK", "LIMIT", "ALLOW", "ESSENTIAL"],
  })
  @IsIn(["BLOCK", "LIMIT", "ALLOW", "ESSENTIAL"])
  ruleType: "BLOCK" | "LIMIT" | "ALLOW" | "ESSENTIAL";

  @ApiProperty({ example: "BLOCK", enum: ["BLOCK", "ALLOW", "WARN"] })
  @IsIn(["BLOCK", "ALLOW", "WARN"])
  action: "BLOCK" | "ALLOW" | "WARN";

  @ApiPropertyOptional({ example: '{ "limitMs": 3600000 }' })
  @IsOptional()
  @IsObject()
  config?: Record<string, any>;
}
