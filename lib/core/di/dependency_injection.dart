import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/transaction_service.dart';
import '../../core/services/supabase_sync_service.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/get_transactions_by_period_usecase.dart';
import '../../domain/usecases/search_transactions_usecase.dart';
import '../../domain/usecases/export_transactions_usecase.dart';
import '../../domain/usecases/import_transactions_usecase.dart';
import '../../domain/usecases/clear_all_transactions_usecase.dart';
import '../../domain/usecases/get_transaction_statistics_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import '../../presentation/providers/transaction_provider_clean.dart';
import '../../core/providers/auth_state_provider.dart';
import '../../core/services/session_manager.dart';
import '../../core/services/http_interceptor_improved.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/datasources/secure_local_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

// Container d'injection de dépendances simplifié
class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  // Instances singleton
  late final TransactionService _transactionService;
  late final SupabaseSyncService _supabaseSyncService;
  late final TransactionRepository _transactionRepository;
  late final GetTransactionsByPeriodUseCase _getTransactionsByPeriodUseCase;
  late final SearchTransactionsUseCase _searchTransactionsUseCase;
  late final ExportTransactionsUseCase _exportTransactionsUseCase;
  late final ImportTransactionsUseCase _importTransactionsUseCase;
  late final ClearAllTransactionsUseCase _clearAllTransactionsUseCase;
  late final GetTransactionStatisticsUseCase _getTransactionStatisticsUseCase;
  late final GetRecentTransactionsUseCase _getRecentTransactionsUseCase;
  late final TransactionProviderClean _transactionProviderClean;
  late final AuthStateProvider _authStateProvider;
  late final SessionManager _sessionManager;
  late final ImprovedHttpClient _httpClient;
  
  // Dépendances d'authentification
  late final SupabaseAuthDataSource _authDataSource;
  late final SecureLocalDataSourceImpl _secureLocalDataSource;
  late final AuthRepository _authRepository;

  // Initialisation des dépendances
  Future<void> initialize() async {
    // 1. Vérifier que Supabase est initialisé
    SupabaseClient supabaseClient;
    try {
      supabaseClient = Supabase.instance.client;
      debugPrint('✅ Client Supabase récupéré avec succès');
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération du client Supabase: $e');
      throw Exception('Supabase n\'est pas initialisé. Vérifiez l\'initialisation dans main.dart');
    }
    
    // 2. Initialiser les services
    _transactionService = TransactionService();
    await _transactionService.initialize();
    
    // 3. Initialiser le service de synchronisation Supabase
    _supabaseSyncService = SupabaseSyncService(supabaseClient);

    // 4. Initialiser le repository
    _transactionRepository = TransactionRepositoryImpl(_transactionService);

    // 3. Initialiser les use cases
    _getTransactionsByPeriodUseCase = GetTransactionsByPeriodUseCase(_transactionRepository);
    _searchTransactionsUseCase = SearchTransactionsUseCase(_transactionRepository);
    _exportTransactionsUseCase = ExportTransactionsUseCase(_transactionRepository);
    _importTransactionsUseCase = ImportTransactionsUseCase(_transactionRepository);
    _clearAllTransactionsUseCase = ClearAllTransactionsUseCase(_transactionRepository);
    _getTransactionStatisticsUseCase = GetTransactionStatisticsUseCase(_transactionRepository);
    _getRecentTransactionsUseCase = GetRecentTransactionsUseCase(_transactionRepository);

    // 4. Initialiser le provider de présentation
    _transactionProviderClean = TransactionProviderClean(
      _getTransactionsByPeriodUseCase,
      _searchTransactionsUseCase,
      _exportTransactionsUseCase,
      _importTransactionsUseCase,
      _clearAllTransactionsUseCase,
      _getTransactionStatisticsUseCase,
      _getRecentTransactionsUseCase,
      _transactionRepository,
    );

    // 5. Initialiser les dépendances d'authentification
    _authDataSource = SupabaseAuthDataSource();
    await _authDataSource.initialize();
    _secureLocalDataSource = SecureLocalDataSourceImpl();
    _authRepository = AuthRepositoryImpl(
      remoteDataSource: _authDataSource,
      localDataSource: _secureLocalDataSource,
    );

    // 6. Initialiser le session manager
    _sessionManager = SessionManager();
    await _sessionManager.initialize();
    
    // 7. Initialiser le provider d'authentification
    _authStateProvider = AuthStateProvider();
    _authStateProvider.initialize(_authRepository);
    
    // 8. Initialiser le client HTTP amélioré
    _httpClient = ImprovedHttpClient();
  }

  // Getters pour accéder aux instances
  TransactionService get transactionService => _transactionService;
  SupabaseSyncService get supabaseSyncService => _supabaseSyncService;
  TransactionRepository get transactionRepository => _transactionRepository;
  GetTransactionsByPeriodUseCase get getTransactionsByPeriodUseCase => _getTransactionsByPeriodUseCase;
  SearchTransactionsUseCase get searchTransactionsUseCase => _searchTransactionsUseCase;
  ExportTransactionsUseCase get exportTransactionsUseCase => _exportTransactionsUseCase;
  ImportTransactionsUseCase get importTransactionsUseCase => _importTransactionsUseCase;
  ClearAllTransactionsUseCase get clearAllTransactionsUseCase => _clearAllTransactionsUseCase;
  GetTransactionStatisticsUseCase get getTransactionStatisticsUseCase => _getTransactionStatisticsUseCase;
  GetRecentTransactionsUseCase get getRecentTransactionsUseCase => _getRecentTransactionsUseCase;
  TransactionProviderClean get transactionProviderClean => _transactionProviderClean;
  AuthStateProvider get authStateProvider => _authStateProvider;
  SessionManager get sessionManager => _sessionManager;
  ImprovedHttpClient get httpClient => _httpClient;
}

// Instance globale
final di = DependencyInjection(); 