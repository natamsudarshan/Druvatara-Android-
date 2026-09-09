import { Module } from "@nestjs/common";
import { FeatureFlagController } from "./feature_flag.controller";
import { FeatureFlagService } from "./feature_flag.service";

@Module({
  controllers: [FeatureFlagController],
  providers: [FeatureFlagService],
  exports: [FeatureFlagService],
})
export class FeatureFlagModule {}
