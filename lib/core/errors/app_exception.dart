sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'Sin conexión a internet.']);
}

class FirebaseAppException extends AppException {
  const FirebaseAppException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class ValidationException extends AppException {
  const ValidationException(super.message);
}

class NotConfiguredException extends AppException {
  const NotConfiguredException(super.message);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'No autorizado.']);
}

class CacheException extends AppException {
  const CacheException(super.message);
}
