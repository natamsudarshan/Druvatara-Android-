import {
  IsString,
  MinLength,
  MaxLength,
  IsOptional,
  IsIn,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateTicketDto {
  @ApiProperty({
    example: "VPN not connecting on Samsung device",
    minLength: 5,
    maxLength: 200,
  })
  @IsString()
  @MinLength(5)
  @MaxLength(200)
  subject: string;

  @ApiProperty({
    example: "The VPN keeps disconnecting...",
    minLength: 10,
    maxLength: 5000,
  })
  @IsString()
  @MinLength(10)
  @MaxLength(5000)
  description: string;

  @ApiProperty({
    example: "TECHNICAL",
    enum: ["TECHNICAL", "BILLING", "FEATURE_REQUEST", "PRIVACY", "OTHER"],
  })
  @IsIn(["TECHNICAL", "BILLING", "FEATURE_REQUEST", "PRIVACY", "OTHER"])
  category: "TECHNICAL" | "BILLING" | "FEATURE_REQUEST" | "PRIVACY" | "OTHER";

  @ApiPropertyOptional({
    example: "HIGH",
    enum: ["LOW", "MEDIUM", "HIGH", "URGENT"],
  })
  @IsOptional()
  @IsIn(["LOW", "MEDIUM", "HIGH", "URGENT"])
  priority?: "LOW" | "MEDIUM" | "HIGH" | "URGENT";
}
