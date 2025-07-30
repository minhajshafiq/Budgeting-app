import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';
import 'savings_deposit_page.dart';

class SavingsBudgetPage extends StatefulWidget {
  final String name;
  final String icon;
  final SavingsGoalType? savingsGoal;
  final double? targetAmount;
  final DateTime? targetDate;

  const SavingsBudgetPage({
    super.key,
    required this.name,
    required this.icon,
    this.savingsGoal,
    this.targetAmount,
    this.targetDate,
  });

  @override
  State<SavingsBudgetPage> createState() => _SavingsBudgetPageState();
}

class _SavingsBudgetPageState extends State<SavingsBudgetPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _progressAnimation;
  
  final TextEditingController _monthlyBudgetController = TextEditingController();
  final FocusNode _monthlyBudgetFocusNode = FocusNode();
  
  double? _calculatedMonthlyBudget;
  int? _monthsToTarget;

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
      duration: const Duration(milliseconds: 1000), // Durée réduite
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve simple
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    );
    
    _progressAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
    );
    
    // Calculer le budget mensuel suggéré
    _calculateSuggestedBudget();
    
    // Démarrer l'animation une fois
    _animationController.forward();
  }
  
  void _calculateSuggestedBudget() {
    if (widget.targetAmount != null) {
      if (widget.targetDate != null) {
        // Calculer basé sur la date cible
        final now = DateTime.now();
        _monthsToTarget = ((widget.targetDate!.difference(now).inDays) / 30).ceil();
        if (_monthsToTarget! > 0) {
          _calculatedMonthlyBudget = widget.targetAmount! / _monthsToTarget!;
        }
      } else {
        // Utiliser une estimation par défaut (24 mois)
        _monthsToTarget = 24;
        _calculatedMonthlyBudget = widget.targetAmount! / 24;
      }
      
      // Pré-remplir le champ avec le budget calculé
      if (_calculatedMonthlyBudget != null) {
        _monthlyBudgetController.text = _calculatedMonthlyBudget!.round().toString();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _monthlyBudgetController.dispose();
    _monthlyBudgetFocusNode.dispose();
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
              targetAmount: widget.targetAmount,
              gradient: gradient,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Carte saisie budget
            _BudgetInputCard(
              monthlyBudgetController: _monthlyBudgetController,
              monthlyBudgetFocusNode: _monthlyBudgetFocusNode,
              calculatedMonthlyBudget: _calculatedMonthlyBudget,
              gradient: gradient,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Suggestions de budget
            if (_calculatedMonthlyBudget != null)
              _SuggestionsCard(
                calculatedMonthlyBudget: _calculatedMonthlyBudget!,
                monthlyBudgetController: _monthlyBudgetController,
                gradient: gradient,
                isDark: isDark,
              ),
            
            const SizedBox(height: 24),
            
            // Aperçu des métriques
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _monthlyBudgetController,
              builder: (context, value, child) {
                if (value.text.isNotEmpty && 
                    double.tryParse(value.text) != null &&
                    double.parse(value.text) > 0) {
                  return _MetricsCard(
                    monthlyBudget: double.parse(value.text),
                    targetAmount: widget.targetAmount,
                    progressAnimation: _progressAnimation,
                    gradient: gradient,
                    isDark: isDark,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final gradient = _getCurrentGradient();
    
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _monthlyBudgetController,
      builder: (context, value, child) {
        final canContinue = value.text.trim().isNotEmpty &&
                            double.tryParse(value.text) != null &&
                            double.parse(value.text) > 0;
        
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

  void _continue() {
    if (_monthlyBudgetController.text.trim().isEmpty) return;
    
    final monthlyBudget = double.tryParse(_monthlyBudgetController.text);
    if (monthlyBudget == null || monthlyBudget <= 0) return;
    
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsDepositPage(
          name: widget.name,
          icon: widget.icon,
          savingsGoal: widget.savingsGoal,
          targetAmount: widget.targetAmount,
          targetDate: widget.targetDate,
          monthlyBudget: monthlyBudget,
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
          'Budget mensuel',
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
  final double? targetAmount;
  final List<Color> gradient;
  final bool isDark;
  
  const _ProjectInfoCard({
    required this.name,
    required this.icon,
    required this.targetAmount,
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
                  targetAmount != null 
                    ? 'Objectif : ${targetAmount!.toInt()}€'
                    : 'Définir votre budget mensuel',
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

// Widget BudgetInputCard optimisé
class _BudgetInputCard extends StatelessWidget {
  final TextEditingController monthlyBudgetController;
  final FocusNode monthlyBudgetFocusNode;
  final double? calculatedMonthlyBudget;
  final List<Color> gradient;
  final bool isDark;
  
  const _BudgetInputCard({
    required this.monthlyBudgetController,
    required this.monthlyBudgetFocusNode,
    required this.calculatedMonthlyBudget,
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
                      'Budget mensuel',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Combien souhaitez-vous épargner chaque mois ?',
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
            controller: monthlyBudgetController,
            focusNode: monthlyBudgetFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: gradient.first,
              letterSpacing: -0.5,
            ),
            decoration: InputDecoration(
              hintText: calculatedMonthlyBudget != null 
                  ? '${calculatedMonthlyBudget!.round()}€'
                  : '200€',
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

// Widget SuggestionsCard amélioré
class _SuggestionsCard extends StatelessWidget {
  final double calculatedMonthlyBudget;
  final TextEditingController monthlyBudgetController;
  final List<Color> gradient;
  final bool isDark;
  
  const _SuggestionsCard({
    required this.calculatedMonthlyBudget,
    required this.monthlyBudgetController,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final suggestedAmount = calculatedMonthlyBudget.round();
    
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
          // En-tête avec le même style que les autres cartes
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
                      'Suggestions intelligentes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Basées sur votre objectif et votre échéance',
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
          
          // Cartes de suggestions compactes
          Row(
            children: [
              Expanded(
                child: _CompactSuggestionCard(
                  title: 'Modéré',
                  amount: (suggestedAmount * 0.7).round(),
                  monthlyBudgetController: monthlyBudgetController,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactSuggestionCard(
                  title: 'Recommandé',
                  amount: suggestedAmount,
                  monthlyBudgetController: monthlyBudgetController,
                  isRecommended: true,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CompactSuggestionCard(
                  title: 'Ambitieux',
                  amount: (suggestedAmount * 1.5).round(),
                  monthlyBudgetController: monthlyBudgetController,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Widget CompactSuggestionCard avec état de sélection
class _CompactSuggestionCard extends StatefulWidget {
  final String title;
  final int amount;
  final TextEditingController monthlyBudgetController;
  final bool isRecommended;
  final bool isDark;
  
  const _CompactSuggestionCard({
    required this.title,
    required this.amount,
    required this.monthlyBudgetController,
    required this.isDark,
    this.isRecommended = false,
  });

  @override
  State<_CompactSuggestionCard> createState() => _CompactSuggestionCardState();
}

class _CompactSuggestionCardState extends State<_CompactSuggestionCard> {
  bool get isSelected => widget.monthlyBudgetController.text == widget.amount.toString();
  
  IconData get cardIcon {
    switch (widget.title) {
      case 'Modéré': return HugeIcons.strokeRoundedShield01;
      case 'Recommandé': return HugeIcons.strokeRoundedTarget01;
      case 'Ambitieux': return HugeIcons.strokeRoundedRocket;
      default: return HugeIcons.strokeRoundedTarget01;
    }
  }
  
  List<Color> get cardColors {
    if (isSelected) {
      return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
    switch (widget.title) {
      case 'Modéré': return const [Color(0xFF10B981), Color(0xFF059669)];
      case 'Recommandé': return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
      case 'Ambitieux': return const [Color(0xFFEF4444), Color(0xFFDC2626)];
      default: return const [Color(0xFF6366F1), Color(0xFF8B5CF6)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.monthlyBudgetController.text = widget.amount.toString();
        setState(() {}); // Déclencher un rebuild pour mettre à jour l'état visuel
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected 
            ? LinearGradient(
                colors: cardColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: !isSelected 
            ? (widget.isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC))
            : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Colors.white.withValues(alpha: 0.3)
              : (widget.isRecommended 
                  ? const Color(0xFF6366F1).withValues(alpha: 0.3)
                  : (widget.isDark 
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05))),
            width: isSelected ? 2 : (widget.isRecommended ? 2 : 1),
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: cardColors.first.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ] : (widget.isRecommended ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : []),
        ),
        child: Column(
          children: [
            // Icône
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    )
                  : LinearGradient(colors: cardColors),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                cardIcon,
                color: Colors.white,
                size: 20,
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (!isSelected && widget.isRecommended) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'Recommandé',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF6366F1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            if (isSelected) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Sélectionné',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected 
                  ? Colors.white
                  : (widget.isDark 
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF0F172A)),
                letterSpacing: -0.2,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              '${widget.amount}€',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isSelected 
                  ? Colors.white
                  : (widget.isRecommended 
                      ? const Color(0xFF6366F1)
                      : (widget.isDark 
                          ? Colors.white
                          : const Color(0xFF0F172A))),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget MetricsCard optimisé
class _MetricsCard extends StatelessWidget {
  final double monthlyBudget;
  final double? targetAmount;
  final Animation<double> progressAnimation;
  final List<Color> gradient;
  final bool isDark;
  
  const _MetricsCard({
    required this.monthlyBudget,
    required this.targetAmount,
    required this.progressAnimation,
    required this.gradient,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final annualSavings = monthlyBudget * 12;
    final monthsToReachTarget = targetAmount != null 
        ? (targetAmount! / monthlyBudget).ceil()
        : null;
    final progressPercentage = targetAmount != null 
        ? min(100.0, (monthlyBudget / (targetAmount! / 12)) * 100)
        : 100.0;
    
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
                  HugeIcons.strokeRoundedAnalytics01,
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
                      'Aperçu de vos économies',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Projection basée sur votre budget mensuel',
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
          
          // Métriques en grille
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  title: 'Par an',
                  value: '${annualSavings.toStringAsFixed(0)}€',
                  icon: HugeIcons.strokeRoundedCalendar03,
                  gradient: gradient,
                ),
              ),
              const SizedBox(width: 16),
              if (monthsToReachTarget != null)
                Expanded(
                  child: _MetricItem(
                    title: 'Durée',
                    value: '$monthsToReachTarget mois',
                    icon: HugeIcons.strokeRoundedClock01,
                    gradient: gradient,
                  ),
                ),
            ],
          ),
          
          if (targetAmount != null) ...[
            const SizedBox(height: 20),
            
            // Barre de progression animée
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression vers l\'objectif',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${progressPercentage.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: gradient.first,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: AnimatedBuilder(
                    animation: progressAnimation,
                    builder: (context, child) {
                      final animatedProgress = min(1.0, (progressPercentage / 100) * progressAnimation.value);
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: animatedProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: gradient.first.withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// Widget MetricItem optimisé
class _MetricItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  
  const _MetricItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradient.first.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: gradient.first.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: gradient.first,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
} 