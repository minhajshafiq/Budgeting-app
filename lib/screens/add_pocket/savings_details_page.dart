import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';
import 'savings_goal_page.dart';

class SavingsDetailsPage extends StatefulWidget {
  const SavingsDetailsPage({super.key});

  @override
  State<SavingsDetailsPage> createState() => _SavingsDetailsPageState();
}

class _SavingsDetailsPageState extends State<SavingsDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  String? _selectedIcon;
  String? _selectedSuggestion;

  // Cache des couleurs pour éviter les recalculs
  static const Map<String, List<Color>> _iconColorsCache = {
    'piggy_bank': [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    'emergency': [Color(0xFFDC2626), Color(0xFFF59E0B)],
    'vacation': [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    'house': [Color(0xFF059669), Color(0xFF10B981)],
    'car': [Color(0xFF7C3AED), Color(0xFFA855F7)],
    'education': [Color(0xFF0891B2), Color(0xFF06B6D4)],
    'investment': [Color(0xFF7C2D12), Color(0xFFEA580C)],
    'travel': [Color(0xFF1E40AF), Color(0xFF3B82F6)],
    'wedding': [Color(0xFFBE185D), Color(0xFFEC4899)],
  };

  // Suggestions intelligentes avec emojis et descriptions (const)
  static const List<Map<String, String>> _suggestions = [
    {
      'name': 'Fonds d\'urgence',
      'icon': 'emergency',
      'emoji': '🛡️',
      'description': 'Pour les imprévus de la vie'
    },
    {
      'name': 'Vacances d\'été',
      'icon': 'vacation',
      'emoji': '🏖️',
      'description': 'Des souvenirs inoubliables'
    },
    {
      'name': 'Nouvelle voiture',
      'icon': 'car',
      'emoji': '🚗',
      'description': 'Mobilité et liberté'
    },
    {
      'name': 'Achat immobilier',
      'icon': 'house',
      'emoji': '🏠',
      'description': 'Votre chez-vous'
    },
    {
      'name': 'Formation',
      'icon': 'education',
      'emoji': '📚',
      'description': 'Investir en soi'
    },
    {
      'name': 'Investissement',
      'icon': 'investment',
      'emoji': '📈',
      'description': 'Faire fructifier'
    },
  ];

  // Icônes disponibles optimisées (const data)
  static const List<Map<String, dynamic>> _availableIconsData = [
    {'id': 'piggy_bank', 'label': 'Épargne'},
    {'id': 'emergency', 'label': 'Urgence'},
    {'id': 'vacation', 'label': 'Vacances'},
    {'id': 'house', 'label': 'Logement'},
    {'id': 'car', 'label': 'Transport'},
    {'id': 'education', 'label': 'Formation'},
    {'id': 'investment', 'label': 'Investissement'},
    {'id': 'travel', 'label': 'Voyage'},
    {'id': 'wedding', 'label': 'Mariage'},
  ];

  @override
  void initState() {
    super.initState();
    
    // Optimisation: Un seul AnimationController au lieu de deux
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000), // Durée réduite
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic, // Curve plus simple
    );
    
    _slideAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    );
    
    // Démarrer l'animation une seule fois
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  // Méthode optimisée pour obtenir l'icône
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
            
            // Header simple (const optimisé)
            _HeaderWidget(isDark: isDark),
            
            const SizedBox(height: 24),
            
            // Carte nom du projet
            _ProjectNameCard(
              nameController: _nameController,
              nameFocusNode: _nameFocusNode,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Sélecteur d'icône (maintenant en premier)
            _IconSelectorCard(
              availableIcons: _availableIconsData,
              selectedIcon: _selectedIcon,
              onIconTap: _onIconTap,
              getIconFromId: _getIconFromId,
              getIconColors: (iconId) => _iconColorsCache[iconId] ?? _iconColorsCache['piggy_bank']!,
              isDark: isDark,
            ),
            
            const SizedBox(height: 24),
            
            // Suggestions rapides (maintenant en second)
            _SuggestionsCard(
              suggestions: _suggestions,
              onSuggestionTap: _onSuggestionTap,
              selectedSuggestion: _selectedSuggestion,
              isDark: isDark,
            ),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = _nameController.text.trim().isNotEmpty && _selectedIcon != null;
    
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _nameController,
      builder: (context, value, child) {
        final isEnabled = value.text.trim().isNotEmpty && _selectedIcon != null;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                : null,
            color: !isEnabled
                ? (isDark 
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05))
                : null,
            borderRadius: BorderRadius.circular(28),
            boxShadow: isEnabled ? [
              const BoxShadow(
                color: Color(0x406366F1),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ] : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isEnabled ? _continue : null,
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
                        color: isEnabled 
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
                      color: isEnabled 
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

  void _onSuggestionTap(Map<String, String> suggestion) {
    setState(() {
      _selectedSuggestion = suggestion['name'];
      _selectedIcon = suggestion['icon'];
      _nameController.text = suggestion['name']!;
    });
    HapticFeedback.lightImpact();
  }

  void _onIconTap(String iconId) {
    setState(() {
      _selectedIcon = iconId;
    });
    HapticFeedback.lightImpact();
  }

  void _continue() {
    if (_nameController.text.trim().isEmpty || _selectedIcon == null) return;
    
    HapticFeedback.mediumImpact();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsGoalPage(
          name: _nameController.text.trim(),
          icon: _selectedIcon!,
        ),
      ),
    );
  }
}

