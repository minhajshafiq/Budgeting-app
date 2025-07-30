import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';

class Step4IncomeTypes extends StatelessWidget {
  const Step4IncomeTypes({super.key});

  static const List<String> _incomeTypes = [
    'Salaire',
    'Freelance',
    'Investissements',
    'Entreprise',
    'Pension',
    'Autre',
  ];

  static const Map<String, IconData> _icons = {
    'Salaire': Icons.work_outline,
    'Freelance': Icons.computer_outlined,
    'Investissements': Icons.trending_up_outlined,
    'Entreprise': Icons.business_outlined,
    'Pension': Icons.elderly_outlined,
    'Autre': Icons.more_horiz_outlined,
  };

  static const Map<String, Color> _colors = {
    'Salaire': Color(0xFFF48A99), // Rose pastel
    'Freelance': Color(0xFF78D078), // Vert pastel
    'Investissements': Color(0xFF6BC6EA), // Bleu pastel
    'Entreprise': Color(0xFFFFB67A), // Orange pastel
    'Pension': Color(0xFFB19CD9), // Violet pastel
    'Autre': Color(0xFFF0E68C), // Jaune pastel
  };

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
                  
                  Text(
                    'Types de revenus',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'Sélectionnez tous les types de revenus qui s\'appliquent à votre situation',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Grille des types de revenus
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35, // plus haut pour 2 colonnes
                    ),
                    itemCount: _incomeTypes.length,
                    itemBuilder: (context, index) {
                      final incomeType = _incomeTypes[index];
                      final isSelected = dataManager.incomeTypes?.contains(incomeType) ?? false;
                      final icon = _icons[incomeType]!;
                      final color = _colors[incomeType]!;
                      return ModernSelectableCard(
                        label: incomeType,
                        icon: icon,
                        color: color,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelected) {
                            final updatedTypes = List<String>.from(dataManager.incomeTypes ?? []);
                            updatedTypes.remove(incomeType);
                            dataManager.updateIncomeTypes(updatedTypes);
                          } else {
                            final updatedTypes = List<String>.from(dataManager.incomeTypes ?? []);
                            updatedTypes.add(incomeType);
                            dataManager.updateIncomeTypes(updatedTypes);
                          }
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
            
            // Message d'aide flottant
            if ((dataManager.incomeTypes?.isEmpty ?? true))
              Positioned(
                top: 80, // Position après le titre et la description
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  opacity: (dataManager.incomeTypes?.isEmpty ?? true) ? 1.0 : 0.0,
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
                            'Veuillez sélectionner au moins un type de revenu pour continuer',
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
        padding: const EdgeInsets.all(12),
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
                width: 44,
                height: 44,
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
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14.5,
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