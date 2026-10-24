import '../../Helpers/error_handler.dart';

/// A lightweight Result type for repository/use-case boundaries.
///
/// Replaces ad-hoc try/catch + thrown AppError surfacing with an explicit
/// success/failure channel, so providers can render typed error states
/// without catching.
sealed class Result<T> {
  const Result();

  R when<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) {
    final self = this;
    return switch (self) {
      Success<T>() => onSuccess(self.value),
      Failure<T>() => onFailure(self.error),
    };
  }

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;
  AppError? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).error : null;
}

class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}
