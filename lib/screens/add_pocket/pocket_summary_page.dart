import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../core/services/supabase_sync_service.dart';
import '../../widgets/modern_animations.dart';
import '../../widgets/app_notification.dart';
import '../../data/models/pocket.dart';
import '../../data/models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import 'package:hugeicons/hugeicons.dart';

class PocketSummaryPage extends StatefulWidget {
  final PocketType category;
  final String name;
  final String icon;
  final String color;
  final SavingsGoalType? savingsGoal;
  final double budget;
  final bool isPercentageMode;
  final double budgetValue;
  final double monthlyIncome;
  final List<Transaction> selectedTransactions;
  // Nouveaux paramètres pour le dépôt d'épargne
  final bool? wantsInitialDeposit;
  final double? depositAmount;
  final DateTime? depositDate;
  final String? depositDescription;

  const PocketSummaryPage({
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
    required this.selectedTransactions,
    this.wantsInitialDeposit,
    this.depositAmount,
    this.depositDate,
    this.depositDescription,
  });

  @override
  State<PocketSummaryPage> createState() => _PocketSummaryPageState();
}

class _PocketSummaryPageState extends State<PocketSummaryPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _successAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _successAnimation;
  
  bool _isCreating = false;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));
    
    _successAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    );
    
    // Démarrer l'animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: _isSuccess ? _buildSuccessView(isDark) : _buildSummaryView(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryView(bool isDark) {
    return Column(
      children: [
        _buildHeader(isDark),
        Expanded(
          child: _buildContent(isDark),
        ),
        _buildCreateButton(isDark),
      ],
    );
  }

  Widget _buildSuccessView(bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animation de succès
            ScaleTransition(
              scale: _successAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pocketColor.withValues(alpha: 0.8), pocketColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pocketColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedCheckmarkCircle01,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            FadeTransition(
              opacity: _successAnimation,
              child: Column(
                children: [
                  Text(
                    'Pocket créé avec succès !',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.text,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'Votre pocket "${widget.name}" a été créé et est prêt à être utilisé.',
                    style: TextStyle(
                      fontSize: 16,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  GestureDetector(
                    onTap: _navigateToPockets,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [pocketColor.withValues(alpha: 0.8), pocketColor],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: pocketColor.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Voir mes pockets',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            HugeIcons.strokeRoundedHome01,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          // Navigation
          Row(
            children: [
              SmartBackButton(
                iconSize: 24,
                onPressed: _isCreating ? null : () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Résumé du Pocket',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDark : AppColors.text,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Message de finalisation
          Text(
            'Vérifiez les informations et créez votre pocket',
            style: TextStyle(
              fontSize: 16,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Aperçu principal du pocket
          _buildMainPocketCard(isDark, pocketColor),
          
          const SizedBox(height: 24),
          
          // Détails du budget
          _buildBudgetDetails(isDark, pocketColor),
          
          const SizedBox(height: 24),
          
          // Dépôt d'épargne initial (si applicable)
          if (widget.wantsInitialDeposit == true && widget.depositAmount != null)
            _buildDepositSection(isDark, pocketColor),
          
          if (widget.wantsInitialDeposit == true && widget.depositAmount != null)
            const SizedBox(height: 24),
          
          // Transactions associées
          if (widget.selectedTransactions.isNotEmpty)
            _buildTransactionsSection(isDark, pocketColor),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMainPocketCard(bool isDark, Color pocketColor) {
    IconData pocketIcon = _getPocketIcon();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pocketColor.withValues(alpha: 0.1),
            pocketColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: pocketColor.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: pocketColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône et nom
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [pocketColor.withValues(alpha: 0.8), pocketColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: pocketColor.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  pocketIcon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              
              const SizedBox(width: 20),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.text,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: pocketColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getCategoryLabel(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: pocketColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        if (widget.savingsGoal != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: pocketColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getSavingsGoalLabel(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: pocketColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Budget principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: pocketColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: pocketColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Budget mensuel',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: pocketColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.budget.toStringAsFixed(0)}€',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: pocketColor,
                    letterSpacing: -1,
                  ),
                ),
                if (widget.isPercentageMode && widget.monthlyIncome > 0) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${widget.budgetValue.toStringAsFixed(0)}% de ${widget.monthlyIncome.toStringAsFixed(0)}€',
                    style: TextStyle(
                      fontSize: 12,
                      color: pocketColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetDetails(bool isDark, Color pocketColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedChart,
                color: pocketColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Détails du budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailRow(
            'Catégorie',
            _getCategoryLabel(),
            isDark,
          ),
          
          _buildDetailRow(
            'Mode de calcul',
            widget.isPercentageMode ? 'Pourcentage' : 'Montant fixe',
            isDark,
          ),
          
          if (widget.isPercentageMode) ...[
            _buildDetailRow(
              'Pourcentage',
              '${widget.budgetValue.toStringAsFixed(0)}%',
              isDark,
            ),
            if (widget.monthlyIncome > 0)
              _buildDetailRow(
                'Revenu mensuel',
                '${widget.monthlyIncome.toStringAsFixed(0)}€',
                isDark,
              ),
          ] else ...[
            _buildDetailRow(
              'Montant fixe',
              '${widget.budget.toStringAsFixed(0)}€',
              isDark,
            ),
          ],
          
          if (widget.savingsGoal != null)
            _buildDetailRow(
              'Type d\'épargne',
              _getSavingsGoalLabel(),
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsSection(bool isDark, Color pocketColor) {
    final totalAmount = widget.selectedTransactions.fold(0.0, (sum, t) => sum + t.amount);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                HugeIcons.strokeRoundedArrowDataTransferHorizontal,
                color: pocketColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Transactions associées',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Résumé
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: pocketColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.selectedTransactions.length} transaction${widget.selectedTransactions.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: pocketColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${totalAmount.toStringAsFixed(2)}€',
                      style: TextStyle(
                        fontSize: 12,
                        color: pocketColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: pocketColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${((totalAmount / widget.budget) * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: pocketColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Liste des transactions (limitée à 3)
          ...widget.selectedTransactions.take(3).map((transaction) => 
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: pocketColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      transaction.title,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${transaction.amount.toStringAsFixed(2)}€',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: pocketColor,
                    ),
                  ),
                ],
              ),
            ),
          ).toList(),
          
          if (widget.selectedTransactions.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              '+${widget.selectedTransactions.length - 3} autres transaction${widget.selectedTransactions.length - 3 > 1 ? 's' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDepositSection(bool isDark, Color pocketColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedMoney01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premier dépôt d\'épargne',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textDark : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Montant qui sera automatiquement épargné',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.green.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Montant principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Montant à épargner',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.depositAmount!.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.green,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Détails du dépôt
          Row(
            children: [
              Expanded(
                child: _buildDepositDetailItem(
                  'Date',
                  _formatDepositDate(widget.depositDate!),
                  HugeIcons.strokeRoundedCalendar03,
                  isDark,
                ),
              ),
              if (widget.depositDescription?.isNotEmpty == true) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildDepositDetailItem(
                    'Description',
                    widget.depositDescription!,
                    HugeIcons.strokeRoundedNote,
                    isDark,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDepositDetailItem(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: AppColors.green,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDark : AppColors.text,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatDepositDate(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCreateButton(bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isCreating ? 0.7 : 1.0,
        child: GestureDetector(
          onTap: _isCreating ? null : _createPocket,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: _isCreating 
                  ? null
                  : LinearGradient(
                      colors: [pocketColor.withValues(alpha: 0.8), pocketColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: _isCreating 
                  ? (isDark ? AppColors.borderDark : AppColors.border)
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isCreating ? null : [
                BoxShadow(
                  color: pocketColor.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _isCreating
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.textDark : AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Création en cours...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textDark : AppColors.text,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        (widget.wantsInitialDeposit == true && widget.depositAmount != null)
                            ? 'Créer le pocket et épargner'
                            : 'Créer le pocket',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        (widget.wantsInitialDeposit == true && widget.depositAmount != null)
                            ? HugeIcons.strokeRoundedMoney01
                            : HugeIcons.strokeRoundedAdd01,
                        color: Colors.white,
                        size: 22,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  IconData _getPocketIcon() {
    switch (widget.icon) {
      case 'home':
        return HugeIcons.strokeRoundedHome01;
      case 'shopping':
        return HugeIcons.strokeRoundedShoppingCart01;
      case 'car':
        return HugeIcons.strokeRoundedCar01;
      case 'health':
        return HugeIcons.strokeRoundedHeartCheck;
      case 'bills':
        return HugeIcons.strokeRoundedInvoice01;
      case 'phone':
        return HugeIcons.strokeRoundedSmartPhone01;
      case 'restaurant':
        return HugeIcons.strokeRoundedRestaurant01;
      case 'entertainment':
        return HugeIcons.strokeRoundedGameController01;
      case 'shopping_bag':
        return HugeIcons.strokeRoundedShoppingBag01;
      case 'travel':
        return HugeIcons.strokeRoundedAirplane01;
      case 'sport':
        return HugeIcons.strokeRoundedFootball;
      case 'music':
        return HugeIcons.strokeRoundedMusicNote01;
      case 'piggy_bank':
        return HugeIcons.strokeRoundedTarget01;
      case 'emergency':
        return HugeIcons.strokeRoundedShield01;
      case 'vacation':
        return HugeIcons.strokeRoundedBeach;
      case 'investment':
        return HugeIcons.strokeRoundedTradeMark;
      case 'house_project':
        return HugeIcons.strokeRoundedBuilding01;
      case 'education':
        return HugeIcons.strokeRoundedBook01;
      default:
        return HugeIcons.strokeRoundedWallet01;
    }
  }

  String _getCategoryLabel() {
    switch (widget.category) {
      case PocketType.needs:
        return 'Besoins essentiels (50%)';
      case PocketType.wants:
        return 'Envies & Loisirs (30%)';
      case PocketType.savings:
        return 'Épargne & Objectifs (20%)';
      case PocketType.custom:
        return 'Personnalisé';
    }
  }

  String _getSavingsGoalLabel() {
    if (widget.savingsGoal == null) return '';
    
    switch (widget.savingsGoal!) {
      case SavingsGoalType.emergency:
        return 'Fonds d\'urgence';
      case SavingsGoalType.vacation:
        return 'Vacances';
      case SavingsGoalType.house:
        return 'Immobilier';
      case SavingsGoalType.car:
        return 'Véhicule';
      case SavingsGoalType.investment:
        return 'Investissement';
      case SavingsGoalType.retirement:
        return 'Retraite';
      case SavingsGoalType.education:
        return 'Formation';
      case SavingsGoalType.other:
        return 'Autre';
    }
  }

  void _createPocket() async {
    setState(() {
      _isCreating = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Créer vraiment le pocket
      await _createPocketInDatabase();

      setState(() {
        _isCreating = false;
        _isSuccess = true;
      });

      // Démarrer l'animation de succès
      _successAnimationController.forward();

      // Afficher une notification de succès
      final hasDeposit = widget.wantsInitialDeposit == true && widget.depositAmount != null;
      AppNotification.success(
        context,
        title: hasDeposit ? 'Pocket créé et épargne ajoutée !' : 'Pocket créé !',
        subtitle: hasDeposit 
            ? 'Votre pocket "${widget.name}" avec ${widget.depositAmount!.toStringAsFixed(2)}€ d\'épargne est disponible'
            : 'Votre pocket "${widget.name}" est maintenant disponible',
      );

      // Retourner à la page des pockets après 3 secondes
      Future.delayed(const Duration(seconds: 3), () {
        _navigateToPockets();
      });

    } catch (e) {
      setState(() {
        _isCreating = false;
      });

      AppNotification.error(
        context,
        title: 'Erreur',
        subtitle: 'Impossible de créer le pocket. Veuillez réessayer.',
      );
    }
  }

  void _navigateToPockets() {
    // Retourner à la page des pockets
    Navigator.of(context).popUntil((route) => route.settings.name == '/pockets' || route.isFirst);
  }

  // Créer le pocket dans la base de données
  Future<void> _createPocketInDatabase() async {
    // Validation des données
    if (widget.name.trim().isEmpty) {
      throw Exception('Le nom du pocket ne peut pas être vide');
    }
    
    if (widget.budget <= 0) {
      throw Exception('Le budget doit être supérieur à 0');
    }
    // Préparer la liste des transactions (inclut les transactions sélectionnées + dépôt d'épargne)
    List<PocketTransaction> pocketTransactions = widget.selectedTransactions
        .map((t) => PocketTransaction.fromTransaction(t))
        .toList();

    // Ajouter la transaction d'épargne si applicable
    if (widget.wantsInitialDeposit == true && widget.depositAmount != null) {
      final savingsTransaction = Transaction(
        id: 'savings_${DateTime.now().millisecondsSinceEpoch}',
        title: widget.depositDescription?.isNotEmpty == true 
            ? widget.depositDescription!
            : 'Dépôt d\'épargne initial - ${widget.name}',
        amount: widget.depositAmount!,
        date: widget.depositDate!,
        type: TransactionType.savings_deposit,
        categoryId: 'savings_${widget.category.toString()}',
        description: 'Dépôt d\'épargne automatique pour ${widget.name}',
        recurrence: RecurrenceType.none,
      );
      
      final savingsPocketTransaction = PocketTransaction(
        id: 'spt_${DateTime.now().millisecondsSinceEpoch}',
        title: savingsTransaction.title,
        amount: savingsTransaction.amount,
        date: savingsTransaction.date,
        description: savingsTransaction.description,
        categoryId: savingsTransaction.categoryId,
        transactionId: savingsTransaction.id,
        type: TransactionType.savings_deposit,
      );
      
      pocketTransactions.add(savingsPocketTransaction);
    }

    // Créer l'objet Pocket
    final newPocket = Pocket(
      id: 'pocket_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.name,
      icon: widget.icon,
      color: widget.color,
      budget: widget.budget,
      spent: pocketTransactions.fold(0.0, (sum, t) => sum + t.amount),
      createdAt: DateTime.now(),
      type: widget.category,
      savingsGoalType: widget.savingsGoal,
      transactions: pocketTransactions,
    );

    // Sauvegarder le pocket sur Supabase
    final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
    final userId = authStateManager.currentUser?.id.value;
    
    if (userId != null) {
      final syncService = SupabaseSyncService(Supabase.instance.client);
      await syncService.createAndSyncPocket(
        userId: userId,
        pocket: newPocket,
      );
      print('✅ Pocket "${widget.name}" créé et synchronisé avec Supabase');
      
      // Mettre à jour le provider local
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.forceSyncFromSupabase();
      
      // La synchronisation du TransactionProvider suffit
      
    } else {
      print('⚠️ Utilisateur non connecté, pocket créé localement uniquement');
      throw Exception('Utilisateur non connecté');
    }
  }


} 