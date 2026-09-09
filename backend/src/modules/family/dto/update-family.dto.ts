import {
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsIn,
  IsObject,
} from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateFamilyDto {
  @ApiPropertyOptional({ example: "Smith Family" })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({ example: "Asia/Kolkata" })
  @IsOptional()
  @IsString()
  timezone?: string;

  @ApiPropertyOptional({ example: "en" })
  @IsOptional()
  @IsString()
  @IsIn(["en", "hi", "ta", "te", "bn", "mr", "gu", "kn", "ml", "pa"])
  language?: string;

  @ApiPropertyOptional({ example: '{ "notifications": { "email": true } }' })
  @IsOptional()
  @IsObject()
  settings?: Record<string, any>;
}
