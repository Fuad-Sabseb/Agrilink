/// Authentication-specific exceptions for proper error handling

/// Unauthorized Role Exception
/// Thrown when user attempts to switch to a role they don't have permission for
class UnauthorizedRoleException implements Exception {
  final String role;
  final String message;

  UnauthorizedRoleException({
    required this.role,
    this.message = 'You are not authorized for this role',
  });

  @override
  String toString() => 'UnauthorizedRoleException: $message (role: $role)';
}

/// Network Exception
/// Thrown when network operations fail (e.g., during role switch)
class NetworkException implements Exception {
  final String operation;
  final String message;

  NetworkException({
    required this.operation,
    this.message = 'Network operation failed',
  });

  @override
  String toString() => 'NetworkException: $message (operation: $operation)';
}

/// Token Expired Exception
/// Thrown when authentication token has expired
class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException({
    this.message = 'Authentication token has expired',
  });

  @override
  String toString() => 'TokenExpiredException: $message';
}

/// Invalid Token Exception
/// Thrown when authentication token is invalid or malformed
class InvalidTokenException implements Exception {
  final String message;

  InvalidTokenException({
    this.message = 'Authentication token is invalid',
  });

  @override
  String toString() => 'InvalidTokenException: $message';
}
