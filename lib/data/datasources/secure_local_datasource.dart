import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/logging/auth_logger.dart';
import '../models/local_auth_model.dart';
import 'auth_datasource.dart';

class SecureLocalDataSourceImpl implements SecureLocalDataSource {
  static const _storage = FlutterSecureStorage();
  
  // Clés pour le stockage sécurisé
  static const String _userKey = 'auth_user';
  static const String _tokenKey = 'auth_token';
  static const String _authDataKey = 'auth_data';

  @override
  Future<void> saveUser(LocalAuthModel user) async {
    try {
      AuthLogger.log('Sauvegarde utilisateur local', data: {'userId': user.id});
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: _userKey, value: userJson);
      AuthLogger.log('Utilisateur sauvegardé avec succès', data: {'userId': user.id});
    } catch (e) {
      AuthLogger.log('Erreur lors de la sauvegarde de l\'utilisateur', 
          level: LogLevel.error, error: e);
      throw Exception('Erreur lors de la sauvegarde de l\'utilisateur: $e');
    }
  }

  @override
  Future<LocalAuthModel?> getUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson == null) return null;
      
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final user = LocalAuthModel.fromJson(userData);
      
      AuthLogger.log('Utilisateur récupéré depuis le stockage local', 
          data: {'userId': user.id, 'isStale': user.isStale});
      
      return user;
    } catch (e) {
      AuthLogger.log('Erreur lors de la récupération de l\'utilisateur local', 
          level: LogLevel.error, error: e);
      // En cas d'erreur, nettoyer les données corrompues
      await clearUser();
      return null;
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }

  @override
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du token: $e');
    }
  }

  @override
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }

  @override
  Future<void> saveAuthData(Map<String, dynamic> data) async {
    try {
      final authDataJson = jsonEncode(data);
      await _storage.write(key: _authDataKey, value: authDataJson);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des données d\'authentification: $e');
    }
  }

  @override
  Future<Map<String, dynamic>?> getAuthData() async {
    try {
      final authDataJson = await _storage.read(key: _authDataKey);
      if (authDataJson == null) return null;
      
      return jsonDecode(authDataJson) as Map<String, dynamic>;
    } catch (e) {
      // En cas d'erreur, nettoyer les données corrompues
      await clearAuthData();
      return null;
    }
  }

  @override
  Future<void> clearAuthData() async {
    try {
      await _storage.delete(key: _authDataKey);
    } catch (e) {
      // Ignorer les erreurs de nettoyage
    }
  }

  // Méthode utilitaire pour nettoyer toutes les données d'authentification
  Future<void> clearAllAuthData() async {
    await Future.wait([
      clearUser(),
      clearToken(),
      clearAuthData(),
    ]);
  }
} 