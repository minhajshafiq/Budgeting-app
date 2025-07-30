import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';
import 'dart:ui'; // Pour ImageFilter

class Step6ComfortLevel extends StatelessWidget {
  const Step6ComfortLevel({super.key});

  static const List<Map<String, dynamic>> _comfortLevels = [
    {
      'title': 'Débutant',
      'subtitle': 'Je commence à gérer mes finances',
      'description': 'Je découvre la gestion d\'argent et j\'apprends les bases',
      'icon': Icons.school_outlined,
      'color': Colors.green,
      'features': [
        'Tutoriels et guides pas à pas',
        'Interface simplifiée',
        'Conseils personnalisés',
        'Notifications d\'aide',
      ],
    },
    {
      'title': 'Intermédiaire',
      'subtitle': 'J\'ai déjà de l\'expérience',
      'description': 'Je connais les bases et je veux optimiser ma gestion',
      'icon': Icons.trending_up_outlined,
      'color': Colors.blue,
      'features': [
        'Analyses détaillées',
        'Outils d\'optimisation',
        'Comparaisons avancées',
        'Stratégies d\'investissement',
      ],
    },
    {
      'title': 'Avancé',
      'subtitle': 'Je suis à l\'aise avec la finance',
      'description': 'Je maîtrise la gestion financière et je veux des outils puissants',
      'icon': Icons.analytics_outlined,
      'color': Colors.purple,
      'features': [
        'Analyses complexes',
        'Intégrations avancées',
        'Outils de trading',
        'Portfolio management',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SignupDataManager>(
      builder: (context, dataManager, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // Titre de l'étape
              Text(
                'Niveau de confort avec les finances',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Cela nous aide à personnaliser votre expérience et les fonctionnalités proposées',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Liste des niveaux
              ...List.generate(_comfortLevels.length, (index) {
                final level = _comfortLevels[index];
                final isSelected = dataManager.comfortLevel == level['title'];
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildComfortLevelCard(
                    context,
                    level,
                    isSelected,
                    () {
                      dataManager.updateComfortLevel(level['title']);
                    },
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Message d'aide
              if (dataManager.comfortLevel == null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Veuillez sélectionner votre niveau de confort pour continuer',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComfortLevelCard(
    BuildContext context,
    Map<String, dynamic> level,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark 
                ? Theme.of(context).colorScheme.surface
                : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? level['color'].withOpacity(0.85)
                  : (isDark 
                      ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                      : Colors.transparent),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: level['color'].withOpacity(0.13),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: isDark 
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec icône et titre
                      Row(
                        children: [
                          // Icône dans cercle dégradé
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  level['color'].withOpacity(0.85),
                                  level['color'].withOpacity(0.55),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: level['color'].withOpacity(0.18),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                level['icon'],
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 22),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  level['title'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? level['color']
                                        : Theme.of(context).colorScheme.onSurface,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  level['subtitle'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Indicateur de sélection moderne
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                            child: isSelected
                                ? Container(
                                    key: const ValueKey('selected'),
                                    margin: const EdgeInsets.only(left: 16, right: 4),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: level['color'],
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: level['color'].withOpacity(0.18),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  )
                                : const SizedBox(width: 0, height: 0),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Description
                      Text(
                        level['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Fonctionnalités incluses
                      Text(
                        'Fonctionnalités incluses :',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...level['features'].map<Widget>((feature) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 15,
                              color: isSelected
                                  ? level['color']
                                  : level['color'].withOpacity(0.5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // En-tête avec icône et titre
                          Row(
                            children: [
                              // Icône dans cercle dégradé
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      level['color'].withOpacity(0.85),
                                      level['color'].withOpacity(0.55),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: level['color'].withOpacity(0.18),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    level['icon'],
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      level['title'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: isSelected
                                            ? level['color']
                                            : Theme.of(context).colorScheme.onSurface,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      level['subtitle'],
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Indicateur de sélection moderne
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                                child: isSelected
                                    ? Container(
                                        key: const ValueKey('selected'),
                                        margin: const EdgeInsets.only(left: 16, right: 4),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: level['color'],
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: level['color'].withOpacity(0.18),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      )
                                    : const SizedBox(width: 0, height: 0),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Description
                          Text(
                            level['description'],
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Fonctionnalités incluses
                          Text(
                            'Fonctionnalités incluses :',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...level['features'].map<Widget>((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 15,
                                  color: isSelected
                                      ? level['color']
                                      : level['color'].withOpacity(0.5),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
} 