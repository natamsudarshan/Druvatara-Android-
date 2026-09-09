import {
  IsString,
  IsOptional,
  IsIn,
  IsInt,
  Min,
  Max,
  MinLength,
  MaxLength,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateChildDto {
  @ApiProperty({ example: "Alex" })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  displayName: string;

  @ApiProperty({
    example: "PRE_TEEN",
    enum: ["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"],
  })
  @IsIn(["TODDLER", "YOUNG_CHILD", "PRE_TEEN", "TEENAGER"])
  ageGroup: "TODDLER" | "YOUNG_CHILD" | "PRE_TEEN" | "TEENAGER";

  @ApiPropertyOptional({ example: "avatar_04" })
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
}
