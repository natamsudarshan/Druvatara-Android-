import { IsString, IsUrl } from "class-validator";
import { ApiProperty } from "@nestjs/swagger";

export class CheckUrlDto {
  @ApiProperty({ example: "https://example.com" })
  @IsString()
  @IsUrl()
  url: string;

  @ApiProperty({ example: "child-id-123" })
  @IsString()
  childId: string;
}
