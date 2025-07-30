import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../widgets/modern_animations.dart';
import '../../data/models/pocket.dart';
import '../../data/models/transaction.dart';
import '../../providers/transaction_provider.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';
import 'pocket_savings_deposit_page.dart';
import 'pocket_summary_page.dart';

class PocketTransactionsPage extends StatefulWidget {
  final PocketType category;
  final String name;
  final String icon;
  final String color;
  final SavingsGoalType? savingsGoal;
  final double budget;
  final bool isPercentageMode;
  final double budgetValue;
  final double monthlyIncome;

  const PocketTransactionsPage({
    super.key,
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    this.savingsGoal,
    required this.budget,
    required this.isPercentageMode,
    required this.budgetValue,
    required this.monthlyIncome,
  });

  @override
  State<PocketTransactionsPage> createState() => _PocketTransactionsPageState();
}

class _PocketTransactionsPageState extends State<PocketTransactionsPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  List<Transaction> _selectedTransactions = [];
  List<Transaction> _filteredTransactions = [];
  String _selectedTimeRange = '3 mois';
  String _sortBy = 'date';
  bool _isAscending = false;

  final List<String> _timeRanges = ['1 mois', '3 mois', '6 mois', 'Tout'];
  final List<String> _sortOptions = ['date', 'montant', 'nom'];

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    // Démarrer l'animation
    _animationController.forward();
    
    // Écouter les changements de recherche
    _searchController.addListener(_filterTransactions);
    
    // Charger les transactions après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }
  
  void _loadTransactions() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final allTransactions = transactionProvider.transactions;
    
    // Filtrer par période
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedTimeRange) {
      case '1 mois':
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '3 mois':
        startDate = now.subtract(const Duration(days: 90));
        break;
      case '6 mois':
        startDate = now.subtract(const Duration(days: 180));
        break;
      case 'Tout':
      default:
        startDate = DateTime(2000); // Date très ancienne
        break;
    }
    
    final filtered = allTransactions
        .where((t) => (t as Transaction).isExpense) // Filtrer uniquement les dépenses
        .where((t) => (t as Transaction).date.isAfter(startDate))
        .toList();
    
    setState(() {
      _filteredTransactions = filtered;
    });
    
    _filterTransactions();
  }
  
  void _filterTransactions() {
    final query = _searchController.text.toLowerCase();
    
    List<Transaction> filtered = _filteredTransactions.cast<Transaction>();
    
    if (query.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              (t as Transaction).title.toLowerCase().contains(query) ||
              ((t as Transaction).description?.toLowerCase().contains(query) ?? false))
          .toList();
    }
    
    // Trier les transactions
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'montant':
          final comparison = (a as Transaction).amount.compareTo((b as Transaction).amount);
          return _isAscending ? comparison : -comparison;
        case 'nom':
          final comparison = (a as Transaction).title.compareTo((b as Transaction).title);
          return _isAscending ? comparison : -comparison;
        case 'date':
        default:
          final comparison = (a as Transaction).date.compareTo((b as Transaction).date);
          return _isAscending ? comparison : -comparison;
      }
    });
    
    setState(() {
      _filteredTransactions = filtered;
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Contenu principal avec header intégré
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _buildScrollableContent(isDark),
              ),
            ),
            
            // Bouton continuer
            FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContinueButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderContent(bool isDark) {
    return Column(
      children: [
        // Navigation
        Row(
          children: [
            SmartBackButton(
              iconSize: 24,
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Créer un Pocket',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 44), // Pour équilibrer avec le bouton retour
          ],
        ),
        
        const SizedBox(height: 20),
        
        // Titre spécifique à l'étape
        Text(
          'Associer des transactions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Sélectionnez les transactions existantes pour ce pocket\n(optionnel)',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
            height: 1.4,
            letterSpacing: -0.1,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScrollableContent(bool isDark) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header scrollable normal
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Header intégré dans le scroll
                _buildHeaderContent(isDark),
                
                const SizedBox(height: 20),
                
                // Indicateur de progression
                _buildProgressIndicator(isDark),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        
        // Section sticky pour recherche et filtres
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyFiltersDelegate(
            child: Container(
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                children: [
                  _buildFiltersContent(isDark),
                  const SizedBox(height: 12),
                  // Statistiques intégrées
                  _buildStatsContainer(isDark),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            isDark: isDark,
          ),
        ),
        
        // Liste des transactions (sans en-tête stats)
        _filteredTransactions.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: _buildEmptyState(isDark),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final transaction = _filteredTransactions[index];
                    final isSelected = _selectedTransactions.contains(transaction);
                    
                    return Padding(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: index == 0 ? 20 : 0,
                        bottom: index == _filteredTransactions.length - 1 ? 32 : 12,
                      ),
                      child: SlideInAnimation(
                        delay: Duration(milliseconds: 50 * index),
                        beginOffset: const Offset(0.3, 0),
                        child: _buildTransactionItem(transaction, isSelected, isDark),
                      ),
                    );
                  },
                  childCount: _filteredTransactions.length,
                ),
              ),
      ],
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '4',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Étape 4 sur 4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Association des transactions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersContent(bool isDark) {
    return Column(
      children: [
        // Barre de recherche
        TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Rechercher une transaction...',
            hintStyle: TextStyle(
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              HugeIcons.strokeRoundedSearch01,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6),
              size: 20,
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Filtres
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Période
              _buildFilterChip(
                isDark,
                'Période',
                _selectedTimeRange,
                () => _showTimeRangePicker(isDark),
              ),
              
              const SizedBox(width: 12),
              
              // Tri
              _buildFilterChip(
                isDark,
                'Trier par',
                _sortBy,
                () => _showSortPicker(isDark),
              ),
              
              const SizedBox(width: 12),
              
              // Ordre
              _buildFilterChip(
                isDark,
                'Ordre',
                _isAscending ? 'Croissant' : 'Décroissant',
                () => setState(() => _isAscending = !_isAscending),
              ),
              
              if (_selectedTransactions.isNotEmpty) ...[
                const SizedBox(width: 12),
                
                // Effacer sélection
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedTransactions.clear());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      HugeIcons.strokeRoundedCancel01,
                      size: 16,
                      color: AppColors.orange,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(bool isDark, String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textDark : AppColors.text,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              HugeIcons.strokeRoundedArrowDown01,
              size: 12,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContainer(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_filteredTransactions.length} transaction(s) trouvée(s)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                if (_selectedTransactions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total sélectionné: ${_getTotalSelectedAmount().toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_selectedTransactions.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedTransactions.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  HugeIcons.strokeRoundedCancel01,
                  size: 16,
                  color: AppColors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction, bool isSelected, bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          if (isSelected) {
            _selectedTransactions.remove(transaction);
          } else {
            _selectedTransactions.add(transaction);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? pocketColor.withValues(alpha: 0.08)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? pocketColor
                : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: pocketColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            // Icône de la transaction
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected 
                    ? pocketColor.withValues(alpha: 0.2)
                    : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getTransactionIcon(transaction),
                color: isSelected 
                    ? pocketColor 
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Détails
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (transaction as Transaction).title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getFormattedDate((transaction as Transaction).date),
                    style: TextStyle(
                      fontSize: 13,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Montant et sélection
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(transaction as Transaction).amount.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (transaction as Transaction).type == TransactionType.expense
                        ? AppColors.red
                        : AppColors.green,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSelected ? pocketColor : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? pocketColor : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                HugeIcons.strokeRoundedSearch01,
                size: 40,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.5),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              'Aucune transaction trouvée',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textDark : AppColors.text,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Essayez de modifier vos filtres ou\najoutez des transactions plus tard',
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: GestureDetector(
        onTap: _continue,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _selectedTransactions.isEmpty 
                    ? 'Passer cette étape' 
                    : 'Créer le pocket (${_selectedTransactions.length} transaction${_selectedTransactions.length > 1 ? 's' : ''})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                HugeIcons.strokeRoundedArrowRight01,
                color: Colors.white,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTimeRangePicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sélectionner la période',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.text,
              ),
            ),
            const SizedBox(height: 20),
            ..._timeRanges.map((range) => ListTile(
              title: Text(range),
              leading: Radio<String>(
                value: range,
                groupValue: _selectedTimeRange,
                onChanged: (value) {
                  setState(() {
                    _selectedTimeRange = value!;
                  });
                  Navigator.pop(context);
                  _loadTransactions();
                },
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  void _showSortPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Trier par',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.text,
              ),
            ),
            const SizedBox(height: 20),
            ..._sortOptions.map((option) => ListTile(
              title: Text(_getSortOptionLabel(option)),
              leading: Radio<String>(
                value: option,
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                  _filterTransactions();
                },
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  String _getSortOptionLabel(String option) {
    switch (option) {
      case 'date':
        return 'Date';
      case 'montant':
        return 'Montant';
      case 'nom':
        return 'Nom';
      default:
        return option;
    }
  }

  IconData _getTransactionIcon(Transaction transaction) {
    // Logique basique pour déterminer l'icône selon le type/catégorie
    if ((transaction as Transaction).title.toLowerCase().contains('restaurant') ||
        (transaction as Transaction).title.toLowerCase().contains('café')) {
      return HugeIcons.strokeRoundedRestaurant01;
    } else if ((transaction as Transaction).title.toLowerCase().contains('course') ||
               (transaction as Transaction).title.toLowerCase().contains('super')) {
      return HugeIcons.strokeRoundedShoppingCart01;
    } else if ((transaction as Transaction).title.toLowerCase().contains('transport') ||
               (transaction as Transaction).title.toLowerCase().contains('uber') ||
               (transaction as Transaction).title.toLowerCase().contains('essence')) {
      return HugeIcons.strokeRoundedCar01;
    } else if ((transaction as Transaction).title.toLowerCase().contains('salaire')) {
      return HugeIcons.strokeRoundedMoney01;
    } else {
      return HugeIcons.strokeRoundedWallet01;
    }
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  double _getTotalSelectedAmount() {
    return _selectedTransactions.fold(0.0, (sum, transaction) => sum + ((transaction as Transaction).amount));
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    
    // Pour les pockets d'épargne, on ne devrait pas permettre la sélection de transactions classiques
    // Les épargnes fonctionnent uniquement avec des dépôts d'épargne
    if (widget.category == PocketType.savings && _selectedTransactions.isNotEmpty) {
      // Vider les transactions sélectionnées car les épargnes ne les acceptent pas
      _selectedTransactions.clear();
    }
    
    // Si c'est une pocket d'épargne, naviguer vers l'étape de dépôt d'épargne
    // Sinon, aller directement au résumé
    if (widget.category == PocketType.savings) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketSavingsDepositPage(
            category: widget.category,
            name: widget.name,
            icon: widget.icon,
            color: widget.color,
            budget: widget.budget,
            isPercentageMode: widget.isPercentageMode,
            budgetValue: widget.budgetValue,
            monthlyIncome: widget.monthlyIncome,
            savingsGoal: widget.savingsGoal,
            selectedTransactions: _selectedTransactions,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketSummaryPage(
            category: widget.category,
            name: widget.name,
            icon: widget.icon,
            color: widget.color,
            budget: widget.budget,
            isPercentageMode: widget.isPercentageMode,
            budgetValue: widget.budgetValue,
            monthlyIncome: widget.monthlyIncome,
            savingsGoal: widget.savingsGoal,
            wantsInitialDeposit: false,
            depositAmount: null,
            depositDate: null,
            depositDescription: null,
            selectedTransactions: _selectedTransactions,
          ),
        ),
      );
    }
  }
}

// Delegate pour la section sticky
class _StickyFiltersDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final bool isDark;

  _StickyFiltersDelegate({
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 230; // Hauteur maximale pour éviter le débordement

  @override
  double get minExtent => 230; // Hauteur minimale (même hauteur = pas de shrink)

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
} 