import 'failure.dart';

sealed class AppException implements Exception {
  const AppException(this.message, {this.details});

  final String message;
  final Object? details;

  String get code;

  Failure toFailure() =>
      Failure(code: code, message: message, details: details);
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.details});
  @override
  String get code => 'network';
}

class RequestTimeoutException extends AppException {
  const RequestTimeoutException(super.message, {super.details});
  @override
  String get code => 'timeout';
}

class ProviderUnavailableException extends AppException {
  const ProviderUnavailableException(super.message, {super.details});
  @override
  String get code => 'provider_unavailable';
}

class BadResponseException extends AppException {
  const BadResponseException(super.message, {super.details});
  @override
  String get code => 'bad_response';
}

class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.details});
  @override
  String get code => 'database';
}

class UnknownException extends AppException {
  const UnknownException(super.message, {super.details});
  @override
  String get code => 'unknown';
}

Failure failureFromObject(Object error) {
  if (error is AppException) return error.toFailure();
  return UnknownException(error.toString(), details: error).toFailure();
}
