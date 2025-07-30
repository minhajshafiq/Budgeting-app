import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../data/models/user.dart' as app_models;
import '../core/config/supabase_config.dart';
import 'secure_storage_service.dart';

// Alias pour éviter les conflits de noms
typedef AppUser = app_models.User;

class AuthService {
  // Service de stockage sécurisé
  final SecureStorageService _secureStorage = SecureStorageService();
  
  // Clés pour SharedPreferences (pour les données non sensibles)
  static const String _userKey = 'current_user';
  
  // Limite de tentatives de connexion échouées (conservée pour la logique métier)
  static const int _maxLoginAttempts = 5;
  static const int _lockoutDurationMinutes = 15;
  
  // Map pour suivre les tentatives de connexion échouées
  final Map<String, LoginAttempts> _failedLoginAttempts = {};
  
  // Variable pour suivre l'état d'initialisation
  bool _isInitialized = false;
  
  // Instance singleton
  static final AuthService _instance = AuthService._internal();
  
  factory AuthService() {
    return _instance;
  }
  
  AuthService._internal();
  
  // Initialisation de Supabase
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('✅ Supabase déjà initialisé');
      return;
    }
    
    debugPrint('🔧 Vérification de la configuration Supabase...');
    debugPrint('URL: ${SupabaseConfig.url}');
    debugPrint('Clé: ${SupabaseConfig.anonKey.substring(0, 20)}...');
    debugPrint('Configuré: ${SupabaseConfig.isConfigured}');
    
    if (!SupabaseConfig.isConfigured) {
      debugPrint('⚠️ ATTENTION: Supabase n\'est pas configuré. Veuillez mettre à jour vos clés dans lib/config/supabase_config.dart');
      throw Exception('Supabase n\'est pas configuré');
    }
    
    try {
      debugPrint('🚀 Initialisation de Supabase...');
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      
      _isInitialized = true;
      debugPrint('✅ Supabase initialisé avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation de Supabase: $e');
      rethrow;
    }
  }
  
  // Obtenir le client Supabase de manière sûre
  SupabaseClient get _client {
    if (!_isInitialized) {
      throw Exception('Supabase n\'est pas initialisé. Appelez initialize() d\'abord.');
    }
    
    try {
      return Supabase.instance.client;
    } catch (e) {
      throw Exception('Erreur lors de l\'accès au client Supabase: $e');
    }
  }
  
  // Inscription avec Supabase
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // S'assurer que Supabase est initialisé
      await _ensureSupabaseInitialized();
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          ...?additionalData,
        },
      );
      
      if (response.user != null) {
        await _saveTokensFromSession(response.session);
        debugPrint('✅ Inscription réussie: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }
  
  // Connexion avec Supabase
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // S'assurer que Supabase est initialisé
      await _ensureSupabaseInitialized();
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        await _saveTokensFromSession(response.session);
        
        // Mettre à jour lastLoginAt dans les métadonnées utilisateur
        try {
          await _client.auth.updateUser(
            UserAttributes(
              data: {
                'last_login_at': DateTime.now().toIso8601String(),
              },
            ),
          );
          debugPrint('✅ LastLoginAt mis à jour');
        } catch (updateError) {
          debugPrint('⚠️ Erreur lors de la mise à jour lastLoginAt: $updateError');
          // Ne pas faire échouer la connexion pour cette erreur
        }
        
        debugPrint('✅ Connexion réussie: ${response.user!.email}');
      }
      
      return response;
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion: $e');
      rethrow;
    }
  }
  
  // Déconnexion
  Future<void> signOut() async {
    try {
      await _ensureSupabaseInitialized();
      await _client.auth.signOut();
      await clearTokens();
      debugPrint('✅ Déconnexion réussie');
    } catch (e) {
      debugPrint('❌ Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }
  
  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _ensureSupabaseInitialized();
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('✅ Email de récupération envoyé à: $email');
    } catch (e) {
      debugPrint('❌ Erreur lors de la réinitialisation: $e');
      rethrow;
    }
  }
  
  // S'assurer que Supabase est initialisé
  Future<void> _ensureSupabaseInitialized() async {
    if (_isInitialized) {
      return;
    }
    
    debugPrint('🔄 Initialisation de Supabase...');
    await initialize();
  }
  
  // Sauvegarder les tokens de la session Supabase
  Future<void> _saveTokensFromSession(Session? session) async {
    if (session == null) return;
    
    try {
      // Vérifier si le stockage sécurisé est disponible
      final isSecureAvailable = await _secureStorage.isSecureStorageAvailable();
      
      if (isSecureAvailable) {
        // Utiliser le stockage sécurisé
        await _secureStorage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          sessionExpiry: session.expiresAt != null 
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : null,
        );
        debugPrint('✅ Tokens sauvegardés dans le stockage sécurisé');
      } else {
        // Fallback vers une méthode alternative si le stockage sécurisé n'est pas disponible
        debugPrint('⚠️ Stockage sécurisé non disponible, impossible de sauvegarder les tokens');
        throw Exception('Stockage sécurisé non disponible');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la sauvegarde des tokens: $e');
    }
  }
  
  // Générer des tokens d'authentification pour un utilisateur (conservé pour compatibilité)
  Future<TokenPair> generateTokens(AppUser user) async {
    await _ensureSupabaseInitialized();
    final session = _client.auth.currentSession;
    if (session != null) {
      await _saveTokensFromSession(session);
      return TokenPair(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
      );
    }
    throw Exception('Aucune session active');
  }
  
  // Vérifier si un token est valide et non expiré (utilise Supabase)
  bool isTokenValid(String token) {
    try {
      final session = _client.auth.currentSession;
      return session != null && session.accessToken == token;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du token: $e');
      return false;
    }
  }
  
  // Rafraîchir le token d'accès (utilise Supabase)
  Future<String?> refreshAccessToken(String refreshToken) async {
    try {
      await _ensureSupabaseInitialized();
      final response = await _client.auth.refreshSession();
      if (response.session != null) {
        await _saveTokensFromSession(response.session);
        return response.session!.accessToken;
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement du token: $e');
      return null;
    }
  }
  
  // Récupérer les tokens stockés
  Future<TokenPair?> getStoredTokens() async {
    try {
      // Essayer d'abord le stockage sécurisé
      final isSecureAvailable = await _secureStorage.isSecureStorageAvailable();
      
      if (isSecureAvailable) {
        final tokens = await _secureStorage.getTokens();
        final accessToken = tokens['access_token'];
        final refreshToken = tokens['refresh_token'];
      
        if (accessToken != null && refreshToken != null) {
      return TokenPair(accessToken: accessToken, refreshToken: refreshToken);
        }
      }
      
      // Pas de fallback, retourner null si le stockage sécurisé n'est pas disponible
      debugPrint('⚠️ Stockage sécurisé non disponible, impossible de récupérer les tokens');
      return null;
      
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération des tokens: $e');
      return null;
    }
  }
  
  // Effacer les tokens
  Future<void> clearTokens() async {
    try {
      // Effacer du stockage sécurisé
      await _secureStorage.clearTokens();
      
      // Effacer toutes les données utilisateur
      await _secureStorage.clearUserData();
    } catch (e) {
      debugPrint('Erreur lors de la suppression des tokens: $e');
    }
  }
  
  // Vérifier si l'utilisateur est bloqué après trop de tentatives échouées
  bool isUserLocked(String email) {
    final attempts = _failedLoginAttempts[email.toLowerCase()];
    if (attempts == null) return false;
    
    if (attempts.count >= _maxLoginAttempts) {
      final lockoutEndTime = attempts.lastAttemptTime
          .add(Duration(minutes: _lockoutDurationMinutes));
      
      if (DateTime.now().isBefore(lockoutEndTime)) {
        return true;
      } else {
        // Réinitialiser le compteur si le temps de blocage est passé
        _failedLoginAttempts.remove(email.toLowerCase());
        return false;
      }
    }
    
    return false;
  }
  
  // Incrémenter le compteur de tentatives échouées
  void incrementFailedLoginAttempt(String email) {
    final lowerEmail = email.toLowerCase();
    if (_failedLoginAttempts.containsKey(lowerEmail)) {
      _failedLoginAttempts[lowerEmail] = LoginAttempts(
        count: _failedLoginAttempts[lowerEmail]!.count + 1,
        lastAttemptTime: DateTime.now(),
      );
    } else {
      _failedLoginAttempts[lowerEmail] = LoginAttempts(
        count: 1,
        lastAttemptTime: DateTime.now(),
      );
    }
  }
  
  // Réinitialiser le compteur de tentatives échouées
  void resetFailedLoginAttempts(String email) {
    _failedLoginAttempts.remove(email.toLowerCase());
  }
  
  // Temps restant avant déblocage (en minutes)
  int getRemainingLockoutTime(String email) {
    final attempts = _failedLoginAttempts[email.toLowerCase()];
    if (attempts == null || attempts.count < _maxLoginAttempts) return 0;
    
    final lockoutEndTime = attempts.lastAttemptTime
        .add(Duration(minutes: _lockoutDurationMinutes));
    
    final remaining = lockoutEndTime.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining : 0;
  }

  // Cache de l'utilisateur actuel
  AppUser? _cachedCurrentUser;

  // Récupérer l'utilisateur actuel (synchrone, depuis le cache ou Supabase)
  AppUser? get currentUser {
    try {
      final supabaseUser = _client.auth.currentUser;
      if (supabaseUser != null) {
        return _mapSupabaseUserToUser(supabaseUser);
      }
      return _cachedCurrentUser;
    } catch (e) {
      // Si Supabase n'est pas initialisé, retourner le cache
      return _cachedCurrentUser;
    }
  }

  // Récupérer l'utilisateur actuel de manière asynchrone
  Future<AppUser?> getCurrentUser() async {
    try {
      await _ensureSupabaseInitialized();
      final supabaseUser = _client.auth.currentUser;
      if (supabaseUser != null) {
        final user = _mapSupabaseUserToUser(supabaseUser);
        _cachedCurrentUser = user;
        
        // Sauvegarder dans le stockage sécurisé
        await _secureStorage.saveUserData(json.encode(user.toJson()));
        
        debugPrint('✅ Utilisateur récupéré depuis Supabase: ${user.fullName}');
        return user;
      }
      
      // Fallback vers le stockage sécurisé si pas de session Supabase
      final userJson = await _secureStorage.getUserData();
      if (userJson != null) {
        try {
          final user = AppUser.fromJson(json.decode(userJson));
          _cachedCurrentUser = user;
          debugPrint('✅ Utilisateur récupéré depuis le stockage local: ${user.fullName}');
          return user;
        } catch (e) {
          debugPrint('❌ Erreur lors du parsing des données utilisateur stockées: $e');
          await _secureStorage.clearUserData();
          return null;
        }
      }
      
      debugPrint('👤 Aucun utilisateur trouvé');
      return null;
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }
  
  // Convertir un utilisateur Supabase en modèle User de l'app
  AppUser _mapSupabaseUserToUser(dynamic supabaseUser) {
    final metadata = supabaseUser.userMetadata ?? {};
    
    // Gérer lastLoginAt de manière sûre et universelle
    DateTime? lastLoginAt;
    final val = supabaseUser.lastSignInAt ?? metadata['last_login_at'];
    lastLoginAt = app_models.User.fromJson({'createdAt': val}).createdAt ?? supabaseUser.createdAt;
    
    return AppUser(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      firstName: metadata['first_name'] ?? '',
      lastName: metadata['last_name'] ?? '',
      phoneNumber: metadata['phone_number'],
      isEmailVerified: supabaseUser.emailConfirmedAt != null,
      createdAt: supabaseUser.createdAt,
      lastLoginAt: lastLoginAt,
      notificationPreferences: metadata['notification_preferences'] != null 
          ? Map<String, bool>.from(metadata['notification_preferences'])
          : null,
    );
  }
  
  // Méthodes de gestion des erreurs Supabase
  String getAuthErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Email ou mot de passe incorrect';
        case 'Email not confirmed':
          return 'Veuillez confirmer votre email avant de vous connecter';
        case 'User already registered':
          return 'Un compte existe déjà avec cet email';
        case 'Password should be at least 6 characters':
          return 'Le mot de passe doit contenir au moins 6 caractères';
        case 'Unable to validate email address: invalid format':
          return 'Format d\'email invalide';
        case 'Signup requires a valid password':
          return 'Le mot de passe est requis pour l\'inscription';
        default:
          return 'Erreur d\'authentification: ${error.message}';
      }
    }
    return 'Erreur inattendue: $error';
  }
  
  // Vérifier si Supabase est configuré
  bool get isSupabaseConfigured => SupabaseConfig.isConfigured;
  
  // Obtenir l'état de la session Supabase
  bool get hasActiveSession {
    try {
      return _client.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }

  // Vérifier si la session actuelle est valide
  Future<bool> isSessionValid() async {
    try {
      await _ensureSupabaseInitialized();
      
      // Vérifier si Supabase a une session active
      final session = _client.auth.currentSession;
      if (session != null) {
        // Vérifier si le token n'est pas expiré
        if (session.expiresAt != null) {
          final expiryTime = DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000);
          final now = DateTime.now();
          final isValid = now.isBefore(expiryTime);
          
          if (isValid) {
            debugPrint('✅ Session Supabase valide');
            return true;
          } else {
            debugPrint('⚠️ Session Supabase expirée');
            return false;
          }
        }
        return true; // Pas d'expiration définie, considérer comme valide
      }
      
      // Vérifier le stockage local
      final tokens = await _secureStorage.getTokens();
      if (tokens['access_token'] != null && tokens['refresh_token'] != null) {
        debugPrint('✅ Tokens trouvés dans le stockage local');
        return true;
      }
      
      debugPrint('👤 Aucune session valide trouvée');
      return false;
    } catch (e) {
      debugPrint('❌ Erreur lors de la vérification de session: $e');
      return false;
    }
  }
}

// Classes d'assistance conservées pour compatibilité
class TokenPair {
  final String accessToken;
  final String refreshToken;
  
  TokenPair({required this.accessToken, required this.refreshToken});
}

class LoginAttempts {
  final int count;
  final DateTime lastAttemptTime;
  
  LoginAttempts({required this.count, required this.lastAttemptTime});
} 