import { Module } from "@nestjs/common";
import { TaraController } from "./tara.controller";
import { TaraService } from "./tara.service";

@Module({
  controllers: [TaraController],
  providers: [TaraService],
  exports: [TaraService],
})
export class TaraModule {}
