import 'dart:async';
import 'dart:io';

class AppError implements Exception {
  final String message;
  final ErrorType type;
  final dynamic details;
  final StackTrace? stackTrace;

  AppError(
    this.message, {
    this.type = ErrorType.unknown,
    this.details,
    this.stackTrace,
  });

  @override
  String toString() => 'AppError: $message (Type: $type)';
}

enum ErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  client,
  timeout,
  unknown,
}

class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is AppError) {
      return error.message;
    } else if (error is FormatException) {
      return 'Data format error: ${error.message}';
    } else if (error is TypeError) {
      return 'Type error: ${error.toString()}';
    } else if (error is Exception) {
      return 'Exception: ${error.toString()}';
    } else {
      return 'An unexpected error occurred: ${error.toString()}';
    }
  }

  static AppError handleException(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    if (error is SocketException) {
      return AppError(
        'No internet connection',
        type: ErrorType.network,
        stackTrace: stackTrace,
      );
    }

    if (error is HttpException) {
      return AppError(
        'HTTP error occurred',
        type: ErrorType.network,
        details: error,
        stackTrace: stackTrace,
      );
    }

    if (error is FormatException) {
      return AppError(
        'Data format error',
        type: ErrorType.client,
        details: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppError(
        'Request timed out',
        type: ErrorType.timeout,
        details: error,
        stackTrace: stackTrace,
      );
    }

    // Handle platform-specific errors if needed
    if (error is Exception) {
      return AppError(
        'An unexpected error occurred',
        type: ErrorType.unknown,
        details: error.toString(),
        stackTrace: stackTrace,
      );
    }

    return AppError(
      error?.toString() ?? 'Unknown error occurred',
      type: ErrorType.unknown,
      stackTrace: stackTrace,
    );
  }

  static bool isNetworkError(dynamic error) {
    return error is SocketException ||
        error is HttpException ||
        error is TimeoutException ||
        (error is AppError && error.type == ErrorType.network);
  }

  static bool isAuthenticationError(dynamic error) {
    return (error is AppError && error.type == ErrorType.authentication) ||
        (error is AppError && error.type == ErrorType.authorization);
  }

  static String getUserFriendlyMessage(dynamic error) {
    if (error is AppError) {
      switch (error.type) {
        case ErrorType.network:
          return 'Please check your internet connection and try again.';
        case ErrorType.authentication:
          return 'Please log in again to continue.';
        case ErrorType.authorization:
          return 'You don\'t have permission to perform this action.';
        case ErrorType.validation:
          return 'Please check your input and try again.';
        case ErrorType.notFound:
          return 'The requested resource was not found.';
        case ErrorType.server:
          return 'Server error occurred. Please try again later.';
        case ErrorType.timeout:
          return 'Request timed out. Please try again.';
        case ErrorType.client:
        case ErrorType.unknown:
          return 'An unexpected error occurred. Please try again later.';
      }
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static Map<String, dynamic> toJson(dynamic error) {
    if (error is AppError) {
      return {
        'message': error.message,
        'type': error.type.toString(),
        'details': error.details,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }

    return {
      'message': error.toString(),
      'type': 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}
