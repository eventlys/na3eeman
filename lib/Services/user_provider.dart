// services/user_api_service.dart

import '../Models/profile_model.dart';

class UserApiService {
  static Future<UserProfile> getUserProfile() async {
    // Simulate API call
    await Future.delayed(Duration(seconds: 1));
    
    // Return mock data - replace with actual API call
    return UserProfile(
      firstName: 'John',
      lastName: 'Doe',
      email: 'john.doe@example.com',
      username: 'johndoe',
      phone: '+1234567890',
    );
  }
}

