import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/theme_provider.dart';
import '../controllers/terms_of_service_controller.dart';
import '../widgets/terms_of_service_header.dart';
import '../widgets/privacy_policy_section.dart';

class TermsOfServiceScreen extends StatefulWidget {
  const TermsOfServiceScreen({super.key});

  @override
  State<TermsOfServiceScreen> createState() => _TermsOfServiceScreenState();
}

class _TermsOfServiceScreenState extends State<TermsOfServiceScreen> {
  late TermsOfServiceController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TermsOfServiceController();
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
                  const TermsOfServiceHeader(),
                  
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
                              'En utilisant notre application de gestion de budget, vous acceptez d\'être lié par ces conditions d\'utilisation. Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
                            ),
                          ],
                        ),
                        
                        // Définitions
                        PrivacyPolicySection(
                          title: 'Définitions',
                          children: [
                            _buildParagraph(
                              'Dans ces conditions d\'utilisation :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('"Application" désigne notre application mobile de gestion de budget'),
                            _buildBulletPoint('"Utilisateur" désigne toute personne utilisant l\'application'),
                            _buildBulletPoint('"Service" désigne l\'ensemble des fonctionnalités offertes par l\'application'),
                            _buildBulletPoint('"Données" désigne toutes les informations que vous saisissez dans l\'application'),
                          ],
                        ),
                        
                        // Acceptation des conditions
                        PrivacyPolicySection(
                          title: 'Acceptation des conditions',
                          children: [
                            _buildParagraph(
                              'En utilisant l\'application, vous confirmez que :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Vous avez lu et compris ces conditions d\'utilisation'),
                            _buildBulletPoint('Vous acceptez d\'être lié par ces conditions'),
                            _buildBulletPoint('Vous avez l\'âge légal pour accepter ces conditions'),
                            _buildBulletPoint('Vous avez l\'autorité pour accepter ces conditions au nom de votre organisation'),
                          ],
                        ),
                        
                        // Description du service
                        PrivacyPolicySection(
                          title: 'Description du service',
                          children: [
                            _buildParagraph(
                              'Notre application offre les fonctionnalités suivantes :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Gestion de budget et de dépenses'),
                            _buildBulletPoint('Suivi des transactions financières'),
                            _buildBulletPoint('Création et gestion de poches d\'épargne'),
                            _buildBulletPoint('Analyse et statistiques financières'),
                            _buildBulletPoint('Synchronisation des données entre appareils'),
                            _buildBulletPoint('Sauvegarde sécurisée de vos données'),
                          ],
                        ),
                        
                        // Compte utilisateur
                        PrivacyPolicySection(
                          title: 'Compte utilisateur',
                          children: [
                            _buildParagraph(
                              'Pour utiliser l\'application, vous devez :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Créer un compte avec des informations exactes'),
                            _buildBulletPoint('Maintenir la confidentialité de vos identifiants'),
                            _buildBulletPoint('Nous informer immédiatement de toute utilisation non autorisée'),
                            _buildBulletPoint('Être responsable de toutes les activités sous votre compte'),
                            _buildBulletPoint('Avoir un seul compte par personne'),
                          ],
                        ),
                        
                        // Utilisation acceptable
                        PrivacyPolicySection(
                          title: 'Utilisation acceptable',
                          children: [
                            _buildParagraph(
                              'Vous vous engagez à :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Utiliser l\'application conformément à la loi'),
                            _buildBulletPoint('Ne pas utiliser l\'application à des fins illégales'),
                            _buildBulletPoint('Ne pas tenter d\'accéder aux systèmes de l\'application'),
                            _buildBulletPoint('Ne pas perturber le fonctionnement de l\'application'),
                            _buildBulletPoint('Respecter les droits de propriété intellectuelle'),
                            _buildBulletPoint('Ne pas transmettre de virus ou de code malveillant'),
                          ],
                        ),
                        
                        // Utilisation interdite
                        PrivacyPolicySection(
                          title: 'Utilisation interdite',
                          children: [
                            _buildParagraph(
                              'Il est interdit de :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Utiliser l\'application pour des activités frauduleuses'),
                            _buildBulletPoint('Tenter de pirater ou de compromettre la sécurité'),
                            _buildBulletPoint('Utiliser des bots ou des scripts automatisés'),
                            _buildBulletPoint('Partager votre compte avec d\'autres personnes'),
                            _buildBulletPoint('Utiliser l\'application pour harceler ou intimider'),
                            _buildBulletPoint('Violer les droits de propriété intellectuelle'),
                          ],
                        ),
                        
                        // Propriété intellectuelle
                        PrivacyPolicySection(
                          title: 'Propriété intellectuelle',
                          children: [
                            _buildParagraph(
                              'L\'application et son contenu sont protégés par :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Les droits d\'auteur et marques déposées'),
                            _buildBulletPoint('Les brevets et secrets commerciaux'),
                            _buildBulletPoint('Les lois sur la propriété intellectuelle'),
                            _buildBulletPoint('Les accords de licence'),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Vous conservez la propriété de vos données, mais nous détenons les droits sur l\'application et ses fonctionnalités.',
                            ),
                          ],
                        ),
                        
                        // Limitation de responsabilité
                        PrivacyPolicySection(
                          title: 'Limitation de responsabilité',
                          children: [
                            _buildParagraph(
                              'Dans toute la mesure permise par la loi :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Nous ne sommes pas responsables des pertes financières'),
                            _buildBulletPoint('Nous ne garantissons pas l\'exactitude des données'),
                            _buildBulletPoint('Nous ne sommes pas responsables des interruptions de service'),
                            _buildBulletPoint('Notre responsabilité est limitée aux dommages directs'),
                            _buildBulletPoint('Nous ne sommes pas responsables des actions des tiers'),
                          ],
                        ),
                        
                        // Indemnisation
                        PrivacyPolicySection(
                          title: 'Indemnisation',
                          children: [
                            _buildParagraph(
                              'Vous acceptez de nous indemniser contre :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Toute réclamation liée à votre utilisation de l\'application'),
                            _buildBulletPoint('Toute violation de ces conditions d\'utilisation'),
                            _buildBulletPoint('Toute activité frauduleuse ou illégale'),
                            _buildBulletPoint('Toute atteinte aux droits de tiers'),
                          ],
                        ),
                        
                        // Résiliation
                        PrivacyPolicySection(
                          title: 'Résiliation',
                          children: [
                            _buildParagraph(
                              'Nous pouvons résilier votre accès :',
                              isBold: true,
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('En cas de violation de ces conditions'),
                            _buildBulletPoint('Pour des raisons de sécurité'),
                            _buildBulletPoint('En cas d\'utilisation frauduleuse'),
                            _buildBulletPoint('Sur demande de l\'utilisateur'),
                            _buildBulletPoint('Pour des raisons techniques ou légales'),
                          ],
                        ),
                        
                        // Modifications des conditions
                        PrivacyPolicySection(
                          title: 'Modifications des conditions',
                          children: [
                            _buildParagraph(
                              'Nous nous réservons le droit de modifier ces conditions :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Pour améliorer nos services'),
                            _buildBulletPoint('Pour respecter les nouvelles réglementations'),
                            _buildBulletPoint('Pour corriger des erreurs ou omissions'),
                            _buildBulletPoint('Pour des raisons de sécurité'),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Les modifications seront notifiées dans l\'application et prendront effet immédiatement.',
                            ),
                          ],
                        ),
                        
                        // Droit applicable
                        PrivacyPolicySection(
                          title: 'Droit applicable',
                          children: [
                            _buildParagraph(
                              'Ces conditions sont régies par :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Le droit français'),
                            _buildBulletPoint('Les tribunaux français compétents'),
                            _buildBulletPoint('Les conventions internationales applicables'),
                          ],
                        ),
                        
                        // Contact
                        PrivacyPolicySection(
                          title: 'Nous contacter',
                          children: [
                            _buildParagraph(
                              'Pour toute question concernant ces conditions d\'utilisation :',
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfo('Email', 'legal@pocketwise.com'),
                            _buildContactInfo('Adresse', '123 Rue de la Législation, 75000 Paris, France'),
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