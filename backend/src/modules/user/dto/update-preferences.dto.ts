import { IsObject, IsOptional } from "class-validator";
import { ApiPropertyOptional } from "@nestjs/swagger";

export class UpdatePreferencesDto {
  @ApiPropertyOptional({
    example:
      '{ "notifications": { "email": true, "push": true }, "theme": "system" }',
  })
  @IsOptional()
  @IsObject()
  preferences?: Record<string, any>;
}
