import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../widgets/modern_animations.dart';
import '../../data/models/pocket.dart';
import '../../data/models/transaction.dart';
import 'package:hugeicons/hugeicons.dart';
import 'pocket_savings_deposit_page.dart';
import 'pocket_transactions_page.dart';

class PocketBudgetPage extends StatefulWidget {
  final PocketType category;
  final String name;
  final String icon;
  final String color;
  final SavingsGoalType? savingsGoal;

  const PocketBudgetPage({
    super.key,
    required this.category,
    required this.name,
    required this.icon,
    required this.color,
    this.savingsGoal,
  });

  @override
  State<PocketBudgetPage> createState() => _PocketBudgetPageState();
}

class _PocketBudgetPageState extends State<PocketBudgetPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _monthlyIncomeController = TextEditingController();
  final FocusNode _budgetFocusNode = FocusNode();
  final FocusNode _incomeFocusNode = FocusNode();
  
  bool _isPercentageMode = true;
  double? _suggestedAmount;
  double _monthlyIncome = 0.0;
  
  // Pourcentages recommandés selon la méthode 50/30/20
  double get _recommendedPercentage {
    switch (widget.category) {
      case PocketType.needs:
        return 50.0;
      case PocketType.wants:
        return 30.0;
      case PocketType.savings:
        return 20.0;
      case PocketType.custom:
        return 10.0;
    }
  }

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
    
    // Initialiser avec le pourcentage recommandé
    _budgetController.text = _recommendedPercentage.toInt().toString();
    
    // Démarrer l'animation
    _animationController.forward();
    
    // Écouter les changements
    _budgetController.addListener(_calculateSuggestion);
    _monthlyIncomeController.addListener(_calculateSuggestion);
  }
  
  void _calculateSuggestion() {
    final income = double.tryParse(_monthlyIncomeController.text) ?? 0.0;
    final budget = double.tryParse(_budgetController.text) ?? 0.0;
    
    setState(() {
      _monthlyIncome = income;
      if (_isPercentageMode && income > 0) {
        _suggestedAmount = income * (budget / 100);
      } else if (!_isPercentageMode && income > 0) {
        _suggestedAmount = (budget / income) * 100;
      } else {
        _suggestedAmount = null;
      }
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _budgetController.dispose();
    _monthlyIncomeController.dispose();
    _budgetFocusNode.dispose();
    _incomeFocusNode.dispose();
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
          'Définissez votre budget',
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
          'Configurez le montant selon la méthode 50/30/20',
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
          
          const SizedBox(height: 24),
          
          // Contenu principal
          _buildContent(isDark),
          
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
                '3',
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
                  'Étape 3 sur 4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Définition du budget',
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
              color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.75, // 3/4 = 75%
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final pocketColor = Color(int.parse(widget.color.substring(1), radix: 16) + 0xFF000000);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Aperçu du pocket
        _buildPocketPreview(isDark, pocketColor),
        
        const SizedBox(height: 32),
        
        // Information sur la méthode 50/30/20
        _buildMethodInfo(isDark, pocketColor),
        
        const SizedBox(height: 32),
        
        // Section revenu mensuel (optionnel)
        _buildIncomeSection(isDark),
        
        const SizedBox(height: 32),
        
        // Sélecteur de mode (pourcentage vs montant)
        _buildModeSelector(isDark),
        
        const SizedBox(height: 24),
        
        // Saisie du budget
        _buildBudgetInput(isDark, pocketColor),
        
        const SizedBox(height: 24),
        
        // Calculs et suggestions
        if (_suggestedAmount != null)
          _buildSuggestion(isDark, pocketColor),
      ],
    );
  }

  Widget _buildPocketPreview(bool isDark, Color pocketColor) {
    IconData pocketIcon;
    switch (widget.icon) {
      case 'home':
        pocketIcon = HugeIcons.strokeRoundedHome01;
        break;
      case 'shopping':
        pocketIcon = HugeIcons.strokeRoundedShoppingCart01;
        break;
      case 'car':
        pocketIcon = HugeIcons.strokeRoundedCar01;
        break;
      case 'restaurant':
        pocketIcon = HugeIcons.strokeRoundedRestaurant01;
        break;
      case 'entertainment':
        pocketIcon = HugeIcons.strokeRoundedGameController01;
        break;
      case 'shopping_bag':
        pocketIcon = HugeIcons.strokeRoundedShoppingBag01;
        break;
      case 'piggy_bank':
        pocketIcon = HugeIcons.strokeRoundedTarget01;
        break;
      case 'emergency':
        pocketIcon = HugeIcons.strokeRoundedShield01;
        break;
      case 'vacation':
        pocketIcon = HugeIcons.strokeRoundedBeach;
        break;
      default:
        pocketIcon = HugeIcons.strokeRoundedWallet01;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pocketColor.withValues(alpha: 0.1),
            pocketColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: pocketColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
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
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              pocketIcon,
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
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pocketColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.category.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: pocketColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (widget.savingsGoal != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: pocketColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.savingsGoal!.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: pocketColor,
                            letterSpacing: 0.5,
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
    );
  }

  Widget _buildMethodInfo(bool isDark, Color pocketColor) {
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
              Icon(
                HugeIcons.strokeRoundedIdea,
                color: pocketColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Méthode 50/30/20',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: pocketColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'Pour ${widget.category.name}, nous recommandons ${_recommendedPercentage.toInt()}% de votre revenu mensuel.',
            style: TextStyle(
              fontSize: 14,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildMethodItem('50%', 'Besoins', widget.category == PocketType.needs, isDark),
              const SizedBox(width: 12),
              _buildMethodItem('30%', 'Envies', widget.category == PocketType.wants, isDark),
              const SizedBox(width: 12),
              _buildMethodItem('20%', 'Épargne', widget.category == PocketType.savings, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodItem(String percentage, String label, bool isActive, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive 
                ? AppColors.primary 
                : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              percentage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.primary : (isDark ? AppColors.textDark : AppColors.text),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isActive 
                    ? AppColors.primary 
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenu mensuel (optionnel)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Indiquez votre revenu pour des suggestions personnalisées',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.8),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextField(
          controller: _monthlyIncomeController,
          focusNode: _incomeFocusNode,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: '0',
            suffixText: '€ / mois',
            suffixStyle: TextStyle(
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withOpacity(0.7),
            ),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5),
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

  Widget _buildModeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mode de saisie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isDark ? AppColors.borderDark : AppColors.border).withOpacity(0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isPercentageMode = true;
                      _budgetController.text = _recommendedPercentage.toInt().toString();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _isPercentageMode ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Pourcentage (%)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _isPercentageMode 
                            ? Colors.white 
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _isPercentageMode = false;
                      _budgetController.clear();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_isPercentageMode ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Montant fixe (€)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: !_isPercentageMode 
                            ? Colors.white 
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetInput(bool isDark, Color pocketColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isPercentageMode ? 'Pourcentage du revenu' : 'Montant mensuel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextField(
          controller: _budgetController,
          focusNode: _budgetFocusNode,
          keyboardType: TextInputType.number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: pocketColor,
          ),
          decoration: InputDecoration(
            hintText: _isPercentageMode ? '${_recommendedPercentage.toInt()}' : '0',
            suffixText: _isPercentageMode ? '%' : '€',
            suffixStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: pocketColor,
            ),
            filled: true,
            fillColor: pocketColor.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: pocketColor.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: pocketColor.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: pocketColor,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestion(bool isDark, Color pocketColor) {
    final isPercentageSuggestion = !_isPercentageMode && _monthlyIncome > 0;
    final suggestionText = isPercentageSuggestion
        ? 'Soit ${_suggestedAmount!.toStringAsFixed(1)}% de votre revenu'
        : 'Soit ${_suggestedAmount!.toStringAsFixed(0)}€ par mois';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pocketColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: pocketColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            HugeIcons.strokeRoundedCalculator,
            color: pocketColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              suggestionText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: pocketColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = _budgetController.text.trim().isNotEmpty;
    
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
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: canContinue ? null : (isDark ? AppColors.borderDark : AppColors.border),
              borderRadius: BorderRadius.circular(28),
              boxShadow: canContinue
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
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
                  'Continuer',
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

  void _continue() {
    final budgetText = _budgetController.text.trim();
    if (budgetText.isEmpty) return;
    
    final budgetValue = double.tryParse(budgetText);
    if (budgetValue == null || budgetValue <= 0) {
      // Afficher une erreur
      return;
    }
    
    // Calculer le budget final en euros
    double finalBudget;
    if (_isPercentageMode && _monthlyIncome > 0) {
      finalBudget = _monthlyIncome * (budgetValue / 100);
    } else if (!_isPercentageMode) {
      finalBudget = budgetValue;
    } else {
      // Mode pourcentage mais pas de revenu renseigné, on garde le pourcentage
      finalBudget = budgetValue; // À ajuster selon la logique métier
    }
    
    HapticFeedback.mediumImpact();
    
    // Pour les pockets d'épargne, on saute l'étape des transactions et on va directement au dépôt d'épargne
    // Pour les autres pockets, on va à l'étape des transactions
    if (widget.category == PocketType.savings) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketSavingsDepositPage(
            category: widget.category,
            name: widget.name,
            icon: widget.icon,
            color: widget.color,
            budget: finalBudget,
            isPercentageMode: _isPercentageMode,
            budgetValue: budgetValue,
            monthlyIncome: _monthlyIncome,
            savingsGoal: widget.savingsGoal,
            selectedTransactions: <Transaction>[], // Liste vide pour les épargnes
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PocketTransactionsPage(
            category: widget.category,
            name: widget.name,
            icon: widget.icon,
            color: widget.color,
            budget: finalBudget,
            isPercentageMode: _isPercentageMode,
            budgetValue: budgetValue,
            monthlyIncome: _monthlyIncome,
            savingsGoal: widget.savingsGoal,
          ),
        ),
      );
    }
  }
} 