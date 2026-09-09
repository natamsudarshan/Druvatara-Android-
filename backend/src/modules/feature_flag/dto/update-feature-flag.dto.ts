import { IsOptional, IsBoolean, IsInt, Min, Max } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdateFeatureFlagDto {
  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @ApiPropertyOptional({ example: 50, minimum: 0, maximum: 100 })
  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  rollout?: number;

  @ApiPropertyOptional({ example: {} })
  @IsOptional()
  rules?: Record<string, any>;
}
