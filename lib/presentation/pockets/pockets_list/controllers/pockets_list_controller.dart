import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/supabase_sync_service.dart';
import '../../../../data/models/pocket.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../widgets/app_notification.dart';
import '../../pocket_details/index.dart';

class PocketsListController extends ChangeNotifier {
  // Services
  late SupabaseSyncService _syncService;
  
  // Animation controllers
  late AnimationController animationController;
  late AnimationController cardAnimationController;
  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;
  late Animation<double> scaleAnimation;
  
  bool isInitialized = false;
  bool _defaultPocketsInitialized = false;
  
  // Cache pour optimiser les performances
  final Map<String, int> _pocketIndexCache = {};

  // Données d'exemple avec la méthode 50/30/20
  List<Pocket> pockets = [
    // 🏠 BESOINS ESSENTIELS (50%)
    Pocket(
      id: '1',
      name: 'Logement',
      icon: 'home',
      color: '#F48A99', // Rose pastel
      budget: 800.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.needs,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '2',
      name: 'Alimentation',
      icon: 'shopping',
      color: '#FFB67A', // Pêche pastel
      budget: 400.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.needs,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '3',
      name: 'Transport',
      icon: 'car',
      color: '#78D078', // Vert pastel
      budget: 200.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.needs,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '4',
      name: 'Factures & Assurances',
      icon: 'subscription',
      color: '#6BC6EA', // Bleu pastel
      budget: 250.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.needs,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    
    // 🎉 ENVIES & LOISIRS (30%)
    Pocket(
      id: '5',
      name: 'Sorties & Restaurants',
      icon: 'restaurant',
      color: '#DDA0DD', // Prune pastel
      budget: 300.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.wants,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '6',
      name: 'Shopping & Vêtements',
      icon: 'bag',
      color: '#F0E68C', // Jaune pastel (khaki)
      budget: 200.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.wants,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '7',
      name: 'Abonnements & Divertissement',
      icon: 'entertainment',
      color: '#87CEEB', // Bleu ciel pastel
      budget: 100.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.wants,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    
    // 💰 ÉPARGNE & OBJECTIFS (20%)
    Pocket(
      id: '8',
      name: 'Fonds d\'urgence',
      icon: 'emergency',
      color: '#FF9999', // Rouge pastel coral
      budget: 300.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.savings,
      savingsGoalType: SavingsGoalType.emergency,
      targetAmount: 5000.0,
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
    Pocket(
      id: '9',
      name: 'Vacances d\'été',
      icon: 'vacation',
      color: '#B19CD9', // Violet pastel
      budget: 200.0,
      spent: 0.0, // Sera calculé automatiquement à partir des transactions
      createdAt: DateTime.now(),
      type: PocketType.savings,
      savingsGoalType: SavingsGoalType.vacation,
      targetAmount: 2000.0,
      targetDate: DateTime(2024, 7, 15),
      transactions: [], // Les transactions seront ajoutées dynamiquement
    ),
  ];

  // === CALCULS DYNAMIQUES ===
  
  // Revenus globaux récupérés automatiquement depuis les transactions
  double getTotalIncome(TransactionProvider transactionProvider) {
    return transactionProvider.totalIncome;
  }

  // Total des montants réels par catégorie (somme des transactions)
  double get totalNeeds {
    final total = pockets
        .where((pocket) => pocket.type == PocketType.needs)
        .fold(0.0, (sum, pocket) => sum + pocket.spent);
    print('📊 DEBUG: totalNeeds = ${total}€');
    return total;
  }
      
  double get totalWants {
    final total = pockets
        .where((pocket) => pocket.type == PocketType.wants)
        .fold(0.0, (sum, pocket) => sum + pocket.spent);
    print('📊 DEBUG: totalWants = ${total}€');
    return total;
  }
      
  // Pour l'épargne, on compte le montant épargné mais on ne le traite pas comme une dépense
  double get totalSavings {
    final total = pockets
        .where((pocket) => pocket.type == PocketType.savings)
        .fold(0.0, (sum, pocket) => sum + pocket.spent);
    print('📊 DEBUG: totalSavings = ${total}€');
    return total;
  }
  
  // Total des dépenses par catégorie (calculé à partir des Pockets)
  double get spentNeeds => pockets
      .where((pocket) => pocket.type == PocketType.needs)
      .fold(0.0, (sum, pocket) => sum + pocket.spent);
      
  double get spentWants => pockets
      .where((pocket) => pocket.type == PocketType.wants)
      .fold(0.0, (sum, pocket) => sum + pocket.spent);
      
  // Pour l'épargne, on ne compte pas les dépôts comme des dépenses
  double get spentSavings => 0.0; // Les dépôts d'épargne ne sont pas des dépenses

  // Budget total disponible (revenus - dépenses - épargne)
  double getAvailableBudget(TransactionProvider transactionProvider) {
    final totalIncome = getTotalIncome(transactionProvider);
    final totalExpenses = spentNeeds + spentWants;
    final totalSavingsAmount = totalSavings; // Montant mis de côté
    
    return totalIncome - totalExpenses - totalSavingsAmount;
  }

  // Balance actuelle (revenus - dépenses - épargne)
  double getCurrentBalance(TransactionProvider transactionProvider) {
    return getAvailableBudget(transactionProvider);
  }

  // Pourcentages par rapport au revenu total
  double getNeedsPercentage(double totalIncome) => totalIncome > 0 ? (totalNeeds / totalIncome * 100) : 0;
  double getWantsPercentage(double totalIncome) => totalIncome > 0 ? (totalWants / totalIncome * 100) : 0;
  double getSavingsPercentage(double totalIncome) => totalIncome > 0 ? (totalSavings / totalIncome * 100) : 0;

  // Pourcentages des dépenses par rapport au budget
  double get needsSpentPercentage => totalNeeds > 0 ? (spentNeeds / totalNeeds * 100) : 0;
  double get wantsSpentPercentage => totalWants > 0 ? (spentWants / totalWants * 100) : 0;
  double get savingsSpentPercentage => totalSavings > 0 ? (spentSavings / totalSavings * 100) : 0;

  // Initialiser les animations
  void initializeAnimations(TickerProvider vsync) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1800),
    );

    cardAnimationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 2400),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOutExpo,
    );

    slideAnimation = CurvedAnimation(
      parent: animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );

    scaleAnimation = CurvedAnimation(
      parent: cardAnimationController,
      curve: Curves.elasticOut,
    );

    animationController.forward();
    cardAnimationController.forward();
    isInitialized = true;
  }

  // Écouter les changements du TransactionProvider
  void listenToTransactionChanges(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    
    // Ajouter un listener pour les changements de transactions
    transactionProvider.addListener(() {
      // Mettre à jour les pockets quand les transactions changent
      updatePocketsFromTransactions(context);
    });
  }

  // Charger les données et vérifier la conformité
  void loadDataAndCheckCompliance(BuildContext context) async {
    // Initialiser le service de synchronisation
    _syncService = SupabaseSyncService(Supabase.instance.client);
    
    // Charger les données de manière asynchrone pour éviter le lag
    _loadDataAsync(context);
  }

  // Charger les données de manière asynchrone
  Future<void> _loadDataAsync(BuildContext context) async {
    try {
      // Synchroniser les pockets par défaut avec Supabase d'abord
      await initializeDefaultPockets(context);
      
      // Puis mettre à jour les pockets avec les données de Supabase
      await updatePocketsFromTransactions(context);
      checkBudgetRuleCompliance(context);
      
      // Notifier l'UI que les données sont chargées
      notifyListeners();
      
    } catch (e) {
      print('❌ Erreur lors du chargement des données: $e');
    }
  }

  // Initialiser les pockets par défaut sur Supabase
  Future<void> initializeDefaultPockets(BuildContext context) async {
    if (_defaultPocketsInitialized) {
      print('✅ Pockets par défaut déjà initialisés');
      return;
    }

    try {
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final userId = authStateManager.currentUser?.id.value;
      
      if (userId == null) {
        print('❌ Utilisateur non connecté, impossible d\'initialiser les pockets');
        return;
      }

      print('🔄 Initialisation des pockets par défaut sur Supabase...');
      
      // Récupérer les pockets existantes une seule fois
      final existingPockets = await _syncService.syncAllData(userId);
      final existingPocketNames = existingPockets.pockets.map((p) => '${p.name}_${p.type}').toSet();
      
      // Créer seulement les pockets manquantes
      for (final pocket in pockets) {
        final pocketKey = '${pocket.name}_${pocket.type}';
        
        if (!existingPocketNames.contains(pocketKey)) {
          try {
            await _syncService.createAndSyncPocket(
              userId: userId,
              pocket: pocket,
            );
            print('✅ Pocket "${pocket.name}" créé sur Supabase');
          } catch (e) {
            print('❌ Erreur lors de la création du pocket "${pocket.name}": $e');
          }
        } else {
          print('⏭️ Pocket "${pocket.name}" existe déjà sur Supabase');
        }
      }
      
      _defaultPocketsInitialized = true;
      print('✅ Initialisation des pockets par défaut terminée');
      
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation des pockets par défaut: $e');
    }
  }

  // Cache pour éviter les synchronisations répétées
  DateTime? _lastSyncTime;
  static const Duration _syncCooldown = Duration(seconds: 10);

  // Mettre à jour les pockets à partir des transactions
  Future<void> updatePocketsFromTransactions(BuildContext context) async {
    // Éviter les synchronisations trop fréquentes
    if (_lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync < _syncCooldown) {
        print('⏭️ Synchronisation ignorée - dernière sync il y a ${timeSinceLastSync.inSeconds}s');
        return;
      }
    }

    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final allTransactions = transactionProvider.transactions;
    
    // Éviter les synchronisations inutiles si pas de transactions
    if (allTransactions.isEmpty && pockets.isNotEmpty) {
      print('⏭️ Synchronisation ignorée - pas de transactions et pockets déjà chargées');
      return;
    }
    
    print('🔄 Mise à jour des pockets depuis ${allTransactions.length} transactions');
    
    // Synchroniser avec Supabase si l'utilisateur est connecté
    final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
    final userId = authStateManager.currentUser?.id.value;
    
    if (userId != null && _defaultPocketsInitialized) {
      try {
        // Récupérer les pockets depuis Supabase
        final syncResult = await _syncService.syncAllData(userId);
        pockets = syncResult.pockets;
        _lastSyncTime = DateTime.now();
        print('✅ Pockets synchronisés depuis Supabase: ${pockets.length} pockets');
      } catch (e) {
        print('❌ Erreur lors de la synchronisation des pockets: $e');
        // En cas d'erreur, utiliser les pockets locaux
      }
    }
    
    // Optimisation : traiter les transactions par lot
    _processTransactionsInBatches(allTransactions);
    
    print('✅ Pockets mis à jour: ${pockets.length} pockets avec ${pockets.fold(0, (sum, p) => sum + p.transactions.length)} transactions totales');
    notifyListeners();
  }

  // Traiter les transactions par lot pour améliorer les performances
  void _processTransactionsInBatches(List<Transaction> allTransactions) {
    // Nettoyer le cache au début
    _pocketIndexCache.clear();
    
    // Réinitialiser les montants dépensés
    for (int i = 0; i < pockets.length; i++) {
      pockets[i] = pockets[i].copyWith(spent: 0.0);
    }

    // Filtrer les transactions une seule fois
    final expenseTransactions = allTransactions.where((transaction) =>
      transaction.isExpense && 
      !transaction.title.toLowerCase().contains('dépôt d\'épargne')
    ).toList();

    // Traiter les transactions par lot de 50
    const batchSize = 50;
    for (int i = 0; i < expenseTransactions.length; i += batchSize) {
      final end = (i + batchSize < expenseTransactions.length) 
          ? i + batchSize 
          : expenseTransactions.length;
      final batch = expenseTransactions.sublist(i, end);
      
      for (final transaction in batch) {
        assignTransactionToPocket(transaction);
      }
    }
  }

  // Supprimer une pocket
  Future<void> deletePocket(BuildContext context, Pocket pocket) async {
    print('🗑️ Suppression de la pocket "${pocket.name}"');
    
    try {
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final userId = authStateManager.currentUser?.id.value;
      
      if (userId != null) {
        // Supprimer la pocket de Supabase
        await _syncService.deleteAndSyncPocket(pocket.id);
        print('✅ Pocket "${pocket.name}" supprimée de Supabase');
        
        // Supprimer de la liste locale
        pockets.removeWhere((p) => p.id == pocket.id);
        notifyListeners();
        
        // Afficher une notification de succès
        AppNotification.show(
          context,
          title: 'Pocket supprimée',
          subtitle: 'La pocket "${pocket.name}" a été supprimée',
          type: NotificationType.success,
        );
      } else {
        throw Exception('Utilisateur non connecté');
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression de la pocket: $e');
      
      // Afficher une notification d'erreur
      AppNotification.show(
        context,
        title: 'Erreur',
        subtitle: 'Impossible de supprimer la pocket. Veuillez réessayer.',
        type: NotificationType.error,
      );
    }
  }

  // Forcer le rafraîchissement de la liste des pockets
  Future<void> refreshPocketsList(BuildContext context) async {
    // Éviter les synchronisations trop fréquentes
    if (_lastSyncTime != null) {
      final timeSinceLastSync = DateTime.now().difference(_lastSyncTime!);
      if (timeSinceLastSync < _syncCooldown) {
        print('⏭️ Rafraîchissement ignoré - dernière sync il y a ${timeSinceLastSync.inSeconds}s');
        // Forcer quand même la notification pour les nouvelles pockets
        notifyListeners();
        return;
      }
    }

    // Vérifier que le service est initialisé
    if (_syncService == null) {
      print('⚠️ Service de synchronisation non initialisé, initialisation...');
      _syncService = SupabaseSyncService(Supabase.instance.client);
    }

    print('🔄 Forçage du rafraîchissement de la liste des pockets');
    
    try {
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final userId = authStateManager.currentUser?.id.value;
      
      if (userId != null) {
        // Récupérer les dernières données depuis Supabase
        final syncResult = await _syncService.syncAllData(userId);
        pockets = syncResult.pockets;
        _lastSyncTime = DateTime.now();
        print('✅ Liste des pockets rafraîchie: ${pockets.length} pockets');
        
        // Notifier l'UI
        notifyListeners();
      }
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement de la liste des pockets: $e');
    }
  }

  // Associer une transaction à un pocket approprié (optimisée)
  void assignTransactionToPocket(Transaction transaction) {
    String pocketId = getPocketIdForTransaction(transaction);
    
    if (pocketId.isNotEmpty) {
      // Utiliser le cache pour trouver l'index du pocket
      int? pocketIndex = _pocketIndexCache[pocketId];
      if (pocketIndex == null) {
        pocketIndex = pockets.indexWhere((p) => p.id == pocketId);
        if (pocketIndex != -1) {
          _pocketIndexCache[pocketId] = pocketIndex;
        }
      }
      
      if (pocketIndex != -1) {
        final pocket = pockets[pocketIndex];
        
        // Vérifier rapidement si la transaction existe déjà
        final hasTransaction = pocket.transactions.any((t) => t.transactionId == transaction.id);
        
        if (!hasTransaction) {
          // Créer une PocketTransaction à partir de la Transaction
          final pocketTransaction = PocketTransaction.fromTransaction(transaction);
          
          // Mettre à jour le pocket de manière optimisée
          final updatedTransactions = List<PocketTransaction>.from(pocket.transactions)..add(pocketTransaction);
          final newSpent = pocket.spent + transaction.amount; // Plus rapide que fold
          
          pockets[pocketIndex] = pocket.copyWith(
            transactions: updatedTransactions,
            spent: newSpent,
          );
          
          print('💼 Transaction ${transaction.title} (${transaction.amount}€) ajoutée au pocket ${pocket.name}');
        }
      }
    }
  }

  // Logique simple pour associer une transaction à un pocket
  String getPocketIdForTransaction(Transaction transaction) {
    // Logique basée sur la catégorie de la transaction
    // Vous pouvez améliorer cette logique selon vos besoins
    switch (transaction.categoryId.toLowerCase()) {
      case 'logement':
      case 'loyer':
      case 'électricité':
      case 'gaz':
      case 'eau':
        return '1'; // Logement
      case 'alimentation':
      case 'courses':
      case 'restaurant':
        return '2'; // Alimentation
      case 'transport':
      case 'essence':
      case 'parking':
        return '3'; // Transport
      case 'factures':
      case 'assurance':
      case 'internet':
        return '4'; // Factures & Assurances
      case 'sorties':
      case 'loisirs':
        return '5'; // Sorties & Restaurants
      case 'shopping':
      case 'vêtements':
        return '6'; // Shopping & Vêtements
      case 'abonnements':
      case 'netflix':
      case 'spotify':
        return '7'; // Abonnements & Divertissement
      case 'épargne':
      case 'urgence':
        return '8'; // Fonds d'urgence
      case 'vacances':
      case 'voyage':
        return '9'; // Vacances d'été
      default:
        return ''; // Aucune association
    }
  }

  // Vérifier la conformité de la règle 50/30/20
  void checkBudgetRuleCompliance(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final totalIncome = getTotalIncome(transactionProvider);
    
    if (totalIncome > 0) {
      final needsPercentage = getNeedsPercentage(totalIncome);
      final wantsPercentage = getWantsPercentage(totalIncome);
      final savingsPercentage = getSavingsPercentage(totalIncome);
      
      // Règle stricte 50/30/20 avec tolérance ±2%
      bool isBalanced =
          (needsPercentage - 50).abs() <= 2 &&
          (wantsPercentage - 30).abs() <= 2 &&
          (savingsPercentage - 20).abs() <= 2;

      if (!isBalanced) {
        // Déclencher l'analyse complète des notifications
        transactionProvider.performComprehensiveAnalysis(pockets);
      }
    }
  }

  // Mettre à jour un pocket
  void updatePocket(Pocket updatedPocket, BuildContext context) async {
    print('🔄 DEBUG: updatePocket appelée pour ${updatedPocket.name}');
    print('📊 DEBUG: Pocket reçu - ${updatedPocket.transactions.length} transactions, ${updatedPocket.spent}€ dépensés');
    
    final index = pockets.indexWhere((pocket) => pocket.id == updatedPocket.id);
    if (index != -1) {
      print('✅ DEBUG: Pocket trouvé à l\'index $index');
      
      // Mettre à jour le pocket avec les nouvelles données
      pockets[index] = updatedPocket;
      
      // Recalculer le montant dépensé basé sur les transactions
      final totalSpent = updatedPocket.transactions.fold(0.0, (sum, t) => sum + t.amount);
      pockets[index] = pockets[index].copyWith(spent: totalSpent);
      
      print('📈 DEBUG: Pocket mis à jour - ${pockets[index].transactions.length} transactions, ${pockets[index].spent}€ dépensés');
      
      // Synchroniser avec Supabase si l'utilisateur est connecté
      final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
      final userId = authStateManager.currentUser?.id.value;
      
      if (userId != null && _defaultPocketsInitialized) {
        try {
          await _syncService.updateAndSyncPocket(
            pocketId: updatedPocket.id,
            pocket: pockets[index],
          );
          print('✅ Pocket "${updatedPocket.name}" synchronisé avec Supabase');
        } catch (e) {
          print('❌ Erreur lors de la synchronisation du pocket "${updatedPocket.name}": $e');
        }
      }
      
      // Forcer la mise à jour de l'interface utilisateur
      notifyListeners();
      
      // Attendre un peu pour s'assurer que l'interface se met à jour
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Forcer une nouvelle notification pour s'assurer que tout est synchronisé
        notifyListeners();
        
        // Vérifier à nouveau la règle 50/30/20 après mise à jour
        checkBudgetRuleCompliance(context);
        
        // Déclencher l'analyse complète des notifications
        final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
        transactionProvider.performComprehensiveAnalysis(pockets);
      });
    } else {
      print('❌ DEBUG: Pocket non trouvé avec l\'ID ${updatedPocket.id}');
    }
  }

  // Naviguer vers la page de détail d'un pocket
  void navigateToPocketDetail(Pocket pocket, BuildContext context) {
    print('🔍 DEBUG: navigateToPocketDetail appelée pour ${pocket.name}');
    
    // Trouver la version la plus récente du pocket dans la liste
    final currentPocket = pockets.firstWhere(
      (p) => p.id == pocket.id,
      orElse: () => pocket,
    );
    
    print('📊 DEBUG: Version actuelle du pocket - ${currentPocket.transactions.length} transactions, ${currentPocket.spent}€ dépensés');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketDetailScreen(
          pocket: currentPocket, // Utiliser la version la plus récente
          onPocketUpdated: (updatedPocket) => updatePocket(updatedPocket, context),
        ),
      ),
    );
  }

  // Ajouter une transaction à un pocket spécifique
  void addTransactionToPocket(String pocketId, PocketTransaction transaction) {
    final pocketIndex = pockets.indexWhere((p) => p.id == pocketId);
    if (pocketIndex != -1) {
      final pocket = pockets[pocketIndex];
      final updatedTransactions = List<PocketTransaction>.from(pocket.transactions)..add(transaction);
      final newSpent = updatedTransactions.fold(0.0, (sum, t) => sum + t.amount);
      
      pockets[pocketIndex] = pocket.copyWith(
        transactions: updatedTransactions,
        spent: newSpent,
      );
      notifyListeners();
    }
  }

  // Supprimer une transaction d'un pocket spécifique
  void removeTransactionFromPocket(String pocketId, String transactionId) {
    final pocketIndex = pockets.indexWhere((p) => p.id == pocketId);
    if (pocketIndex != -1) {
      final pocket = pockets[pocketIndex];
      final updatedTransactions = pocket.transactions.where((t) => t.id != transactionId).toList();
      final newSpent = updatedTransactions.fold(0.0, (sum, t) => sum + t.amount);
      
      pockets[pocketIndex] = pocket.copyWith(
        transactions: updatedTransactions,
        spent: newSpent,
      );
      notifyListeners();
    }
  }

  // Recalculer le montant dépensé pour un pocket spécifique
  void recalculatePocketSpent(String pocketId) {
    final pocketIndex = pockets.indexWhere((p) => p.id == pocketId);
    if (pocketIndex != -1) {
      final pocket = pockets[pocketIndex];
      final newSpent = pocket.transactions.fold(0.0, (sum, t) => sum + t.amount);
      
      pockets[pocketIndex] = pocket.copyWith(spent: newSpent);
      notifyListeners();
    }
  }

  // Obtenir la couleur depuis un code hexadécimal
  Color getColorFromHex(String hexColor) {
    return Color(int.parse(hexColor.substring(1), radix: 16) + 0xFF000000);
  }

  // Obtenir l'icône depuis une chaîne
  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'home':
        return HugeIcons.strokeRoundedHome01;
      case 'subscription':
        return HugeIcons.strokeRoundedCalendar01;
      case 'shopping':
        return HugeIcons.strokeRoundedShoppingCart01;
      case 'bag':
        return HugeIcons.strokeRoundedShoppingBag01;
      case 'car':
        return HugeIcons.strokeRoundedCar01;
      case 'restaurant':
        return HugeIcons.strokeRoundedRestaurant01;
      case 'entertainment':
        return HugeIcons.strokeRoundedGameController01;
      case 'emergency':
        return HugeIcons.strokeRoundedMedicalMask;
      case 'vacation':
        return HugeIcons.strokeRoundedAirplane01;
      default:
        return HugeIcons.strokeRoundedWallet01;
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    cardAnimationController.dispose();
    super.dispose();
  }
} 