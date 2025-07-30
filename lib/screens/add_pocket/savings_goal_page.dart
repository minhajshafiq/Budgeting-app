import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';
import 'savings_budget_page.dart';

class SavingsGoalPage extends StatefulWidget {
  final String name;
  final String icon;

  const SavingsGoalPage({
    super.key,
    required this.name,
    required this.icon,
  });

  @override
  State<SavingsGoalPage> createState() => _SavingsGoalPageState();
}

class _SavingsGoalPageState extends State<SavingsGoalPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final TextEditingController _targetAmountController = TextEditingController();
  final FocusNode _targetAmountFocusNode = FocusNode();
  
  SavingsGoalType? _selectedGoalType;
  DateTime? _selectedTargetDate;
  bool _hasTargetDate = false;

  // Cache optimisé des types d'objectifs (const data)
  static const Map<SavingsGoalType, Map<String, dynamic>> _goalTypesData = {
    SavingsGoalType.emergency: {
      'name': 'Fonds d\'urgence',
      'emoji': '🛡️',
      'description': 'Sécurité financière',
      'suggestedAmount': 3000.0,
    },
    SavingsGoalType.vacation: {
      'name': 'Vacances',
      'emoji': '🏖️',
      'description': 'Voyage de rêve',
      'suggestedAmount': 2000.0,
      'defaultMonths': 12,
    },
    SavingsGoalType.house: {
      'name': 'Immobilier',
      'emoji': '🏠',
      'description': 'Achat immobilier',
      'suggestedAmount': 15000.0,
      'defaultMonths': 24,
    },
    SavingsGoalType.car: {
      'name': 'Véhicule',
      'emoji': '🚗',
      'description': 'Nouvelle voiture',
      'suggestedAmount': 8000.0,
      'defaultMonths': 18,
    },
    SavingsGoalType.investment: {
      'name': 'Investissement',
      'emoji': '📈',
      'description': 'Faire fructifier',
      'suggestedAmount': 5000.0,
    },
    SavingsGoalType.education: {
      'name': 'Formation',
      'emoji': '📚',
      'description': 'Développement personnel',
      'suggestedAmount': 3000.0,
      'defaultMonths': 12,
    },
  };

  // Cache des couleurs optimisé
  static const Map<SavingsGoalType, List<Color>> _goalColorsCache = {
    SavingsGoalType.emergency: [Color(0xFFDC2626), Color(0xFFF59E0B)],
    SavingsGoalType.vacation: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    SavingsGoalType.house: [Color(0xFF059669), Color(0xFF10B981)],
    SavingsGoalType.car: [Color(0xFF7C3AED), Color(0xFFA855F7)],
    SavingsGoalType.investment: [Color(0xFF7C2D12), Color(0xFFEA580C)],
    SavingsGoalType.education: [Color(0xFF0891B2), Color(0xFF06B6D4)],
  };

  // Cache des icônes optimisé
  static const Map<SavingsGoalType, IconData> _goalIconsCache = {
    SavingsGoalType.emergency: HugeIcons.strokeRoundedShield01,
    SavingsGoalType.vacation: HugeIcons.strokeRoundedBeach,
    SavingsGoalType.house: HugeIcons.strokeRoundedBuilding01,
    SavingsGoalType.car: HugeIcons.strokeRoundedCar01,
    SavingsGoalType.investment: HugeIcons.strokeRoundedTradeMark,
    SavingsGoalType.education: HugeIcons.strokeRoundedBook01,
  };

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
      curve: Curves.easeOutCubic,
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _targetAmountController.dispose();
    _targetAmountFocusNode.dispose();
    super.dispose();
  }

  // Méthodes optimisées pour accéder aux données cachées
  List<Color> _getGoalColors(SavingsGoalType goalType) {
    return _goalColorsCache[goalType] ?? _goalColorsCache[SavingsGoalType.emergency]!;
  }

  IconData _getGoalIcon(SavingsGoalType goalType) {
    return _goalIconsCache[goalType] ?? _goalIconsCache[SavingsGoalType.emergency]!;
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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            
            // Header optimisé
            _HeaderWidget(isDark: isDark),
            
            const SizedBox(height: 32),
            
            // Sélecteur de type d'objectif amélioré (sans carte info)
            _EnhancedGoalTypeSelector(
              goalTypesData: _goalTypesData,
              selectedGoalType: _selectedGoalType,
              onGoalTypeSelected: _onGoalTypeSelected,
              getGoalColors: _getGoalColors,
              getGoalIcon: _getGoalIcon,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Montant cible
            _TargetAmountCard(
              targetAmountController: _targetAmountController,
              targetAmountFocusNode: _targetAmountFocusNode,
              selectedGoalType: _selectedGoalType,
              goalTypesData: _goalTypesData,
              getGoalColors: _getGoalColors,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Date cible optionnelle
            _TargetDateCard(
              hasTargetDate: _hasTargetDate,
              selectedTargetDate: _selectedTargetDate,
              onToggleTargetDate: _onToggleTargetDate,
              onDateSelected: _onDateSelected,
              selectedGoalType: _selectedGoalType,
              getGoalColors: _getGoalColors,
              isDark: isDark,
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = _selectedGoalType != null;
    final colors = _selectedGoalType != null 
        ? _getGoalColors(_selectedGoalType!)
        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: canContinue
            ? LinearGradient(colors: colors)
            : null,
        color: !canContinue
            ? (isDark 
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05))
            : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: canContinue ? [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.4),
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
  }

  void _onGoalTypeSelected(SavingsGoalType goalType) {
    setState(() {
      _selectedGoalType = goalType;
      
      // Auto-remplir le montant suggéré
      final goalData = _goalTypesData[goalType]!;
      _targetAmountController.text = goalData['suggestedAmount'].toString();
      
      // Auto-définir la date si suggérée
      if (goalData.containsKey('defaultMonths')) {
        final months = goalData['defaultMonths'] as int;
        _selectedTargetDate = DateTime.now().add(Duration(days: months * 30));
        _hasTargetDate = true;
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onToggleTargetDate(bool value) {
    setState(() {
      _hasTargetDate = value;
      if (!value) {
        _selectedTargetDate = null;
      } else if (_selectedGoalType != null) {
        final goalData = _goalTypesData[_selectedGoalType!]!;
        if (goalData.containsKey('defaultMonths')) {
          final months = goalData['defaultMonths'] as int;
          _selectedTargetDate = DateTime.now().add(Duration(days: months * 30));
        } else {
          _selectedTargetDate = DateTime.now().add(const Duration(days: 365));
        }
      }
    });
    HapticFeedback.lightImpact();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedTargetDate = date;
    });
  }

  void _continue() {
    if (_selectedGoalType == null) return;
    
    final targetAmount = _targetAmountController.text.trim().isNotEmpty 
        ? double.tryParse(_targetAmountController.text) 
        : null;
    
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsBudgetPage(
          name: widget.name,
          icon: widget.icon,
          savingsGoal: _selectedGoalType!,
          targetAmount: targetAmount,
          targetDate: _hasTargetDate ? _selectedTargetDate : null,
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
          'Objectif d\'épargne',
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
  final IconData Function(String) getIconFromId;
  final bool isDark;
  
  const _ProjectInfoCard({
    required this.name,
    required this.icon,
    required this.getIconFromId,
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Icon(
              getIconFromId(icon),
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
                  'Définissez votre objectif d\'épargne',
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
}

// Widget EnhancedGoalTypeSelector amélioré
class _EnhancedGoalTypeSelector extends StatelessWidget {
  final Map<SavingsGoalType, Map<String, dynamic>> goalTypesData;
  final SavingsGoalType? selectedGoalType;
  final Function(SavingsGoalType) onGoalTypeSelected;
  final List<Color> Function(SavingsGoalType) getGoalColors;
  final IconData Function(SavingsGoalType) getGoalIcon;
  final bool isDark;
  
  const _EnhancedGoalTypeSelector({
    required this.goalTypesData,
    required this.selectedGoalType,
    required this.onGoalTypeSelected,
    required this.getGoalColors,
    required this.getGoalIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre principal amélioré
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedTarget01,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type d\'objectif',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choisissez le type qui correspond à votre projet d\'épargne',
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark 
                              ? Colors.white.withValues(alpha: 0.7)
                              : const Color(0xFF64748B),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 28),
        
        // Liste verticale des types d'objectifs
        Column(
          children: goalTypesData.entries.map((entry) {
            final goalType = entry.key;
            final goalData = entry.value;
            final isSelected = selectedGoalType == goalType;
            final colors = getGoalColors(goalType);
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _EnhancedGoalTypeItem(
                goalType: goalType,
                goalData: goalData,
                colors: colors,
                icon: getGoalIcon(goalType),
                isSelected: isSelected,
                onTap: () => onGoalTypeSelected(goalType),
                isDark: isDark,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Widget EnhancedGoalTypeItem amélioré
class _EnhancedGoalTypeItem extends StatelessWidget {
  final SavingsGoalType goalType;
  final Map<String, dynamic> goalData;
  final List<Color> colors;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  
  const _EnhancedGoalTypeItem({
    required this.goalType,
    required this.goalData,
    required this.colors,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          gradient: isSelected 
            ? LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: !isSelected
            ? (isDark 
                ? AppColors.surfaceDark
                : Colors.white)
            : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
              ? Colors.white.withValues(alpha: 0.3)
              : (isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.08)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ] : [
            BoxShadow(
              color: isDark 
                ? Colors.black.withValues(alpha: 0.2)
                : const Color(0x08000000),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icône avec design amélioré
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.3),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [] : [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected 
                  ? Colors.white
                  : Colors.white,
                size: 28,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Contenu textuel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goalData['name'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                        ? Colors.white
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      letterSpacing: -0.3,
                      height: 1.2,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    goalData['description'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected 
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isDark 
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B)),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Montant suggéré
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.white.withValues(alpha: 0.2)
                        : colors.first.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Suggéré: ${goalData['suggestedAmount']}€',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                          ? Colors.white
                          : colors.first,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicateur de sélection
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected 
                  ? Colors.white
                  : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected 
                    ? Colors.white
                    : (isDark 
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2)),
                  width: 2,
                ),
              ),
              child: isSelected 
                ? Icon(
                    Icons.check,
                    color: colors.first,
                    size: 16,
                  )
                : null,
            ),
          ],
        ),
      ),
    );
  }
}

// Widget TargetAmountCard optimisé
class _TargetAmountCard extends StatelessWidget {
  final TextEditingController targetAmountController;
  final FocusNode targetAmountFocusNode;
  final SavingsGoalType? selectedGoalType;
  final Map<SavingsGoalType, Map<String, dynamic>> goalTypesData;
  final List<Color> Function(SavingsGoalType) getGoalColors;
  final bool isDark;
  
  const _TargetAmountCard({
    required this.targetAmountController,
    required this.targetAmountFocusNode,
    required this.selectedGoalType,
    required this.goalTypesData,
    required this.getGoalColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = selectedGoalType != null 
        ? getGoalColors(selectedGoalType!)
        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    
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
                  gradient: LinearGradient(colors: colors),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedMoneyBag01,
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
                      'Montant cible (optionnel)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Quel est votre objectif financier ?',
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
            controller: targetAmountController,
            focusNode: targetAmountFocusNode,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: colors.first,
              letterSpacing: -0.4,
            ),
            decoration: InputDecoration(
              hintText: selectedGoalType != null 
                  ? '${goalTypesData[selectedGoalType!]!['suggestedAmount'].toInt()}€'
                  : '1000€',
              hintStyle: TextStyle(
                color: colors.first.withValues(alpha: 0.4),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              filled: true,
              fillColor: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: colors.first.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: colors.first,
                  width: 2,
                ),
              ),
              suffixText: '€',
              suffixStyle: TextStyle(
                color: colors.first,
                fontWeight: FontWeight.w800,
                fontSize: 24,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget TargetDateCard optimisé
class _TargetDateCard extends StatelessWidget {
  final bool hasTargetDate;
  final DateTime? selectedTargetDate;
  final Function(bool) onToggleTargetDate;
  final Function(DateTime) onDateSelected;
  final SavingsGoalType? selectedGoalType;
  final List<Color> Function(SavingsGoalType) getGoalColors;
  final bool isDark;
  
  const _TargetDateCard({
    required this.hasTargetDate,
    required this.selectedTargetDate,
    required this.onToggleTargetDate,
    required this.onDateSelected,
    required this.selectedGoalType,
    required this.getGoalColors,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final colors = selectedGoalType != null 
        ? getGoalColors(selectedGoalType!)
        : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)];
    
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
                  gradient: LinearGradient(colors: colors),
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedCalendar03,
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
                      'Date cible (optionnel)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Quand souhaitez-vous atteindre votre objectif ?',
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
              Switch(
                value: hasTargetDate,
                onChanged: onToggleTargetDate,
                activeColor: colors.first,
              ),
            ],
          ),
          
          if (hasTargetDate) ...[
            const SizedBox(height: 20),
            
            GestureDetector(
              onTap: () => _selectDate(context, onDateSelected, colors),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: colors.first.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.first.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: colors),
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                            'Date cible',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.first.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            selectedTargetDate != null 
                                ? _formatDate(selectedTargetDate!)
                                : 'Sélectionner une date',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colors.first,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    Icon(
                      HugeIcons.strokeRoundedArrowRight01,
                      color: colors.first,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, Function(DateTime) onDateSelected, List<Color> colors) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedTargetDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
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
      onDateSelected(picked);
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