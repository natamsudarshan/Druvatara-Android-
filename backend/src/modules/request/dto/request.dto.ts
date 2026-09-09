import { IsString, IsOptional, IsEnum, IsObject } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { RequestType, RequestStatus } from "@prisma/client";

export class CreateRequestDto {
  @ApiProperty({ enum: RequestType })
  @IsEnum(RequestType)
  type: RequestType;

  @ApiProperty({ example: "com.instagram.android" })
  @IsString()
  resource: string;

  @ApiPropertyOptional({ example: "Instagram" })
  @IsOptional()
  @IsString()
  resourceName?: string;

  @ApiProperty({ example: { additionalMinutes: 30 } })
  @IsObject()
  requestedValue: Record<string, any>;

  @ApiPropertyOptional({ example: { currentLimit: 60 } })
  @IsOptional()
  @IsObject()
  currentValue?: Record<string, any>;

  @ApiPropertyOptional({ example: "Please allow me more time" })
  @IsOptional()
  @IsString()
  childMessage?: string;
}

export class DecideRequestDto {
  @ApiProperty({ enum: ["APPROVED", "MODIFIED", "REJECTED"] })
  @IsEnum(["APPROVED", "MODIFIED", "REJECTED"])
  status: "APPROVED" | "MODIFIED" | "REJECTED";

  @ApiPropertyOptional({ example: "Approved for today only" })
  @IsOptional()
  @IsString()
  parentMessage?: string;

  @ApiPropertyOptional({ example: { additionalMinutes: 15 } })
  @IsOptional()
  @IsObject()
  modifiedValue?: Record<string, any>;
}

export class RequestQueryDto {
  @ApiPropertyOptional({ enum: RequestStatus })
  @IsOptional()
  @IsEnum(RequestStatus)
  status?: RequestStatus;
}
