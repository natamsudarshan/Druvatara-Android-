import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { ThrottlerModule, ThrottlerGuard } from "@nestjs/throttler";
import { ScheduleModule } from "@nestjs/schedule";
import { APP_GUARD } from "@nestjs/core";
import { PrismaModule } from "./prisma/prisma.module";
import { AuthModule } from "./modules/auth/auth.module";
import { UserModule } from "./modules/user/user.module";
import { FamilyModule } from "./modules/family/family.module";
import { ChildModule } from "./modules/child/child.module";
import { DeviceModule } from "./modules/device/device.module";
import { PairingModule } from "./modules/pairing/pairing.module";
import { PolicyModule } from "./modules/policy/policy.module";
import { ApplicationModule } from "./modules/application/application.module";
import { UsageModule } from "./modules/usage/usage.module";
import { ScreenTimeModule } from "./modules/screen_time/screen_time.module";
import { ScheduleModule as ScheduleModuleCustom } from "./modules/schedule/schedule.module";
import { FilteringModule } from "./modules/filtering/filtering.module";
import { ThreatIntelModule } from "./modules/threat_intel/threat_intel.module";
import { LocationModule } from "./modules/location/location.module";
import { GeofenceModule } from "./modules/geofence/geofence.module";
import { AlertModule } from "./modules/alert/alert.module";
import { RequestModule } from "./modules/request/request.module";
import { CoParentModule } from "./modules/co_parent/co_parent.module";
import { TaraModule } from "./modules/tara/tara.module";
import { SafetyScoreModule } from "./modules/safety_score/safety_score.module";
import { ReportModule } from "./modules/report/report.module";
import { NotificationModule } from "./modules/notification/notification.module";
import { SubscriptionModule } from "./modules/subscription/subscription.module";
import { PaymentModule } from "./modules/payment/payment.module";
import { SupportModule } from "./modules/support/support.module";
import { AdminModule } from "./modules/admin/admin.module";
import { AuditModule } from "./modules/audit/audit.module";
import { AnalyticsModule } from "./modules/analytics/analytics.module";
import { FeatureFlagModule } from "./modules/feature_flag/feature_flag.module";
import { PrivacyModule } from "./modules/privacy/privacy.module";

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: [".env.local", ".env"],
    }),
    ScheduleModule.forRoot(),
    ThrottlerModule.forRoot([
      {
        ttl: 60000,
        limit: 100,
      },
    ]),
    PrismaModule,
    AuthModule,
    UserModule,
    FamilyModule,
    ChildModule,
    DeviceModule,
    PairingModule,
    PolicyModule,
    ApplicationModule,
    UsageModule,
    ScreenTimeModule,
    ScheduleModuleCustom,
    FilteringModule,
    ThreatIntelModule,
    LocationModule,
    GeofenceModule,
    AlertModule,
    RequestModule,
    CoParentModule,
    TaraModule,
    SafetyScoreModule,
    ReportModule,
    NotificationModule,
    SubscriptionModule,
    PaymentModule,
    SupportModule,
    AdminModule,
    AuditModule,
    AnalyticsModule,
    FeatureFlagModule,
    PrivacyModule,
  ],
  providers: [
    {
      provide: APP_GUARD,
      useClass: ThrottlerGuard,
    },
  ],
})
export class AppModule {}
