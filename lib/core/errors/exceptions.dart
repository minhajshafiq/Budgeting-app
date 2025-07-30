// Exceptions centralisées pour l'application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

// Exceptions d'authentification
class AuthenticationException extends AppException {
  AuthenticationException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class AuthorizationException extends AppException {
  AuthorizationException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de réseau
class NetworkException extends AppException {
  final int? statusCode;
  
  NetworkException(String message, {this.statusCode, String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class ConnectionException extends AppException {
  ConnectionException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de données
class DataException extends AppException {
  DataException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  ValidationException(String message, {this.fieldErrors, String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de stockage
class StorageException extends AppException {
  StorageException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de services
class ServiceException extends AppException {
  ServiceException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de paiement
class PaymentException extends AppException {
  PaymentException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions d'UI
class UIException extends AppException {
  UIException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de navigation
class NavigationException extends AppException {
  NavigationException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de configuration
class ConfigurationException extends AppException {
  ConfigurationException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
}

// Exceptions de performance
class PerformanceException extends AppException {
  PerformanceException(String message, {String? code, dynamic details}) 
    : super(message, code: code, details: details);
} 