// Widget Header optimisé avec const
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
          'Nom de l\'épargne',
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

// Widget ProjectNameCard optimisé
class _ProjectNameCard extends StatelessWidget {
  final TextEditingController nameController;
  final FocusNode nameFocusNode;
  final bool isDark;
  
  const _ProjectNameCard({
    required this.nameController,
    required this.nameFocusNode,
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: const Icon(
                  HugeIcons.strokeRoundedEdit01,
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
                      'Nom de l\'épargne',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Donnez un nom à votre projet d\'épargne',
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
            controller: nameController,
            focusNode: nameFocusNode,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
            decoration: InputDecoration(
              hintText: 'Mon projet d\'épargne',
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
                  color: Colors.black.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                borderSide: BorderSide(
                  color: Color(0xFF6366F1),
                  width: 2,
                ),
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
  final List<Map<String, String>> suggestions;
  final Function(Map<String, String>) onSuggestionTap;
  final String? selectedSuggestion;
  final bool isDark;
  
  const _SuggestionsCard({
    required this.suggestions,
    required this.onSuggestionTap,
    required this.selectedSuggestion,
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
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
                      'Suggestions populaires',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Choisissez parmi nos suggestions ou créez le vôtre',
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
          
          // Liste verticale des suggestions (plus lisible)
          Column(
            children: suggestions.map((suggestion) {
              final isSelected = selectedSuggestion == suggestion['name'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SuggestionItemVertical(
                  suggestion: suggestion,
                  isSelected: isSelected,
                  onTap: () => onSuggestionTap(suggestion),
                  isDark: isDark,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Widget SuggestionItemVertical - Version liste verticale plus spacieuse
class _SuggestionItemVertical extends StatelessWidget {
  final Map<String, String> suggestion;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  
  const _SuggestionItemVertical({
    required this.suggestion,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF6366F1).withValues(alpha: 0.1)
            : (isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF6366F1)
              : (isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: const Color(0xFF6366F1).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Row(
          children: [
            // Emoji avec fond coloré
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: isSelected 
                  ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                  : LinearGradient(
                      colors: [
                        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
                        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                      ]
                    ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  suggestion['emoji']!,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Contenu textuel
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['name']!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                        ? const Color(0xFF6366F1)
                        : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion['description']!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected 
                        ? const Color(0xFF6366F1).withValues(alpha: 0.8)
                        : (isDark 
                            ? Colors.white.withValues(alpha: 0.6)
                            : const Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
            
            // Indicateur de sélection
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Widget IconSelectorCard optimisé
class _IconSelectorCard extends StatelessWidget {
  final List<Map<String, dynamic>> availableIcons;
  final String? selectedIcon;
  final Function(String) onIconTap;
  final IconData Function(String) getIconFromId;
  final List<Color> Function(String) getIconColors;
  final bool isDark;
  
  const _IconSelectorCard({
    required this.availableIcons,
    required this.selectedIcon,
    required this.onIconTap,
    required this.getIconFromId,
    required this.getIconColors,
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
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                                 child: const Icon(
                   HugeIcons.strokeRoundedColorPicker,
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
                      'Choisir une icône',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Sélectionnez l\'icône qui représente votre épargne',
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
          
          // Grid d'icônes optimisé
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: availableIcons.length,
            itemBuilder: (context, index) {
              final iconData = availableIcons[index];
              final iconId = iconData['id'] as String;
              final isSelected = selectedIcon == iconId;
              final colors = getIconColors(iconId);
              
              return _IconItem(
                iconId: iconId,
                icon: getIconFromId(iconId),
                colors: colors,
                isSelected: isSelected,
                onTap: () => onIconTap(iconId),
                isDark: isDark,
              );
            },
          ),
        ],
      ),
    );
  }
}

// Widget IconItem optimisé
class _IconItem extends StatelessWidget {
  final String iconId;
  final IconData icon;
  final List<Color> colors;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  
  const _IconItem({
    required this.iconId,
    required this.icon,
    required this.colors,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected 
            ? LinearGradient(colors: colors)
            : null,
          color: !isSelected
            ? (isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.5)
                : const Color(0xFFF8FAFC))
            : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? Colors.white.withValues(alpha: 0.3)
              : (isDark 
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ] : [],
        ),
        child: Icon(
          icon,
          color: isSelected 
            ? Colors.white 
            : (isDark ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF64748B)),
          size: 28,
        ),
      ),
    );
  }
} 