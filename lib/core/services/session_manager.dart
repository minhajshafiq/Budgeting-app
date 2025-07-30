import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../domain/entities/auth_entity.dart';
import '../../data/models/user.dart' as app_models;
import 'secure_storage_service.dart';

/// Service unifié pour la gestion des sessions utilisateur
/// Centralise toute la logique de session, authentification et synchronisation
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  
  // Stream pour notifier les changements de session
  final StreamController<SessionState> _sessionStateController = 
      StreamController<SessionState>.broadcast();
  
  // État actuel de la session
  SessionState _currentState = SessionState.initial;
  AuthEntity? _currentUser;
  Timer? _sessionRefreshTimer;
  
  // Configuration
  static const Duration _sessionExpiryDuration = Duration(days: 30);
  static const Duration _tokenRefreshThreshold = Duration(minutes: 5);
  static const Duration _sessionCheckInterval = Duration(minutes: 1);

  // Getters
  Stream<SessionState> get sessionStateStream => _sessionStateController.stream;
  SessionState get currentState => _currentState;
  AuthEntity? get currentUser => _currentUser;
  bool get isAuthenticated => _currentState == SessionState.authenticated && _currentUser != null;
  bool get sessionValid => _currentState == SessionState.authenticated;

  /// Initialiser le gestionnaire de session
  Future<void> initialize() async {
    debugPrint('🔄 Initialisation du SessionManager...');
    
    try {
      // Vérifier si une session existe
      final hasValidSession = await _checkExistingSession();
      
      if (hasValidSession) {
        await _restoreSession();
      } else {
        _setState(SessionState.unauthenticated);
      }
      
      // Démarrer le monitoring de session
      _startSessionMonitoring();
      
      debugPrint('✅ SessionManager initialisé');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation du SessionManager: $e');
      _setState(SessionState.error);
    }
  }

  /// Créer une nouvelle session utilisateur
  Future<bool> createSession({
    required AuthEntity user,
    required String accessToken,
    required String refreshToken,
    DateTime? sessionExpiry,
  }) async {
    try {
      debugPrint('🔄 Création de session pour: ${user.fullName}');
      _setState(SessionState.loading);

      // Sauvegarder les données de session
      await _saveSessionData(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
        sessionExpiry: sessionExpiry,
      );

      // Mettre à jour l'état
      _currentUser = user;
      _setState(SessionState.authenticated);

      // Programmer le rafraîchissement du token
      _scheduleTokenRefresh();

      debugPrint('✅ Session créée avec succès');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la création de session: $e');
      _setState(SessionState.error);
      return false;
    }
  }

  /// Restaurer une session existante
  Future<bool> _restoreSession() async {
    try {
      debugPrint('🔄 Restauration de session...');
      _setState(SessionState.loading);

      // Vérifier l'expiration de session
      if (await _isSessionExpired()) {
        debugPrint('⚠️ Session expirée');
        await clearSession();
        return false;
      }

      // Récupérer les données utilisateur
      final user = await _getStoredUser();
      if (user == null) {
        debugPrint('👤 Aucun utilisateur trouvé');
        await clearSession();
        return false;
      }

      // Vérifier la validité des tokens
      final tokens = await _secureStorage.getTokens();
      if (tokens['access_token'] == null || tokens['refresh_token'] == null) {
        debugPrint('🔑 Tokens manquants');
        await clearSession();
        return false;
      }

      // Valider et rafraîchir les tokens si nécessaire
      final isValid = await _validateAndRefreshTokens(
        tokens['access_token']!,
        tokens['refresh_token']!,
      );

      if (!isValid) {
        debugPrint('❌ Tokens invalides');
        await clearSession();
        return false;
      }

      // Mettre à jour l'état
      _currentUser = user;
      _setState(SessionState.authenticated);

      // Programmer le rafraîchissement du token
      _scheduleTokenRefresh();

      debugPrint('✅ Session restaurée avec succès');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la restauration de session: $e');
      await clearSession();
      return false;
    }
  }

  /// Rafraîchir le token d'accès
  Future<bool> refreshAccessToken() async {
    try {
      debugPrint('🔄 Rafraîchissement du token d\'accès...');

      final tokens = await _secureStorage.getTokens();
      if (tokens['refresh_token'] == null) {
        debugPrint('❌ Refresh token manquant');
        return false;
      }

      // Utiliser Supabase pour rafraîchir le token
      final response = await Supabase.instance.client.auth.refreshSession();
      
      if (response.session != null) {
        // Sauvegarder le nouveau token
        await _secureStorage.saveTokens(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? tokens['refresh_token']!,
          sessionExpiry: response.session!.expiresAt != null 
            ? DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt! * 1000)
            : null,
        );

        debugPrint('✅ Token rafraîchi avec succès');
        return true;
      }

      debugPrint('❌ Échec du rafraîchissement du token');
      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors du rafraîchissement du token: $e');
      return false;
    }
  }

  /// Mettre à jour les données utilisateur
  Future<void> updateUserData(AuthEntity user) async {
    try {
      debugPrint('🔄 Mise à jour des données utilisateur: ${user.fullName}');
      
      _currentUser = user;
      await _saveUserData(user);
      
      debugPrint('✅ Données utilisateur mises à jour');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour des données utilisateur: $e');
    }
  }

  /// Nettoyer la session
  Future<void> clearSession() async {
    try {
      debugPrint('🧹 Nettoyage de la session...');
      
      // Arrêter le monitoring
      _stopSessionMonitoring();
      
      // Nettoyer le stockage
      await _secureStorage.clearTokens();
      await _secureStorage.clearUserData();
      await _clearSessionMetadata();
      
      // Réinitialiser l'état
      _currentUser = null;
      _setState(SessionState.unauthenticated);
      
      debugPrint('✅ Session nettoyée avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage de session: $e');
    }
  }

  /// Vérifier si la session est valide
  Future<bool> isSessionValid() async {
    try {
      // Vérifier l'état actuel
      if (_currentState != SessionState.authenticated || _currentUser == null) {
        return false;
      }

      // Vérifier l'expiration de session
      if (await _isSessionExpired()) {
        return false;
      }

      // Vérifier la validité des tokens
      final tokens = await _secureStorage.getTokens();
      if (tokens['access_token'] == null || tokens['refresh_token'] == null) {
        return false;
      }

      return await _validateAndRefreshTokens(tokens['access_token']!, tokens['refresh_token']!);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification de session: $e');
      return false;
    }
  }

  /// Obtenir le token d'accès actuel
  Future<String?> getAccessToken() async {
    try {
      final tokens = await _secureStorage.getTokens();
      return tokens['access_token'];
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du token: $e');
      return null;
    }
  }

  // Méthodes privées

  /// Vérifier s'il existe une session valide
  Future<bool> _checkExistingSession() async {
    try {
      // Vérifier la présence de tokens
      final hasTokens = await _secureStorage.hasTokens();
      if (!hasTokens) return false;

      // Vérifier l'expiration de session
      if (await _isSessionExpired()) return false;

      // Vérifier la présence de données utilisateur
      final userJson = await _secureStorage.getUserData();
      return userJson != null;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification de session existante: $e');
      return false;
    }
  }

  /// Sauvegarder les données de session
  Future<void> _saveSessionData({
    required AuthEntity user,
    required String accessToken,
    required String refreshToken,
    DateTime? sessionExpiry,
  }) async {
    // Sauvegarder les tokens
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: user.id.value,
      sessionExpiry: sessionExpiry ?? DateTime.now().add(_sessionExpiryDuration),
    );

    // Sauvegarder les données utilisateur
    await _saveUserData(user);

    // Sauvegarder les métadonnées
    await _saveSessionMetadata();
  }

  /// Sauvegarder les données utilisateur
  Future<void> _saveUserData(AuthEntity user) async {
    final userModel = app_models.User(
      id: user.id.value,
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email.value,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt ?? DateTime.now(),
    );

    await _secureStorage.saveUserData(json.encode(userModel.toJson()));
  }

  /// Récupérer l'utilisateur stocké
  Future<AuthEntity?> _getStoredUser() async {
    try {
      final userJson = await _secureStorage.getUserData();
      if (userJson == null) return null;

      final userData = json.decode(userJson) as Map<String, dynamic>;
      final user = app_models.User.fromJson(userData);

      return AuthEntity(
        id: UserId(user.id),
        email: Email(user.email),
        firstName: user.firstName,
        lastName: user.lastName,
        createdAt: user.createdAt,
        lastLoginAt: user.lastLoginAt,
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Valider et rafraîchir les tokens
  Future<bool> _validateAndRefreshTokens(String accessToken, String refreshToken) async {
    try {
      // Vérifier si le token d'accès est valide
      if (await _isTokenValid(accessToken)) {
        return true;
      }

      // Essayer de rafraîchir le token
      return await refreshAccessToken();
    } catch (e) {
      debugPrint('❌ Erreur lors de la validation des tokens: $e');
      return false;
    }
  }

  /// Valider un token
  Future<bool> _isTokenValid(String token) async {
    try {
      // Vérifier avec Supabase
      final session = Supabase.instance.client.auth.currentSession;
      return session != null && session.accessToken == token;
    } catch (e) {
      debugPrint('❌ Erreur lors de la validation du token: $e');
      return false;
    }
  }

  /// Vérifier si la session est expirée
  Future<bool> _isSessionExpired() async {
    try {
      final expiryJson = await _secureStorage.getSecureValue('session_expiry');
      if (expiryJson == null) return false;

      final expiryTime = DateTime.parse(expiryJson);
      return DateTime.now().isAfter(expiryTime);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification d\'expiration: $e');
      return false;
    }
  }

  /// Sauvegarder les métadonnées de session
  Future<void> _saveSessionMetadata() async {
    try {
      final now = DateTime.now();
      await _secureStorage.saveSecureValue('last_login', now.toIso8601String());
      await _secureStorage.saveSecureValue('session_created', now.toIso8601String());
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des métadonnées: $e');
    }
  }

  /// Nettoyer les métadonnées de session
  Future<void> _clearSessionMetadata() async {
    try {
      await _secureStorage.deleteSecureValue('last_login');
      await _secureStorage.deleteSecureValue('session_created');
      await _secureStorage.deleteSecureValue('session_expiry');
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage des métadonnées: $e');
    }
  }

  /// Programmer le rafraîchissement du token
  void _scheduleTokenRefresh() {
    _sessionRefreshTimer?.cancel();
    
    // Vérifier le token toutes les minutes
    _sessionRefreshTimer = Timer.periodic(_sessionCheckInterval, (timer) async {
      if (_currentState == SessionState.authenticated) {
        final shouldRefresh = await _shouldRefreshToken();
        if (shouldRefresh) {
          await refreshAccessToken();
        }
      } else {
        timer.cancel();
      }
    });
  }

  /// Vérifier si le token doit être rafraîchi
  Future<bool> _shouldRefreshToken() async {
    try {
      final tokens = await _secureStorage.getTokens();
      if (tokens['session_expiry'] == null) return false;

      final expiryTime = DateTime.parse(tokens['session_expiry']!);
      final now = DateTime.now();
      final timeUntilExpiry = expiryTime.difference(now);

      return timeUntilExpiry <= _tokenRefreshThreshold;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification du rafraîchissement: $e');
      return false;
    }
  }

  /// Démarrer le monitoring de session
  void _startSessionMonitoring() {
    // Monitoring déjà géré par _scheduleTokenRefresh
  }

  /// Arrêter le monitoring de session
  void _stopSessionMonitoring() {
    _sessionRefreshTimer?.cancel();
    _sessionRefreshTimer = null;
  }

  /// Mettre à jour l'état de la session
  void _setState(SessionState state) {
    _currentState = state;
    _sessionStateController.add(state);
  }

  /// Disposer des ressources
  void dispose() {
    _stopSessionMonitoring();
    _sessionStateController.close();
  }
}

/// États possibles de la session
enum SessionState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
  expired,
}

/// Exceptions personnalisées
class SessionException implements Exception {
  final String message;
  final SessionState? state;
  
  SessionException(this.message, [this.state]);
  
  @override
  String toString() => 'SessionException: $message';
}

class TokenRefreshException implements Exception {
  final String message;
  
  TokenRefreshException(this.message);
  
  @override
  String toString() => 'TokenRefreshException: $message';
} 