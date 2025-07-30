import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import '../../data/models/transaction.dart';
import '../../widgets/modern_animations.dart';
import 'pocket_summary_page.dart';

class PocketSavingsDepositPage extends StatefulWidget {
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

  const PocketSavingsDepositPage({
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
  });

  @override
  State<PocketSavingsDepositPage> createState() => _PocketSavingsDepositPageState();
}

class _PocketSavingsDepositPageState extends State<PocketSavingsDepositPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  
  DateTime _selectedDate = DateTime.now();
  bool _wantsToAddDeposit = false;

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
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocusNode.dispose();
    _descriptionFocusNode.dispose();
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
          'Premier dépôt d\'épargne',
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
          'Souhaitez-vous ajouter un montant à cette Pocket\nd\'épargne dès maintenant ?',
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Header intégré dans le scroll
          _buildHeaderContent(isDark),
          
          const SizedBox(height: 20),
          
          // Indicateur de progression
          _buildProgressIndicator(isDark),
          
          const SizedBox(height: 32),
          
          // Aperçu de la pocket
          _buildPocketPreview(isDark),
          
          const SizedBox(height: 32),
          
          // Question principale
          _buildDepositQuestion(isDark),
          
          const SizedBox(height: 24),
          
          // Formulaire conditionnel
          if (_wantsToAddDeposit) ...[
            _buildDepositForm(isDark),
            const SizedBox(height: 32),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
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
                '5',
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
                  'Étape 5 sur 5',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Premier dépôt (optionnel)',
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

  Widget _buildPocketPreview(bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: pocketColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pocketColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: pocketColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconData(widget.icon),
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Budget: ${widget.budget.toStringAsFixed(2)}€',
                  style: TextStyle(
                    fontSize: 14,
                    color: pocketColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.savingsGoal != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    _getSavingsGoalLabel(widget.savingsGoal!),
                    style: TextStyle(
                      fontSize: 12,
                      color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
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

  Widget _buildDepositQuestion(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              Icon(
                HugeIcons.strokeRoundedMoney01,
                size: 48,
                color: AppColors.green,
              ),
              const SizedBox(height: 16),
              Text(
                'Ajouter un premier montant ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textDark : AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vous pouvez directement épargner un montant dans cette pocket pour bien commencer !',
                style: TextStyle(
                  fontSize: 14,
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _wantsToAddDeposit = false;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: !_wantsToAddDeposit 
                              ? AppColors.primary 
                              : (isDark ? AppColors.surfaceDark : AppColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: !_wantsToAddDeposit 
                                ? AppColors.primary
                                : (isDark ? AppColors.borderDark : AppColors.border),
                          ),
                        ),
                        child: Text(
                          'Non, plus tard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: !_wantsToAddDeposit 
                                ? Colors.white
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _wantsToAddDeposit = true;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _wantsToAddDeposit 
                              ? AppColors.green 
                              : (isDark ? AppColors.surfaceDark : AppColors.surface),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _wantsToAddDeposit 
                                ? AppColors.green
                                : (isDark ? AppColors.borderDark : AppColors.border),
                          ),
                        ),
                        child: Text(
                          'Oui, ajouter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _wantsToAddDeposit 
                                ? Colors.white
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepositForm(bool isDark) {
    return SlideInAnimation(
      delay: const Duration(milliseconds: 300),
      beginOffset: const Offset(0, 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          _buildAmountField(isDark),
          
          const SizedBox(height: 24),
          
          // Date
          _buildDateField(isDark),
          
          const SizedBox(height: 24),
          
          // Description optionnelle
          _buildDescriptionField(isDark),
        ],
      ),
    );
  }

  Widget _buildAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Montant à épargner',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _amountController,
          focusNode: _amountFocusNode,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.green,
          ),
          decoration: InputDecoration(
            hintText: '0.00',
            suffixText: '€',
            suffixStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.green,
            ),
            filled: true,
            fillColor: AppColors.green.withValues(alpha: 0.1),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.green.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.green.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.green,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date du dépôt',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _selectDate(isDark),
          child: Container(
            width: double.infinity,
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
                Icon(
                  HugeIcons.strokeRoundedCalendar03,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatDate(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const Spacer(),
                Icon(
                  HugeIcons.strokeRoundedArrowDown01,
                  color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (optionnelle)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descriptionController,
          focusNode: _descriptionFocusNode,
          maxLines: 3,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Note ou mémo personnel...',
            hintStyle: TextStyle(
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.6),
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = true; // Toujours possible de continuer (avec ou sans dépôt)
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canContinue ? 1.0 : 0.5,
        child: GestureDetector(
          onTap: canContinue ? _continue : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: canContinue
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: canContinue ? null : (isDark ? AppColors.borderDark : AppColors.border),
              borderRadius: BorderRadius.circular(28),
              boxShadow: canContinue
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _wantsToAddDeposit ? 'Créer la Pocket et épargner' : 'Créer la Pocket',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: canContinue ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  HugeIcons.strokeRoundedArrowRight01,
                  color: canContinue ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _selectDate(bool isDark) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  IconData _getIconData(String iconId) {
    // Map des icônes similaire à celui dans pocket_details_page.dart
    switch (iconId) {
      case 'home':
        return HugeIcons.strokeRoundedHome01;
      case 'wallet':
        return HugeIcons.strokeRoundedWallet01;
      case 'car':
        return HugeIcons.strokeRoundedCar01;
      case 'plane':
        return HugeIcons.strokeRoundedAirplane01;
      case 'target':
        return HugeIcons.strokeRoundedTarget01;
      case 'money':
        return HugeIcons.strokeRoundedMoney01;
      default:
        return HugeIcons.strokeRoundedWallet01;
    }
  }

  String _getSavingsGoalLabel(SavingsGoalType goal) {
    switch (goal) {
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

  void _continue() {
    HapticFeedback.mediumImpact();
    
    // Valider le montant si l'utilisateur veut ajouter un dépôt
    if (_wantsToAddDeposit) {
      final amountText = _amountController.text.trim();
      if (amountText.isEmpty) {
        // Afficher une erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un montant'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
      
      final amount = double.tryParse(amountText);
      if (amount == null || amount <= 0) {
        // Afficher une erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veuillez saisir un montant valide'),
            backgroundColor: AppColors.red,
          ),
        );
        return;
      }
    }
    
    // Naviguer vers le résumé final avec les informations du dépôt
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
          wantsInitialDeposit: _wantsToAddDeposit,
          depositAmount: _wantsToAddDeposit ? double.tryParse(_amountController.text.trim()) : null,
          depositDate: _wantsToAddDeposit ? _selectedDate : null,
          depositDescription: _wantsToAddDeposit ? _descriptionController.text.trim() : null,
          selectedTransactions: widget.selectedTransactions,
        ),
      ),
    );
  }
} 