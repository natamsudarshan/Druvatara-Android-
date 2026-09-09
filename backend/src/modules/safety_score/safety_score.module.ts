import { Module } from "@nestjs/common";
import { SafetyScoreController } from "./safety_score.controller";
import { SafetyScoreService } from "./safety_score.service";

@Module({
  controllers: [SafetyScoreController],
  providers: [SafetyScoreService],
  exports: [SafetyScoreService],
})
export class SafetyScoreModule {}
