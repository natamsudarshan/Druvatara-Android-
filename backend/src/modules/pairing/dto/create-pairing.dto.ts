import { IsString, IsIn, IsOptional } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreatePairingDto {
  @ApiProperty({ example: "fam_abc123" })
  @IsString()
  familyId: string;

  @ApiProperty({ example: "child_abc123" })
  @IsString()
  childId: string;

  @ApiProperty({ example: "ANDROID", enum: ["ANDROID", "IOS"] })
  @IsIn(["ANDROID", "IOS"])
  platform: "ANDROID" | "IOS";

  @ApiPropertyOptional({ example: "dev_abc123" })
  @IsOptional()
  @IsString()
  deviceInternalId?: string;
}
