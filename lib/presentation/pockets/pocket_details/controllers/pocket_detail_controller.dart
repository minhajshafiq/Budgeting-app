import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/constants.dart';
import '../../../../data/models/pocket.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';
import 'package:hugeicons/hugeicons.dart';
import '../widgets/transaction_selection_modal.dart';
import 'package:provider/provider.dart';
import '../../../../widgets/app_notification.dart';

class PocketDetailController extends ChangeNotifier {
  late Pocket _currentPocket;
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late AnimationController _progressAnimationController;
  late AnimationController _fadeAnimationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  bool _isEditing = false;
  bool _isSaving = false;
  
  Function(Pocket)? _onPocketUpdated;
  
  // Suggestions automatiques pour les noms de pockets
  final List<String> _pocketSuggestions = [
    'Maison', 'Courses', 'Transport', 'Santé', 'Loisirs', 
    'Restaurant', 'Vêtements', 'Sport', 'Éducation', 'Cadeaux',
    'Abonnements', 'Shopping', 'Voyage', 'Essence', 'Épargne'
  ];
  
  List<String> _filteredSuggestions = [];

  // Getters
  Pocket get currentPocket => _currentPocket;
  bool get isEditing => _isEditing;
  bool get isSaving => _isSaving;
  List<String> get filteredSuggestions => _filteredSuggestions;
  TextEditingController get nameController => _nameController;
  TextEditingController get budgetController => _budgetController;
  AnimationController get progressAnimationController => _progressAnimationController;
  AnimationController get fadeAnimationController => _fadeAnimationController;
  Animation<double> get progressAnimation => _progressAnimation;
  Animation<double> get fadeAnimation => _fadeAnimation;

