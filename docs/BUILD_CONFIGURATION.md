# Flutter Build & Configuration Guide

## Environment Setup

The app now supports three environments: **development**, **staging**, and **production**.

### Building for Different Environments

#### Development Build
```bash
# Android
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1

# iOS (using localhost)
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1

# With all config
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-client-id \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

#### Staging Build
```bash
flutter run --release \
  --dart-define=API_BASE_URL=https://staging-api.na3eeman.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-staging-client-id \
  --flavor staging
```

#### Production Build
```bash
# Android APK
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.na3eeman.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-prod-client-id \
  --dart-define=APPLE_CLIENT_ID=your-apple-id \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_... \
  --flavor production

# iOS
flutter build ios --release \
  --dart-define=API_BASE_URL=https://api.na3eeman.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-prod-client-id \
  --dart-define=APPLE_CLIENT_ID=your-apple-id \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_... \
  --flavor production
```

## Configuration Variables

### Required Variables
- **API_BASE_URL**: Backend API URL (must include `/api/v1`)

### Optional Variables
- **GOOGLE_CLIENT_ID**: Google OAuth client ID
- **APPLE_CLIENT_ID**: Apple Sign In client ID
- **STRIPE_PUBLISHABLE_KEY**: Stripe publishable key (pk_test_* or pk_live_*)

## Environment Files

### Create .env files (for local development)

**`.env.development`** (git-ignored):
```env
API_BASE_URL=http://localhost:8000/api/v1
GOOGLE_CLIENT_ID=your-dev-client-id
APPLE_CLIENT_ID=your-dev-apple-id
STRIPE_PUBLISHABLE_KEY=pk_test_your_test_key
```

**`.env.production`** (git-ignored):
```env
API_BASE_URL=https://api.na3eeman.com/api/v1
GOOGLE_CLIENT_ID=your-prod-client-id
APPLE_CLIENT_ID=your-prod-apple-id
STRIPE_PUBLISHABLE_KEY=pk_live_your_live_key
```

## VS Code Launch Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Development",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_BASE_URL=http://localhost:8000/api/v1",
        "--dart-define=GOOGLE_CLIENT_ID=your-dev-client-id"
      ]
    },
    {
      "name": "Staging",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_BASE_URL=https://staging-api.na3eeman.com/api/v1",
        "--dart-define=GOOGLE_CLIENT_ID=your-staging-client-id"
      ],
      "flutterMode": "release"
    },
    {
      "name": "Production",
      "request": "launch",
      "type": "dart",
      "program": "lib/main.dart",
      "args": [
        "--dart-define=API_BASE_URL=https://api.na3eeman.com/api/v1",
        "--dart-define=GOOGLE_CLIENT_ID=your-prod-client-id",
        "--dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_..."
      ],
      "flutterMode": "release"
    }
  ]
}
```

## Updating main.dart

Add this to the beginning of `main()`:

```dart
import 'package:na3eeman/config/environment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize environment (defaults to dev if not specified)
  await Environment.init(flavor: AppFlavor.dev);
  
  // Rest of your initialization...
  runApp(MyApp());
}
```

## API Endpoints Changes

### Old Format (Before)
```dart
// Hardcoded base URL
const baseUrl = 'https://your-api-url.com/api';

// Old endpoint
ApiService().get('/auth/login');  // Wrong!
```

### New Format (After)
```dart
import 'package:na3eeman/Services/api/endpoints.dart';
import 'package:na3eeman/Helpers/config.dart';

// Base URL from environment
final baseUrl = AppConfig.baseUrl;  // https://api.na3eeman.com/api/v1

// New endpoint
ApiService().get(Endpoints.login);  // Correct: /auth/login/
```

### Endpoint Helper Methods

