import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/theme_provider.dart';
import '../controllers/privacy_policy_controller.dart';
import '../widgets/privacy_policy_header.dart';
import '../widgets/privacy_policy_section.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late PrivacyPolicyController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = PrivacyPolicyController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDarkMode = themeProvider.isDarkMode;
          
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  // Header
                  const PrivacyPolicyHeader(),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),
                        
                        // Introduction
                        PrivacyPolicySection(
                          title: 'Introduction',
                          children: [
                            _buildParagraph(
                              'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              isBold: true,
                            ),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Nous respectons votre vie privée et nous nous engageons à protéger vos données personnelles. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations lorsque vous utilisez notre application de gestion de budget.',
                            ),
                          ],
                        ),
                        
                        // Collecte des données
                        PrivacyPolicySection(
                          title: 'Collecte des données',
                          children: [
                            _buildParagraph(
                              'Nous collectons les informations suivantes :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Informations de compte (nom, email, mot de passe)'),
                            _buildBulletPoint('Données financières (transactions, budgets, objectifs)'),
                            _buildBulletPoint('Données d\'utilisation (préférences, paramètres)'),
                            _buildBulletPoint('Données techniques (adresse IP, type d\'appareil)'),
                          ],
                        ),
                        
                        // Utilisation des données
                        PrivacyPolicySection(
                          title: 'Utilisation des données',
                          children: [
                            _buildParagraph(
                              'Vos données sont utilisées pour :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Fournir et améliorer nos services'),
                            _buildBulletPoint('Personnaliser votre expérience utilisateur'),
                            _buildBulletPoint('Analyser les tendances d\'utilisation'),
                            _buildBulletPoint('Assurer la sécurité de votre compte'),
                            _buildBulletPoint('Vous contacter en cas de besoin'),
                          ],
                        ),
                        
                        // Partage des données
                        PrivacyPolicySection(
                          title: 'Partage des données',
                          children: [
                            _buildParagraph(
                              'Nous ne vendons, n\'échangeons ni ne louons vos données personnelles à des tiers. Nous pouvons partager vos informations uniquement dans les cas suivants :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Avec votre consentement explicite'),
                            _buildBulletPoint('Pour respecter les obligations légales'),
                            _buildBulletPoint('Avec nos prestataires de services de confiance'),
                            _buildBulletPoint('Pour protéger nos droits et notre sécurité'),
                          ],
                        ),
                        
                        // Sécurité des données
                        PrivacyPolicySection(
                          title: 'Sécurité des données',
                          children: [
                            _buildParagraph(
                              'Nous mettons en place des mesures de sécurité appropriées pour protéger vos données :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Chiffrement des données en transit et au repos'),
                            _buildBulletPoint('Authentification sécurisée'),
                            _buildBulletPoint('Accès limité aux données personnelles'),
                            _buildBulletPoint('Surveillance continue de la sécurité'),
                            _buildBulletPoint('Sauvegardes régulières et sécurisées'),
                          ],
                        ),
                        
                        // Vos droits
                        PrivacyPolicySection(
                          title: 'Vos droits',
                          children: [
                            _buildParagraph(
                              'Vous avez les droits suivants concernant vos données :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Accéder à vos données personnelles'),
                            _buildBulletPoint('Corriger des données inexactes'),
                            _buildBulletPoint('Supprimer vos données'),
                            _buildBulletPoint('Limiter le traitement de vos données'),
                            _buildBulletPoint('Exporter vos données'),
                            _buildBulletPoint('Retirer votre consentement'),
                          ],
                        ),
                        
                        // Cookies et technologies similaires
                        PrivacyPolicySection(
                          title: 'Cookies et technologies similaires',
                          children: [
                            _buildParagraph(
                              'Notre application peut utiliser des cookies et des technologies similaires pour :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Mémoriser vos préférences'),
                            _buildBulletPoint('Analyser l\'utilisation de l\'application'),
                            _buildBulletPoint('Améliorer les performances'),
                            _buildBulletPoint('Assurer la sécurité'),
                          ],
                        ),
                        
                        // Conservation des données
                        PrivacyPolicySection(
                          title: 'Conservation des données',
                          children: [
                            _buildParagraph(
                              'Nous conservons vos données personnelles aussi longtemps que nécessaire pour :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Fournir nos services'),
                            _buildBulletPoint('Respecter nos obligations légales'),
                            _buildBulletPoint('Résoudre les litiges'),
                            _buildBulletPoint('Appliquer nos accords'),
                          ],
                        ),
                        
                        // Modifications de la politique
                        PrivacyPolicySection(
                          title: 'Modifications de la politique',
                          children: [
                            _buildParagraph(
                              'Nous pouvons mettre à jour cette politique de confidentialité de temps à autre. Nous vous informerons de tout changement important par :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Notification dans l\'application'),
                            _buildBulletPoint('Email de notification'),
                            _buildBulletPoint('Publication sur notre site web'),
                          ],
                        ),
                        
                        // Contact
                        PrivacyPolicySection(
                          title: 'Nous contacter',
                          children: [
                            _buildParagraph(
                              'Si vous avez des questions concernant cette politique de confidentialité, contactez-nous :',
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfo('Email', 'privacy@pocketwise.com'),
                            _buildContactInfo('Adresse', '123 Rue de la Confidentialité, 75000 Paris, France'),
                            _buildContactInfo('Téléphone', '+33 1 23 45 67 89'),
                          ],
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildParagraph(String text, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 8, right: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


} 