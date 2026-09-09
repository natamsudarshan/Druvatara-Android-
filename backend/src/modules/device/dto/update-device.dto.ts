import { IsString, IsOptional } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateDeviceDto {
  @ApiPropertyOptional({ example: "Alex Phone" })
  @IsOptional()
  @IsString()
  deviceName?: string;

  @ApiPropertyOptional({ example: "34" })
  @IsOptional()
  @IsString()
  platformVersion?: string;

  @ApiPropertyOptional({ example: "1.0.1" })
  @IsOptional()
  @IsString()
  appVersion?: string;

  @ApiPropertyOptional({ example: "101" })
  @IsOptional()
  @IsString()
  buildNumber?: string;
}
