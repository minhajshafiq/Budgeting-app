import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../widgets/modern_animations.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';


class PocketCategoryPage extends StatefulWidget {
  const PocketCategoryPage({super.key});

  @override
  State<PocketCategoryPage> createState() => _PocketCategoryPageState();
}

class _PocketCategoryPageState extends State<PocketCategoryPage> 
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late AnimationController _cardsAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;
  
  PocketType? _selectedCategory;
  bool _isAnimatingSelection = false;

  final List<CategoryOption> _categories = [
    CategoryOption(
      type: PocketType.needs,
      title: 'Besoins essentiels',
      subtitle: '50% de votre budget',
      description: 'Logement, alimentation, transport, factures...',
      icon: HugeIcons.strokeRoundedHome01,
      color: const Color(0xFF3B82F6),
      examples: ['Loyer/Prêt immobilier', 'Courses alimentaires', 'Transport', 'Factures & Assurances', 'Frais de santé'],
    ),
    CategoryOption(
      type: PocketType.wants,
      title: 'Envies & Loisirs',
      subtitle: '30% de votre budget',
      description: 'Sorties, shopping, divertissement...',
      icon: HugeIcons.strokeRoundedGameController01,
      color: const Color(0xFF8B5CF6),
      examples: ['Restaurants & Sorties', 'Shopping & Mode', 'Abonnements', 'Voyages & Loisirs', 'Sport & Hobbies'],
    ),
    CategoryOption(
      type: PocketType.savings,
      title: 'Épargne & Objectifs',
      subtitle: '20% de votre budget',
      description: 'Économies, investissements, projets...',
      icon: HugeIcons.strokeRoundedTarget01,
      color: const Color(0xFF10B981),
      examples: ['Fonds d\'urgence', 'Épargne vacances', 'Projet immobilier', 'Retraite', 'Investissements'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutExpo),
    );
    
    _startAnimations();
  }
  
  void _startAnimations() async {
    _headerAnimationController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _cardsAnimationController.forward();
  }
  
  @override
  void dispose() {
    _headerAnimationController.dispose();
    _cardsAnimationController.dispose();
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
                opacity: _cardsAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_cardsAnimation),
                  child: _buildScrollableContent(isDark),
                ),
              ),
            ),
            
            // Bouton continuer
            FadeTransition(
              opacity: _cardsAnimation,
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
        
        // Titre et description
        Text(
          'Choisissez une catégorie',
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
          'Votre pocket sera créé selon la méthode 50/30/20\npour une gestion budgétaire équilibrée',
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
          FadeTransition(
            opacity: _headerAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.3),
                end: Offset.zero,
              ).animate(_headerAnimation),
              child: _buildHeaderContent(isDark),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Indicateur de progression
          _buildProgressIndicator(isDark),
          
          const SizedBox(height: 24),
          
          // Cartes des catégories
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = _selectedCategory == category.type;
              
              return SlideInAnimation(
                delay: Duration(milliseconds: 300 + (index * 150)),
                beginOffset: const Offset(0.3, 0),
                child: _buildCategoryCard(category, isSelected, isDark),
              );
            },
          ),
          
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
                '1',
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
                  'Étape 1 sur 4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Catégorie budgétaire',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textDark : AppColors.text,
                  ),
                ),
              ],
            ),
          ),
          // Barre de progression
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.25, // 1/4 = 25%
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

  Widget _buildCategoryCard(CategoryOption category, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () => _selectCategory(category.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected 
              ? category.color.withValues(alpha: 0.08)
              : (isDark ? AppColors.surfaceDark : AppColors.surface),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? category.color
                : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected) ...[
              BoxShadow(
                color: category.color.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ] else ...[
              BoxShadow(
                color: (isDark ? Colors.black : Colors.black).withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icône avec animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween(begin: 0.0, end: isSelected ? 1.2 : 1.0),
                  curve: Curves.elasticOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              category.color.withValues(alpha: 0.8),
                              category.color,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: category.color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          category.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Titre et sous-titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textDark : AppColors.text,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category.subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: category.color,
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
                    color: isSelected ? category.color : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? category.color : (isDark ? AppColors.borderDark : AppColors.border),
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              category.description,
              style: TextStyle(
                fontSize: 15,
                color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.9),
                height: 1.4,
                letterSpacing: -0.1,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Exemples
            Text(
              'Exemples :',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: category.color,
                letterSpacing: 0.2,
              ),
            ),
            
            const SizedBox(height: 8),
            
                          Container(
                height: 80, // Hauteur fixe pour éviter le mouvement
                alignment: Alignment.topLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(3, (index) {
                    if (index < category.examples.length) {
                      final example = category.examples[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: category.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: category.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          example,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: category.color,
                          ),
                        ),
                      );
                    } else {
                      // Placeholder invisible pour maintenir la structure
                      return const SizedBox.shrink();
                    }
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = _selectedCategory != null;
    
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

  void _selectCategory(PocketType type) {
    if (_isAnimatingSelection) return;
    
    HapticFeedback.lightImpact();
    setState(() {
      _selectedCategory = type;
      _isAnimatingSelection = true;
    });
    
    // Petite animation de feedback
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _isAnimatingSelection = false;
      });
    });
  }

  void _continue() {
    if (_selectedCategory == null) return;
    
    HapticFeedback.mediumImpact();
    
    // Si c'est une épargne, rediriger vers le flux personnalisé d'épargne
    if (_selectedCategory == PocketType.savings) {
      Navigator.pushNamed(
        context,
        '/add-savings/details',
      );
    } else {
      // Pour les autres catégories, utiliser le flux normal
      Navigator.pushNamed(
        context,
        '/add-pocket/details',
        arguments: {
          'category': _selectedCategory,
        },
      );
    }
  }
}

// Classe pour représenter une option de catégorie
class CategoryOption {
  final PocketType type;
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> examples;

  CategoryOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.examples,
  });
} 