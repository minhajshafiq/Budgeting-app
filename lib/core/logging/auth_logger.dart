import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

// Niveaux de log
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

// Logger sécurisé pour l'authentification
class AuthLogger {
  static const String _tag = '[AUTH]';
  static const String _sensitiveDataMask = '***';
  
  // Données sensibles à masquer
  static const List<String> _sensitiveFields = [
    'email',
    'password',
    'token',
    'access_token',
    'refresh_token',
    'secret',
    'key',
  ];

  // Log sécurisé - ne jamais afficher de données sensibles
  static void log(
    String message, {
    LogLevel level = LogLevel.info,
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final sanitizedData = _sanitizeData(data);
    final logMessage = _buildLogMessage(message, sanitizedData, error);
    
    switch (level) {
      case LogLevel.debug:
        if (kDebugMode) {
          developer.log(logMessage, name: _tag, level: 500);
        }
        break;
      case LogLevel.info:
        developer.log(logMessage, name: _tag, level: 800);
        break;
      case LogLevel.warning:
        developer.log(logMessage, name: _tag, level: 900);
        break;
      case LogLevel.error:
        developer.log(logMessage, name: _tag, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  // Logs spécifiques pour l'authentification
  static void logSignUpAttempt(String userId) {
    log('Tentative d\'inscription', data: {'userId': userId});
  }

  static void logSignUpSuccess(String userId) {
    log('Inscription réussie', data: {'userId': userId});
  }

  static void logSignUpFailure(String userId, String reason) {
    log('Échec de l\'inscription', 
        level: LogLevel.error,
        data: {'userId': userId, 'reason': reason});
  }

  static void logSignInAttempt(String email) {
    log('Tentative de connexion', data: {'email': _maskEmail(email)});
  }

  static void logSignInSuccess(String userId) {
    log('Connexion réussie', data: {'userId': userId});
  }

  static void logSignInFailure(String email, String reason) {
    log('Échec de la connexion', 
        level: LogLevel.error,
        data: {'email': _maskEmail(email), 'reason': reason});
  }

  static void logSignOut(String userId) {
    log('Déconnexion', data: {'userId': userId});
  }

  static void logTokenRefresh(String userId) {
    log('Rafraîchissement du token', data: {'userId': userId});
  }

  static void logTokenRefreshFailure(String userId, String reason) {
    log('Échec du rafraîchissement du token', 
        level: LogLevel.error,
        data: {'userId': userId, 'reason': reason});
  }

  static void logDataSync(String userId, String source) {
    log('Synchronisation des données', data: {'userId': userId, 'source': source});
  }

  static void logDataSyncFailure(String userId, String source, String reason) {
    log('Échec de la synchronisation', 
        level: LogLevel.error,
        data: {'userId': userId, 'source': source, 'reason': reason});
  }

  static void logSecurityEvent(String event, String userId) {
    log('Événement de sécurité', 
        level: LogLevel.warning,
        data: {'event': event, 'userId': userId});
  }

  // Méthodes utilitaires
  static String _maskEmail(String email) {
    if (email.isEmpty) return _sensitiveDataMask;
    final parts = email.split('@');
    if (parts.length != 2) return _sensitiveDataMask;
    
    final username = parts[0];
    final domain = parts[1];
    
    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }
    
    return '${username[0]}***${username[username.length - 1]}@$domain';
  }

  static Map<String, dynamic>? _sanitizeData(Map<String, dynamic>? data) {
    if (data == null) return null;
    
    final sanitized = <String, dynamic>{};
    
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      
      if (_sensitiveFields.any((field) => key.toLowerCase().contains(field))) {
        sanitized[key] = _sensitiveDataMask;
      } else if (value is String && _isSensitiveValue(value)) {
        sanitized[key] = _sensitiveDataMask;
      } else {
        sanitized[key] = value;
      }
    }
    
    return sanitized;
  }

  static bool _isSensitiveValue(String value) {
    // Détecter les patterns sensibles
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    final tokenPattern = RegExp(r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$');
    final uuidPattern = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false);
    
    return emailPattern.hasMatch(value) || 
           tokenPattern.hasMatch(value) || 
           uuidPattern.hasMatch(value);
  }

  static String _buildLogMessage(String message, Map<String, dynamic>? data, Object? error) {
    final buffer = StringBuffer(message);
    
    if (data != null && data.isNotEmpty) {
      buffer.write(' | Data: $data');
    }
    
    if (error != null) {
      buffer.write(' | Error: $error');
    }
    
    return buffer.toString();
  }

  // Logs de performance
  static void logOperationTime(String operation, Duration duration) {
    log('Opération terminée', 
        data: {'operation': operation, 'duration_ms': duration.inMilliseconds});
  }

  // Logs de debug (seulement en mode debug)
  static void debug(String message, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      log(message, level: LogLevel.debug, data: data);
    }
  }
} 