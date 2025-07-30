import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';

// Intercepteur HTTP pour ajouter les tokens JWT aux requêtes
class AuthHttpClient extends http.BaseClient {
  final http.Client _inner = http.Client();
  
  // File d'attente pour les requêtes en attente pendant le rafraîchissement du token
  final List<_PendingRequest> _pendingRequests = [];
  bool _isRefreshing = false;
  
  // Completer pour attendre la fin du rafraîchissement
  Completer<bool>? _refreshCompleter;
  
  // Référence à AuthProvider (sera injectée)
  AuthStateManager? _authStateManager;
  
  // Méthode pour injecter AuthProvider
  void setAuthStateManager(AuthStateManager authStateManager) {
    _authStateManager = authStateManager;
  }
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Vérifier si AuthProvider est disponible
    if (_authStateManager == null) {
      debugPrint('⚠️ AuthProvider non disponible, requête sans authentification');
      return _inner.send(request);
    }
    
    // Vérifier si l'utilisateur est authentifié
    if (!_authStateManager!.isAuthenticated) {
      return _inner.send(request);
    }
    
    // Vérifier si le token est valide
    if (_authStateManager!.currentUser?.token != null) {
      // Ajouter le token d'accès à l'en-tête
      request.headers['Authorization'] = 'Bearer ${_authStateManager!.currentUser?.token?.value}';
      return _inner.send(request);
    } else if (_isRefreshing) {
      // Si le token est en cours de rafraîchissement, mettre la requête en file d'attente
      return await _enqueueRequest(request);
    } else {
      // Essayer de rafraîchir le token
      _isRefreshing = true;
      _refreshCompleter = Completer<bool>();
      
      try {
        // Note: Le rafraîchissement est maintenant géré automatiquement par AuthProvider
        // On attend juste un peu pour laisser le temps au rafraîchissement
        await Future.delayed(const Duration(milliseconds: 100));
        
        final hasValidToken = _authStateManager!.currentUser?.token != null;
        _refreshCompleter!.complete(hasValidToken);
        
        if (hasValidToken) {
          // Token rafraîchi avec succès, ajouter à la requête
          request.headers['Authorization'] = 'Bearer ${_authStateManager!.currentUser?.token?.value}';
          
          // Traiter les requêtes en attente
          _processPendingRequests();
          
          return _inner.send(request);
        } else {
          // Échec du rafraîchissement, rejeter toutes les requêtes en attente
          _rejectPendingRequests();
          
          // Continuer sans token (sera probablement rejeté par l'API)
          return _inner.send(request);
        }
      } catch (e) {
        debugPrint('❌ Erreur lors du rafraîchissement du token: $e');
        _refreshCompleter!.complete(false);
        _rejectPendingRequests();
        return _inner.send(request);
      } finally {
        _isRefreshing = false;
        _refreshCompleter = null;
      }
    }
  }
  
  // Mettre une requête en file d'attente pendant le rafraîchissement du token
  Future<http.StreamedResponse> _enqueueRequest(http.BaseRequest request) async {
    final completer = Completer<http.StreamedResponse>();
    _pendingRequests.add(_PendingRequest(request, completer));
    
    // Attendre que le rafraîchissement soit terminé
    final refreshed = await _refreshCompleter!.future;
    
    // Si la requête a été traitée par _processPendingRequests, retourner le résultat
    if (completer.isCompleted) {
      return completer.future;
    }
    
    // Sinon, la requête n'a pas été traitée (le token n'a pas été rafraîchi)
    if (!refreshed) {
      // Continuer sans token (sera probablement rejeté par l'API)
      return _inner.send(request);
    }
    
    // Ajouter le token rafraîchi et envoyer la requête
    request.headers['Authorization'] = 'Bearer ${_authStateManager!.currentUser?.token?.value}';
    return _inner.send(request);
  }
  
  // Traiter les requêtes en attente après le rafraîchissement du token
  void _processPendingRequests() {
    for (final pendingRequest in _pendingRequests) {
      if (!pendingRequest.completer.isCompleted) {
        try {
          // Ajouter le token rafraîchi à la requête
          pendingRequest.request.headers['Authorization'] = 'Bearer ${_authStateManager!.currentUser?.token?.value}';
          
          // Envoyer la requête
          _inner.send(pendingRequest.request).then(
            (response) => pendingRequest.completer.complete(response),
            onError: (error) => pendingRequest.completer.completeError(error),
          );
        } catch (e) {
          pendingRequest.completer.completeError(e);
        }
      }
    }
    _pendingRequests.clear();
  }
  
  // Rejeter toutes les requêtes en attente
  void _rejectPendingRequests() {
    for (final pendingRequest in _pendingRequests) {
      if (!pendingRequest.completer.isCompleted) {
        pendingRequest.completer.completeError(
          const HttpException('Échec du rafraîchissement du token')
        );
      }
    }
    _pendingRequests.clear();
  }
  
  // Méthodes utilitaires pour les requêtes HTTP
  Future<http.Response> getWithAuth(Uri url, {Map<String, String>? headers}) {
    return send(http.Request('GET', url)..headers.addAll(headers ?? {}))
        .then((response) => http.Response.fromStream(response));
  }
  
  Future<http.Response> postWithAuth(
    Uri url, 
    {Map<String, String>? headers, Object? body, Encoding? encoding}
  ) {
    final request = http.Request('POST', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    
    if (encoding != null) {
      request.encoding = encoding;
    }
    
    return send(request).then((response) => http.Response.fromStream(response));
  }
  
  Future<http.Response> putWithAuth(
    Uri url, 
    {Map<String, String>? headers, Object? body, Encoding? encoding}
  ) {
    final request = http.Request('PUT', url)
      ..headers.addAll(headers ?? {})
      ..body = body?.toString() ?? '';
    
    if (encoding != null) {
      request.encoding = encoding;
    }
    
    return send(request).then((response) => http.Response.fromStream(response));
  }
  
  Future<http.Response> deleteWithAuth(Uri url, {Map<String, String>? headers}) {
    return send(http.Request('DELETE', url)..headers.addAll(headers ?? {}))
        .then((response) => http.Response.fromStream(response));
  }
  
  @override
  void close() {
    _inner.close();
  }
}

// Classe pour stocker une requête en attente
class _PendingRequest {
  final http.BaseRequest request;
  final Completer<http.StreamedResponse> completer;
  
  _PendingRequest(this.request, this.completer);
} 