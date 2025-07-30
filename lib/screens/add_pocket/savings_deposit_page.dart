import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';
import 'savings_summary_page.dart';

class SavingsDepositPage extends StatefulWidget {
  final String name;
  final String icon;
  final SavingsGoalType? savingsGoal;
  final double? targetAmount;
  final DateTime? targetDate;
  final double monthlyBudget;

  const SavingsDepositPage({
    super.key,
    required this.name,
    required this.icon,
    this.savingsGoal,
    this.targetAmount,
    this.targetDate,
    required this.monthlyBudget,
  });

  @override
  State<SavingsDepositPage> createState() => _SavingsDepositPageState();
}

class _SavingsDepositPageState extends State<SavingsDepositPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _switchAnimation;
  
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();
  
  bool _makeInitialDeposit = false;
  DateTime _selectedDate = DateTime.now();

  // Cache des gradients optimisé (const)
  static const Map<SavingsGoalType, List<Color>> _goalGradientsCache = {
    SavingsGoalType.emergency: [Color(0xFFDC2626), Color(0xFFF59E0B)],
    SavingsGoalType.vacation: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    SavingsGoalType.house: [Color(0xFF059669), Color(0xFF10B981)],
    SavingsGoalType.car: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    SavingsGoalType.investment: [Color(0xFF7C2D12), Color(0xFFEA580C)],
    SavingsGoalType.education: [Color(0xFF0891B2), Color(0xFF06B6D4)],
  };

  // Méthode optimisée pour obtenir le gradient
  List<Color> _getCurrentGradient() {
    return _goalGradientsCache[widget.savingsGoal] ?? 
           const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  }

  @override
  void initState() {
    super.initState();
    
    // Optimisation: Un seul AnimationController
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800), // Durée réduite
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve simple
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    
    _switchAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
    
    // Démarrer l'animation une fois
    _animationController.forward();
    
    // Pré-remplir la description
    _descriptionController.text = 'Dépôt initial pour ${widget.name}';
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
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Contenu principal optimisé
          SafeArea(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _slideAnimation.value) * 30),
                    child: _buildContent(isDark),
                  ),
                );
              },
            ),
          ),
          
          // Bouton continuer optimisé
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: _buildContinueButton(isDark),
          ),
        ],
      ),
    );
  }

  // Widget content séparé pour éviter les rebuilds
  Widget _buildContent(bool isDark) {
    final gradient = _getCurrentGradient();
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header simple (const optimisé)
            _HeaderWidget(isDark: isDark),
            
            const SizedBox(height: 24),
            
            // Carte info du projet
            _ProjectInfoCard(
              name: widget.name,
              icon: widget.icon,
              monthlyBudget: widget.monthlyBudget,
              gradient: gradient,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Carte options de dépôt
            _DepositOptionsCard(
              makeInitialDeposit: _makeInitialDeposit,
              onToggleDeposit: _onToggleDeposit,
              gradient: gradient,
              isDark: isDark,
            ),
            
            // Détails du dépôt (conditionnel)
            if (_makeInitialDeposit) ...[
              const SizedBox(height: 24),
              
              // Montant du dépôt
              _DepositAmountCard(
                amountController: _amountController,
                amountFocusNode: _amountFocusNode,
                monthlyBudget: widget.monthlyBudget,
                gradient: gradient,
                isDark: isDark,
              ),
              
              const SizedBox(height: 24),
              
              // Suggestions de montant
              _SuggestionsCard(
                monthlyBudget: widget.monthlyBudget,
                amountController: _amountController,
                gradient: gradient,
                isDark: isDark,
              ),
              
              const SizedBox(height: 24),
              
              // Date et description
              _DepositDetailsCard(
                descriptionController: _descriptionController,
                descriptionFocusNode: _descriptionFocusNode,
                selectedDate: _selectedDate,
                onDateChanged: _onDateChanged,
                gradient: gradient,
                isDark: isDark,
              ),
            ],
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final gradient = _getCurrentGradient();
    
    return ValueListenableBuilder<bool>(
      valueListenable: ValueNotifier(_makeInitialDeposit),
      builder: (context, makeDeposit, child) {
        final canContinue = !makeDeposit || 
                           (_amountController.text.trim().isNotEmpty &&
                            double.tryParse(_amountController.text) != null &&
                            double.parse(_amountController.text) > 0);
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: canContinue
                ? LinearGradient(colors: gradient)
                : null,
            color: !canContinue
                ? (isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05))
                : null,
            borderRadius: BorderRadius.circular(28),
            boxShadow: canContinue ? [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: canContinue ? _continue : null,
              borderRadius: BorderRadius.circular(28),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continuer',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: canContinue 
                          ? Colors.white 
                          : (isDark 
                              ? Colors.white.withValues(alpha: 0.4)
                              : const Color(0xFF94A3B8)),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      color: canContinue 
                        ? Colors.white 
                        : (isDark 
                            ? Colors.white.withValues(alpha: 0.4)
                            : const Color(0xFF94A3B8)),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconFromId(String iconId) {
    switch (iconId) {
      case 'piggy_bank': return HugeIcons.strokeRoundedTarget01;
      case 'emergency': return HugeIcons.strokeRoundedShield01;
      case 'vacation': return HugeIcons.strokeRoundedBeach;
      case 'house': return HugeIcons.strokeRoundedBuilding01;
      case 'car': return HugeIcons.strokeRoundedCar01;
      case 'education': return HugeIcons.strokeRoundedBook01;
      case 'investment': return HugeIcons.strokeRoundedTradeMark;
      case 'travel': return HugeIcons.strokeRoundedAirplane01;
      case 'wedding': return HugeIcons.strokeRoundedHeartCheck;
      default: return HugeIcons.strokeRoundedTarget01;
    }
  }

  void _onToggleDeposit(bool value) {
    setState(() {
      _makeInitialDeposit = value;
      if (!value) {
        _amountController.clear();
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    
    final initialDepositAmount = _makeInitialDeposit && 
                                 _amountController.text.trim().isNotEmpty
        ? double.tryParse(_amountController.text)
        : null;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsSummaryPage(
          name: widget.name,
          icon: widget.icon,
          savingsGoal: widget.savingsGoal,
          targetAmount: widget.targetAmount,
          targetDate: widget.targetDate,
          monthlyBudget: widget.monthlyBudget,
          wantsInitialDeposit: _makeInitialDeposit,
          depositAmount: initialDepositAmount,
          depositDate: _makeInitialDeposit ? _selectedDate : null,
          depositDescription: _makeInitialDeposit ? _descriptionController.text : null,
        ),
      ),
    );
  }
}

// Widget Header optimisé
class _HeaderWidget extends StatelessWidget {
  final bool isDark;
  
  const _HeaderWidget({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SmartBackButton(),
        Text(
          'Dépôt initial',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(width: 40),
      ],
    );
  }
}

// Widget ProjectInfoCard optimisé
class _ProjectInfoCard extends StatelessWidget {
  final String name;
  final String icon;
  final double monthlyBudget;
  final List<Color> gradient;
  final bool isDark;
  
  const _ProjectInfoCard({
    required this.name,
    required this.icon,
    required this.monthlyBudget,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 32,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconFromId(icon),
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
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  'Budget mensuel : ${monthlyBudget.toInt()}€',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark 
                      ? Colors.white.withValues(alpha: 0.6)
                      : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromId(String iconId) {
    switch (iconId) {
      case 'piggy_bank': return HugeIcons.strokeRoundedTarget01;
      case 'emergency': return HugeIcons.strokeRoundedShield01;
      case 'vacation': return HugeIcons.strokeRoundedBeach;
      case 'house': return HugeIcons.strokeRoundedBuilding01;
      case 'car': return HugeIcons.strokeRoundedCar01;
      case 'education': return HugeIcons.strokeRoundedBook01;
      case 'investment': return HugeIcons.strokeRoundedTradeMark;
      case 'travel': return HugeIcons.strokeRoundedAirplane01;
      case 'wedding': return HugeIcons.strokeRoundedHeartCheck;
      default: return HugeIcons.strokeRoundedTarget01;
    }
  }
}

// Widget DepositOptionsCard optimisé
class _DepositOptionsCard extends StatelessWidget {
  final bool makeInitialDeposit;
  final Function(bool) onToggleDeposit;
  final List<Color> gradient;
  final bool isDark;
  
  const _DepositOptionsCard({
    required this.makeInitialDeposit,
    required this.onToggleDeposit,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 32,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedMoneyAdd01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dépôt initial (optionnel)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Souhaitez-vous commencer avec un premier versement ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Options radio-style
          Column(
            children: [
              _DepositOption(
                title: 'Commencer le mois prochain',
                description: 'Pas de dépôt initial, démarrage avec le budget mensuel',
                icon: HugeIcons.strokeRoundedCalendarAdd01,
                isSelected: !makeInitialDeposit,
                onTap: () => onToggleDeposit(false),
                gradient: gradient,
                isDark: isDark,
              ),
              
              const SizedBox(height: 12),
              
              _DepositOption(
                title: 'Faire un dépôt initial',
                description: 'Commencer immédiatement avec un premier versement',
                icon: HugeIcons.strokeRoundedMoneyAdd01,
                isSelected: makeInitialDeposit,
                onTap: () => onToggleDeposit(true),
                gradient: gradient,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget DepositOption optimisé
class _DepositOption extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final List<Color> gradient;
  final bool isDark;
  
  const _DepositOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? gradient.first.withValues(alpha: 0.1)
            : (isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? gradient.first
              : (isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(colors: gradient)
                  : null,
                color: !isSelected
                  ? (isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05))
                  : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected 
                  ? Colors.white
                  : (isDark 
                      ? Colors.white.withValues(alpha: 0.6)
                      : const Color(0xFF64748B)),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                        ? gradient.first
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected 
                        ? gradient.first.withValues(alpha: 0.8)
                        : (isDark 
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Radio indicator
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                    ? gradient.first
                    : (isDark 
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2)),
                  width: 2,
                ),
                color: isSelected 
                  ? gradient.first
                  : Colors.transparent,
              ),
              child: isSelected
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 12,
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget DepositAmountCard optimisé
class _DepositAmountCard extends StatelessWidget {
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final double monthlyBudget;
  final List<Color> gradient;
  final bool isDark;
  
  const _DepositAmountCard({
    required this.amountController,
    required this.amountFocusNode,
    required this.monthlyBudget,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 32,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedWallet01,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Montant du dépôt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Quel montant souhaitez-vous déposer maintenant ?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          TextField(
            controller: amountController,
            focusNode: amountFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: gradient.first,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: '${monthlyBudget.round()}€',
              hintStyle: TextStyle(
                color: gradient.first.withValues(alpha: 0.4),
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
              filled: true,
              fillColor: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: gradient.first.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: gradient.first,
                  width: 2,
                ),
              ),
              suffixText: '€',
              suffixStyle: TextStyle(
                color: gradient.first,
                fontWeight: FontWeight.w800,
                fontSize: 28,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget SuggestionsCard optimisé
class _SuggestionsCard extends StatelessWidget {
  final double monthlyBudget;
  final TextEditingController amountController;
  final List<Color> gradient;
  final bool isDark;
  
  const _SuggestionsCard({
    required this.monthlyBudget,
    required this.amountController,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 32,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedIdea,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Suggestions rapides',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Basées sur votre budget mensuel',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Suggestions en grille
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SuggestionChip(
                title: '1/2 mensuel',
                amount: (monthlyBudget * 0.5).round(),
                emoji: '💡',
                amountController: amountController,
                gradient: gradient,
              ),
              _SuggestionChip(
                title: '1 mensuel',
                amount: monthlyBudget.round(),
                emoji: '👍',
                amountController: amountController,
                gradient: gradient,
              ),
              _SuggestionChip(
                title: '2 mensuels',
                amount: (monthlyBudget * 2).round(),
                emoji: '🚀',
                amountController: amountController,
                gradient: gradient,
              ),
              _SuggestionChip(
                title: '100€',
                amount: 100,
                emoji: '💸',
                amountController: amountController,
                gradient: gradient,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget SuggestionChip optimisé
class _SuggestionChip extends StatelessWidget {
  final String title;
  final int amount;
  final String emoji;
  final TextEditingController amountController;
  final List<Color> gradient;
  
  const _SuggestionChip({
    required this.title,
    required this.amount,
    required this.emoji,
    required this.amountController,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        amountController.text = amount.toString();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${amount}€',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget DepositDetailsCard optimisé
class _DepositDetailsCard extends StatelessWidget {
  final TextEditingController descriptionController;
  final FocusNode descriptionFocusNode;
  final DateTime selectedDate;
  final Function(DateTime) onDateChanged;
  final List<Color> gradient;
  final bool isDark;
  
  const _DepositDetailsCard({
    required this.descriptionController,
    required this.descriptionFocusNode,
    required this.selectedDate,
    required this.onDateChanged,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark 
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 32,
            offset: Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedInformationCircle,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Détails du dépôt',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Date et description de la transaction',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark 
                          ? Colors.white.withValues(alpha: 0.6)
                          : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Sélecteur de date
          GestureDetector(
            onTap: () => _selectDate(context, onDateChanged, gradient),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: gradient.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gradient.first.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedCalendar03,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date du dépôt',
                          style: TextStyle(
                            fontSize: 12,
                            color: gradient.first.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: gradient.first,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(
                    HugeIcons.strokeRoundedArrowRight01,
                    color: gradient.first,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description
          TextField(
            controller: descriptionController,
            focusNode: descriptionFocusNode,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(
                color: gradient.first,
                fontWeight: FontWeight.w600,
              ),
              filled: true,
              fillColor: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: gradient.first.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: gradient.first,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateChanged, List<Color> colors) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: colors.first,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      onDateChanged(picked);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
} 