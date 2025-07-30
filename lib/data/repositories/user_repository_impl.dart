import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';
import 'package:my_flutter_app/data/mappers/transaction_entity_mapper.dart';

class UserRepositoryImpl implements UserRepository {
  final SupabaseClient _supabase;
  final FlutterSecureStorage _secureStorage;
  
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  UserRepositoryImpl({
    required SupabaseClient supabase,
    required FlutterSecureStorage secureStorage,
  })  : _supabase = supabase,
        _secureStorage = secureStorage;

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Map<String, bool>? notificationPreferences,
  }) async {
    try {
      // Créer l'utilisateur dans Supabase Auth
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'notificationPreferences': notificationPreferences,
        },
      );

      if (authResponse.user == null) {
        throw UserAuthenticationException('Échec de la création du compte');
      }

      // Créer le profil utilisateur dans la base de données
      final userModel = UserModel(
        id: authResponse.user!.id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        notificationPreferences: notificationPreferences,
      );

      await _supabase
          .from('users')
          .insert(userModel.toJson());

      return TransactionEntityMapper.toUserEntity(userModel);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } on AuthException catch (e) {
      throw UserAuthenticationException('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw UserAuthenticationException('Identifiants invalides');
      }

      // Récupérer les données utilisateur complètes
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', authResponse.user!.id)
          .single();

      final userModel = User.fromJson(userData);
      
      // Sauvegarder le token si rememberMe est activé
      if (rememberMe && authResponse.session?.accessToken != null) {
        await saveAuthToken(authResponse.session!.accessToken);
      }

      return TransactionEntityMapper.toUserEntity(userModel);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } on AuthException catch (e) {
      throw UserAuthenticationException('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw UserRepositoryException('Erreur lors de la déconnexion: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw UserAuthenticationException('Erreur de réinitialisation: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity?> getUserById(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;

      final userModel = User.fromJson(data);
      return TransactionEntityMapper.toUserEntity(userModel);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity?> getUserByEmail(String email) async {
    try {
      final data = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .maybeSingle();

      if (data == null) return null;

      final userModel = User.fromJson(data);
      return TransactionEntityMapper.toUserEntity(userModel);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity> updateUser(UserEntity user) async {
    try {
      final userModel = TransactionEntityMapper.toDataUser(user);
      
      await _supabase
          .from('users')
          .update(userModel.toJson())
          .eq('id', user.id.value);

      return TransactionEntityMapper.toUserEntity(userModel);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _supabase
          .from('users')
          .delete()
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<List<UserEntity>> getAllUsers() async {
    try {
      final data = await _supabase
          .from('users')
          .select();

      return data
          .map((json) => TransactionEntityMapper.toUserEntity(User.fromJson(json)))
          .toList();
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      return await getUserById(user.id);
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<bool> isUserAuthenticated() async {
    try {
      return _supabase.auth.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> updateLastLogin(String userId) async {
    try {
      await _supabase
          .from('users')
          .update({'lastLoginAt': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> updateNotificationPreferences(
    String userId, 
    Map<String, bool> preferences
  ) async {
    try {
      await _supabase
          .from('users')
          .update({'notificationPreferences': preferences})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity> upgradeToPremium(
    String userId, 
    PremiumPlan plan,
    DateTime expiresAt,
  ) async {
    try {
      final updateData = {
        'isPremium': true,
        'premiumPlan': plan.toString().split('.').last,
        'premiumExpiresAt': expiresAt.toIso8601String(),
      };

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId);

      final updatedUser = await getUserById(userId);
      if (updatedUser == null) {
        throw UserNotFoundException('Utilisateur non trouvé après mise à jour');
      }

      return updatedUser;
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<UserEntity> cancelPremium(String userId) async {
    try {
      final updateData = {
        'isPremium': false,
        'premiumPlan': null,
        'premiumExpiresAt': null,
      };

      await _supabase
          .from('users')
          .update(updateData)
          .eq('id', userId);

      final updatedUser = await getUserById(userId);
      if (updatedUser == null) {
        throw UserNotFoundException('Utilisateur non trouvé après mise à jour');
      }

      return updatedUser;
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> verifyEmail(String userId) async {
    try {
      // Logique de vérification email
      await _supabase
          .from('users')
          .update({'isEmailVerified': true})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<void> verifyPhone(String userId, String code) async {
    try {
      // Logique de vérification téléphone
      await _supabase
          .from('users')
          .update({'isPhoneVerified': true})
          .eq('id', userId);
    } on PostgrestException catch (e) {
      throw UserRepositoryException('Erreur base de données: ${e.message}');
    } catch (e) {
      throw UserRepositoryException('Erreur inattendue: $e');
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      return await _secureStorage.read(key: _tokenKey);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _secureStorage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw UserRepositoryException('Erreur de sauvegarde du token: $e');
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _secureStorage.delete(key: _tokenKey);
    } catch (e) {
      throw UserRepositoryException('Erreur de suppression du token: $e');
    }
  }

  @override
  Future<void> saveUserLocally(UserEntity user) async {
    try {
      final userModel = TransactionEntityMapper.toDataUser(user);
      final userJson = jsonEncode(userModel.toJson());
      await _secureStorage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw UserRepositoryException('Erreur de sauvegarde locale: $e');
    }
  }

  @override
  Future<UserEntity?> getUserFromLocal() async {
    try {
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson == null) return null;

      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      final userModel = User.fromJson(userData);
      return TransactionEntityMapper.toUserEntity(userModel);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> clearLocalUser() async {
    try {
      await _secureStorage.delete(key: _userKey);
    } catch (e) {
      throw UserRepositoryException('Erreur de suppression locale: $e');
    }
  }
} 