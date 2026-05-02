// lib/Services/use_cases/auth_use_cases.dart
import '../repositories/auth_repository.dart';
import '../../Helpers/error_handler.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Map<String, dynamic>> execute(String email, String password) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      throw AppError('Email and password are required', type: ErrorType.validation);
    }

    if (!_isValidEmail(email)) {
      throw AppError('Please enter a valid email', type: ErrorType.validation);
    }

    if (password.length < 6) {
      throw AppError('Password must be at least 6 characters', type: ErrorType.validation);
    }

    return await _repository.login(email, password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Map<String, dynamic>> execute(Map<String, dynamic> userData) async {
    // Validation
    final requiredFields = ['first_name', 'last_name', 'email', 'password', 'phone_number', 'gender', 'role'];
    for (final field in requiredFields) {
      if (userData[field] == null || userData[field].toString().isEmpty) {
        throw AppError('$field is required', type: ErrorType.validation);
      }
    }

    if (!_isValidEmail(userData['email'])) {
      throw AppError('Please enter a valid email', type: ErrorType.validation);
    }

    if (userData['password'].length < 6) {
      throw AppError('Password must be at least 6 characters', type: ErrorType.validation);
    }

    if (!_isValidPhone(userData['phone_number'])) {
      throw AppError('Please enter a valid phone number', type: ErrorType.validation);
    }

    final validRoles = ['customer', 'expert', 'owner', 'admin'];
    if (!validRoles.contains(userData['role'])) {
      throw AppError('Invalid role specified', type: ErrorType.validation);
    }

    return await _repository.register(userData);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(phone);
  }
}

class ForgotPasswordUseCase {
  final AuthRepository _repository;

  ForgotPasswordUseCase(this._repository);

  Future<Map<String, dynamic>> execute(String email) async {
    if (email.isEmpty) {
      throw AppError('Email is required', type: ErrorType.validation);
    }

    if (!_isValidEmail(email)) {
      throw AppError('Please enter a valid email', type: ErrorType.validation);
    }

    return await _repository.forgotPassword(email);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }
}

class ResetPasswordUseCase {
  final AuthRepository _repository;

  ResetPasswordUseCase(this._repository);

  Future<Map<String, dynamic>> execute({
    required String token,
    required String newPassword,
  }) async {
    if (token.isEmpty) {
      throw AppError('Reset token is required', type: ErrorType.validation);
    }

    if (newPassword.isEmpty) {
      throw AppError('New password is required', type: ErrorType.validation);
    }

    if (newPassword.length < 6) {
      throw AppError('Password must be at least 6 characters', type: ErrorType.validation);
    }

    return await _repository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

class ChangePasswordUseCase {
  final AuthRepository _repository;

  ChangePasswordUseCase(this._repository);

  Future<Map<String, dynamic>> execute({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      throw AppError('Both current and new password are required', type: ErrorType.validation);
    }

    if (newPassword.length < 6) {
      throw AppError('New password must be at least 6 characters', type: ErrorType.validation);
    }

    if (currentPassword == newPassword) {
      throw AppError('New password must be different from current password', type: ErrorType.validation);
    }

    return await _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
