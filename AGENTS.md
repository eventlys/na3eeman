# AGENTS.md

Guidance for AI coding agents working on this repository.

## Project Overview

**Na3eeman** (`na3eeman`, Android applicationId `com.na3eman.app`) is a Flutter
mobile application for salon/barbershop booking and business management. It
serves multiple user roles — customers, salon **owners** (with subscription
tiers: Artisan, Studio, Elite, Empire), staff, and admins — with features
covering appointments, inventory, loyalty points, offers, subscriptions,
disputes, and analytics.

- **Framework:** Flutter (Dart SDK `^3.8.1`), app version `1.3.2+9`
- **Platforms:** Android (primary, deployed to Play Store), iOS, Web, Windows,
  macOS, Linux scaffolds present
- **Localization:** English (`en-US`) and Arabic (`ar-EG`) via
  `easy_localization`; translation files in `assets/Lang/`. Default currency
  is SAR.
- **Backend:** REST API (base URL injected per environment), Firebase (Core,
  Messaging, Analytics), Sentry for crash reporting.

### Key configuration files

| File | Purpose |
|---|---|
| `pubspec.yaml` / `pubspec.lock` | Dart/Flutter dependencies and asset declarations |
| `analysis_options.yaml` | `flutter_lints` rules; analyzer excludes platform folders (`android/`, `ios/`, etc.) |
| `lib/config/environment.dart` | Flavor system (`dev` / `staging` / `prod`), environment config loading |
| `lib/Helpers/config.dart` | `AppConfig` — static app constants and feature flags backed by `Environment` |
| `.env.example` | Template for required secrets (API URL, Firebase, Google Maps, Stripe, Twilio, Cloudflare) |
| `.github/workflows/flutter-ci.yml` | CI/CD pipeline (format, analyze, test, Trivy scan, build, Play Store deploy) |
| `.github/coderabbit.yaml` | CodeRabbit review config (security & performance profile) |
| `android/app/build.gradle.kts` | Android build config; release signing via untracked `key.properties` |

## Architecture & Code Organization

The app uses **Provider** for state management (`lib/Providers/`, registered in
`lib/Providers/provider_wrapper.dart`) and named routes
(`lib/Routes/routes.dart`, route names in `lib/Routes/route_names.dart`).
Dependency injection is via **constructor injection with lazy singleton
defaults** (e.g. `XProvider({ApiService? apiService}) : _api = apiService ?? ApiService()`);
`ApiService` is a `package:http` singleton. The old GetIt `service_locator.dart`
and `DependencyInjection` were removed (they had zero live callers).
`lib/main.dart` bootstraps in this order: environment → Firebase → storage →
crash reporting → notifications/FCM → background service → security scan →
`runApp`.

Directory layout under `lib/` (~340 Dart files):

- `app/` — root app widget (`app.dart`)
- `config/environment.dart` — flavor-based config (`AppFlavor`, `EnvironmentConfig`)
- `core/` — cross-cutting building blocks: `auth/` (role-based access:
  `role_permission_manager.dart`, `role_based_route.dart`, `role_based_widget.dart`),
  `services/` (`auth_service.dart`, `feature_access_service.dart` — subscription
  tier feature gating), `router/`, `theme/` (colors, typography, spacing),
  `enums/`, `middleware/` (permission guards), `widgets/` (reusable UI),
  `utils/`
- `Packages/features/` — feature modules, each typically with `pages/`,
  `widgets/`, `overlays/`: `auth`, `onboarding`, `home`, `salon`, `owner`,
  `staff`, `admin`, `appointments`, `profile`, `subscription`, `disputes`,
  `navigation` (+ a duplicate-cased `Navigations/` — be careful on
  case-sensitive filesystems), `cart_commented` (disabled cart feature)
- `Packages/Core/` — shared core UI: `widgets/` (incl. `base/error_boundary.dart`),
  `themes/`, `constants/`, `backgrounds/`, `utils/`
- `Services/` — layered backend access:
  - `api/` — `api_service.dart` (`package:http` singleton with auth headers,
    timeout, response envelope handling), `api_interceptor_service.dart`,
    `throttler.dart`, `endpoints.dart`
  - `repositories/` — `auth_repository.dart`, `salon_repository.dart`, plus the
    focused set split from the old `BusinessService` facade (`appointment_`,
    `staff_`, `salon_catalog_`, `payment_`, `loyalty_`, `review_`,
    `subscription_`, `user_`, `report_`)
  - `use_cases/` — `auth_use_cases.dart`, `appointment_use_cases.dart`
    (validation-bearing only; pure pass-throughs were removed)
  - `notification/fcm_service.dart`, `core/` (performance, app management),
  `utils/` (location, files, filters), `storage_service.dart`, `security_service.dart`
- `Providers/` — `ChangeNotifier` providers per feature (`auth_provider.dart`,
  `salon_provider.dart`, `owner_provider.dart`, `subscription_provider.dart`, …),
  registered in `provider_wrapper.dart` (the single registry) and re-exported by
  `main_providers.dart` / `app_providers.dart`
- `Models/` — data models grouped by domain: `auth/`, `salon/`, `appointments/`,
  `commerce/`, `inventory/`, `loyalty/`, `reports/`, `staff/`, `subscription/`
  (note: a duplicate `subscriptions/` folder also exists)
- `Helpers/` — utility/helper classes (`logger.dart` → `AppLogger`,
  `validation_helper.dart`, `storage_helper.dart`, `security_helper.dart`,
  `notification_helper.dart`, …)
