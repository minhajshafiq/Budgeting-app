import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'session_manager.dart';

/// Intercepteur HTTP amélioré pour la gestion automatique des tokens
/// Utilise le SessionManager pour une gestion centralisée des sessions
class ImprovedHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  final SessionManager _sessionManager = SessionManager();
  
  // File d'attente pour les requêtes en attente pendant le rafraîchissement
  final List<_PendingRequest> _pendingRequests = [];
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;
  
  // Configuration
  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      // Ajouter les headers par défaut
      _addDefaultHeaders(request);
      
      // Ajouter le token d'authentification si disponible
      await _addAuthHeader(request);
      
      // Envoyer la requête avec retry automatique
      return await _sendWithRetry(request);
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'envoi de la requête: $e');
      rethrow;
    }
  }

  /// Envoyer une requête avec retry automatique
  Future<http.StreamedResponse> _sendWithRetry(http.BaseRequest request) async {
    int retryCount = 0;
    
    while (retryCount < _maxRetries) {
      try {
        final response = await _inner.send(request).timeout(_requestTimeout);
        
        // Si la réponse est 401 (Unauthorized), essayer de rafraîchir le token
        if (response.statusCode == 401) {
          final refreshed = await _handleUnauthorized(request);
          if (refreshed) {
            // Réessayer la requête avec le nouveau token
            await _addAuthHeader(request);
            return await _inner.send(request).timeout(_requestTimeout);
          } else {
            // Échec du rafraîchissement, retourner la réponse 401
            return response;
          }
        }
        
        return response;
      } catch (e) {
        retryCount++;
        debugPrint('❌ Tentative $retryCount échouée: $e');
        
        if (retryCount >= _maxRetries) {
          rethrow;
        }
        
        // Attendre avant de réessayer
        await Future.delayed(_retryDelay * retryCount);
      }
    }
    
    throw Exception('Nombre maximum de tentatives atteint');
  }

  /// Gérer une réponse 401 (Unauthorized)
  Future<bool> _handleUnauthorized(http.BaseRequest request) async {
    // Si déjà en cours de rafraîchissement, attendre
    if (_isRefreshing) {
      return await _waitForRefresh();
    }
    
    // Démarrer le rafraîchissement
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();
    
    try {
      // Mettre la requête en file d'attente
      final pendingCompleter = Completer<http.StreamedResponse>();
      _pendingRequests.add(_PendingRequest(request, pendingCompleter));
      
      // Essayer de rafraîchir le token
      final success = await _sessionManager.refreshAccessToken();
      
      if (success) {
        // Traiter les requêtes en attente
        _processPendingRequests();
        _refreshCompleter!.complete(true);
        return true;
      } else {
        // Échec du rafraîchissement
        _rejectPendingRequests();
        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erreur lors du rafraîchissement: $e');
      _rejectPendingRequests();
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Attendre la fin du rafraîchissement
  Future<bool> _waitForRefresh() async {
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }
    return false;
  }

  /// Traiter les requêtes en attente
  void _processPendingRequests() {
    for (final pendingRequest in _pendingRequests) {
      if (!pendingRequest.completer.isCompleted) {
        try {
          // Ajouter le nouveau token à la requête
          _addAuthHeader(pendingRequest.request).then((_) {
            // Envoyer la requête
            _inner.send(pendingRequest.request).then(
              (response) => pendingRequest.completer.complete(response),
              onError: (error) => pendingRequest.completer.completeError(error),
            );
          });
        } catch (e) {
          pendingRequest.completer.completeError(e);
        }
      }
    }
    _pendingRequests.clear();
  }

  /// Rejeter toutes les requêtes en attente
  void _rejectPendingRequests() {
    for (final pendingRequest in _pendingRequests) {
      if (!pendingRequest.completer.isCompleted) {
        pendingRequest.completer.completeError(
          Exception('Token refresh failed'),
        );
      }
    }
    _pendingRequests.clear();
  }

  /// Ajouter les headers par défaut
  void _addDefaultHeaders(http.BaseRequest request) {
    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['User-Agent'] = 'FlutterApp/1.0';
  }

  /// Ajouter le header d'authentification
  Future<void> _addAuthHeader(http.BaseRequest request) async {
    try {
      // Vérifier si l'utilisateur est authentifié
      if (!_sessionManager.isAuthenticated) {
        return;
      }
      
      // Obtenir le token d'accès
      final token = await _sessionManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'ajout du header d\'authentification: $e');
    }
  }

  /// Effectuer une requête GET
  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    final request = http.Request('GET', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    
    final streamedResponse = await send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  /// Effectuer une requête POST
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final request = http.Request('POST', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body is String ? body : json.encode(body);
    }
    
    final streamedResponse = await send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  /// Effectuer une requête PUT
  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final request = http.Request('PUT', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body is String ? body : json.encode(body);
    }
    
    final streamedResponse = await send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  /// Effectuer une requête DELETE
  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final request = http.Request('DELETE', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body is String ? body : json.encode(body);
    }
    
    final streamedResponse = await send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  /// Effectuer une requête PATCH
  Future<http.Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final request = http.Request('PATCH', url);
    if (headers != null) {
      request.headers.addAll(headers);
    }
    if (body != null) {
      request.body = body is String ? body : json.encode(body);
    }
    
    final streamedResponse = await send(request);
    return await http.Response.fromStream(streamedResponse);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}

/// Classe pour représenter une requête en attente
class _PendingRequest {
  final http.BaseRequest request;
  final Completer<http.StreamedResponse> completer;
  
  _PendingRequest(this.request, this.completer);
}

/// Exceptions personnalisées
class HttpInterceptorException implements Exception {
  final String message;
  final int? statusCode;
  
  HttpInterceptorException(this.message, [this.statusCode]);
  
  @override
  String toString() => 'HttpInterceptorException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class TokenRefreshException implements Exception {
  final String message;
  
  TokenRefreshException(this.message);
  
  @override
  String toString() => 'TokenRefreshException: $message';
} 