import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/logging/auth_logger.dart';
import '../datasources/auth_datasource.dart';
import '../datasources/secure_local_datasource.dart';
import '../models/supabase_auth_model.dart';
import '../models/local_auth_model.dart';
import '../mappers/auth_model_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _remoteDataSource;
  final SecureLocalDataSource _localDataSource;
  final AuthModelMapper _mapper;

  AuthRepositoryImpl({
    required AuthDataSource remoteDataSource,
    required SecureLocalDataSource localDataSource,
    AuthModelMapper? mapper,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _mapper = mapper ?? AuthModelMapperImpl();

  @override
  Future<AuthEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Inscription via la source de données distante
      final supabaseModel = await _remoteDataSource.signUp(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      // Convertir en entité du domaine
      final authEntity = _mapper.toEntity(supabaseModel);

      // Sauvegarder localement (sans le token)
      final localModel = _mapper.supabaseToLocal(supabaseModel);
      await _localDataSource.saveUser(localModel);
      
      // Sauvegarder le token séparément
      if (authEntity.token != null) {
        await _localDataSource.saveToken(authEntity.token!.value);
      }

      AuthLogger.logDataSync(authEntity.id.value, 'signup');
      return authEntity;
    } catch (e) {
      AuthLogger.logDataSyncFailure('unknown', 'signup', e.toString());
      // Nettoyer les données locales en cas d'erreur
      await _localDataSource.clearAllAuthData();
      rethrow;
    }
  }

  @override
  Future<AuthEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Connexion via la source de données distante
      final supabaseModel = await _remoteDataSource.signIn(
        email: email,
        password: password,
      );

      // Convertir en entité du domaine
      final authEntity = _mapper.toEntity(supabaseModel);

      // Sauvegarder localement (sans le token)
      final localModel = _mapper.supabaseToLocal(supabaseModel);
      await _localDataSource.saveUser(localModel);
      
      // Sauvegarder le token séparément
      if (authEntity.token != null) {
        await _localDataSource.saveToken(authEntity.token!.value);
      }

      AuthLogger.logDataSync(authEntity.id.value, 'signin');
      return authEntity;
    } catch (e) {
      AuthLogger.logDataSyncFailure('unknown', 'signin', e.toString());
      // Nettoyer les données locales en cas d'erreur
      await _localDataSource.clearAllAuthData();
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Déconnexion via la source de données distante
      await _remoteDataSource.signOut();
    } catch (e) {
      // Continuer même si la déconnexion distante échoue
    } finally {
      // Toujours nettoyer les données locales
      await _localDataSource.clearAllAuthData();
    }
  }

  @override
  Future<AuthEntity?> getCurrentUser() async {
    try {
      // Essayer de récupérer depuis la source distante d'abord
      final remoteUser = await _remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        // Mettre à jour les données locales
        final localModel = _mapper.supabaseToLocal(remoteUser);
        await _localDataSource.saveUser(localModel);
        return _mapper.toEntity(remoteUser);
      }

      // Si pas d'utilisateur distant, essayer le local
      final localUser = await _localDataSource.getUser();
      if (localUser != null) {
        // Vérifier si le token est encore valide
        final token = await _localDataSource.getToken();
        if (token != null) {
          return _mapper.toEntityFromLocal(localUser, token);
        }
      }

      return null;
    } catch (e) {
      // En cas d'erreur, nettoyer et retourner null
      await _localDataSource.clearAllAuthData();
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      // Vérifier d'abord la source distante
      final isRemoteAuthenticated = await _remoteDataSource.isAuthenticated();
      if (isRemoteAuthenticated) {
        return true;
      }

      // Si pas authentifié à distance, vérifier le token local
      final token = await _localDataSource.getToken();
      return token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> saveUserLocally(AuthEntity user) async {
    final localModel = _mapper.toLocalModel(user);
    await _localDataSource.saveUser(localModel);
  }

  @override
  Future<AuthEntity?> getUserFromLocal() async {
    final localModel = await _localDataSource.getUser();
    if (localModel == null) return null;

    // Récupérer le token séparément
    final token = await _localDataSource.getToken();
    return _mapper.toEntityFromLocal(localModel, token);
  }

  @override
  Future<void> clearLocalData() async {
    await _localDataSource.clearAllAuthData();
  }

  @override
  Future<void> saveAuthToken(String token) async {
    await _localDataSource.saveToken(token);
  }

  @override
  Future<String?> getAuthToken() async {
    return await _localDataSource.getToken();
  }

  @override
  Future<void> clearAuthToken() async {
    await _localDataSource.clearToken();
  }
} 