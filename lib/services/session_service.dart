import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../data/models/user.dart';
import 'secure_storage_service.dart';
import 'auth_service.dart';

/// Service dédié à la gestion de la persistance de session
class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final SecureStorageService _secureStorage = SecureStorageService();
  final AuthService _authService = AuthService();

  // Clés pour le stockage
  static const String _sessionKey = 'user_session';
  static const String _lastLoginKey = 'last_login_timestamp';
  static const String _sessionExpiryKey = 'session_expiry';

  /// Sauvegarder une session utilisateur
  Future<void> saveSession(User user, {String? accessToken, String? refreshToken}) async {
    try {
      debugPrint('💾 Sauvegarde de la session pour: ${user.fullName}');
      
      // Sauvegarder les données utilisateur
      await _secureStorage.saveUserData(json.encode(user.toJson()));
      
      // Sauvegarder les tokens si fournis
      if (accessToken != null && refreshToken != null) {
        await _secureStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      }
      
      // Sauvegarder les métadonnées de session
      await _saveSessionMetadata();
      
      debugPrint('✅ Session sauvegardée avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde de session: $e');
      rethrow;
    }
  }

  /// Restaurer une session utilisateur
  Future<User?> restoreSession() async {
    try {
      debugPrint('🔄 Tentative de restauration de session...');
      
      // Vérifier si la session n'est pas expirée
      if (await _isSessionExpired()) {
        debugPrint('⚠️ Session expirée, nettoyage...');
        await clearSession();
        return null;
      }
      
      // Récupérer les données utilisateur
      final userJson = await _secureStorage.getUserData();
      if (userJson == null) {
        debugPrint('👤 Aucune donnée utilisateur trouvée');
        return null;
      }
      
      // Parser les données utilisateur
      final user = User.fromJson(json.decode(userJson));
      
      // Vérifier la validité des tokens
      final tokens = await _secureStorage.getTokens();
      if (tokens['access_token'] != null && tokens['refresh_token'] != null) {
        final isValid = await _validateTokens(tokens['access_token']!, tokens['refresh_token']!);
        if (isValid) {
          debugPrint('✅ Session restaurée avec succès: ${user.fullName}');
          return user;
        } else {
          debugPrint('⚠️ Tokens invalides, nettoyage de la session');
          await clearSession();
          return null;
        }
      }
      
      debugPrint('✅ Session restaurée (sans tokens): ${user.fullName}');
      return user;
    } catch (e) {
      debugPrint('❌ Erreur lors de la restauration de session: $e');
      await clearSession();
      return null;
    }
  }

  /// Vérifier si une session existe
  Future<bool> hasValidSession() async {
    try {
      // Vérifier l'expiration
      if (await _isSessionExpired()) {
        return false;
      }
      
      // Vérifier la présence de données utilisateur
      final userJson = await _secureStorage.getUserData();
      if (userJson == null) {
        return false;
      }
      
      // Vérifier la présence de tokens
      final tokens = await _secureStorage.getTokens();
      if (tokens['access_token'] == null || tokens['refresh_token'] == null) {
        return false;
      }
      
      // Vérifier la validité des tokens
      return await _validateTokens(tokens['access_token']!, tokens['refresh_token']!);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification de session: $e');
      return false;
    }
  }

  /// Nettoyer une session
  Future<void> clearSession() async {
    try {
      debugPrint('🧹 Nettoyage de la session...');
      
      await _secureStorage.clearTokens();
      await _secureStorage.clearUserData();
      await _clearSessionMetadata();
      
      debugPrint('✅ Session nettoyée avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage de session: $e');
    }
  }

  /// Mettre à jour les données utilisateur de la session
  Future<void> updateSessionUser(User user) async {
    try {
      debugPrint('🔄 Mise à jour des données utilisateur: ${user.fullName}');
      
      await _secureStorage.saveUserData(json.encode(user.toJson()));
      await _saveSessionMetadata();
      
      debugPrint('✅ Données utilisateur mises à jour');
    } catch (e) {
      debugPrint('❌ Erreur lors de la mise à jour des données utilisateur: $e');
    }
  }

  /// Vérifier la validité des tokens
  Future<bool> _validateTokens(String accessToken, String refreshToken) async {
    try {
      // Vérifier si le token d'accès est valide
      if (_authService.isTokenValid(accessToken)) {
        return true;
      }
      
      // Essayer de rafraîchir le token
      final newAccessToken = await _authService.refreshAccessToken(refreshToken);
      if (newAccessToken != null) {
        // Sauvegarder le nouveau token
        await _secureStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
        );
        return true;
      }
      
      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de la validation des tokens: $e');
      return false;
    }
  }

  /// Vérifier si la session est expirée
  Future<bool> _isSessionExpired() async {
    try {
      final expiryJson = await _secureStorage.getSecureValue(_sessionExpiryKey);
      if (expiryJson == null) {
        return false; // Pas d'expiration définie
      }
      
      final expiryTime = DateTime.parse(expiryJson);
      final now = DateTime.now();
      
      return now.isAfter(expiryTime);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification d\'expiration: $e');
      return false;
    }
  }

  /// Sauvegarder les métadonnées de session
  Future<void> _saveSessionMetadata() async {
    try {
      final now = DateTime.now();
      
      // Sauvegarder le timestamp de dernière connexion
      await _secureStorage.saveSecureValue(_lastLoginKey, now.toIso8601String());
      
      // Définir l'expiration de session (30 jours par défaut)
      final expiryTime = now.add(const Duration(days: 30));
      await _secureStorage.saveSecureValue(_sessionExpiryKey, expiryTime.toIso8601String());
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des métadonnées: $e');
    }
  }

  /// Nettoyer les métadonnées de session
  Future<void> _clearSessionMetadata() async {
    try {
      await _secureStorage.deleteSecureValue(_lastLoginKey);
      await _secureStorage.deleteSecureValue(_sessionExpiryKey);
    } catch (e) {
      debugPrint('❌ Erreur lors du nettoyage des métadonnées: $e');
    }
  }

  /// Obtenir le timestamp de dernière connexion
  Future<DateTime?> getLastLoginTime() async {
    try {
      final lastLoginJson = await _secureStorage.getSecureValue(_lastLoginKey);
      if (lastLoginJson != null) {
        return DateTime.parse(lastLoginJson);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du timestamp: $e');
      return null;
    }
  }

  /// Définir la durée d'expiration de session
  Future<void> setSessionExpiry(Duration duration) async {
    try {
      final expiryTime = DateTime.now().add(duration);
      await _secureStorage.saveSecureValue(_sessionExpiryKey, expiryTime.toIso8601String());
      debugPrint('✅ Expiration de session définie: ${duration.inDays} jours');
    } catch (e) {
      debugPrint('❌ Erreur lors de la définition de l\'expiration: $e');
    }
  }
} 