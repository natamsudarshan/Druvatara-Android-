import {
  IsString,
  IsOptional,
  IsNumber,
  Min,
  Max,
  IsEnum,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { PaymentProvider } from "@prisma/client";

export class CreatePaymentDto {
  @ApiProperty({ enum: PaymentProvider })
  @IsEnum(PaymentProvider)
  provider: PaymentProvider;

  @ApiProperty({ example: 99900 })
  @IsNumber()
  @Min(1)
  amount: number;

  @ApiProperty({ example: "INR" })
  @IsString()
  currency: string = "INR";

  @ApiProperty({ example: "Subscription renewal" })
  @IsString()
  description: string;

  @ApiPropertyOptional()
  @IsOptional()
  metadata?: Record<string, any>;
}