- `Routes/routes.dart` — named route table

### Data flow convention

UI (feature pages/widgets) → Provider (`ChangeNotifier`) → Use Case (only where
real validation logic lives) → Repository → `ApiService` (`package:http`) → REST
API. Enforced in CI by `scripts/check_architecture.py` (no `Services/api/` or
`Services/repositories/` imports allowed under `lib/Packages/`).

## Build and Run

```bash
flutter pub get

# Run with a flavor (defaults to dev if --dart-define is omitted)
flutter run --dart-define=FLAVOR=dev

# Environment files are required: .env, .env.dev (declared as assets in pubspec.yaml).
# Copy .env.example and fill in values. CI creates dummy files if missing.
cp .env.example .env

# Release builds (CI passes all config via --dart-define, see flutter-ci.yml)
flutter build apk --release --dart-define=FLAVOR=prod --dart-define=API_BASE_URL=... 
flutter build appbundle --release --dart-define=FLAVOR=prod ...
```

Android release signing needs an untracked `android/key.properties`
(`keyAlias`, `keyPassword`, `storeFile`, `storePassword`); without it the
release build falls back to the debug signing config.

Launcher icons: `dart run flutter_launcher_icons` (config in `pubspec.yaml`).

## Testing

```bash
flutter test                 # run unit/widget tests
flutter test --coverage      # CI runs this; output to coverage/lcov.info
```

- Tests live in `test/` mirroring the source layout (currently only
  `test/owner/feature_access_service_test.dart` plus `test/test_helpers.dart`).
- `flutter_test` and `mockito` are used; `test/test_helpers.dart` provides
  shared fixtures (`TestData`) and `setupTestEnvironment()`.
- When adding behavior to `lib/core/` services (e.g. feature access,
  permissions), add matching tests under `test/` in the same folder structure.

## Lint and Format

CI enforces all of the following on pushes/PRs to `main`, `develop`, `stg`
(Flutter 3.44.0 stable, Java 17):

```bash
dart format --set-exit-if-changed .   # formatting is enforced — format before committing
dart analyze && flutter analyze        # must be clean
flutter test --coverage                # must pass
trivy fs --severity HIGH,CRITICAL .    # security scan (HIGH/CRITICAL fails the build)
```

Lint rules come from `package:flutter_lints/flutter.yaml` (v6). The analyzer
excludes `build/` and all platform directories. `asset_does_not_exist` is
ignored project-wide.

## Deployment

Defined entirely in `.github/workflows/flutter-ci.yml`:

1. Format → analyze → test → Trivy security scan.
2. Build release AAB and APK with all config injected via `--dart-define`
   (GitHub vars/secrets).
3. On `main` and `stg` only: authenticate to Google Cloud (Workload Identity),
   fetch the Play Store service-account key from Secret Manager, and upload
   the AAB to the Play Store track defined by `PLAY_STORE_TRACK` (default
   `closed`).

`scripts/blutter_scan.sh` runs a local Blutter (Checkmarx) security scan
against the release APK via Docker.

Utility scripts live in `scripts/`: `check_packages.dart` (pubspec dependency
versions), `deduplicate_lang.py`, and the Phase-5 CI gate scripts
(`check_coverage.py`, `check_locale_parity.py`, `check_architecture.py`,
`check_dead_code.py`).

## Conventions

- **Language:** Code, comments, and docs are in English (UI strings are
  localized in `assets/Lang/*.json`).
- **Naming:** Folder names are inconsistent in case (`Helpers/`, `Models/`,
  `Packages/`, `Providers/`, `Routes/`, `Services/` are capitalized; `app/`,
  `config/`, `core/` are lowercase). Match the existing folder you are editing
  rather than renaming.
- **State management:** Use Provider/`ChangeNotifier` (register new providers
  in `lib/Providers/provider_wrapper.dart`). Provider is the established pattern.
- **DI:** Constructor-inject dependencies with a lazy singleton default
  (e.g. `XProvider({ApiService? apiService}) : _api = apiService ?? ApiService()`).
  No GetIt locator — it was removed.
- **Config:** Never hardcode URLs/keys. Read them through `Environment.config`
  / `AppConfig`, sourced from `.env*` files or `--dart-define`.
- **Logging:** Use `AppLogger` (`lib/Helpers/logger.dart`), gated by
  `AppConfig.enableLogging`; avoid bare `print`.
- **Errors:** The app is wrapped in an `ErrorBoundary`; global handling is set
  up by `GlobalErrorHandler.setup()`.

## Security Considerations

- **Secrets:** Never commit real `.env` files (`.env.example` is the template;
  `.env*` are git-ignored but bundled as assets at runtime — do not log their
  contents). API keys come from `.env*` / `--dart-define` / CI secrets.
- **Runtime hardening:** `SecurityService` performs a root/tamper scan at
  startup and controls screenshot prevention
  (`flutter_windowmanager_plus`); sensitive screens reinforce it.
- **Storage:** Use `flutter_secure_storage` / the existing storage helpers for
  tokens and sensitive data, not plain `shared_preferences`.
- **Access control:** Role-based UI/routes go through
  `lib/core/auth/role_permission_manager.dart`; owner features are gated by
  subscription tier via `FeatureAccessService` (`lib/core/services/feature_access_service.dart`)
  — keep these checks when adding gated features.
- **CI gate:** Trivy fails the build on HIGH/CRITICAL findings; CodeRabbit
  reviews PRs with a security/performance profile.
