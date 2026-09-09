import { Module } from "@nestjs/common";
import { ThreatIntelController } from "./threat_intel.controller";
import { ThreatIntelService } from "./threat_intel.service";

@Module({
  controllers: [ThreatIntelController],
  providers: [ThreatIntelService],
  exports: [ThreatIntelService],
})
export class ThreatIntelModule {}
