import { Module } from "@nestjs/common";
import { ScreenTimeController } from "./screen_time.controller";
import { ScreenTimeService } from "./screen_time.service";

@Module({
  controllers: [ScreenTimeController],
  providers: [ScreenTimeService],
  exports: [ScreenTimeService],
})
export class ScreenTimeModule {}
