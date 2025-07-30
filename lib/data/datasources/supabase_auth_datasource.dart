import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../core/config/supabase_config.dart';
import '../../core/logging/auth_logger.dart';
import '../models/supabase_auth_model.dart';
import '../mappers/auth_model_mapper.dart';
import 'auth_datasource.dart';

class SupabaseAuthDataSource implements AuthDataSource {
  SupabaseClient? _supabase;
  
  SupabaseClient get _client {
    if (_supabase == null) {
      throw Exception('Supabase non initialisé');
    }
    return _supabase!;
  }

  Future<void> initialize() async {
    if (!SupabaseConfig.isConfigured) {
      throw Exception('Configuration Supabase invalide');
    }
    
    try {
      // Utiliser l'instance Supabase déjà initialisée
      _supabase = Supabase.instance.client;
      debugPrint('✅ Client Supabase récupéré dans AuthDataSource');
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du client Supabase: $e');
      throw Exception('Supabase n\'est pas initialisé. Vérifiez l\'initialisation dans main.dart');
    }
  }

  @override
  Future<SupabaseAuthModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      AuthLogger.logSignUpAttempt('pending');
      
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.user == null) {
        AuthLogger.logSignUpFailure('unknown', 'User creation failed');
        throw Exception('Erreur lors de l\'inscription');
      }

      // Créer le modèle d'authentification Supabase
      final authModel = SupabaseAuthModel.fromSupabaseResponse(
        id: response.user!.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        token: response.session?.accessToken,
        createdAt: DateTime.parse(response.user!.createdAt),
        lastLoginAt: response.user!.lastSignInAt != null 
            ? DateTime.parse(response.user!.lastSignInAt!) 
            : null,
        isEmailVerified: response.user!.emailConfirmedAt != null,
        userMetadata: response.user!.userMetadata,
      );

      AuthLogger.logSignUpSuccess(response.user!.id);
      return authModel;

      // Essayer de sauvegarder dans la table profiles (optionnel)
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
        });
      } catch (e) {
        AuthLogger.log('Table profiles non trouvée, profil utilisateur non sauvegardé', 
            level: LogLevel.warning, data: {'error': e.toString()});
      }

      return authModel;
    } catch (e) {
      AuthLogger.log('Erreur lors de l\'inscription', 
          level: LogLevel.error, error: e);
      rethrow;
    }
  }

  @override
  Future<SupabaseAuthModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AuthLogger.logSignInAttempt(email);
      
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        AuthLogger.logSignInFailure(email, 'Invalid credentials');
        throw Exception('Email ou mot de passe incorrect');
      }

      // Récupérer les données du profil depuis Supabase
      String firstName = '';
      String lastName = '';
      
      try {
        final profileData = await _client
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', response.user!.id)
            .single();
        
        firstName = profileData['first_name'] ?? '';
        lastName = profileData['last_name'] ?? '';
      } catch (e) {
        AuthLogger.log('Impossible de récupérer le profil', 
            level: LogLevel.warning, data: {'error': e.toString()});
        // Utiliser les données par défaut
        firstName = response.user!.userMetadata?['first_name'] ?? '';
        lastName = response.user!.userMetadata?['last_name'] ?? '';
      }

      final authModel = SupabaseAuthModel.fromSupabaseResponse(
        id: response.user!.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        token: response.session?.accessToken,
        createdAt: DateTime.parse(response.user!.createdAt),
        lastLoginAt: response.user!.lastSignInAt != null 
            ? DateTime.parse(response.user!.lastSignInAt!) 
            : null,
        isEmailVerified: response.user!.emailConfirmedAt != null,
        userMetadata: response.user!.userMetadata,
      );

      AuthLogger.logSignInSuccess(response.user!.id);
      return authModel;
    } catch (e) {
      AuthLogger.logSignInFailure(email, e.toString());
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final user = _client.auth.currentUser;
      await _client.auth.signOut();
      if (user != null) {
        AuthLogger.logSignOut(user.id);
      }
    } catch (e) {
      AuthLogger.log('Erreur lors de la déconnexion', 
          level: LogLevel.error, error: e);
      rethrow;
    }
  }

  @override
  Future<SupabaseAuthModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      // Récupérer les données du profil
      String firstName = '';
      String lastName = '';
      
      try {
        final profileData = await _client
            .from('profiles')
            .select('first_name, last_name')
            .eq('id', user.id)
            .single();
        
        firstName = profileData['first_name'] ?? '';
        lastName = profileData['last_name'] ?? '';
      } catch (e) {
        AuthLogger.log('Impossible de récupérer le profil', 
            level: LogLevel.warning, data: {'error': e.toString()});
        firstName = user.userMetadata?['first_name'] ?? '';
        lastName = user.userMetadata?['last_name'] ?? '';
      }

      return SupabaseAuthModel.fromSupabaseResponse(
        id: user.id,
        email: user.email ?? '',
        firstName: firstName,
        lastName: lastName,
        token: _client.auth.currentSession?.accessToken,
        createdAt: DateTime.parse(user.createdAt),
        lastLoginAt: user.lastSignInAt != null 
            ? DateTime.parse(user.lastSignInAt!) 
            : null,
        isEmailVerified: user.emailConfirmedAt != null,
        userMetadata: user.userMetadata,
      );
    } catch (e) {
      AuthLogger.log('Erreur lors de la récupération de l\'utilisateur', 
          level: LogLevel.error, error: e);
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final user = _client.auth.currentUser;
      final session = _client.auth.currentSession;
      return user != null && session != null;
    } catch (e) {
      debugPrint('Erreur lors de la vérification d\'authentification: $e');
      return false;
    }
  }
} 