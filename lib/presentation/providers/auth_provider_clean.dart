import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

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
    if (error is InvalidEmailException) {
      return 'Email invalide';
    } else if (error is InvalidUserDataException) {
      return error.message;
    } else if (error is AuthenticationFailedException) {
      return 'Échec de l\'authentification';
    } else if (error is UserAlreadyExistsException) {
      return 'Un utilisateur avec cet email existe déjà';
    } else if (error is NetworkException) {
      return 'Erreur de connexion réseau';
    } else if (error.toString().contains('Email ou mot de passe incorrect')) {
      return 'Email ou mot de passe incorrect';
    } else {
      return 'Une erreur inattendue s\'est produite';
    }
  }
} 