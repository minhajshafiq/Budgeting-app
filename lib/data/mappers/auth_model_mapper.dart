import '../../domain/entities/auth_entity.dart';
import '../models/supabase_auth_model.dart';
import '../models/local_auth_model.dart';

// Interface du mapper pour l'authentification
abstract class AuthModelMapper {
  // Conversion vers entité du domaine
  AuthEntity toEntity(SupabaseAuthModel model);
  AuthEntity toEntityFromLocal(LocalAuthModel model, String? token);
  
  // Conversion depuis entité du domaine
  SupabaseAuthModel toSupabaseModel(AuthEntity entity);
  LocalAuthModel toLocalModel(AuthEntity entity);
  
  // Conversion entre modèles
  LocalAuthModel supabaseToLocal(SupabaseAuthModel supabaseModel);
  SupabaseAuthModel localToSupabase(LocalAuthModel localModel, String? token);
}

// Implémentation du mapper
class AuthModelMapperImpl implements AuthModelMapper {
  @override
  AuthEntity toEntity(SupabaseAuthModel model) {
    return AuthEntity(
      id: UserId(model.id),
      email: Email(model.email),
      firstName: model.firstName,
      lastName: model.lastName,
      token: model.token != null ? AuthToken(model.token!) : null,
      createdAt: model.createdAt,
      lastLoginAt: model.lastLoginAt,
      isEmailVerified: model.isEmailVerified,
    );
  }

  @override
  AuthEntity toEntityFromLocal(LocalAuthModel model, String? token) {
    return AuthEntity(
      id: UserId(model.id),
      email: Email(model.email),
      firstName: model.firstName,
      lastName: model.lastName,
      token: token != null ? AuthToken(token) : null,
      createdAt: model.createdAt,
      lastLoginAt: model.lastLoginAt,
      isEmailVerified: model.isEmailVerified,
    );
  }

  @override
  SupabaseAuthModel toSupabaseModel(AuthEntity entity) {
    return SupabaseAuthModel(
      id: entity.id.value,
      email: entity.email.value,
      firstName: entity.firstName,
      lastName: entity.lastName,
      token: entity.token?.value,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
    );
  }

  @override
  LocalAuthModel toLocalModel(AuthEntity entity) {
    return LocalAuthModel(
      id: entity.id.value,
      email: entity.email.value,
      firstName: entity.firstName,
      lastName: entity.lastName,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
      isEmailVerified: entity.isEmailVerified,
      lastSyncAt: DateTime.now(),
    );
  }

  @override
  LocalAuthModel supabaseToLocal(SupabaseAuthModel supabaseModel) {
    return LocalAuthModel.fromSupabaseModel(supabaseModel);
  }

  @override
  SupabaseAuthModel localToSupabase(LocalAuthModel localModel, String? token) {
    return SupabaseAuthModel(
      id: localModel.id,
      email: localModel.email,
      firstName: localModel.firstName,
      lastName: localModel.lastName,
      token: token,
      createdAt: localModel.createdAt,
      lastLoginAt: localModel.lastLoginAt,
      isEmailVerified: localModel.isEmailVerified,
    );
  }
}

// Extension pour faciliter l'utilisation
extension AuthModelMapperExtensions on AuthModelMapper {
  // Méthodes utilitaires
  List<AuthEntity> toEntityList(List<SupabaseAuthModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  List<SupabaseAuthModel> toSupabaseModelList(List<AuthEntity> entities) {
    return entities.map((entity) => toSupabaseModel(entity)).toList();
  }

  List<LocalAuthModel> toLocalModelList(List<AuthEntity> entities) {
    return entities.map((entity) => toLocalModel(entity)).toList();
  }
} 