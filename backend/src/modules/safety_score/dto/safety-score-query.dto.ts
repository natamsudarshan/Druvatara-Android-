import { IsOptional, IsInt, Min, Max } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";
import { Transform } from "class-transformer";

export class SafetyScoreQueryDto {
  @ApiPropertyOptional({ minimum: 1, maximum: 365 })
  @IsOptional()
  @Transform(({ value }) => parseInt(value))
  @IsInt()
  @Min(1)
  @Max(365)
  days?: number = 30;
}
