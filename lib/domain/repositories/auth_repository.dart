import '../entities/auth_entity.dart';

// Exceptions du domaine pour l'authentification
abstract class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => 'AuthException: $message';
}

class AuthenticationFailedException extends AuthException {
  AuthenticationFailedException(String message) : super(message);
}

class UserAlreadyExistsException extends AuthException {
  UserAlreadyExistsException(String message) : super(message);
}

class NetworkException extends AuthException {
  NetworkException(String message) : super(message);
}

// Interface du repository d'authentification
abstract class AuthRepository {
  // Inscription
  Future<AuthEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  // Connexion
  Future<AuthEntity> signIn({
    required String email,
    required String password,
  });

  // Déconnexion
  Future<void> signOut();

  // Récupérer l'utilisateur actuel
  Future<AuthEntity?> getCurrentUser();

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated();

  // Sauvegarder l'utilisateur localement
  Future<void> saveUserLocally(AuthEntity user);

  // Récupérer l'utilisateur depuis le stockage local
  Future<AuthEntity?> getUserFromLocal();

  // Nettoyer les données locales
  Future<void> clearLocalData();

  // Sauvegarder le token d'authentification
  Future<void> saveAuthToken(String token);

  // Récupérer le token d'authentification
  Future<String?> getAuthToken();

  // Nettoyer le token d'authentification
  Future<void> clearAuthToken();
} 