  // Initialiser le contrôleur
  void initialize(Pocket pocket, TickerProvider vsync, {Function(Pocket)? onPocketUpdated}) {
    _currentPocket = pocket;
    _onPocketUpdated = onPocketUpdated;
    _nameController = TextEditingController(text: _currentPocket.name);
    _budgetController = TextEditingController(text: _currentPocket.budget.toInt().toString());
    
    // Initialiser les contrôleurs d'animation
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    );
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentPocket.progressPercentage / 100,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));
    
    // Écouter les changements pour les suggestions
    _nameController.addListener(_updateSuggestions);
    
    // Démarrer les animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fadeAnimationController.forward();
      _progressAnimationController.forward();
    });
  }

  // Nettoyer les ressources
  @override
  void dispose() {
    _nameController.removeListener(_updateSuggestions);
    _nameController.dispose();
    _budgetController.dispose();
    _progressAnimationController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  // Mettre à jour les suggestions
  void _updateSuggestions() {
    final query = _nameController.text.toLowerCase();
    if (query.isEmpty) {
      _filteredSuggestions = [];
      notifyListeners();
      return;
    }
    
    _filteredSuggestions = _pocketSuggestions
        .where((suggestion) => 
            suggestion.toLowerCase().contains(query) && 
            suggestion.toLowerCase() != query)
        .take(3)
        .toList();
    notifyListeners();
  }

  // Obtenir la couleur du pocket
  Color getPocketColor() {
    return Color(int.parse(_currentPocket.color.substring(1), radix: 16) + 0xFF000000);
  }

  // Obtenir l'icône du pocket
  IconData getPocketIcon() {
    switch (_currentPocket.icon) {
      case 'home':
        return HugeIcons.strokeRoundedHome01;
      case 'subscription':
        return HugeIcons.strokeRoundedCalendar01;
      case 'shopping':
        return HugeIcons.strokeRoundedShoppingCart01;
      case 'bag':
        return HugeIcons.strokeRoundedShoppingBag01;
      default:
        return HugeIcons.strokeRoundedWallet01;
    }
  }

  // Basculer le mode édition
  void toggleEditMode() {
    HapticFeedback.lightImpact();
    if (_isEditing) {
      // Si on est en mode édition, sauvegarder
      _saveChanges();
    } else {
      // Si on n'est pas en mode édition, passer en mode édition
      _isEditing = true;
      notifyListeners();
    }
  }



  // Sauvegarder les changements
  void _saveChanges() async {
    if (_isSaving) return;
    
    _isSaving = true;
    notifyListeners();
    
    try {
      // Validation
      final newName = _nameController.text.trim();
      final newBudget = double.tryParse(_budgetController.text);
      
      print('Sauvegarde en cours...');
      print('Nouveau nom: $newName');
      print('Nouveau budget: $newBudget');
      
      if (newName.isEmpty) {
        throw Exception('Le nom ne peut pas être vide');
      }
      
      if (newBudget == null || newBudget <= 0) {
        throw Exception('Le budget doit être un nombre positif');
      }
      
      // Mettre à jour le pocket
      final oldPocket = _currentPocket;
      _currentPocket = _currentPocket.copyWith(
        name: newName,
        budget: newBudget,
      );
      
      print('Pocket mis à jour: ${_currentPocket.name} - ${_currentPocket.budget}€');
      
      // Simuler un délai de sauvegarde
      await Future.delayed(const Duration(milliseconds: 800));
      
      print('Fin du délai de sauvegarde');
      
      // Mettre à jour l'état
      _isEditing = false;
      _isSaving = false;
      
      print('État mis à jour: isEditing=$_isEditing, isSaving=$_isSaving');
      
      // Notifier les listeners
      notifyListeners();
      
      print('Listeners notifiés');
      
      // Feedback haptique de succès
      HapticFeedback.lightImpact();
      
      // Notifier le parent si un callback est fourni
      if (_onPocketUpdated != null) {
        print('Notification du parent...');
        _onPocketUpdated!(_currentPocket);
      } else {
        print('Aucun callback parent fourni');
      }
      
      print('Sauvegarde terminée avec succès');
      
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      _isSaving = false;
      notifyListeners();
      
      // Feedback haptique d'erreur
      HapticFeedback.heavyImpact();
      
      // Afficher l'erreur (sera géré par le widget)
      rethrow;
    }
  }

  // Obtenir le pocket mis à jour avec les données récentes
  Pocket getUpdatedPocket(TransactionProvider transactionProvider) {
    // Utiliser uniquement les transactions locales du pocket
    final localTransactions = _currentPocket.transactions;
    
    // Trier par date (plus récentes en premier)
    final sortedTransactions = List<PocketTransaction>.from(localTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    
    final totalSpent = sortedTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    return _currentPocket.copyWith(
      transactions: sortedTransactions,
      spent: totalSpent,
    );
  }

  // Vérifier si une transaction est déjà dans le pocket
  bool isTransactionInPocket(String transactionId) {
    return _currentPocket.transactions.any((t) => 
        t.transactionId == transactionId || t.id == transactionId);
  }

  // Mettre à jour l'animation de progression
  void updateProgressAnimation() {
    final newProgress = _currentPocket.progressPercentage / 100;
    
    // Créer une nouvelle animation avec la nouvelle valeur
    _progressAnimation = Tween<double>(
      begin: _progressAnimation.value, // Commencer depuis la valeur actuelle
      end: newProgress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Redémarrer l'animation
    _progressAnimationController.reset();
    _progressAnimationController.forward();
    
    print('🔄 Animation de progression mise à jour: ${_currentPocket.progressPercentage}%');
  }

  // Rafraîchir les données du pocket depuis les données locales uniquement
  void refreshPocketData() {
    print('🔄 Rafraîchissement des données du pocket ${_currentPocket.name}');
    
    // Recalculer le montant dépensé basé sur les transactions locales
    final totalSpent = _currentPocket.transactions.fold(0.0, (sum, t) => sum + t.amount);
    
    _currentPocket = _currentPocket.copyWith(spent: totalSpent);
    
    print('✅ Pocket rafraîchi: ${_currentPocket.transactions.length} transactions, ${_currentPocket.spent}€ dépensés');
    
    // Mettre à jour l'animation de progression
    updateProgressAnimation();
    
    notifyListeners();
  }

  // Ajouter une transaction au pocket
  void addTransactionToPocket(Transaction transaction) {
    final pocketTransaction = PocketTransaction.fromTransaction(transaction);
    final updatedTransactions = List<PocketTransaction>.from(_currentPocket.transactions)
      ..add(pocketTransaction);
    
    final totalSpent = updatedTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    _currentPocket = _currentPocket.copyWith(
      transactions: updatedTransactions,
      spent: totalSpent,
    );
    
    notifyListeners();
  }

  // Supprimer une transaction du pocket
  void removeTransactionFromPocket(String transactionId) {
    final updatedTransactions = _currentPocket.transactions
        .where((t) => t.id != transactionId)
        .toList();
    
    final totalSpent = updatedTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    _currentPocket = _currentPocket.copyWith(
      transactions: updatedTransactions,
      spent: totalSpent,
    );
    
    notifyListeners();
  }

  // Obtenir les statistiques du pocket
  Map<String, dynamic> getPocketStats(TransactionProvider transactionProvider) {
    final updatedPocket = getUpdatedPocket(transactionProvider);
    final transactions = updatedPocket.transactions;
    
    if (transactions.isEmpty) {
      return {
        'totalTransactions': 0,
        'averageAmount': 0.0,
        'largestTransaction': 0.0,
        'mostFrequentDay': 'Aucune',
        'monthlyTrend': 0.0,
      };
    }
    
    // Calculer les statistiques
    final totalTransactions = transactions.length;
    final averageAmount = transactions.fold(0.0, (sum, t) => sum + t.amount) / totalTransactions;
    final largestTransaction = transactions.map((t) => t.amount).reduce((a, b) => a > b ? a : b);
    
    // Jour le plus fréquent
    final dayCounts = <String, int>{};
    for (final transaction in transactions) {
      final day = _getDayName(transaction.date.weekday);
      dayCounts[day] = (dayCounts[day] ?? 0) + 1;
    }
    final mostFrequentDay = dayCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    
    // Tendance mensuelle (simplifiée)
    final monthlyTrend = transactions.length > 1 ? 5.2 : 0.0; // Simulation
    
    return {
      'totalTransactions': totalTransactions,
      'averageAmount': averageAmount,
      'largestTransaction': largestTransaction,
      'mostFrequentDay': mostFrequentDay,
      'monthlyTrend': monthlyTrend,
    };
  }

  // Obtenir le nom du jour
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Lundi';
      case 2: return 'Mardi';
      case 3: return 'Mercredi';
      case 4: return 'Jeudi';
      case 5: return 'Vendredi';
      case 6: return 'Samedi';
      case 7: return 'Dimanche';
      default: return 'Inconnu';
    }
  }

  // Sélectionner une suggestion
  void selectSuggestion(String suggestion) {
    HapticFeedback.lightImpact();
    _nameController.text = suggestion;
    _filteredSuggestions = [];
    notifyListeners();
  }

  // Annuler l'édition
  void cancelEdit() {
    _nameController.text = _currentPocket.name;
    _budgetController.text = _currentPocket.budget.toInt().toString();
    _filteredSuggestions = [];
    _isEditing = false;
    notifyListeners();
  }

  // Afficher le modal d'ajout de transaction
  void showAddTransactionModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Si c'est un pocket d'épargne, montrer le modal de dépôt d'épargne
    if (_currentPocket.isSavingsPocket) {
      showSavingsDepositModal(context);
      return;
    }
    
    // Sinon, montrer le modal de sélection de transactions classiques
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionSelectionModal(
        pocket: _currentPocket,
        onTransactionsAdded: (transactions) async {
          print('🔄 Ajout de ${transactions.length} transaction(s) au pocket ${_currentPocket.name}');
          
          // Filtrer les transactions qui ne sont pas déjà dans le pocket
          final newTransactions = transactions.where((transaction) => 
              !isTransactionInPocket(transaction.id)).toList();
          
          if (newTransactions.isEmpty) {
            AppNotification.info(
              context,
              title: 'Aucune nouvelle transaction',
              subtitle: 'Toutes les transactions sélectionnées sont déjà dans ce pocket',
            );
            Navigator.pop(context);
            return;
          }
          
          // NE PAS ajouter les transactions au TransactionProvider global
          // Les transactions restent uniquement dans le pocket local
          print('📝 Transactions ajoutées uniquement au pocket local (pas au provider global)');
          
          // Mettre à jour le pocket avec les nouvelles transactions
          Pocket updatedPocket = _currentPocket;
          
          for (final transaction in newTransactions) {
            final pocketTransaction = PocketTransaction.fromTransaction(transaction);
            updatedPocket = updatedPocket.addExpenseTransaction(pocketTransaction);
            print('💼 Transaction ${transaction.title} ajoutée au pocket local uniquement');
          }
          
          // Mettre à jour l'état local
          _currentPocket = updatedPocket;
          
          // Mettre à jour l'animation de progression
          updateProgressAnimation();
          
          notifyListeners();
          
          print('✅ Pocket mis à jour: ${_currentPocket.name} - ${_currentPocket.transactions.length} transactions - ${_currentPocket.spent}€ dépensés');
          print('📋 Transactions dans le pocket:');
          for (final transaction in _currentPocket.transactions) {
            print('  - ${transaction.title}: ${transaction.amount}€ (${transaction.date})');
          }
          
          // Notifier le parent pour mettre à jour la liste des pockets
          if (_onPocketUpdated != null) {
            print('🔄 Notification du parent pour mise à jour de la liste');
            _onPocketUpdated!(updatedPocket);
          }
          
          // Fermer le modal
          Navigator.pop(context);
          
          // Afficher une notification de succès
          AppNotification.success(
            context,
            title: 'Transaction ajoutée',
            subtitle: '${newTransactions.length} transaction(s) ajoutée(s) à ${_currentPocket.name}',
          );
        },
      ),
    );
  }

  // Modal pour les dépôts d'épargne
  void showSavingsDepositModal(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre
              Text(
                'Ajouter un dépôt d\'épargne',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
              const SizedBox(height: 24),
              
              // Champ montant
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant à épargner',
                  prefixText: '€ ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Sélecteur de date
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setModalState(() {
                      selectedDate = date;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF6BC6EA)),
                      const SizedBox(width: 12),
                      Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        style: TextStyle(
                          color: isDark ? AppColors.textDark : AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Description optionnelle
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (optionnelle)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              
              // Bouton de confirmation
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = double.tryParse(amountController.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(context);
                      
                      // NE PAS créer de transaction globale pour l'épargne
                      // Le dépôt reste uniquement dans le pocket local
                      print('📝 Dépôt d\'épargne ajouté uniquement au pocket local (pas au provider global)');
                      
                      // Ajouter au pocket
                      addSavingsDeposit(amount, selectedDate, descriptionController.text);
                      
                      // Afficher une notification de succès
                      AppNotification.success(
                        context,
                        title: 'Dépôt d\'épargne ajouté',
                        subtitle: '${amount.toStringAsFixed(2)}€ ajouté à ${_currentPocket.name}',
                      );
                    } else {
                      AppNotification.error(
                        context,
                        title: 'Montant invalide',
                        subtitle: 'Veuillez saisir un montant valide',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF78D078),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ajouter le dépôt',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ajouter un dépôt d'épargne
  void addSavingsDeposit(double amount, DateTime date, String? description) async {
    if (!_currentPocket.isSavingsPocket) {
      return;
    }

    print('💰 Ajout d\'un dépôt d\'épargne de ${amount}€ - Cela retire ${amount}€ du budget disponible');

    // Créer un dépôt d'épargne
    final savingsDeposit = PocketTransaction(
      id: 'spt_${DateTime.now().millisecondsSinceEpoch}',
      title: description?.isNotEmpty == true 
          ? description!
          : 'Dépôt d\'épargne - ${_currentPocket.name}',
      amount: amount,
      date: date,
      description: 'Dépôt d\'épargne dans ${_currentPocket.name}',
      type: TransactionType.savings_deposit,
    );

    try {
      // NE PAS créer de transaction globale pour l'épargne
      // Le dépôt reste uniquement dans le pocket local
      print('📝 Dépôt d\'épargne ajouté uniquement au pocket local (pas au provider global)');
      
      // Utiliser la méthode spécifique pour l'épargne
      final updatedPocket = _currentPocket.addSavingsDeposit(savingsDeposit);
      
      // Mettre à jour l'état local et notifier le parent
      _currentPocket = updatedPocket;
      
      // Mettre à jour l'animation de progression
      updateProgressAnimation();
      
      notifyListeners();
      
      // Notifier le parent pour mettre à jour la liste des pockets
      if (_onPocketUpdated != null) {
        print('🔄 Notification du parent pour mise à jour de la liste et du budget disponible');
        _onPocketUpdated!(updatedPocket);
      }
      
      print('✅ Dépôt d\'épargne ajouté: ${amount}€ retiré du budget disponible');
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors de l\'ajout du dépôt d\'épargne: $e');
    }
  }

  // Supprimer une transaction
  void deleteTransaction(PocketTransaction transaction) async {
    print('🗑️ Suppression de la transaction du pocket: ${transaction.title} (${transaction.id})');
    print('📊 Avant suppression: ${_currentPocket.transactions.length} transactions, ${_currentPocket.spent}€ dépensés');
    
    // Vérifier si c'est un dépôt d'épargne
    final isSavingsDeposit = transaction.type == TransactionType.savings_deposit;
    if (isSavingsDeposit) {
      print('💰 Suppression d\'un dépôt d\'épargne de ${transaction.amount}€ - Cela remet ${transaction.amount}€ dans le budget disponible');
    }
    
    try {
      final updatedTransactions = _currentPocket.transactions
          .where((t) => t.id != transaction.id)
          .toList();
      
      final totalSpent = updatedTransactions.fold(0.0, (sum, t) => sum + t.amount);
      
      _currentPocket = _currentPocket.copyWith(
        transactions: updatedTransactions,
        spent: totalSpent,
      );
      
      print('✅ Après suppression: ${_currentPocket.transactions.length} transactions, ${_currentPocket.spent}€ dépensés');
      
      // Mettre à jour l'animation de progression
      updateProgressAnimation();
      
      // Forcer la mise à jour de l'interface utilisateur
      notifyListeners();
      
      // Attendre un peu pour s'assurer que l'interface se met à jour
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Notifier à nouveau pour s'assurer que tout est synchronisé
      notifyListeners();
      
      // Notifier le parent
      if (_onPocketUpdated != null) {
        print('🔄 Notification du parent pour mise à jour de la liste');
        _onPocketUpdated!(_currentPocket);
      }
      
      // La transaction reste dans le TransactionProvider global
      // Elle peut être réutilisée dans d'autres pockets
      print('ℹ️ Transaction conservée dans l\'application globale: ${transaction.title}');
      
      if (isSavingsDeposit) {
        print('✅ Dépôt d\'épargne supprimé: ${transaction.amount}€ remis dans le budget disponible');
      }
      
    } catch (e) {
      print('❌ Erreur lors de la suppression de la transaction: $e');
    }
  }

  // Obtenir une date relative
  String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return "Aujourd'hui";
    } else if (difference.inDays == 1) {
      return "Hier";
    } else if (difference.inDays < 7) {
      return "Il y a ${difference.inDays} jours";
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return weeks == 1 ? "Il y a 1 semaine" : "Il y a $weeks semaines";
    } else {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? "Il y a 1 mois" : "Il y a $months mois";
    }
  }

  // Obtenir l'icône appropriée pour une transaction
  IconData getIconForTransaction(PocketTransaction transaction) {
    if (transaction.icon != null) {
      return getPocketIcon();
    }
    
    // Utiliser l'icône du pocket par défaut ou une icône basée sur le titre
    if (transaction.title.toLowerCase().contains('carrefour') || 
        transaction.title.toLowerCase().contains('auchan') ||
        transaction.title.toLowerCase().contains('leclerc') ||
        transaction.title.toLowerCase().contains('lidl') ||
        transaction.title.toLowerCase().contains('intermarché')) {
      return HugeIcons.strokeRoundedShoppingCart01;
    } else if (transaction.title.toLowerCase().contains('amazon') ||
               transaction.title.toLowerCase().contains('fnac') ||
               transaction.title.toLowerCase().contains('darty')) {
      return HugeIcons.strokeRoundedShoppingBag01;
    } else if (transaction.title.toLowerCase().contains('essence') ||
               transaction.title.toLowerCase().contains('total') ||
               transaction.title.toLowerCase().contains('shell')) {
      return HugeIcons.strokeRoundedCar01;
    } else if (transaction.title.toLowerCase().contains('restaurant') ||
               transaction.title.toLowerCase().contains('mcdo') ||
               transaction.title.toLowerCase().contains('burger')) {
      return HugeIcons.strokeRoundedRestaurant01;
    }
    
    // Icône par défaut
    return getPocketIcon();
  }
} 