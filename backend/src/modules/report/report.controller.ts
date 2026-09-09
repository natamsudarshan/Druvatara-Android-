import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from "@nestjs/common";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";
import { ReportService } from "./report.service";
import { JwtAuthGuard } from "../../common/guards/jwt-auth.guard";
import { CurrentUser } from "../../common/decorators/current-user.decorator";
import { GenerateReportDto, ReportQueryDto } from "./dto";

@ApiTags("Reports")
@Controller("children/:childId/reports")
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class ReportController {
  constructor(private reportService: ReportService) {}

  @Get("types")
  @ApiOperation({ summary: "Get available report types" })
  async getTypes() {
    const types = await this.reportService.getReportTypes();
    return { success: true, data: types };
  }

  @Get()
  @ApiOperation({ summary: "Get reports for child" })
  async getReports(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Query() query: ReportQueryDto,
  ) {
    const reports = await this.reportService.getReports(
      "",
      childId,
      userId,
      query.type,
    );
    return { success: true, data: reports };
  }

  @Post("generate")
  @ApiOperation({ summary: "Generate a new report" })
  async generateReport(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Body() generateReportDto: GenerateReportDto,
  ) {
    const report = await this.reportService.generateReport(
      "",
      childId,
      userId,
      generateReportDto.type,
      new Date(generateReportDto.periodStart),
      new Date(generateReportDto.periodEnd),
    );
    return { success: true, data: report };
  }

  @Get(":reportId")
  @ApiOperation({ summary: "Get report by ID" })
  async getReport(
    @CurrentUser("sub") userId: string,
    @Param("childId") childId: string,
    @Param("reportId") reportId: string,
  ) {
    const report = await this.reportService.getReportById(reportId, userId);
    return { success: true, data: report };
  }
}
