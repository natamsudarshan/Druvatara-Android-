import {
  IsString,
  IsOptional,
  IsIn,
  IsInt,
  Min,
  Max,
  MinLength,
  MaxLength,
  IsObject,
} from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateChildDto {
  @ApiPropertyOptional({ example: "Alex" })
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  displayName?: string;

  @ApiPropertyOptional({
    example: "TEENAGER",
    enum: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
  })
  @IsOptional()
  @IsIn(["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"])
  ageGroup?: "TODDLER" | "YOUNG_CHILD" | "PRE_TEEN" | "TEENAGER";

  @ApiPropertyOptional({ example: "avatar_05" })
  @IsOptional()
  @IsString()
  avatarId?: string;

  @ApiPropertyOptional({ example: 2014 })
  @IsOptional()
  @IsInt()
  @Min(2005)
  @Max(new Date().getFullYear())
  birthYear?: number;

  @ApiPropertyOptional({ example: 6 })
  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(12)
  birthMonth?: number;

  @ApiPropertyOptional({ example: '{ "screenTimeLimit": 10800000 }' })
  @IsOptional()
  @IsObject()
  settings?: Record<string, any>;
}
