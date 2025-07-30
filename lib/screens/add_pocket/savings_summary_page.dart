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

class SavingsSummaryPage extends StatefulWidget {
  final String name;
  final String icon;
  final SavingsGoalType? savingsGoal;
  final double? targetAmount;
  final DateTime? targetDate;
  final double monthlyBudget;
  final bool? wantsInitialDeposit;
  final double? depositAmount;
  final DateTime? depositDate;
  final String? depositDescription;

  const SavingsSummaryPage({
    super.key,
    required this.name,
    required this.icon,
    this.savingsGoal,
    this.targetAmount,
    this.targetDate,
    required this.monthlyBudget,
    this.wantsInitialDeposit,
    this.depositAmount,
    this.depositDate,
    this.depositDescription,
  });

  @override
  State<SavingsSummaryPage> createState() => _SavingsSummaryPageState();
}

class _SavingsSummaryPageState extends State<SavingsSummaryPage>
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
    
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
    );
    
    _successAnimation = CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.elasticOut,
    );
    
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
        child: _isSuccess 
            ? _buildSuccessView(isDark)
            : Column(
                children: [
                  // Contenu principal
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildScrollableContent(isDark),
                    ),
                  ),
                  
                  // Bouton créer
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildCreateButton(isDark),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildScrollableContent(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header
          _buildHeaderContent(isDark),
          
          const SizedBox(height: 32),
          
          // Carte principale de résumé
          ScaleTransition(
            scale: _scaleAnimation,
            child: _buildMainSummaryCard(isDark),
          ),
          
          const SizedBox(height: 24),
          
          // Détails de l'épargne
          _buildSavingsDetails(isDark),
          
          const SizedBox(height: 24),
          
          // Dépôt initial (si configuré)
          if (widget.wantsInitialDeposit == true && widget.depositAmount != null)
            _buildInitialDepositCard(isDark),
          
          const SizedBox(height: 32),
        ],
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
                  'Résumé',
                  style: TextStyle(
                    fontSize: 20,
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
        
        const SizedBox(height: 20),
        
        // Titre principal avec icône
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle01,
                color: AppColors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Prêt à créer !',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Étape 5 sur 5',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Vérifiez les détails de votre épargne avant de la créer',
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

  Widget _buildMainSummaryCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green, AppColors.green.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône et nom
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: _getSavingsIcon(),
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      _getSavingsGoalLabel(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Montants principaux
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budget mensuel',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.monthlyBudget.toStringAsFixed(0)}€',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              if (widget.targetAmount != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Objectif total',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.targetAmount!.toStringAsFixed(0)}€',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          // Date limite si définie
          if (widget.targetDate != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedCalendar03,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Objectif à atteindre le ${_formatDate(widget.targetDate!)}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingsDetails(bool isDark) {
    final monthsToTarget = widget.targetAmount != null && widget.targetDate != null
        ? (widget.targetDate!.difference(DateTime.now()).inDays / 30).ceil()
        : null;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedCalculator01,
                color: AppColors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Détails de l\'épargne',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Répartition par année
          _buildDetailRow(
            'Épargne annuelle',
            '${(widget.monthlyBudget * 12).toStringAsFixed(0)}€',
            isDark,
          ),
          
          if (monthsToTarget != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Durée estimée',
              '$monthsToTarget mois',
              isDark,
            ),
          ],
          
          if (widget.targetAmount != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              'Progression mensuelle',
              '${((widget.monthlyBudget / widget.targetAmount!) * 100).toStringAsFixed(1)}%',
              isDark,
            ),
          ],
          
          const SizedBox(height: 12),
          _buildDetailRow(
            'Type d\'épargne',
            'Épargne & Objectifs (20%)',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Row(
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
    );
  }

  Widget _buildInitialDepositCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.green.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedMoneyAdd01,
                color: AppColors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Dépôt initial',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Montant',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.depositAmount!.toStringAsFixed(0)}€',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ],
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(widget.depositDate!),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textDark : AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          if (widget.depositDescription?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              widget.depositDescription!,
              style: TextStyle(
                fontSize: 14,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCreateButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: _isCreating ? 0.7 : 1.0,
        child: GestureDetector(
          onTap: _isCreating ? null : _createSavingsPocket,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.green, AppColors.green.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isCreating) ...[
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Création en cours...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Créer mon épargne',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    HugeIcons.strokeRoundedTarget01,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
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
                  color: AppColors.green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Épargne créée !',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textDark : AppColors.text,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Votre épargne "${widget.name}" a été créée avec succès.\nVous pouvez maintenant commencer à épargner !',
              style: TextStyle(
                fontSize: 16,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Bouton pour retourner à l'accueil
            GestureDetector(
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.green, AppColors.green.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Retour à l\'accueil',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
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
    );
  }

  IconData _getSavingsIcon() {
    switch (widget.icon) {
      case 'piggy_bank':
        return HugeIcons.strokeRoundedTarget01;
      case 'emergency':
        return HugeIcons.strokeRoundedShield01;
      case 'vacation':
        return HugeIcons.strokeRoundedBeach;
      case 'house':
        return HugeIcons.strokeRoundedBuilding01;
      case 'car':
        return HugeIcons.strokeRoundedCar01;
      case 'education':
        return HugeIcons.strokeRoundedBook01;
      case 'investment':
        return HugeIcons.strokeRoundedTradeMark;
      case 'travel':
        return HugeIcons.strokeRoundedAirplane01;
      case 'wedding':
        return HugeIcons.strokeRoundedHeartCheck;
      default:
        return HugeIcons.strokeRoundedTarget01;
    }
  }

  String _getSavingsGoalLabel() {
    if (widget.savingsGoal == null) return 'Épargne personnalisée';
    
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
        return 'Autre objectif';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _createSavingsPocket() async {
    setState(() {
      _isCreating = true;
    });

    HapticFeedback.mediumImpact();

    try {
      // Créer vraiment l'épargne
      await _createSavingsPocketInDatabase();

      // Animation de succès
      setState(() {
        _isCreating = false;
        _isSuccess = true;
      });
      
      _successAnimationController.forward();

      // Afficher une notification de succès
      AppNotification.success(
        context,
        title: 'Épargne créée !',
        subtitle: 'Votre épargne "${widget.name}" est prête',
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
        subtitle: 'Impossible de créer l\'épargne: $e',
      );
    }
  }

  // Créer l'épargne dans la base de données
  Future<void> _createSavingsPocketInDatabase() async {
    // Validation des données
    if (widget.name.trim().isEmpty) {
      throw Exception('Le nom de l\'épargne ne peut pas être vide');
    }
    
    if (widget.monthlyBudget <= 0) {
      throw Exception('Le budget mensuel doit être supérieur à 0');
    }
    // Préparer la liste des transactions (dépôt initial si configuré)
    List<PocketTransaction> pocketTransactions = [];

    // Ajouter le dépôt initial si configuré
    if (widget.wantsInitialDeposit == true && widget.depositAmount != null) {
      final initialDeposit = PocketTransaction(
        id: 'spt_${DateTime.now().millisecondsSinceEpoch}',
        title: widget.depositDescription?.isNotEmpty == true 
            ? widget.depositDescription!
            : 'Dépôt initial - ${widget.name}',
        amount: widget.depositAmount!,
        date: widget.depositDate!,
        description: 'Dépôt d\'épargne initial pour ${widget.name}',
        type: TransactionType.savings_deposit,
      );
      
      pocketTransactions.add(initialDeposit);
    }

    // Créer l'objet Pocket d'épargne
    final newSavingsPocket = Pocket(
      id: 'savings_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.name,
      icon: widget.icon,
      color: '#10B981', // Vert pour l'épargne
      budget: widget.monthlyBudget,
      spent: widget.depositAmount ?? 0.0, // Pour l'épargne, "spent" = montant épargné
      createdAt: DateTime.now(),
      type: PocketType.savings,
      savingsGoalType: widget.savingsGoal,
      targetAmount: widget.targetAmount,
      targetDate: widget.targetDate,
      transactions: pocketTransactions,
    );

    debugPrint('Nouvelle épargne créée: ${newSavingsPocket.name}');
    debugPrint('Budget mensuel: ${newSavingsPocket.budget}€');
    if (newSavingsPocket.targetAmount != null) {
      debugPrint('Objectif: ${newSavingsPocket.targetAmount}€');
    }
    debugPrint('Transactions: ${newSavingsPocket.transactions.length}');

    // Sauvegarder l'épargne sur Supabase
    final authStateManager = Provider.of<AuthStateManager>(context, listen: false);
    final userId = authStateManager.currentUser?.id.value;
    
    if (userId != null) {
      final syncService = SupabaseSyncService(Supabase.instance.client);
      await syncService.createAndSyncPocket(
        userId: userId,
        pocket: newSavingsPocket,
      );
      print('✅ Épargne "${widget.name}" créée et synchronisée avec Supabase');
      
      // Mettre à jour le provider local
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.forceSyncFromSupabase();
      
      // La synchronisation du TransactionProvider suffit
      
    } else {
      print('⚠️ Utilisateur non connecté, épargne créée localement uniquement');
      throw Exception('Utilisateur non connecté');
    }
  }

  void _navigateToPockets() {
    // Retourner à la page des pockets
    Navigator.of(context).popUntil((route) => route.settings.name == '/pockets' || route.isFirst);
  }


} 