```dart
import 'package:na3eeman/Services/api/endpoints.dart';

// Pagination
final url = Endpoints.withPagination(Endpoints.salons, page: 2, pageSize: 20);
// /salons/salons/?page=2&page_size=20

// Search
final searchUrl = Endpoints.withSearch(Endpoints.salons, 'barber');
// /salons/salons/?search=barber

// Filters
final filteredUrl = Endpoints.withFilters(Endpoints.salons, {'city': 'Riyadh', 'rating_min': 4});
// /salons/salons/?city=Riyadh&rating_min=4

// Path parameters
final salonUrl = Endpoints.salonDetails(123);
// /salons/salons/123/

// Nearby salons
final nearbyUrl = Endpoints.getNearbySalonsUrl(
  latitude: 24.7136,
  longitude: 46.6753,
  radiusKm: 5.0,
);
// /salons/salons/?lat=24.7136&lng=46.6753&radius=5.0
```

## Testing Different Environments

### Test with Local Backend
```bash
# Start Django backend on localhost:8000
cd ../na3eeman_be
source .venv/bin/activate
export DJANGO_ENV=development
python manage.py runserver

# Run Flutter app pointing to local backend
cd ../na3eeman
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api/v1
```

### Test with Staging
```bash
flutter run --dart-define=API_BASE_URL=https://staging-api.na3eeman.com/api/v1
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Build Flutter App

on:
  push:
    branches: [main, develop]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK (Staging)
        if: github.ref == 'refs/heads/develop'
        run: |
          flutter build apk --release \
            --dart-define=API_BASE_URL=${{ secrets.STAGING_API_URL }} \
            --dart-define=GOOGLE_CLIENT_ID=${{ secrets.GOOGLE_CLIENT_ID_STAGING }}
      
      - name: Build APK (Production)
        if: github.ref == 'refs/heads/main'
        run: |
          flutter build apk --release \
            --dart-define=API_BASE_URL=${{ secrets.PROD_API_URL }} \
            --dart-define=GOOGLE_CLIENT_ID=${{ secrets.GOOGLE_CLIENT_ID_PROD }} \
            --dart-define=STRIPE_PUBLISHABLE_KEY=${{ secrets.STRIPE_KEY_PROD }}
```

## Verifying Configuration

Add this debug print in `main()`:

```dart
void main() async {
  await Environment.init(flavor: AppFlavor.dev);
  
  if (Environment.isDevelopment) {
    print('=== DEVELOPMENT MODE ===');
    print('API URL: ${AppConfig.baseUrl}');
    print('Logging: ${AppConfig.enableLogging}');
    print('Analytics: ${AppConfig.enableAnalytics}');
  }
  
  runApp(MyApp());
}
```

## Common Issues

### 1. "Too many positional arguments: 0 expected, but 1 found"
- **Cause**: Trying to use old endpoint format
- **Fix**: Use `Endpoints.xxx` constants instead of strings

### 2. "404 Not Found" errors
- **Cause**: Endpoint mismatch between app and backend
- **Fix**: Verify backend is using `/api/v1/` prefix and endpoints match

### 3. "Connection refused" on Android emulator
- **Cause**: `localhost` doesn't work on Android emulator
- **Fix**: Use `10.0.2.2` instead of `localhost` for Android emulator

### 4. API calls timeout
- **Cause**: Wrong API URL or backend not running
- **Fix**: Verify `API_BASE_URL` and that backend is accessible

## Migration Checklist

- [ ] Update all imports to use `Endpoints` class
- [ ] Replace hardcoded URLs with `Endpoints.xxx` constants
- [ ] Test login flow with new `/auth/login/` endpoint
- [ ] Test salon listing with new `/salons/salons/` endpoint
- [ ] Test appointments with new `/salons/appointments/` endpoint
- [ ] Test loyalty with new `/loyalty/balance/` endpoint
- [ ] Verify token refresh works with `/auth/token/refresh/`
- [ ] Test on Android emulator (use 10.0.2.2)
- [ ] Test on iOS simulator (use localhost)
- [ ] Test on physical device (use your computer's IP or staging URL)

## Next Steps

See `docs/FLUTTER_CHANGES.md` for detailed migration instructions for the rest of the app.
