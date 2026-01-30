# Flutter Environment & API Configuration - Migration Guide

## 🎯 Overview

The Flutter app has been refactored to use a dynamic environment configuration system and updated API endpoints that align with the backend's `/api/v1/` structure.

## ✅ What's Been Updated

### 1. Configuration Files

#### **`lib/config/environment.dart`** (NEW)
- Environment management system with dev/staging/prod flavors
- Feature flags per environment
- API configuration (timeouts, retries)
- OAuth client IDs
- Payment provider keys

#### **`lib/Helpers/config.dart`** (REFACTORED)
- Now integrates with `Environment` system
- Dynamic values from environment
- Static constants for app-wide settings

#### **`lib/Services/api/endpoints.dart`** (COMPLETELY REWRITTEN)
- All endpoints aligned with backend `/api/v1/` structure
- Helper methods for pagination, search, filtering
- Path parameter helpers
- Legacy compatibility layer

#### **`lib/Services/api/api_service.dart`** (COMPLETELY REFACTORED)
- **702 lines → ~600 lines**
- Uses new `Endpoints` class throughout
- **Automatic token refresh** with retry queue
- Improved error handling
- Network retry logic
- Better logging integration
- Cleaner method signatures

#### **`lib/main.dart`** (UPDATED)
- Initializes `Environment` on startup
- Logs environment info in debug mode
- Uses dynamic app name and debug banner settings

## 🔄 Key Endpoint Changes

| Old Endpoint | New Endpoint | Notes |
|--------------|--------------|-------|
| `/auth/login` | `/auth/login/` | Trailing slash added |
| `/auth/profile` | `/auth/me/` | Renamed for clarity |
| `/auth/refresh` | `/auth/token/refresh/` | JWT endpoint structure |
| `/shops` | `/shops/shops/` | RESTful nesting |
| `/appointments` | `/shops/appointments/` | Moved under shops |
| `/loyalty/balance` | `/loyalty/balance/` | Consistent structure |

## 🚀 How to Use

### Running the App

#### Development (Local Backend)
```bash
flutter run \
  --dart-define=API_BASE_URL=http://localhost:8000/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-dev-client-id
```

**For Android Emulator** (use `10.0.2.2` instead of `localhost`):
```bash
flutter run \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

#### Staging
```bash
flutter run --release \
  --dart-define=API_BASE_URL=https://staging-api.na3eeman.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-staging-client-id
```

#### Production Build
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://api.na3eeman.com/api/v1 \
  --dart-define=GOOGLE_CLIENT_ID=your-prod-client-id \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_...
```

### Using the API Service

#### Before (Old Way)
```dart
// Hardcoded endpoints
final response = await ApiService().get('/auth/profile');
final shops = await ApiService().get('/shops?page=1&limit=20');
```

#### After (New Way)
```dart
import 'package:na3eeman/Services/api/endpoints.dart';
import 'package:na3eeman/Services/api/api_service.dart';

// Using Endpoints constants
final user = await ApiService().getCurrentUser();

// Using helper methods
final shops = await ApiService().getShops(
  page: 1,
  pageSize: 20,
  search: 'barber',
);

// Manual endpoint construction if needed
final endpoint = Endpoints.withPagination(Endpoints.shops, page: 2);
final response = await ApiService().get(endpoint);
```

### Token Refresh (Automatic)

The new `ApiService` automatically handles token refresh:

```dart
// No changes needed in your code!
// When a 401 is received:
// 1. ApiService automatically calls /auth/token/refresh/
// 2. Saves new access token
// 3. Retries the original request
// 4. Returns the result

try {
  final user = await ApiService().getCurrentUser();
  // Token refresh happens automatically if needed
} catch (e) {
  // Only thrown if refresh fails or user is truly logged out
}
```

### Network Retry Logic

Automatic retry for network failures:

```dart
// Automatically retries up to 3 times for network errors
final shops = await ApiService().getShops();
// If it fails due to network timeout, it will retry with exponential backoff
```

## 📝 Migration Checklist for Remaining Code

- [ ] Update all `ApiService()` calls that use old endpoints
- [ ] Replace hardcoded `/auth/profile` with `Endpoints.currentUser` or `getCurrentUser()`
- [ ] Replace manual pagination params with helper methods
- [ ] Update auth providers to handle new token structure
- [ ] Test login flow end-to-end
- [ ] Test shop listing and details
- [ ] Test appointment booking
- [ ] Test loyalty balance and redemption
- [ ] Verify token refresh works automatically
- [ ] Test on Android emulator (10.0.2.2)
- [ ] Test on iOS simulator (localhost)

## 🔧 Configuration Reference

### AppConfig (Static Values)
```dart
import 'package:na3eeman/Helpers/config.dart';

// API Configuration
AppConfig.baseUrl              // From environment
AppConfig.apiTimeout           // Duration(seconds: 30) in dev
AppConfig.maxRetries           // 3 retries

// Feature Flags
AppConfig.enableBiometricAuth  // true/false per environment
AppConfig.enableSocialLogin    // true/false per environment
AppConfig.enableAnalytics      // false in dev, true in prod

// UI Constants
AppConfig.defaultCurrency      // 'SAR'
AppConfig.defaultLanguage      // 'en'
AppConfig.defaultPageSize      // 20
```

### Environment (Dynamic Values)
```dart
import 'package:na3eeman/config/environment.dart';

// Check current environment
Environment.isDevelopment      // true if dev flavor
Environment.isProduction       // true if prod flavor
Environment.flavor             // AppFlavor.dev/.staging/.prod

// Config access
Environment.config.apiBaseUrl
Environment.config.enableLogging
Environment.config.googleClientId
```

## 🐛 Common Issues

### 1. "Connection refused" on Android
**Problem**: Using `localhost` on Android emulator  
**Solution**: Use `10.0.2.2` instead
```bash
--dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

### 2. "404 Not Found" errors
**Problem**: Endpoints don't match backend  
**Solution**: Verify backend is running on `/api/v1/` and use `Endpoints` constants

### 3. "Invalid JSON response"
**Problem**: Backend returning HTML error page  
**Solution**: Check backend logs, ensure CORS is configured correctly

### 4. Token refresh not working
**Problem**: Refresh token expired or invalid  
**Solution**: Check backend JWT settings, ensure `ROTATE_REFRESH_TOKENS` is enabled

## 📊 API Service Improvements Summary

| Before | After |
|--------|-------|
| 702 lines | ~600 lines |
| Hardcoded endpoints | `Endpoints` class |
| Manual token refresh | Automatic with retry queue |
| No retry logic | 3 retries for network errors |
| Basic error handling | Rich error types |
| Inconsistent logging | Structured logging |
| No request deduplication | Token refresh queue |

## 🎨 Next Steps

1. **Update Providers**: Refactor large provider files to use new ApiService methods
2. **Test Flows**: End-to-end testing of critical user flows
3. **Error UI**: Update UI to show better error messages
4. **Offline Mode**: Implement offline caching with new structure
5. **Analytics**: Integrate analytics if enabled for environment

---

**For detailed build instructions**, see [`docs/BUILD_CONFIGURATION.md`](./BUILD_CONFIGURATION.md)  
**For backend API changes**, see [`../na3eeman_be/docs/API_MIGRATION.md`](../../na3eeman_be/docs/API_MIGRATION.md)
