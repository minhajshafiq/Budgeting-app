import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import '../data/models/transaction.dart';
import '../data/models/pocket.dart';
import '../presentation/providers/transaction_provider_clean.dart';
import 'transaction_edit_modal.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final bool showStatusBubble;
  final Function(Transaction, Pocket)? onAddToPocket;

  const TransactionListItem({
    Key? key,
    required this.transaction,
    this.showStatusBubble = false,
    this.onAddToPocket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        _showEditModal(context);
      },
      onLongPress: onAddToPocket != null ? () => _showPocketOptions(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            
            // Icône de catégorie
            _buildCategoryIcon(isDark),
            const SizedBox(width: 12),
            
            // Informations de transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(transaction.date),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            Text(
              transaction.formattedAmount,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: _getAmountColor(transaction.isIncome, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(bool isDark) {
    // Si la transaction a une imageUrl, on affiche l'image
    if (transaction.imageUrl != null && transaction.imageUrl!.isNotEmpty) {
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipOval(
          child: transaction.imageUrl!.startsWith('http')
              ? Image.network(
                  transaction.imageUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultIcon(isDark);
                  },
                )
              : Image.file(
                  File(transaction.imageUrl!),
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildDefaultIcon(isDark);
                  },
                ),
        ),
      );
    }

    // Sinon, on affiche l'icône par défaut
    return _buildDefaultIcon(isDark);
  }

  Widget _buildDefaultIcon(bool isDark) {
    final categoryIcons = {
      'expense_food': HugeIcons.strokeRoundedRestaurant01,
      'expense_transport': HugeIcons.strokeRoundedCar01,
      'expense_shopping': HugeIcons.strokeRoundedShoppingBag01,
      'expense_subscription': HugeIcons.strokeRoundedCreditCard,
      'expense_entertainment': HugeIcons.strokeRoundedGameController01,
      'expense_health': HugeIcons.strokeRoundedHeartCheck,
      'expense_bills': HugeIcons.strokeRoundedInvoice01,
      'expense_other': HugeIcons.strokeRoundedMoreHorizontal,
      'income_salary': HugeIcons.strokeRoundedMoney01,
      'income_freelance': HugeIcons.strokeRoundedComputerProgramming01,
      'income_investment': HugeIcons.strokeRoundedTradeMark,
      'income_gift': HugeIcons.strokeRoundedGift,
      'income_other': HugeIcons.strokeRoundedWallet01,
    };

    final categoryColors = {
      'expense_food': const Color(0xFFFF6B6B),
      'expense_transport': const Color(0xFF4ECDC4),
      'expense_shopping': const Color(0xFFFFE66D),
      'expense_subscription': const Color(0xFF6C5CE7),
      'expense_entertainment': const Color(0xFFFF9FF3),
      'expense_health': const Color(0xFF54A0FF),
      'expense_bills': const Color(0xFFFFA502),
      'expense_other': const Color(0xFF95A5A6),
      'income_salary': const Color(0xFF00B894),
      'income_freelance': const Color(0xFF00CEC9),
      'income_investment': const Color(0xFF6C5CE7),
      'income_gift': const Color(0xFFFF7675),
      'income_other': const Color(0xFF81ECEC),
    };

    final icon = categoryIcons[transaction.categoryId] ?? HugeIcons.strokeRoundedMoreHorizontal;
    final color = categoryColors[transaction.categoryId] ?? AppColors.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: HugeIcon(
          icon: icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  Color _getAmountColor(bool isIncome, bool isDark) {
    if (isIncome) return AppColors.green;
    return AppColors.red;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }



  void _showEditModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => TransactionEditModal(
        transaction: transaction,
      ),
    );
  }

  // Méthode pour afficher les options de pocket
  void _showPocketOptions(BuildContext context) {
    if (onAddToPocket == null) return;
    
    HapticFeedback.mediumImpact();
    
    // Liste d'exemple de pockets (à remplacer par les données réelles)
    // Exclure les pockets d'épargne pour les transactions normales
    final List<Pocket> pockets = [
      Pocket(
        id: '1',
        name: 'Logement',
        icon: 'home',
        color: '#4C6EF5',
        budget: 800.0,
        createdAt: DateTime.now(),
        type: PocketType.needs,
      ),
      Pocket(
        id: '2',
        name: 'Alimentation',
        icon: 'shopping',
        color: '#4C6EF5',
        budget: 400.0,
        createdAt: DateTime.now(),
        type: PocketType.needs,
      ),
      Pocket(
        id: '5',
        name: 'Sorties & Restaurants',
        icon: 'restaurant',
        color: '#7C3AED',
        budget: 300.0,
        createdAt: DateTime.now(),
        type: PocketType.wants,
      ),
      // Note: Les pockets d'épargne sont exclus car ils n'acceptent que les dépôts d'épargne
    ];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _PocketSelectionModal(
        transaction: transaction,
        pockets: pockets,
        onPocketSelected: (pocket) {
          Navigator.pop(context);
          onAddToPocket!(transaction, pocket);
        },
      ),
    );
  }
}

// Nouveau widget pour la sélection de pocket
class _PocketSelectionModal extends StatelessWidget {
  final Transaction transaction;
  final List<Pocket> pockets;
  final Function(Pocket) onPocketSelected;

  const _PocketSelectionModal({
    required this.transaction,
    required this.pockets,
    required this.onPocketSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de drag
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          
          // Titre
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Ajouter à un pocket',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Sélectionnez un pocket pour y ajouter cette transaction',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Liste des pockets
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pockets.length,
              itemBuilder: (context, index) {
                final pocket = pockets[index];
                final pocketColor = Color(int.parse(pocket.color.substring(1), radix: 16) + 0xFF000000);
                
                return ListTile(
                  onTap: () => onPocketSelected(pocket),
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: pocketColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIconFromString(pocket.icon), color: pocketColor, size: 20),
                  ),
                  title: Text(
                    pocket.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                  subtitle: Text(
                    '${pocket.typeLabel} • ${pocket.remainingBudget.toStringAsFixed(0)}€ restants',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Méthode pour obtenir une icône à partir de son nom
  IconData _getIconFromString(String iconName) {
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
} 