sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Network connection failed']);
}

class PermissionFailure extends AppFailure {
  const PermissionFailure([super.message = 'Required permission denied']);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}
