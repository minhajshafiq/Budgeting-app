import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';

class Step8TrackingFrequency extends StatelessWidget {
  const Step8TrackingFrequency({super.key});

  static const List<Map<String, dynamic>> _trackingFrequencies = [
    {
      'title': 'Quotidien',
      'description': 'Suivi quotidien de vos finances',
      'icon': Icons.calendar_today_outlined,
      'color': Color(0xFF78D078), // Vert pastel
    },
    {
      'title': 'Hebdomadaire',
      'description': 'Bilan hebdomadaire de vos finances',
      'icon': Icons.view_week_outlined,
      'color': Color(0xFF6BC6EA), // Bleu pastel
    },
    {
      'title': 'Mensuel',
      'description': 'Vue d\'ensemble mensuelle',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFFB19CD9), // Violet pastel
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
                    'Fréquence de suivi',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Text(
                    'À quelle fréquence souhaitez-vous suivre vos finances ?',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Grille des fréquences
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 2.5,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _trackingFrequencies.length,
                    itemBuilder: (context, index) {
                      final frequency = _trackingFrequencies[index];
                      final isSelected = dataManager.trackingFrequency == frequency['title'];
                      
                      return _buildFrequencyCard(
                        context,
                        frequency,
                        isSelected,
                        () {
                          dataManager.updateTrackingFrequency(frequency['title']);
                        },
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
            
            // Message d'aide flottant
            if (dataManager.trackingFrequency == null)
              Positioned(
                top: 80,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.3),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
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
                          'Veuillez sélectionner une fréquence de suivi pour continuer',
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
          ],
        );
      },
    );
  }

  Widget _buildFrequencyCard(
    BuildContext context,
    Map<String, dynamic> frequency,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected 
              ? frequency['color'].withOpacity(0.13)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? frequency['color']
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? frequency['color'].withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 4 : 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icône avec gradient et ombre comme dans pockets
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isSelected
                        ? [
                            frequency['color'],
                            frequency['color'].withOpacity(0.7),
                          ]
                        : [
                            frequency['color'].withOpacity(0.3),
                            frequency['color'].withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: frequency['color'].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  frequency['icon'],
                  color: isSelected ? Colors.white : frequency['color'],
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Contenu textuel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      frequency['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected 
                            ? frequency['color']
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      frequency['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicateur de sélection
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: frequency['color'],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: frequency['color'].withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 