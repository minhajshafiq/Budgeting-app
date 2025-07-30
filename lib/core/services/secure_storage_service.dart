import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service pour le stockage sécurisé des données sensibles
/// Utilise flutter_secure_storage qui chiffre automatiquement les données
/// sur Android (KeyStore) et iOS (Keychain)
class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  
  // Clés pour les tokens
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _sessionExpiryKey = 'session_expiry';
  
  // Clés pour les données utilisateur
  static const String _userDataKey = 'user_data';
  static const String _rememberMeKey = 'remember_me';
  
  // Clés pour les transactions
  static const String _transactionsKey = 'transactions';
  
  // Clés pour le thème
  static const String _themeModeKey = 'theme_mode';
  static const String _isDarkModeKey = 'is_dark_mode';
  
  // Options de sécurité pour Android et iOS
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );
  
  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );
  
  // Instance singleton
  static final SecureStorageService _instance = SecureStorageService._internal();
  
  factory SecureStorageService() {
    return _instance;
  }
  
  SecureStorageService._internal();
  
  /// Sauvegarder les tokens de session de manière sécurisée
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    String? userId,
    DateTime? sessionExpiry,
  }) async {
    try {
      debugPrint('🔐 Sauvegarde sécurisée des tokens...');
      
      // Sauvegarder les tokens
      await _storage.write(
        key: _accessTokenKey,
        value: accessToken,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.write(
        key: _refreshTokenKey,
        value: refreshToken,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      // Sauvegarder les métadonnées de session
      if (userId != null) {
        await _storage.write(
          key: _userIdKey,
          value: userId,
          aOptions: _getAndroidOptions(),
          iOptions: _getIOSOptions(),
        );
      }
      
      if (sessionExpiry != null) {
        await _storage.write(
          key: _sessionExpiryKey,
          value: sessionExpiry.toIso8601String(),
          aOptions: _getAndroidOptions(),
          iOptions: _getIOSOptions(),
        );
      }
      
      debugPrint('✅ Tokens sauvegardés avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des tokens: $e');
      rethrow;
    }
  }
  
  /// Récupérer les tokens de session
  Future<Map<String, String?>> getTokens() async {
    try {
      debugPrint('🔐 Récupération des tokens sécurisés...');
      
      final accessToken = await _storage.read(
        key: _accessTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      final refreshToken = await _storage.read(
        key: _refreshTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      final userId = await _storage.read(
        key: _userIdKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      final sessionExpiryString = await _storage.read(
        key: _sessionExpiryKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      DateTime? sessionExpiry;
      if (sessionExpiryString != null) {
        try {
          sessionExpiry = DateTime.parse(sessionExpiryString);
        } catch (e) {
          debugPrint('⚠️ Erreur lors du parsing de la date d\'expiration: $e');
        }
      }
      
      debugPrint('✅ Tokens récupérés avec succès');
      
      return {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'user_id': userId,
        'session_expiry': sessionExpiry?.toIso8601String(),
      };
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des tokens: $e');
      return {
        'access_token': null,
        'refresh_token': null,
        'user_id': null,
        'session_expiry': null,
      };
    }
  }
  
  /// Vérifier si des tokens existent
  Future<bool> hasTokens() async {
    try {
      final accessToken = await _storage.read(
        key: _accessTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      return accessToken != null && accessToken.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification des tokens: $e');
      return false;
    }
  }
  
  /// Supprimer tous les tokens
  Future<void> clearTokens() async {
    try {
      debugPrint('🗑️ Suppression des tokens sécurisés...');
      
      await _storage.delete(
        key: _accessTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.delete(
        key: _refreshTokenKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.delete(
        key: _userIdKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.delete(
        key: _sessionExpiryKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      debugPrint('✅ Tokens supprimés avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression des tokens: $e');
      rethrow;
    }
  }
  
  /// Vérifier si la session est expirée
  Future<bool> isSessionExpired() async {
    try {
      final sessionExpiryString = await _storage.read(
        key: _sessionExpiryKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      if (sessionExpiryString == null) return true;
      
      final sessionExpiry = DateTime.parse(sessionExpiryString);
      final now = DateTime.now();
      
      return now.isAfter(sessionExpiry);
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification d\'expiration: $e');
      return true; // Considérer comme expiré en cas d'erreur
    }
  }
  
  /// Sauvegarder une valeur sécurisée générique
  Future<void> saveSecureValue(String key, String value) async {
    try {
      await _storage.write(
        key: key,
        value: value,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde de $key: $e');
      rethrow;
    }
  }
  
  /// Récupérer une valeur sécurisée générique
  Future<String?> getSecureValue(String key) async {
    try {
      return await _storage.read(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de $key: $e');
      return null;
    }
  }
  
  /// Supprimer une valeur sécurisée générique
  Future<void> deleteSecureValue(String key) async {
    try {
      await _storage.delete(
        key: key,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de $key: $e');
      rethrow;
    }
  }
  
  /// Obtenir les options Android avec gestion d'erreur
  AndroidOptions _getAndroidOptions() {
    try {
      return _androidOptions;
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la configuration Android, utilisation des options par défaut: $e');
      return const AndroidOptions();
    }
  }
  
  /// Obtenir les options iOS avec gestion d'erreur
  IOSOptions _getIOSOptions() {
    try {
      return _iosOptions;
    } catch (e) {
      debugPrint('⚠️ Erreur lors de la configuration iOS, utilisation des options par défaut: $e');
      return const IOSOptions();
    }
  }
  
  /// Sauvegarder les données utilisateur
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(
        key: _userDataKey,
        value: userData,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      debugPrint('✅ Données utilisateur sauvegardées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des données utilisateur: $e');
      rethrow;
    }
  }
  
  /// Récupérer les données utilisateur
  Future<String?> getUserData() async {
    try {
      return await _storage.read(
        key: _userDataKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des données utilisateur: $e');
      return null;
    }
  }
  
  /// Sauvegarder les transactions
  Future<void> saveTransactions(String transactionsData) async {
    try {
      await _storage.write(
        key: _transactionsKey,
        value: transactionsData,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      debugPrint('✅ Transactions sauvegardées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des transactions: $e');
      rethrow;
    }
  }
  
  /// Récupérer les transactions
  Future<String?> getTransactions() async {
    try {
      return await _storage.read(
        key: _transactionsKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des transactions: $e');
      return null;
    }
  }
  
  /// Sauvegarder les préférences de thème
  Future<void> saveThemePreferences({
    required String themeMode,
    required bool isDarkMode,
  }) async {
    try {
      await _storage.write(
        key: _themeModeKey,
        value: themeMode,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.write(
        key: _isDarkModeKey,
        value: isDarkMode.toString(),
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      debugPrint('✅ Préférences de thème sauvegardées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des préférences de thème: $e');
      rethrow;
    }
  }
  
  /// Récupérer les préférences de thème
  Future<Map<String, dynamic>> getThemePreferences() async {
    try {
      final themeMode = await _storage.read(
        key: _themeModeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      final isDarkModeString = await _storage.read(
        key: _isDarkModeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      final isDarkMode = isDarkModeString == 'true';
      
      return {
        'themeMode': themeMode ?? 'system',
        'isDarkMode': isDarkMode,
      };
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des préférences de thème: $e');
      return {
        'themeMode': 'system',
        'isDarkMode': false,
      };
    }
  }
  
  /// Sauvegarder l'option "Se souvenir de moi"
  Future<void> saveRememberMe(bool rememberMe) async {
    try {
      await _storage.write(
        key: _rememberMeKey,
        value: rememberMe.toString(),
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde de "Se souvenir de moi": $e');
      rethrow;
    }
  }
  
  /// Récupérer l'option "Se souvenir de moi"
  Future<bool> getRememberMe() async {
    try {
      final value = await _storage.read(
        key: _rememberMeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      return value == 'true';
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de "Se souvenir de moi": $e');
      return false;
    }
  }
  
  /// Supprimer toutes les données utilisateur
  Future<void> clearUserData() async {
    try {
      await _storage.delete(
        key: _userDataKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.delete(
        key: _rememberMeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      debugPrint('✅ Données utilisateur supprimées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression des données utilisateur: $e');
      rethrow;
    }
  }
  
  /// Supprimer toutes les données de l'application
  Future<void> clearAllData() async {
    try {
      await clearTokens();
      await clearUserData();
      
      // Supprimer les transactions
      await _storage.delete(
        key: _transactionsKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      // Supprimer les préférences de thème
      await _storage.delete(
        key: _themeModeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      await _storage.delete(
        key: _isDarkModeKey,
        aOptions: _getAndroidOptions(),
        iOptions: _getIOSOptions(),
      );
      
      debugPrint('✅ Toutes les données supprimées');
    } catch (e) {
      debugPrint('❌ Erreur lors de la suppression de toutes les données: $e');
      rethrow;
    }
  }
  
  /// Vérifier si le stockage sécurisé est disponible
  Future<bool> isSecureStorageAvailable() async {
    try {
      // Test simple pour vérifier la disponibilité
      await _storage.write(key: 'test_key', value: 'test_value');
      await _storage.delete(key: 'test_key');
      return true;
    } catch (e) {
      debugPrint('❌ Stockage sécurisé non disponible: $e');
      return false;
    }
  }
} 