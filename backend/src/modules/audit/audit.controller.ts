import { Controller, Get, Query, UseGuards } from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { AuditService } from "./audit.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { AdminAuthGuard } from "../../common/guards/jwt-auth.guard";
import { AuditAction } from "@prisma/client";
import { AuditQueryDto } from "./dto/audit-query.dto";

@ApiTags("Audit")
@Controller("admin/audit")
@UseGuards(AdminAuthGuard)
@ApiBearerAuth()
export class AuditController {
  constructor(private auditService: AuditService) {}

  @Get()
  @ApiOperation({ summary: "Get audit logs" })
  async getLogs(@Query() query: AuditQueryDto) {
    const result = await this.auditService.getLogs({
      ...query,
      startDate: query.startDate ? new Date(query.startDate) : undefined,
      endDate: query.endDate ? new Date(query.endDate) : undefined,
    });
    return { success: true, data: result };
  }
}
