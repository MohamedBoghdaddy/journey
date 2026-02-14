class AppException implements Exception {
  const AppException(this.message, {this.code, this.cause});

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    final parts = <String>[];
    parts.add('AppException: $message');
    if (code != null) parts.add('code=$code');
    if (cause != null) parts.add('cause=$cause');
    return parts.join(' | ');
  }
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.cause});
}

class AppAuthException extends AppException {
  const AppAuthException(super.message, {super.code, super.cause});
}

class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code, super.cause});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.cause});
}
