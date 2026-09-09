import { IsOptional, IsString } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class ReportQueryDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  type?: string;
}
