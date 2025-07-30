import '../entities/user_entity.dart';

// Exceptions du domaine
abstract class UserRepositoryException implements Exception {
  final String message;
  UserRepositoryException(this.message);
  
  @override
  String toString() => 'UserRepositoryException: $message';
}

class UserNotFoundException extends UserRepositoryException {
  UserNotFoundException(String message) : super(message);
}

class UserAuthenticationException extends UserRepositoryException {
  UserAuthenticationException(String message) : super(message);
}

class UserValidationException extends UserRepositoryException {
  UserValidationException(String message) : super(message);
}

// Interface du repository
abstract class UserRepository {
  // Authentification
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Map<String, bool>? notificationPreferences,
  });

  Future<UserEntity> signIn({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<void> signOut();

  Future<void> resetPassword(String email);

  // Opérations CRUD
  Future<UserEntity?> getUserById(String userId);
  
  Future<UserEntity?> getUserByEmail(String email);
  
  Future<UserEntity> updateUser(UserEntity user);
  
  Future<void> deleteUser(String userId);
  
  Future<List<UserEntity>> getAllUsers();

  // Gestion des sessions
  Future<UserEntity?> getCurrentUser();
  
  Future<bool> isUserAuthenticated();
  
  Future<void> updateLastLogin(String userId);

  // Gestion des préférences
  Future<void> updateNotificationPreferences(
    String userId, 
    Map<String, bool> preferences
  );

  // Gestion premium
  Future<UserEntity> upgradeToPremium(
    String userId, 
    PremiumPlan plan,
    DateTime expiresAt,
  );

  Future<UserEntity> cancelPremium(String userId);

  // Vérification
  Future<void> verifyEmail(String userId);
  
  Future<void> verifyPhone(String userId, String code);

  // Gestion des tokens
  Future<String?> getAuthToken();
  
  Future<void> saveAuthToken(String token);
  
  Future<void> clearAuthToken();

  // Gestion des données locales
  Future<void> saveUserLocally(UserEntity user);
  
  Future<UserEntity?> getUserFromLocal();
  
  Future<void> clearLocalUser();
} 