import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../core/constants/constants.dart';
import '../../../../data/models/pocket.dart';
import '../../../../data/models/transaction.dart';
import '../../../../providers/transaction_provider.dart';

class TransactionSelectionModal extends StatefulWidget {
  final Pocket pocket;
  final Function(List<Transaction>) onTransactionsAdded;

  const TransactionSelectionModal({
    super.key,
    required this.pocket,
    required this.onTransactionsAdded,
  });

  @override
  State<TransactionSelectionModal> createState() => _TransactionSelectionModalState();
}

class _TransactionSelectionModalState extends State<TransactionSelectionModal> 
    with TickerProviderStateMixin {
  final List<Transaction> _selectedTransactions = [];
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
            blurRadius: 32,
            offset: const Offset(0, -8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header moderne avec barre de drag
          _buildModernHeader(isDark),
          
          // Barre de recherche moderne
          _buildModernSearchBar(isDark),
          
          // Liste des transactions avec animations
          Expanded(
            child: _buildTransactionsList(isDark),
          ),
          
          // Footer moderne avec bouton d'action
          _buildModernFooter(isDark),
        ],
      ),
    );
  }
  
  Widget _buildModernHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Barre de drag moderne
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 20),
          
          // Titre avec icône
          Row(
            children: [
                             Container(
                 width: 48,
                 height: 48,
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [
                       const Color(0xFF6BC6EA).withValues(alpha: 0.1),
                       const Color(0xFF6BC6EA).withValues(alpha: 0.05),
                     ],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(16),
                 ),
                 child: Icon(
                   HugeIcons.strokeRoundedWallet01,
                   color: const Color(0xFF6BC6EA),
                   size: 24,
                 ),
               ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajouter des transactions',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDark : AppColors.text,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sélectionnez les dépenses à associer',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: TextField(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.textDark : AppColors.text,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher une transaction...',
          hintStyle: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6BC6EA).withValues(alpha: 0.1),
                  const Color(0xFF6BC6EA).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              HugeIcons.strokeRoundedSearch01,
              color: const Color(0xFF6BC6EA),
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }
  
  Widget _buildTransactionsList(bool isDark) {
    return Consumer<TransactionProvider>(
      builder: (context, transactionProvider, child) {
        // Filtrer les transactions qui ne sont pas déjà dans le pocket
        final existingTransactionIds = widget.pocket.transactions
            .where((t) => t.transactionId != null)
            .map((t) => t.transactionId!)
            .toSet();
        
        // Obtenir uniquement les dépenses et filtrer
        final availableTransactions = transactionProvider.transactions
            .where((t) => t.isExpense) // Filtrer uniquement les dépenses
            .where((t) => !existingTransactionIds.contains(t.id))
            .where((t) =>
                t.title.toLowerCase().contains(_searchQuery) ||
                t.description?.toLowerCase().contains(_searchQuery) == true)
            .toList();
        
        if (availableTransactions.isEmpty) {
          return _buildEmptyState(isDark);
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: availableTransactions.length,
          itemBuilder: (context, index) {
            final transaction = availableTransactions[index];
            final isSelected = _selectedTransactions.contains(transaction);
            
            return SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: index == availableTransactions.length - 1 ? 16 : 12,
                  ),
                  child: _buildModernTransactionItem(
                    transaction: transaction,
                    isSelected: isSelected,
                    onToggle: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        if (isSelected) {
                          _selectedTransactions.remove(transaction);
                        } else {
                          _selectedTransactions.add(transaction);
                        }
                      });
                    },
                    isDark: isDark,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6BC6EA).withValues(alpha: 0.1),
                  const Color(0xFF6BC6EA).withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              HugeIcons.strokeRoundedInvoice01,
              size: 36,
              color: const Color(0xFF6BC6EA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty 
                ? 'Aucune transaction disponible' 
                : 'Aucun résultat pour "$_searchQuery"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty 
                ? 'Toutes les dépenses sont déjà associées à ce pocket'
                : 'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildModernTransactionItem({
    required Transaction transaction,
    required bool isSelected,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    final categoryIcons = {
      'expense_food': HugeIcons.strokeRoundedRestaurant01,
      'expense_transport': HugeIcons.strokeRoundedCar01,
      'expense_shopping': HugeIcons.strokeRoundedShoppingBag01,
      'expense_subscription': HugeIcons.strokeRoundedCreditCard,
      'expense_entertainment': HugeIcons.strokeRoundedGameController01,
      'expense_health': HugeIcons.strokeRoundedHeartCheck,
      'expense_bills': HugeIcons.strokeRoundedInvoice01,
      'expense_other': HugeIcons.strokeRoundedMoreHorizontal,
    };

    final categoryColors = {
      'expense_food': const Color(0xFFF48A99),
      'expense_transport': const Color(0xFF6BC6EA),
      'expense_shopping': const Color(0xFFFFB67A),
      'expense_subscription': const Color(0xFF78D078),
      'expense_entertainment': const Color(0xFFF48A99),
      'expense_health': const Color(0xFF6BC6EA),
      'expense_bills': const Color(0xFFFFB67A),
      'expense_other': const Color(0xFF78D078),
    };
    
    final icon = categoryIcons[transaction.categoryId] ?? HugeIcons.strokeRoundedMoreHorizontal;
    final color = categoryColors[transaction.categoryId] ?? const Color(0xFF6BC6EA);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: isSelected 
            ? color.withValues(alpha: isDark ? 0.15 : 0.08)
            : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected 
              ? color.withValues(alpha: 0.6)
              : (isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3)),
          width: isSelected ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? color.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icône de catégorie
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Détails de la transaction
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDark : AppColors.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(transaction.date),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 16),
                
                                 // Montant uniquement
                 Text(
                   '${transaction.amount.toStringAsFixed(2)}€',
                   style: TextStyle(
                     fontSize: 16,
                     fontWeight: FontWeight.w700,
                     color: const Color(0xFFF48A99),
                   ),
                 ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildModernFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Informations de sélection
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_selectedTransactions.length} transaction(s) sélectionnée(s)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                if (_selectedTransactions.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Total: ${_selectedTransactions.fold(0.0, (sum, t) => sum + t.amount).toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Bouton d'action moderne
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _selectedTransactions.isEmpty 
                  ? null 
                  : () {
                      HapticFeedback.mediumImpact();
                      widget.onTransactionsAdded(_selectedTransactions);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedTransactions.isEmpty 
                    ? (isDark ? AppColors.borderDark : AppColors.border)
                    : const Color(0xFF6BC6EA),
                foregroundColor: _selectedTransactions.isEmpty 
                    ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
                    : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(24),
                 ),
                elevation: _selectedTransactions.isEmpty ? 0 : 4,
                shadowColor: const Color(0xFF6BC6EA).withValues(alpha: 0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                                     Icon(
                     Icons.add,
                     size: 18,
                   ),
                  const SizedBox(width: 8),
                                     Text(
                     'Ajouter',
                     style: const TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.w700,
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 