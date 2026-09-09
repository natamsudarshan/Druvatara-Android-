# Druvatara Guardian

An AI-powered digital safety and family protection platform for Android and iOS.

## Project Structure

```
druvatara-guardian/
├── apps/
│   ├── guardian_parent/          # Flutter Parent Application
│   │   ├── lib/
│   │   │   ├── core/             # Core utilities (theme, router, localization)
│   │   │   ├── design_system/    # Shared design system
│   │   │   ├── features/         # Feature modules
│   │   │   │   ├── authentication/
│   │   │   │   ├── family/
│   │   │   │   ├── child/
│   │   │   │   ├── pairing/
│   │   │   │   ├── dashboard/
│   │   │   │   ├── devices/
│   │   │   │   ├── applications/
│   │   │   │   ├── screen_time/
│   │   │   │   ├── schedules/
│   │   │   │   ├── web_safety/
│   │   │   │   ├── location/
│   │   │   │   ├── alerts/
│   │   │   │   ├── reports/
│   │   │   │   ├── tara/
│   │   │   │   ├── requests/
│   │   │   │   ├── co_parent/
│   │   │   │   ├── subscription/
│   │   │   │   ├── account/
│   │   │   │   ├── privacy/
│   │   │   │   ├── support/
│   │   │   │   └── settings/
│   │   │   └── main.dart
│   │   └── pubspec.yaml
│   │
│   └── guardian_child/           # Flutter Child Companion Application
│       ├── lib/
│       │   ├── core/
│       │   ├── design_system/
│       │   ├── features/
│       │   │   ├── pairing/
│       │   │   ├── protection_status/
│       │   │   ├── screen_time/
│       │   │   ├── requests/
│       │   │   ├── permission_health/
│       │   │   ├── help/
│       │   │   └── privacy/
│       │   └── main.dart
│       └── pubspec.yaml
│
├── packages/
│   ├── design_system/            # Shared design system package
│   ├── api_client/               # Shared API client
│   ├── shared_models/            # Shared data models
│   ├── analytics/                # Analytics utilities
│   └── localisation/             # Localization utilities
│
├── android_native/
│   └── guardian_engine/          # Kotlin Native Protection Engine
│       └── src/main/kotlin/com/druvatara/guardian/
│           ├── engine/           # Main GuardianEngine orchestrator
│           ├── policy/           # Policy management & enforcement
│           ├── usage/            # App usage tracking
│           ├── app_inventory/    # Installed app detection
│           ├── app_control/      # App blocking/restriction
│           ├── screen_time/      # Screen time enforcement
│           ├── schedule/         # Bedtime/school schedules
│           ├── vpn/              # Local VPN web filtering
│           ├── location/         # Location tracking
│           ├── geofence/         # Geofencing
│           ├── device_health/    # Device health monitoring
│           ├── event_queue/      # Offline event queue
│           ├── sync/             # Backend synchronization
│           ├── boot_recovery/    # Boot recovery
│           ├── tamper_detection/ # Tamper/root detection
│           ├── permission/       # Permission management
│           ├── capability/       # Device capability detection
│           └── identity/         # Device identity & credentials
│
├── backend/                      # NestJS Backend API
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── prisma/
│   │   │   ├── prisma.module.ts
│   │   │   ├── prisma.service.ts
│   │   │   └── schema.prisma
│   │   ├── common/
│   │   │   ├── decorators/
│   │   │   ├── guards/
│   │   │   ├── filters/
│   │   │   ├── interceptors/
│   │   │   ├── pipes/
│   │   │   └── utils/
│   │   └── modules/
│   │       ├── auth/
│   │       ├── user/
│   │       ├── family/
│   │       ├── child/
│   │       ├── device/
│   │       ├── pairing/
│   │       ├── policy/
│   │       ├── application/
│   │       ├── usage/
│   │       ├── screen_time/
│   │       ├── schedule/
│   │       ├── filtering/
│   │       ├── threat_intel/
│   │       ├── location/
│   │       ├── geofence/
│   │       ├── alert/
│   │       ├── request/
│   │       ├── co_parent/
│   │       ├── tara/
│   │       ├── safety_score/
│   │       ├── report/
│   │       ├── notification/
│   │       ├── subscription/
│   │       ├── payment/
│   │       ├── support/
│   │       ├── admin/
│   │       ├── audit/
│   │       ├── analytics/
│   │       ├── feature_flag/
│   │       └── privacy/
│   ├── prisma/
│   ├── test/
│   ├── package.json
│   ├── tsconfig.json
│   └── nest-cli.json
│
├── infrastructure/
│   ├── docker/
│   │   └── Dockerfile.backend
│   ├── k8s/
│   └── terraform/
│
├── docs/
│
├── docker-compose.yml
├── .env.example
├── package.json (root - Turborepo)
└── README.md
```

## Technology Stack

### Mobile (Android)
- **UI Framework**: Flutter 3.19+ with Dart 3.3+
- **State Management**: Riverpod 2.5+
- **Navigation**: GoRouter 14+
- **Native Layer**: Kotlin with Android Jetpack
- **Background Processing**: WorkManager, Foreground Services
- **Local Database**: Drift (SQLite)
- **Secure Storage**: Flutter Secure Storage + Android Keystore
- **Push Notifications**: Firebase Cloud Messaging
- **Architecture**: Clean Architecture with feature modules

### Mobile (iOS) - Phase 2
- **UI Framework**: Flutter (shared) + Swift (native)
- **Native Frameworks**: Family Controls, Managed Settings, Device Activity
- **Push Notifications**: Apple Push Notification Service

