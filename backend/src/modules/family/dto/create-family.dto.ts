import {
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsIn,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateFamilyDto {
  @ApiProperty({ example: "Smith Family" })
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({ example: "Asia/Kolkata", default: "Asia/Kolkata" })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({ example: "en", default: "en" })
  @IsOptional()
  @IsString()
  @IsIn(["en", "hi", "ta", "te", "bn", "mr", "gu", "kn", "ml", "pa"])
  language?: string;
}
