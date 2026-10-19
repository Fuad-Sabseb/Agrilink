/// Transport-specific exceptions for proper error handling

/// Job Already Accepted Exception
class JobAlreadyAcceptedException implements Exception {
  final String jobId;
  final String acceptedBy;
  final DateTime acceptedAt;
  final String message;

  JobAlreadyAcceptedException({
    required this.jobId,
    required this.acceptedBy,
    required this.acceptedAt,
    this.message = 'This job has already been accepted by another transporter',
  });

  @override
  String toString() => 'JobAlreadyAcceptedException: $message';
}

/// Job Not Found Exception
class JobNotFoundException implements Exception {
  final String jobId;
  final String message;

  JobNotFoundException({
    required this.jobId,
    this.message = 'Job not found or no longer available',
  });

  @override
  String toString() => 'JobNotFoundException: $message';
}

/// Invalid State Transition Exception
class InvalidStateTransitionException implements Exception {
  final String currentState;
  final String attemptedState;
  final String message;

  InvalidStateTransitionException({
    required this.currentState,
    required this.attemptedState,
    this.message = 'Invalid state transition',
  });

  @override
  String toString() => 'InvalidStateTransitionException: $message';
}

/// Photo Capture Exception
class PhotoCaptureException implements Exception {
  final String message;
  
  PhotoCaptureException(this.message);

  @override
  String toString() => 'PhotoCaptureException: $message';
}

/// Signature Exception
class SignatureException implements Exception {
  final String message;

  SignatureException(this.message);

  @override
  String toString() => 'SignatureException: $message';
}

/// Permission Denied Exception
class PermissionDeniedException implements Exception {
  final String permission;
  final String message;

  PermissionDeniedException({
    required this.permission,
    this.message = 'Permission denied',
  });

  @override
  String toString() => 'PermissionDeniedException: $message';
}
