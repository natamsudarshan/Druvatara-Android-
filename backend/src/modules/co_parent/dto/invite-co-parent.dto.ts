import { IsEmail, IsString, IsOptional, IsBoolean } from "class-validator";
import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";

export class InviteCoParentDto {
  @ApiProperty({ example: "coparent@example.com" })
  @IsEmail()
  email: string;

  @ApiProperty({ example: "child_abc123" })
  @IsString()
  childId: string;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  viewAlerts?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  viewLocation?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  approveRequests?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  modifyPolicies?: boolean;

  @ApiPropertyOptional({ example: true })
  @IsOptional()
  @IsBoolean()
  viewReports?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean()
  manageDevices?: boolean;
}
