import 'package:flutter/foundation.dart';
import '../services/session_manager.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

/// Provider unifié pour la gestion d'état d'authentification
/// Utilise le SessionManager pour une gestion centralisée des sessions
class AuthStateProvider extends ChangeNotifier {
  final SessionManager _sessionManager = SessionManager();
  
  // État actuel
  AuthState _state = AuthState.initial;
  AuthEntity? _currentUser;
  String? _errorMessage;
  bool _isLoading = false;

  // Use Cases
  late final SignUpUseCase _signUpUseCase;
  late final SignInUseCase _signInUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;
  late final IsAuthenticatedUseCase _isAuthenticatedUseCase;
  
  // Repository
  late final AuthRepository _authRepository;

  // Getters
  AuthState get state => _state;
  AuthEntity? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  SessionManager get sessionManager => _sessionManager;

  /// Initialiser le provider avec le repository
  void initialize(AuthRepository repository) {
    _authRepository = repository;
    _signUpUseCase = SignUpUseCase(repository);
    _signInUseCase = SignInUseCase(repository);
    _signOutUseCase = SignOutUseCase(repository);
    _getCurrentUserUseCase = GetCurrentUserUseCase(repository);
    _isAuthenticatedUseCase = IsAuthenticatedUseCase(repository);

    // Écouter les changements de session
    _sessionManager.sessionStateStream.listen(_onSessionStateChanged);
  }

  /// Initialiser et vérifier le statut d'authentification
  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);
      
      // Initialiser le session manager
      await _sessionManager.initialize();
      
      // Vérifier si l'utilisateur est authentifié
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

  /// Inscription d'un nouvel utilisateur
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

      // Créer une session pour le nouvel utilisateur
      await _createSessionForUser(user);

      _setAuthenticated(user);
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      return false;
    }
  }

  /// Connexion d'un utilisateur
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

      // Créer une session pour l'utilisateur connecté
      await _createSessionForUser(user);

      _setAuthenticated(user);
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      return false;
    }
  }

  /// Déconnexion de l'utilisateur
  Future<void> signOut() async {
    try {
      _setLoading(true);

      // Nettoyer la session
      await _sessionManager.clearSession();

      // Appeler le use case de déconnexion
      await _signOutUseCase.execute();

      _setUnauthenticated();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      // Même en cas d'erreur, on déconnecte localement
      _setUnauthenticated();
    }
  }

  /// Mettre à jour le profil utilisateur
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
  }) async {
    try {
      if (_currentUser == null) return false;

      // Créer un nouvel utilisateur avec les données mises à jour
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
      );

      // Mettre à jour dans le session manager
      await _sessionManager.updateUserData(updatedUser);

      // Mettre à jour l'état local
      _currentUser = updatedUser;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour du profil: $e');
      return false;
    }
  }

  /// Rafraîchir le token d'accès
  Future<bool> refreshToken() async {
    try {
      final success = await _sessionManager.refreshAccessToken();
      if (success) {
        debugPrint('✅ Token rafraîchi avec succès');
      } else {
        debugPrint('❌ Échec du rafraîchissement du token');
        // Si le rafraîchissement échoue, déconnecter l'utilisateur
        await signOut();
      }
      return success;
    } catch (e) {
      debugPrint('❌ Erreur lors du rafraîchissement du token: $e');
      await signOut();
      return false;
    }
  }

  /// Vérifier si la session est valide
  Future<bool> isSessionValid() async {
    return await _sessionManager.isSessionValid();
  }

  /// Obtenir le token d'accès actuel
  Future<String?> getAccessToken() async {
    return await _sessionManager.getAccessToken();
  }

  /// Réinitialiser le mot de passe
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;

      // TODO: Implémenter la réinitialisation du mot de passe
      // Pour l'instant, simuler un succès
      await Future.delayed(const Duration(seconds: 1));
      
      _setLoading(false);
      return true;
    } catch (e) {
      final errorMessage = _getErrorMessage(e);
      _setError(errorMessage);
      return false;
    }
  }

  // Méthodes privées

  /// Créer une session pour un utilisateur
  Future<void> _createSessionForUser(AuthEntity user) async {
    try {
      // Récupérer les tokens depuis le repository
      final tokens = await _getCurrentUserUseCase.execute();
      if (tokens != null && tokens.token != null) {
        await _sessionManager.createSession(
          user: user,
          accessToken: tokens.token!.value,
          refreshToken: '', // Le refresh token sera géré par Supabase
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la création de session: $e');
    }
  }

  /// Gérer les changements d'état de session
  void _onSessionStateChanged(SessionState sessionState) {
    switch (sessionState) {
      case SessionState.initial:
        _setState(AuthState.initial);
        break;
      case SessionState.loading:
        _setLoading(true);
        break;
      case SessionState.authenticated:
        _setLoading(false);
        // L'utilisateur sera mis à jour via le session manager
        break;
      case SessionState.unauthenticated:
        _setUnauthenticated();
        break;
      case SessionState.error:
        _setError('Erreur de session');
        break;
      case SessionState.expired:
        _setError('Session expirée');
        _setUnauthenticated();
        break;
    }
  }

  /// Définir l'état de chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    _state = loading ? AuthState.loading : _state;
    notifyListeners();
  }

  /// Définir une erreur
  void _setError(String message) {
    _errorMessage = message;
    _state = AuthState.error;
    _isLoading = false;
    notifyListeners();
  }

  /// Définir l'utilisateur comme authentifié
  void _setAuthenticated(AuthEntity user) {
    _currentUser = user;
    _state = AuthState.authenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Définir l'utilisateur comme non authentifié
  void _setUnauthenticated() {
    _currentUser = null;
    _state = AuthState.unauthenticated;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Définir l'état
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  /// Obtenir un message d'erreur lisible
  String _getErrorMessage(dynamic error) {
    if (error is String) return error;
    
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('invalid email')) {
      return 'Adresse email invalide';
    } else if (errorString.contains('weak password')) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    } else if (errorString.contains('email already registered')) {
      return 'Cette adresse email est déjà utilisée';
    } else if (errorString.contains('invalid credentials')) {
      return 'Email ou mot de passe incorrect';
    } else if (errorString.contains('network')) {
      return 'Erreur de connexion réseau';
    } else {
      return 'Une erreur est survenue. Veuillez réessayer.';
    }
  }

  @override
  void dispose() {
    _sessionManager.dispose();
    super.dispose();
  }
}

/// États d'authentification
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
} 