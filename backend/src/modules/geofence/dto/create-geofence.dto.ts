import {
  IsString,
  IsNumber,
  IsOptional,
  IsIn,
  IsBoolean,
  Min,
  Max,
  MinLength,
  MaxLength,
} from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class CreateGeofenceDto {
  @ApiProperty({ example: "Home" })
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  name: string;

  @ApiProperty({ example: 12.9716 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  latitude: number;

  @ApiProperty({ example: 77.5946 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  longitude: number;

  @ApiProperty({ example: 500 })
  @IsNumber()
  @Min(50)
  @Max(50000)
  radiusMeters: number;

  @ApiPropertyOptional({ example: "CIRCLE", enum: ["CIRCLE", "POLYGON"] })
  @IsOptional()
  @IsIn(["CIRCLE", "POLYGON"])
  type?: "CIRCLE" | "POLYGON";

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  alertOnEnter?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  alertOnExit?: boolean;
}
