import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/providers/auth_provider.dart';
import '../utils/user_provider.dart';
import '../data/models/user.dart';

/// Service pour synchroniser les informations utilisateur entre AuthProvider et UserProvider
class UserSessionSync {
  static final UserSessionSync _instance = UserSessionSync._internal();
  
  factory UserSessionSync() {
    return _instance;
  }
  
  UserSessionSync._internal();
  
  /// Synchroniser les informations utilisateur de AuthProvider vers UserProvider
  void syncUserInfo(AuthStateManager authStateManager, UserProvider userProvider) {
    final User? currentUser = authStateManager.currentUser;
    
    if (currentUser != null) {
      userProvider.updateProfile(
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        email: currentUser.email,
      );
      debugPrint('Session utilisateur synchronisée: ${currentUser.fullName}');
    } else {
      userProvider.logout();
      debugPrint('Session utilisateur déconnectée');
    }
  }
  
  /// Mettre à jour les informations utilisateur dans les deux providers
  Future<bool> updateUserInfo({
    required AuthStateManager authProvider,
    required UserProvider userProvider,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      // Mettre à jour dans AuthProvider
      final success = await authProvider.updateProfile(
        firstName: firstName,
        lastName: lastName,
      );
      
      if (success) {
        // Mettre à jour dans UserProvider
        userProvider.updateProfile(
          firstName: firstName ?? userProvider.firstName,
          lastName: lastName ?? userProvider.lastName,
          email: email ?? userProvider.email,
        );
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }
  
  /// Mettre à jour les préférences de notifications dans les deux providers
  Future<bool> updateNotificationPreferences({
    required AuthStateManager authProvider,
    required UserProvider userProvider,
    required Map<String, bool> notificationPreferences,
  }) async {
    try {
      // Mettre à jour dans AuthProvider
      final success = await authProvider.updateNotificationPreferences(notificationPreferences);
      
      if (success) {
        debugPrint('Préférences de notification mises à jour');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des préférences de notification: $e');
      return false;
    }
  }
} 