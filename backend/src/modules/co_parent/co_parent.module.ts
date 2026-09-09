import { Module } from "@nestjs/common";
import { CoParentController } from "./co_parent.controller";
import { CoParentService } from "./co_parent.service";

@Module({
  controllers: [CoParentController],
  providers: [CoParentService],
  exports: [CoParentService],
})
export class CoParentModule {}
