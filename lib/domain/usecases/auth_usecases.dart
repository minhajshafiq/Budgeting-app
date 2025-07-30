import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

// Use Case pour l'inscription
class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthEntity> execute({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Validation métier
    _validateSignUpData(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    // Inscription via le repository
    final user = await repository.signUp(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    // Sauvegarder localement
    await repository.saveUserLocally(user);
    if (user.token != null) {
      await repository.saveAuthToken(user.token!.value);
    }

    return user;
  }

  void _validateSignUpData({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) {
    if (email.isEmpty || !_isValidEmail(email)) {
      throw InvalidEmailException('Email invalide');
    }

    if (password.length < 8) {
      throw InvalidUserDataException('Le mot de passe doit contenir au moins 8 caractères');
    }

    if (firstName.trim().isEmpty) {
      throw InvalidUserDataException('Le prénom est requis');
    }

    if (lastName.trim().isEmpty) {
      throw InvalidUserDataException('Le nom est requis');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}

// Use Case pour la connexion
class SignInUseCase {
  final AuthRepository repository;

  SignInUseCase(this.repository);

  Future<AuthEntity> execute({
    required String email,
    required String password,
  }) async {
    // Validation
    if (email.isEmpty || password.isEmpty) {
      throw InvalidUserDataException('Email et mot de passe requis');
    }

    if (!_isValidEmail(email)) {
      throw InvalidEmailException('Format d\'email invalide');
    }

    // Authentification via le repository
    final user = await repository.signIn(
      email: email,
      password: password,
    );

    // Sauvegarder localement
    await repository.saveUserLocally(user);
    if (user.token != null) {
      await repository.saveAuthToken(user.token!.value);
    }

    return user;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email);
  }
}

// Use Case pour la déconnexion
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> execute() async {
    await repository.signOut();
    await repository.clearLocalData();
    await repository.clearAuthToken();
  }
}

// Use Case pour récupérer l'utilisateur actuel
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<AuthEntity?> execute() async {
    // Vérifier si l'utilisateur est authentifié
    final isAuthenticated = await repository.isAuthenticated();
    if (!isAuthenticated) {
      return null;
    }

    // Récupérer l'utilisateur local d'abord
    AuthEntity? user = await repository.getUserFromLocal();
    
    // Si pas d'utilisateur local, essayer de récupérer depuis le serveur
    if (user == null) {
      user = await repository.getCurrentUser();
      if (user != null) {
        await repository.saveUserLocally(user);
      }
    }

    return user;
  }
}

// Use Case pour vérifier l'authentification
class IsAuthenticatedUseCase {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  Future<bool> execute() async {
    return await repository.isAuthenticated();
  }
} 