import 'app_failure.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get dataOrNull => switch (this) {
        Success<T>(data: final d) => d,
        Failure<T>() => null,
      };

  AppFailure? get failureOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(failure: final f) => f,
      };
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppFailure failure;
  const Failure(this.failure);
}

