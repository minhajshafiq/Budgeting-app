import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/smart_back_button.dart';
import '../../data/models/pocket.dart';
import 'package:hugeicons/hugeicons.dart';
import 'pocket_budget_page.dart';

class PocketDetailsPage extends StatefulWidget {
  final PocketType category;

  const PocketDetailsPage({
    super.key,
    required this.category,
  });

  @override
  State<PocketDetailsPage> createState() => _PocketDetailsPageState();
}

class _PocketDetailsPageState extends State<PocketDetailsPage> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  
  String? _selectedIcon;
  SavingsGoalType? _selectedSavingsGoal;
  
  List<String> _filteredSuggestions = [];
  
  // Suggestions de noms selon la catégorie
  List<String> get _nameSuggestions {
    switch (widget.category) {
      case PocketType.needs:
        return [
          'Logement', 'Alimentation', 'Transport', 'Santé', 'Factures',
          'Assurances', 'Téléphone', 'Internet', 'Électricité', 'Eau',
          'Courses', 'Carburant', 'Pharmacie', 'Frais bancaires'
        ];
      case PocketType.wants:
        return [
          'Restaurants', 'Sorties', 'Shopping', 'Vêtements', 'Loisirs',
          'Voyage', 'Sport', 'Abonnements', 'Streaming', 'Jeux',
          'Cinéma', 'Concerts', 'Cadeaux', 'Hobbies'
        ];
      case PocketType.savings:
        return [
          'Fonds d\'urgence', 'Vacances', 'Voiture', 'Appartement', 'Maison',
          'Retraite', 'Investissements', 'Formation', 'Projet', 'Réserve'
        ];
      case PocketType.custom:
        return [];
    }
  }
  
  // Icônes disponibles selon la catégorie
  List<PocketIcon> get _availableIcons {
    switch (widget.category) {
      case PocketType.needs:
        return [
          PocketIcon(id: 'home', icon: HugeIcons.strokeRoundedHome01, label: 'Maison'),
          PocketIcon(id: 'shopping', icon: HugeIcons.strokeRoundedShoppingCart01, label: 'Courses'),
          PocketIcon(id: 'car', icon: HugeIcons.strokeRoundedCar01, label: 'Transport'),
          PocketIcon(id: 'health', icon: HugeIcons.strokeRoundedHeartCheck, label: 'Santé'),
          PocketIcon(id: 'bills', icon: HugeIcons.strokeRoundedInvoice01, label: 'Factures'),
          PocketIcon(id: 'phone', icon: HugeIcons.strokeRoundedSmartPhone01, label: 'Téléphone'),
        ];
      case PocketType.wants:
        return [
          PocketIcon(id: 'restaurant', icon: HugeIcons.strokeRoundedRestaurant01, label: 'Restaurant'),
          PocketIcon(id: 'entertainment', icon: HugeIcons.strokeRoundedGameController01, label: 'Loisirs'),
          PocketIcon(id: 'shopping_bag', icon: HugeIcons.strokeRoundedShoppingBag01, label: 'Shopping'),
          PocketIcon(id: 'travel', icon: HugeIcons.strokeRoundedAirplane01, label: 'Voyage'),
          PocketIcon(id: 'sport', icon: HugeIcons.strokeRoundedFootball, label: 'Sport'),
          PocketIcon(id: 'music', icon: HugeIcons.strokeRoundedMusicNote01, label: 'Musique'),
        ];
      case PocketType.savings:
        return [
          PocketIcon(id: 'piggy_bank', icon: HugeIcons.strokeRoundedTarget01, label: 'Épargne'),
          PocketIcon(id: 'emergency', icon: HugeIcons.strokeRoundedShield01, label: 'Urgence'),
          PocketIcon(id: 'vacation', icon: HugeIcons.strokeRoundedBeach, label: 'Vacances'),
          PocketIcon(id: 'investment', icon: HugeIcons.strokeRoundedTradeMark, label: 'Investissement'),
          PocketIcon(id: 'house_project', icon: HugeIcons.strokeRoundedBuilding01, label: 'Immobilier'),
          PocketIcon(id: 'education', icon: HugeIcons.strokeRoundedBook01, label: 'Formation'),
        ];
      case PocketType.custom:
        return [];
    }
  }
  
  // Couleurs automatiquement attribuées selon la catégorie (méthode 50/30/20)

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
    
    // Sélections par défaut
    _selectedIcon = _availableIcons.first.id;
    
    // Démarrer l'animation
    _animationController.forward();
    
    // Écouter les changements de texte pour les suggestions
    _nameController.addListener(_updateSuggestions);
  }
  
  String _getDefaultColor() {
    switch (widget.category) {
      case PocketType.needs:
        return '#3B82F6'; // Bleu pour les besoins (50%)
      case PocketType.wants:
        return '#8B5CF6'; // Violet pour les envies (30%)
      case PocketType.savings:
        return '#10B981'; // Vert pour l'épargne (20%)
      case PocketType.custom:
        return '#3B82F6';
    }
  }
  

  
  void _updateSuggestions() {
    final query = _nameController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredSuggestions = []);
      return;
    }
    
    setState(() {
      _filteredSuggestions = _nameSuggestions
          .where((suggestion) => 
              suggestion.toLowerCase().contains(query) && 
              suggestion.toLowerCase() != query)
          .take(4)
          .toList();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
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
          'Personnalisez votre pocket',
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
          'Choisissez un nom, une icône et une couleur',
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
                '2',
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
                  'Étape 2 sur 4',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personnalisation',
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
              widthFactor: 0.5, // 2/4 = 50%
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section nom
        _buildNameSection(isDark),
        
        const SizedBox(height: 32),
        
        // Section icône
        _buildIconSection(isDark),
        
        const SizedBox(height: 32),
        

        
        // Section objectif d'épargne (seulement pour savings)
        if (widget.category == PocketType.savings)
          _buildSavingsGoalSection(isDark),
      ],
    );
  }

  Widget _buildNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nom du pocket',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Donnez un nom à votre pocket pour l\'identifier facilement',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: 16),
        
        TextField(
          controller: _nameController,
          focusNode: _nameFocusNode,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: 'Ex: Logement, Sorties, Épargne...',
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
        
        // Suggestions
        if (_filteredSuggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
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
                Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _filteredSuggestions.map((suggestion) => 
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        _nameController.text = suggestion;
                        setState(() => _filteredSuggestions = []);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildIconSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icône',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Choisissez une icône qui représente votre pocket',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _availableIcons.length,
          itemBuilder: (context, index) {
            final iconOption = _availableIcons[index];
            final isSelected = _selectedIcon == iconOption.id;
            final color = Color(int.parse(_getDefaultColor().substring(1), radix: 16) + 0xFF000000);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedIcon = iconOption.id;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? color.withValues(alpha: 0.1)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected 
                        ? color
                        : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isSelected ? color : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        iconOption.icon,
                        color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        size: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      iconOption.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }



  Widget _buildSavingsGoalSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'épargne',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.text,
          ),
        ),
        
        const SizedBox(height: 12),
        
        Text(
          'Précisez le type d\'objectif d\'épargne (optionnel)',
          style: TextStyle(
            fontSize: 14,
            color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary).withValues(alpha: 0.8),
          ),
        ),
        
        const SizedBox(height: 16),
        
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SavingsGoalType.values.map((goal) {
            final isSelected = _selectedSavingsGoal == goal;
            final label = _getSavingsGoalLabel(goal);
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedSavingsGoal = isSelected ? null : goal;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isDark ? AppColors.surfaceDark : AppColors.surface),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isSelected 
                        ? AppColors.primary 
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContinueButton(bool isDark) {
    final canContinue = _nameController.text.trim().isNotEmpty;
    
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
    if (_nameController.text.trim().isEmpty) return;
    
    HapticFeedback.mediumImpact();
    
    // Naviguer vers l'étape suivante avec navigation directe
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PocketBudgetPage(
          category: widget.category,
          name: _nameController.text.trim(),
          icon: _selectedIcon ?? '',
          color: _getDefaultColor(),
        ),
      ),
    );
  }
}

// Classes helper
class PocketIcon {
  final String id;
  final IconData icon;
  final String label;

  PocketIcon({
    required this.id,
    required this.icon,
    required this.label,
  });
} 