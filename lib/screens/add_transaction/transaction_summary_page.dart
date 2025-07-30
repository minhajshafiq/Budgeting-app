import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/constants/constants.dart';
import '../../widgets/modern_animations.dart';
import '../../core/widgets/card_container.dart';
import '../../widgets/app_notification.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction.dart';
import '../../data/models/category.dart';
import '../../presentation/transactions_history/screens/transaction_history_screen.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/widgets/smart_back_button.dart';
import 'transaction_amount_page.dart';

class TransactionSummaryPage extends StatefulWidget {
  final Map<String, dynamic> transactionData;
  
  const TransactionSummaryPage({
    Key? key, 
    required this.transactionData,
  }) : super(key: key);

  @override
  State<TransactionSummaryPage> createState() => _TransactionSummaryPageState();
}

class _TransactionSummaryPageState extends State<TransactionSummaryPage> 
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _successController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOut,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mainController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _successController.forward();
  }
  
  @override
  void dispose() {
    _mainController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    final bool isIncome = widget.transactionData['isIncome'] as bool;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header moderne et épuré
            _buildModernHeader(),
            
            // Contenu principal avec scroll
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Animation de succès moderne
                    _buildSuccessAnimation(isIncome),
                    
                    const SizedBox(height: 24),
                    
                    // Carte de résumé moderne
                    _buildSummaryCard(),
                    
                    const SizedBox(height: 20),
                    
                    // Boutons d'action
                    _buildActionButtons(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final Color backgroundColor = isDark ? AppColors.backgroundDark : AppColors.background;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      child: Row(
        children: [
          // Bouton retour simple
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                  color: textColor,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Résumé',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Étape 3/3',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bouton de fermeture minimaliste
          GestureDetector(
            onTap: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                    blurRadius: 4,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSuccessAnimation(bool isIncome) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Icône de succès simplifiée
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isIncome 
                    ? [AppColors.green, AppColors.green.withOpacity(0.8)]
                    : [AppColors.red, AppColors.red.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              isIncome ? 'Revenu prêt !' : 'Dépense prête !',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isIncome ? AppColors.green : AppColors.red,
                letterSpacing: -0.3,
              ),
            ),
            
            const SizedBox(height: 2),
            
            Text(
              'Vérifiez les détails',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark 
                  ? AppColors.textSecondaryDark 
                  : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color cardColor = isDark ? AppColors.surfaceDark : Colors.white;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    final bool isIncome = widget.transactionData['isIncome'] as bool;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // En-tête simplifié
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.03),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: HugeIcon(
                        icon: isIncome ? HugeIcons.strokeRoundedInvoice01 : HugeIcons.strokeRoundedInvoice02,
                        color: isIncome ? AppColors.green : AppColors.red,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Détails de la transaction",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu de la carte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Montant en évidence
                  _buildHighlightedAmount(isIncome),
                  
                  const SizedBox(height: 16),
                  
                  // Autres détails
                  _buildDetailRow("Titre", widget.transactionData['title'] as String, HugeIcons.strokeRoundedEdit01),
                  _buildDetailRow("Catégorie", widget.transactionData['category'] as String, HugeIcons.strokeRoundedMenu01),
                  _buildDetailRow("Date", widget.transactionData['date'] as String, HugeIcons.strokeRoundedCalendar03),
                  _buildDetailRow("Récurrence", _getRecurrenceLabel(widget.transactionData['recurrence'] as String), HugeIcons.strokeRoundedRepeat),
                  
                  // Image si présente
                  if (widget.transactionData['imageUrl'] != null || widget.transactionData['imagePath'] != null)
                    Column(
                      children: [
                        const SizedBox(height: 12),
                        _buildImagePreview(),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHighlightedAmount(bool isIncome) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String amount = widget.transactionData['amount'] as String;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.15),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isIncome ? AppColors.green : AppColors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedMoney01,
                color: isIncome ? AppColors.green : AppColors.red,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Montant",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? AppColors.green : AppColors.red,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color textColor = isDark ? AppColors.textDark : AppColors.text;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: HugeIcon(
                icon: icon,
                color: AppColors.primary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildImagePreview() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedImage01,
                  color: AppColors.primary,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Image associée",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: _buildImageContent(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildImageContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String? imagePath = widget.transactionData['imagePath'] as String?;
    final String? imageUrl = widget.transactionData['imageUrl'] as String?;
    
    // Si aucune image n'est sélectionnée
    if (imagePath == null && imageUrl == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedImage01,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              "Aucune image sélectionnée",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }
    
    // Si on a une image locale
    if (imagePath != null) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(isDark);
        },
      );
    }
    
    // Si on a une image URL
    if (imageUrl != null) {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageError(isDark);
        },
      );
    }
    
    // Fallback
    return _buildImageError(isDark);
  }
  
  Widget _buildImageError(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedImage01,
            color: AppColors.red,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            "Erreur",
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(_slideAnimation),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Bouton secondaire (Modifier)
              Expanded(
                child: GestureDetector(
                  onTap: _isLoading ? null : _handleModify,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Modifier',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Bouton principal (Confirmer)
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _isLoading ? null : _saveTransaction,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Confirmer',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const HugeIcon(
                                  icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ],
                            ),
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
  
  String _getRecurrenceLabel(String recurrence) {
    switch (recurrence) {
      case 'none':
        return 'Aucune récurrence';
      case 'weekly':
        return 'Hebdomadaire';
      case 'monthly':
        return 'Mensuelle';
      case 'quarterly':
        return 'Trimestrielle';
      case 'annual':
        return 'Annuelle';
      default:
        return 'Aucune récurrence';
    }
  }
  
  void _saveTransaction() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Déterminer l'imageUrl à sauvegarder
      String? imageUrlToSave;
      if (widget.transactionData['imagePath'] != null) {
        // Si une image de galerie est sélectionnée, on utilise le chemin local
        imageUrlToSave = widget.transactionData['imagePath'] as String;
      } else if (widget.transactionData['imageUrl'] != null) {
        // Si un logo Logo.dev est sélectionné, on utilise l'URL
        imageUrlToSave = widget.transactionData['imageUrl'] as String;
      }

      // Convertir les données en objet Transaction
      final transaction = Transaction(
        title: widget.transactionData['title'] as String,
        amount: double.parse(widget.transactionData['amount'].toString().replaceAll(RegExp(r'[+\-€\s]'), '')),
        date: _parseDate(widget.transactionData['date'] as String),
        categoryId: _getCategoryId(widget.transactionData['category'] as String, widget.transactionData['isIncome'] as bool),
        type: (widget.transactionData['isIncome'] as bool) ? TransactionType.income : TransactionType.expense,
        description: null,
        recurrence: _parseRecurrence(widget.transactionData['recurrence'] as String),
        imageUrl: imageUrlToSave,
      );

      // Sauvegarder via le provider
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.addTransaction(transaction);
      
      // Afficher la notification
      final bool isIncome = widget.transactionData['isIncome'] as bool;
      final String title = widget.transactionData['title'] as String;
      final String amount = widget.transactionData['amount'] as String;
      
      AppNotification.success(
        context,
        title: isIncome ? 'Revenu ajouté' : 'Dépense ajoutée',
        subtitle: '$title - $amount',
      );
      
      // Navigation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const TransactionHistoryScreen(),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      print('Erreur lors de la sauvegarde: $e');
      AppNotification.error(
        context,
        title: 'Erreur',
        subtitle: 'Impossible de sauvegarder la transaction',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  DateTime _parseDate(String dateString) {
    try {
      // Format: "5 Mai 2024"
      final parts = dateString.split(' ');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = _getMonthNumber(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      print('Erreur parsing date: $e');
    }
    return DateTime.now();
  }

  int _getMonthNumber(String monthName) {
    const months = {
      'Janvier': 1, 'Février': 2, 'Mars': 3, 'Avril': 4,
      'Mai': 5, 'Juin': 6, 'Juillet': 7, 'Août': 8,
      'Septembre': 9, 'Octobre': 10, 'Novembre': 11, 'Décembre': 12
    };
    return months[monthName] ?? DateTime.now().month;
  }

  String _getCategoryId(String categoryName, bool isIncome) {
    final categories = DefaultCategories.getCategoriesForType(isIncome: isIncome);
    final category = categories.firstWhere(
      (cat) => cat.name == categoryName,
      orElse: () => isIncome ? DefaultCategories.defaultIncomeCategory : DefaultCategories.defaultExpenseCategory,
    );
    return category.id;
  }

  RecurrenceType _parseRecurrence(String recurrence) {
    switch (recurrence) {
      case 'weekly': return RecurrenceType.weekly;
      case 'monthly': return RecurrenceType.monthly;
      case 'quarterly': return RecurrenceType.quarterly;
      case 'annual': return RecurrenceType.yearly;
      default: return RecurrenceType.none;
    }
  }
  
  void _handleModify() {
    // Extraire les données de la transaction
    final String amount = widget.transactionData['amount'].toString().replaceAll(RegExp(r'[+\-€\s]'), '');
    final bool isIncome = widget.transactionData['isIncome'] as bool;
    final String title = widget.transactionData['title'] as String;
    final String category = widget.transactionData['category'] as String;
    final String? imageUrl = widget.transactionData['imageUrl'] as String?;
    final String? imagePath = widget.transactionData['imagePath'] as String?;
    final double amountValue = double.parse(amount);
    
    // Naviguer vers la première page avec toutes les données préremplies
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionAmountPage(
          isIncome: isIncome,
          transactionType: isIncome ? 'income' : 'expense',
          initialAmount: amountValue,
          initialTitle: title,
          initialCategory: category,
          initialImageUrl: imageUrl,
          initialImagePath: imagePath,
        ),
      ),
      (route) => route.isFirst,
    );
  }
} 