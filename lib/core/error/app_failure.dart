sealed class AppFailure {
  final String message;
  final String? code;
  const AppFailure(this.message, {this.code});
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network connection failed', String? code]) : super(code: code);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([super.message = 'Required permission denied', String? code]) : super(code: code);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error occurred', String? code]) : super(code: code);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message, {super.code});
}

class GenericFailure extends AppFailure {
  const GenericFailure(super.message, {super.code});
}
