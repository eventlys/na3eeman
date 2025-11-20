import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// Global test setup
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Setup any global mocks or configurations
}

// Common test data
class TestData {
  static const String testEmail = 'test@example.com';
  static const String testPassword = 'Test123!';
  static const String testToken = 'test_jwt_token';
  static const String testUserId = 'user_123';

  static Map<String, dynamic> getTestUser() {
    return {
      'id': testUserId,
      'name': 'Test User',
      'email': testEmail,
      'phone': '+1234567890',
      'profilePicture': 'https://example.com/avatar.jpg',
      'role': 'customer',
    };
  }

  static Map<String, dynamic> getTestShop() {
    return {
      'id': 'shop_123',
      'title': 'Test Barber Shop',
      'workingHours': '9:00 - 18:00',
      'shopLocation': '123 Test Street',
      'shopRating': 4.5,
      'profilePicture': 'https://example.com/shop.jpg',
    };
  }
}

// Mock generators
@GenerateMocks([
  // Add your services and repositories here
])
void main() {}
