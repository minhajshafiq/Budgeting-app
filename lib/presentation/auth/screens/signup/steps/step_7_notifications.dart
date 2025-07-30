import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../signup_data.dart';
import 'dart:ui'; // Pour ImageFilter

class Step7Notifications extends StatelessWidget {
  const Step7Notifications({super.key});

  static const List<Map<String, dynamic>> _notificationTypes = [
    {
      'key': 'budget_exceeded',
      'title': 'Dépassement de budget',
      'description': 'Vous recevrez une alerte quand vous dépassez votre budget',
      'icon': Icons.warning_amber_outlined,
      'color': Color(0xFFFFB67A), // Orange pastel
    },
    {
      'key': 'goal_achieved',
      'title': 'Objectif atteint',
      'description': 'Célébrez vos succès quand vous atteignez vos objectifs',
      'icon': Icons.celebration_outlined,
      'color': Color(0xFF78D078), // Vert pastel
    },
    {
      'key': 'month_end',
      'title': 'Fin de mois',
      'description': 'Récapitulatif mensuel de vos finances',
      'icon': Icons.calendar_month_outlined,
      'color': Color(0xFF6BC6EA), // Bleu pastel
    },
    {
      'key': 'unusual_debit',
      'title': 'Dépense inhabituelle',
      'description': 'Alerte pour les dépenses qui sortent de vos habitudes',
      'icon': Icons.trending_down_outlined,
      'color': Color(0xFFF48A99), // Rose pastel
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
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                'Choisissez les types de notifications que vous souhaitez recevoir',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 32),
              
              // Liste des types de notifications
              ...List.generate(_notificationTypes.length, (index) {
                final notification = _notificationTypes[index];
                final isEnabled = dataManager.notificationPreferences?[notification['key']] ?? false;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildNotificationCard(
                    context,
                    notification,
                    isEnabled,
                    (value) {
                      final updatedPreferences = Map<String, dynamic>.from(dataManager.notificationPreferences ?? {});
                      updatedPreferences[notification['key']] = value;
                      dataManager.updateNotificationPreferences(updatedPreferences);
                    },
                  ),
                );
              }),
              
              const SizedBox(height: 24),
              
              // Informations sur les notifications
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'À propos des notifications',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Vous pouvez modifier ces paramètres à tout moment dans les réglages\n'
                      '• Les notifications importantes (sécurité, compte) sont toujours activées\n'
                      '• Nous respectons votre vie privée et ne partageons jamais vos données',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                        height: 1.4,
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

  Widget _buildNotificationCard(
    BuildContext context,
    Map<String, dynamic> notification,
    bool isEnabled,
    ValueChanged<bool> onChanged,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isEnabled),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isEnabled
                ? notification['color'].withOpacity(0.85)
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isEnabled ? 2 : 1,
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: notification['color'].withOpacity(0.13),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
          child: Row(
            children: [
              // Icône avec gradient et ombre comme dans pockets
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isEnabled
                        ? [
                            notification['color'],
                            notification['color'].withOpacity(0.7),
                          ]
                        : [
                            notification['color'].withOpacity(0.3),
                            notification['color'].withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: notification['color'].withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  notification['icon'],
                  color: isEnabled ? Colors.white : notification['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 18),
              // Contenu textuel
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isEnabled
                            ? notification['color']
                            : Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 0.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['description'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              // Switch moderne
              Switch(
                value: isEnabled,
                onChanged: onChanged,
                activeColor: notification['color'],
                activeTrackColor: notification['color'].withOpacity(0.25),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 