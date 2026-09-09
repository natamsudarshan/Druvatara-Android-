import { IsString, IsIn, IsOptional } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { PrivacyRequestType } from "@prisma/client";

export class CreatePrivacyRequestDto {
  @ApiProperty({
    enum: [
      "ACCESS",
      "RECTIFICATION",
      "ERASURE",
      "RESTRICTION",
      "PORTABILITY",
      "OBJECTION",
      "WITHDRAW_CONSENT",
    ],
  })
  @IsIn([
    "ACCESS",
    "RECTIFICATION",
    "ERASURE",
    "RESTRICTION",
    "PORTABILITY",
    "OBJECTION",
    "WITHDRAW_CONSENT",
  ])
  type: PrivacyRequestType;

  @ApiProperty()
  @IsString()
  description: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  childId?: string;
}
