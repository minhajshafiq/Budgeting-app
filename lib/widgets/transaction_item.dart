import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../core/constants/constants.dart';
import 'package:hugeicons/hugeicons.dart';
import 'transaction_edit_modal.dart';
import '../data/models/transaction.dart';
import '../data/models/pocket.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/transaction_provider.dart';
import 'modern_animations.dart';

// Constantes pour l'optimisation
class _Constants {
  static const double avatarSize = 48.0;
  static const double imageSize = 48.0;
  static const double imagePadding = 0.0;
  static const double borderRadius = 12.0;
  static const double modalBorderRadius = 24.0;
  static const int logoGridSize = 9;
  static const Duration requestTimeout = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Styles réutilisables
  static TextStyle titleStyle(BuildContext context) => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).brightness == Brightness.dark 
      ? AppColors.textDark 
      : AppColors.text,
  );
  
  static TextStyle dateStyle(BuildContext context) => GoogleFonts.inter(
    fontSize: 13,
    color: Theme.of(context).brightness == Brightness.dark 
      ? AppColors.textSecondaryDark 
      : AppColors.textSecondary,
  );
  
  static TextStyle amountStyle(BuildContext context) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Theme.of(context).brightness == Brightness.dark 
      ? AppColors.textDark 
      : AppColors.text,
  );
}

class TransactionItem extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final String imageUrl;
  final String category;
  final Function(Map<String, dynamic>)? onUpdate;
  final Transaction? transaction; // Transaction complète (optionnelle)
  final Function(Transaction, Pocket)? onAddToPocket; // Callback pour ajouter à un pocket

  const TransactionItem({
    Key? key,
    required this.title,
    required this.date,
    required this.amount,
    this.imageUrl = 'https://storage.googleapis.com/pr-newsroom-wp/1/2018/11/Spotify_Logo_RGB_Green.png',
    this.category = 'Abonnements',
    this.onUpdate,
    this.transaction,
    this.onAddToPocket,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPositive = amount.startsWith('+');
    
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        HapticFeedback.lightImpact();
        _showTransactionEditModal(context);
      },
      onLongPress: transaction != null ? () => _showPocketOptions(context) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            // Avatar optimisé avec Hero pour les transitions
            Hero(
              tag: 'transaction_avatar_$title',
              child: _buildOptimizedAvatar(isDark),
            ),
            const SizedBox(width: 18),
            
            // Informations de transaction
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _Constants.titleStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    date,
                    style: _Constants.dateStyle(context),
                  ),
                ],
              ),
            ),
            
            // Montant avec couleur conditionnelle optimisée
            Text(
              amount,
              style: _Constants.amountStyle(context).copyWith(
                color: _getAmountColor(amount, isPositive, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar optimisé avec loading et error handling améliorés
  Widget _buildOptimizedAvatar(bool isDark) {
    // Si la transaction a une imageUrl, on l'utilise en priorité
    String? imageUrlToUse = imageUrl;
    if (transaction?.imageUrl != null && transaction!.imageUrl!.isNotEmpty) {
      imageUrlToUse = transaction!.imageUrl!;
    }

    return _CircularAvatar(
      imageUrl: imageUrlToUse?.startsWith('http') == true ? imageUrlToUse : null,
      imageFile: imageUrlToUse?.startsWith('http') == false && imageUrlToUse != null ? File(imageUrlToUse) : null,
      size: _Constants.avatarSize,
      isDark: isDark,
    );
  }

  // Méthode utilitaire pour déterminer la couleur du montant
  Color _getAmountColor(String amount, bool isPositive, bool isDark) {
    if (isPositive) return AppColors.green;
    if (amount.startsWith('-')) return AppColors.red;
    return isDark ? AppColors.textDark : AppColors.text;
  }

  void _showTransactionEditModal(BuildContext context) {
    // Créer un objet Transaction à partir des données
    final transaction = Transaction(
      id: '', // Pas d'ID pour les transactions mock
      title: title,
      description: title,
      amount: double.tryParse(amount.replaceAll(RegExp(r'[+\-€\s]'), '')) ?? 0.0,
      date: DateTime.now(), // Utiliser la date actuelle par défaut
      categoryId: 'expense_other', // Catégorie par défaut valide
      type: amount.startsWith('+') ? TransactionType.income : TransactionType.expense,
      recurrence: RecurrenceType.none,
    );
    
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
    if (transaction == null || onAddToPocket == null) return;
    
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
        transaction: transaction!,
        pockets: pockets,
        onPocketSelected: (pocket) {
          Navigator.pop(context);
          onAddToPocket!(transaction!, pocket);
        },
      ),
    );
  }
}

// Avatar circulaire optimisé avec fallback
class _CircularAvatar extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double size;
  final bool isDark;
  final IconData? fallbackIcon;

  const _CircularAvatar({
    this.imageUrl,
    this.imageFile,
    required this.size,
    required this.isDark,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
        decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : Colors.grey[100],
        border: Border.all(
          color: isDark ? AppColors.borderDark.withValues(alpha: 0.3) : AppColors.border.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipOval(
        child: _buildImageContent(),
      ),
    );
  }

  Widget _buildImageContent() {
    // Priorité: fichier local > URL > fallback
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        errorBuilder: _buildErrorWidget,
      );
    }
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder: _buildLoadingWidget,
        errorBuilder: _buildErrorWidget,
      );
    }
    
    return _buildFallbackWidget();
  }

  Widget _buildLoadingWidget(BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    
    return Center(
      child: SizedBox(
        width: size * 0.4,
        height: size * 0.4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
                color: AppColors.primary,
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, Object error, StackTrace? stackTrace) {
    return _buildFallbackWidget();
  }

  Widget _buildFallbackWidget() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark ? AppColors.surfaceDark : Colors.grey[50],
      ),
      child: Icon(
        fallbackIcon ?? HugeIcons.strokeRoundedUser,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        size: size * 0.4,
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