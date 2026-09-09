import {
  IsString,
  IsOptional,
  MinLength,
  MaxLength,
  IsIn,
} from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateUserDto {
  @ApiPropertyOptional({ example: "John Doe" })
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

  @ApiPropertyOptional({ example: "https://example.com/avatar.png" })
  @IsOptional()
  @IsString()
  avatarUrl?: string;
}
