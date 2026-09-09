import { Module } from "@nestjs/common";
import { FilteringController } from "./filtering.controller";
import { FilteringService } from "./filtering.service";

@Module({
  controllers: [FilteringController],
  providers: [FilteringService],
  exports: [FilteringService],
})
export class FilteringModule {}