### Backend
- **Framework**: NestJS 10+ with TypeScript
- **Database**: PostgreSQL 16 with Prisma ORM
- **Cache**: Redis 7
- **Message Queue**: Redis-backed queues (BullMQ)
- **Object Storage**: MinIO (S3-compatible)
- **Authentication**: JWT with rotating refresh tokens
- **API Documentation**: Swagger/OpenAPI
- **Validation**: class-validator + class-transformer
- **Testing**: Jest

### Infrastructure
- **Containerization**: Docker
- **Orchestration**: Kubernetes (planned)
- **IaC**: Terraform (planned)
- **CI/CD**: GitHub Actions
- **Monitoring**: Prometheus + Grafana + Sentry
- **Logging**: Structured JSON logs

## Key Features

### Parent App
- Family account management
- Child profile creation with age-appropriate defaults
- Device pairing via QR code / pairing code
- Real-time dashboard with protection status
- Screen time limits and schedules
- Application management and rules
- Web safety filtering (categories, safe search, allow/block lists)
- Location tracking and geofencing (safe zones)
- Safety alerts with TARA AI explanations
- Daily/weekly/monthly reports
- Child access requests with approve/reject
- Co-parent management with granular permissions
- Subscription management
- Privacy controls and data export

### Child App (Companion)
- Transparent protection status display
- Remaining screen time visualization
- Active schedule awareness
- Permission health monitoring
- Access request flow
- Help and privacy information
- Emergency access preserved

### Native Guardian Engine (Kotlin)
- **Policy Engine**: Deterministic precedence-based enforcement
- **Usage Engine**: UsageStatsManager integration
- **App Inventory**: Real-time app detection
- **App Control**: Multi-tier (Standard/Enhanced/Managed)
- **Screen Time**: Local enforcement with warnings
- **Schedules**: Bedtime, school time, custom schedules
- **VPN Filter**: Local VpnService for domain-based filtering
- **Location**: FusedLocationProvider with adaptive tracking
- **Geofencing**: Native geofencing + backend validation
- **Device Health**: Continuous protection status monitoring
- **Event Queue**: Offline-first with batch sync
- **Sync Engine**: Policy pull, health push, event upload
- **Boot Recovery**: Automatic service restoration
- **Tamper Detection**: Root, emulator, hooking framework detection

### Backend API
- **Authentication**: Multi-class (User, Device, Admin, Provider)
- **Family Management**: Multi-child, co-parent, invitations
- **Device Management**: Registration, health, commands
- **Policy System**: Versioned, device-targeted, transactional
- **Usage Analytics**: Aggregated summaries, screen time events
- **Web Safety**: Threat intelligence integration
- **Location Services**: Real-time + history + geofencing
- **Alerts**: Deduplication, severity, TARA explanations
- **Child Requests**: Temporary overrides with expiry
- **TARA AI**: Context-aware, safety-filtered responses
- **Safety Score**: Deterministic weighted scoring
- **Reports**: Async generation with data completeness
- **Subscriptions**: Multi-tier with Stripe/Razorpay
- **Privacy**: Data export, deletion, consent management

## Getting Started

### Prerequisites
- Node.js 20+
- Flutter 3.19+ (Dart 3.3+)
- Android Studio / Xcode
- Docker & Docker Compose
- PostgreSQL 16+ (or use Docker)
- Redis 7+ (or use Docker)

### Backend Setup

```bash
cd backend
cp .env.example .env
# Edit .env with your configuration

npm install
npm run db:generate
npm run db:push
npm run db:seed
npm run start:dev
```

Backend will be available at `http://localhost:3000`
API docs at `http://localhost:3000/docs`

### Database (Docker)

```bash
docker-compose up -d postgres redis minio
```

### Flutter Apps

```bash
# Parent app
cd apps/guardian_parent
flutter pub get
flutter run

# Child app
cd apps/guardian_child
flutter pub get
flutter run
```

### Android Native Engine

```bash
cd android_native
./gradlew :guardian_engine:build
```

## Architecture Principles

1. **Modular Monolith First** - Backend starts as modular monolith, extracts services when justified
2. **API-First Design** - All clients communicate via versioned REST APIs
3. **Mobile-Native Where Required** - Flutter for shared UI, Kotlin/Swift for OS integration
4. **Offline-First Child Protection** - Critical policies enforce locally during network loss
5. **Event-Driven Processing** - Async processing for device events, notifications, AI
6. **Privacy by Design** - Minimal data collection, on-device processing for sensitive functions
7. **Zero Trust** - Every request authenticated and authorized
8. **Provider Abstraction** - External services behind internal adapters
9. **Observability by Default** - Logs, metrics, traces for all critical workflows
10. **Druvatara Ownership** - Code, infrastructure, keys, accounts owned by Druvatara

## Security Considerations

- All API communication over HTTPS/TLS 1.3
- JWT access tokens (15min) + rotating refresh tokens (30d)
- Device-specific credentials with versioning and revocation
- Android Keystore / iOS Keychain for sensitive data
- Encrypted local databases (SQLCipher/Drift)
- Certificate pinning for critical endpoints
- Regular security scanning (OWASP, Snyk)
- Play Integrity / App Attest for device verification

## Privacy Compliance

- COPPA, GDPR, PDPA (India) compliant
- Age-appropriate design
- Data minimization - only collect what's necessary
- On-device processing for sensitive analysis
- Clear consent flows with granular controls
- Right to data export and deletion
- No advertising profiling of children
- Regular privacy impact assessments

## Development Workflow

1. **Feature Branching** - Branch from `main`, PR with review
2. **Conventional Commits** - `feat:`, `fix:`, `docs:`, etc.
3. **Automated Testing** - Unit, integration, E2E in CI
4. **Staging Deployment** - Auto-deploy on merge to `develop`
5. **Production Release** - Tagged releases with manual approval

## License

Proprietary - Druvatara 2026