import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../presentation/auth/core/types/auth_types.dart' as auth_types;

// États d'authentification
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

// Classe pour gérer l'état d'authentification
class AuthStateManager extends ChangeNotifier {
  AuthState _state = AuthState.initial;
  AuthEntity? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthState get state => _state;
  AuthEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;

  // Use Cases
  late final SignUpUseCase _signUpUseCase;
  late final SignInUseCase _signInUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsAuthenticatedUseCase _isAuthenticatedUseCase;

  // Initialisation avec injection de dépendances
  void initialize(AuthRepository repository) {
    _signUpUseCase = SignUpUseCase(repository);
    _signInUseCase = SignInUseCase(repository);
    _signOutUseCase = SignOutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    _isAuthenticatedUseCase = IsAuthenticatedUseCase(repository);
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    _state = loading ? AuthState.loading : _state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
  }

  void _setAuthenticated(AuthEntity user) {
    _currentUser = user;
    _state = AuthState.authenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setUnauthenticated() {
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // Méthodes publiques
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      
      final isAuthenticated = await _isAuthenticatedUseCase.execute();
      if (isAuthenticated) {
      final user = await _getCurrentUserUseCase.execute();
      if (user != null) {
          _setAuthenticated(user);
        } else {
          _setUnauthenticated();
        }
      } else {
        _setUnauthenticated();
      }
    } catch (e) {
      debugPrint('Erreur lors de la vérification du statut d\'authentification: $e');
      _setUnauthenticated();
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _signUpUseCase.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _setAuthenticated(user);
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      final user = await _signInUseCase.execute(
        email: email,
        password: password,
      );

      _setAuthenticated(user);
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔄 Début de la déconnexion...');
      _setLoading(true);
      await _signOutUseCase.execute();
      debugPrint('✅ Déconnexion réussie via use case');
      _setUnauthenticated();
      debugPrint('✅ État mis à jour: utilisateur déconnecté');
    } catch (e) {
      debugPrint('❌ Erreur lors de la déconnexion: $e');
      // Même en cas d'erreur, on déconnecte localement
      _setUnauthenticated();
      debugPrint('✅ Déconnexion locale effectuée malgré l\'erreur');
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = _currentUser != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // Méthode utilitaire pour convertir les exceptions en messages d'erreur
  String _getErrorMessage(dynamic error) {
    // Erreurs d'authentification spécifiques
    if (error is InvalidEmailException) {
      return 'Email invalide';
    } else if (error is InvalidUserDataException) {
      return error.message;
    } else if (error is AuthenticationFailedException) {
      return 'Échec de l\'authentification';
    } else if (error is UserAlreadyExistsException) {
      return 'Un compte avec cet email existe déjà. Veuillez vous connecter ou utiliser un autre email.';
    } else if (error is NetworkException) {
      return 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
    } 
    // Erreurs Supabase spécifiques
    else if (error.toString().contains('User already registered')) {
      return 'Un compte avec cet email existe déjà. Veuillez vous connecter ou utiliser un autre email.';
    } else if (error.toString().contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (error.toString().contains('Email not confirmed')) {
      return 'Veuillez confirmer votre email avant de vous connecter';
    } else if (error.toString().contains('Too many requests')) {
      return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
    } else if (error.toString().contains('Password should be at least')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    } else if (error.toString().contains('Unable to validate email address')) {
      return 'Format d\'email invalide';
    } else if (error.toString().contains('Network error') || error.toString().contains('Connection failed')) {
      return 'Erreur de connexion réseau. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('timeout') || error.toString().contains('timed out')) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion internet.';
    } else if (error.toString().contains('server error') || error.toString().contains('500')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    } else if (error.toString().contains('service unavailable') || error.toString().contains('503')) {
      return 'Service temporairement indisponible. Veuillez réessayer plus tard.';
    } else if (error.toString().contains('bad request') || error.toString().contains('400')) {
      return 'Données invalides. Veuillez vérifier vos informations.';
    } else if (error.toString().contains('unauthorized') || error.toString().contains('401')) {
      return 'Accès non autorisé. Veuillez vous reconnecter.';
    } else if (error.toString().contains('forbidden') || error.toString().contains('403')) {
      return 'Accès interdit. Veuillez contacter le support.';
    } else if (error.toString().contains('not found') || error.toString().contains('404')) {
      return 'Ressource non trouvée. Veuillez réessayer.';
    } else if (error.toString().contains('conflict') || error.toString().contains('409')) {
      return 'Conflit de données. Un compte avec ces informations existe peut-être déjà.';
    } else if (error.toString().contains('rate limit') || error.toString().contains('429')) {
      return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
    } else if (error.toString().contains('Email ou mot de passe incorrect')) {
      return 'Email ou mot de passe incorrect';
    } else {
      // Erreur générique avec plus de détails pour le débogage
      debugPrint('Erreur non gérée: $error');
      return 'Une erreur inattendue s\'est produite. Veuillez réessayer.';
    }
  }

  // Ajout pour la clean architecture : resetPassword
  Future<bool> resetPassword(String email) async {
    // On délègue à AuthProvider pour compatibilité
    if (this is AuthProvider) {
      return await (this as AuthProvider).resetPassword(email);
    }
    debugPrint('resetPassword non implémenté pour AuthStateManager générique');
    return false;
  }
}

// Alias pour maintenir la compatibilité avec l'ancien code
class AuthProvider extends AuthStateManager {
  // Méthode de connexion pour compatibilité avec l'ancien code
  Future<LoginResult> login(auth_types.LoginData loginData) async {
    try {
      final success = await signIn(
        email: loginData.email,
        password: loginData.password,
      );
      
      if (success && currentUser != null) {
        return LoginResult(
          success: true,
          user: currentUser!,
          error: null,
        );
      } else {
        return LoginResult(
          success: false,
          user: null,
          error: errorMessage ?? 'Échec de la connexion',
        );
      }
    } catch (e) {
      return LoginResult(
        success: false,
        user: null,
        error: _getErrorMessage(e),
      );
    }
  }
  
  // Méthode de réinitialisation de mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      // Implémentation de la réinitialisation de mot de passe
      // Cette méthode devrait être implémentée selon vos besoins
      debugPrint('🔄 Réinitialisation de mot de passe pour: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur lors de la réinitialisation: $e');
      return false;
    }
  }
  
  // Getter pour l'erreur
  String? get error => errorMessage;
}

// Classe pour la compatibilité
class LoginResult {
  final bool success;
  final AuthEntity? user;
  final String? error;
  
  LoginResult({
    required this.success,
    this.user,
    this.error,
  });
} 