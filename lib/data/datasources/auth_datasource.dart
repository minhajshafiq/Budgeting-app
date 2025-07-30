import '../models/supabase_auth_model.dart';
import '../models/local_auth_model.dart';

// Interface pour la source de données d'authentification
abstract class AuthDataSource {
  Future<SupabaseAuthModel> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<SupabaseAuthModel> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<SupabaseAuthModel?> getCurrentUser();

  Future<bool> isAuthenticated();
}

// Interface pour le stockage local sécurisé
abstract class SecureLocalDataSource {
  Future<void> saveUser(LocalAuthModel user);
  Future<LocalAuthModel?> getUser();
  Future<void> clearUser();
  
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
  
  Future<void> saveAuthData(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getAuthData();
  Future<void> clearAuthData();
  
  Future<void> clearAllAuthData();
} 