import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';

class Step5FinancialGoals extends StatelessWidget {
  const Step5FinancialGoals({super.key});

  final List<Map<String, dynamic>> _financialGoals = const [
    {
      'title': 'Épargner',
      'description': 'Mettre de l\'argent de côté pour un objectif futur',
      'icon': Icons.savings_outlined,
      'color': Color(0xFF78D078), // Vert pastel
    },
    {
      'title': 'Investir',
      'description': 'Faire fructifier mon argent sur le long terme',
      'icon': Icons.trending_up_outlined,
      'color': Color(0xFF6BC6EA), // Bleu pastel
    },
    {
      'title': 'Gérer mes dépenses',
      'description': 'Mieux contrôler et optimiser mes dépenses quotidiennes',
      'icon': Icons.account_balance_wallet_outlined,
      'color': Color(0xFFFFB67A), // Orange pastel
    },
    {
      'title': 'Préparer ma retraite',
      'description': 'Constituer un capital pour ma retraite',
      'icon': Icons.elderly_outlined,
      'color': Color(0xFFB19CD9), // Violet pastel
    },
    {
      'title': 'Acheter un bien immobilier',
      'description': 'Épargner pour l\'achat d\'une maison ou un appartement',
      'icon': Icons.home_outlined,
      'color': Color(0xFFF48A99), // Rose pastel
    },
    {
      'title': 'Autre',
      'description': 'Un objectif personnel spécifique',
      'icon': Icons.more_horiz_outlined,
      'color': Color(0xFFF0E68C), // Jaune pastel
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupDataManager>(
      builder: (context, dataManager, child) {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  // Titre de l'étape
                  Text(
                    'Objectif financier principal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Quel est votre objectif principal pour utiliser cette application ?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Grille des objectifs financiers
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2, // Réduit pour plus d'espace vertical
                    ),
                    itemCount: _financialGoals.length,
                    itemBuilder: (context, index) {
                      final goal = _financialGoals[index];
                      final isSelected = dataManager.financialGoals?.contains(goal['title']) ?? false;
                      return ModernSelectableCard(
                        label: goal['title'],
                        icon: goal['icon'],
                        color: goal['color'],
                        isSelected: isSelected,
                        onTap: () {
                          final updatedGoals = List<String>.from(dataManager.financialGoals ?? []);
                          if (isSelected) {
                            updatedGoals.remove(goal['title']);
                          } else {
                            updatedGoals.add(goal['title']);
                          }
                          dataManager.updateFinancialGoals(updatedGoals);
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
            
            // Message d'aide flottant
            if ((dataManager.financialGoals?.isEmpty ?? true))
              Positioned(
                top: 80, // Position après le titre et la description
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  opacity: (dataManager.financialGoals?.isEmpty ?? true) ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Veuillez sélectionner un objectif financier pour continuer',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class ModernSelectableCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const ModernSelectableCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.13)
              : Theme.of(context).colorScheme.surface.withOpacity(0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? color.withOpacity(0.13) : Colors.black.withOpacity(0.03),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 1),
            ),
          ],
          backgroundBlendMode: BlendMode.luminosity,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône avec gradient et ombre comme dans pockets
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            color,
                            color.withOpacity(0.7),
                          ]
                        : [
                            color.withOpacity(0.3),
                            color.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.85),
                  letterSpacing: 0.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 