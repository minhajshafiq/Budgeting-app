import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../utils/theme_provider.dart';
import '../controllers/legal_notices_controller.dart';
import '../widgets/legal_notices_header.dart';
import '../widgets/privacy_policy_section.dart';

class LegalNoticesScreen extends StatefulWidget {
  const LegalNoticesScreen({super.key});

  @override
  State<LegalNoticesScreen> createState() => _LegalNoticesScreenState();
}

class _LegalNoticesScreenState extends State<LegalNoticesScreen> {
  late LegalNoticesController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = LegalNoticesController();
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
                  const LegalNoticesHeader(),
                  
                  // Content
                  Expanded(
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 8),
                        
                        // Éditeur
                        PrivacyPolicySection(
                          title: 'Éditeur',
                          children: [
                            _buildParagraph(
                              'Cette application mobile est éditée par :',
                              isBold: true,
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfo('Raison sociale', 'PocketWise SARL'),
                            _buildContactInfo('Adresse', '123 Rue de l\'Innovation, 75000 Paris, France'),
                            _buildContactInfo('Téléphone', '+33 1 23 45 67 89'),
                            _buildContactInfo('Email', 'contact@pocketwise.com'),
                            _buildContactInfo('SIRET', '123 456 789 00012'),
                            _buildContactInfo('Capital social', '50 000 €'),
                            _buildContactInfo('RCS', 'Paris B 123 456 789'),
                          ],
                        ),
                        
                        // Directeur de publication
                        PrivacyPolicySection(
                          title: 'Directeur de publication',
                          children: [
                            _buildParagraph(
                              'Le directeur de publication est :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('M. Jean Dupont'),
                            _buildBulletPoint('Directeur Général'),
                            _buildBulletPoint('Email : direction@pocketwise.com'),
                          ],
                        ),
                        
                        // Hébergement
                        PrivacyPolicySection(
                          title: 'Hébergement',
                          children: [
                            _buildParagraph(
                              'L\'application et ses données sont hébergées par :',
                              isBold: true,
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfo('Hébergeur', 'Supabase Inc.'),
                            _buildContactInfo('Adresse', '2018 156th Ave NE, Bellevue, WA 98007, USA'),
                            _buildContactInfo('Site web', 'https://supabase.com'),
                            _buildContactInfo('Email', 'support@supabase.com'),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Les données sont stockées sur des serveurs sécurisés en Europe conformément au RGPD.',
                            ),
                          ],
                        ),
                        
                        // Propriété intellectuelle
                        PrivacyPolicySection(
                          title: 'Propriété intellectuelle',
                          children: [
                            _buildParagraph(
                              'L\'ensemble de ce site relève de la législation française et internationale sur le droit d\'auteur et la propriété intellectuelle. Tous les droits de reproduction sont réservés, y compris pour les documents téléchargeables et les représentations iconographiques et photographiques.',
                            ),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'La reproduction de tout ou partie de ce site sur un support électronique quel qu\'il soit est formellement interdite sauf autorisation expresse du directeur de la publication.',
                            ),
                          ],
                        ),
                        
                        // Marques déposées
                        PrivacyPolicySection(
                          title: 'Marques déposées',
                          children: [
                            _buildParagraph(
                              'Les marques et logos figurant sur ce site sont des marques déposées. Toute reproduction totale ou partielle de ces marques et/ou logos, effectuée à partir des éléments du site sans l\'autorisation expresse de l\'exploitant du site Internet est donc prohibée, au sens de l\'article L.713-2 du Code de la propriété intellectuelle.',
                            ),
                          ],
                        ),
                        
                        // Liens hypertextes
                        PrivacyPolicySection(
                          title: 'Liens hypertextes',
                          children: [
                            _buildParagraph(
                              'Les liens hypertextes mis en place dans le cadre du présent site web en direction d\'autres ressources présentes sur le réseau Internet ne sauraient engager la responsabilité de l\'éditeur.',
                            ),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'L\'éditeur ne peut être tenu responsable du contenu des sites vers lesquels des liens sont établis.',
                            ),
                          ],
                        ),
                        
                        // Cookies
                        PrivacyPolicySection(
                          title: 'Cookies',
                          children: [
                            _buildParagraph(
                              'L\'application peut utiliser des cookies pour :',
                            ),
                            const SizedBox(height: 12),
                            _buildBulletPoint('Mémoriser vos préférences de connexion'),
                            _buildBulletPoint('Analyser le trafic et l\'utilisation de l\'application'),
                            _buildBulletPoint('Améliorer les performances et la sécurité'),
                            _buildBulletPoint('Personnaliser votre expérience utilisateur'),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Vous pouvez désactiver les cookies dans les paramètres de votre navigateur, mais cela peut affecter le fonctionnement de l\'application.',
                            ),
                          ],
                        ),
                        
                        // Données personnelles
                        PrivacyPolicySection(
                          title: 'Données personnelles',
                          children: [
                            _buildParagraph(
                              'Conformément à la loi Informatique et Libertés du 6 janvier 1978 modifiée et au Règlement Général sur la Protection des Données (RGPD), vous disposez d\'un droit d\'accès, de rectification, de suppression et d\'opposition aux données personnelles vous concernant.',
                            ),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Pour exercer ces droits, vous pouvez nous contacter à l\'adresse email : privacy@pocketwise.com',
                            ),
                          ],
                        ),
                        
                        // Responsabilité
                        PrivacyPolicySection(
                          title: 'Responsabilité',
                          children: [
                            _buildParagraph(
                              'L\'éditeur s\'efforce d\'assurer au mieux de ses possibilités l\'exactitude et la mise à jour des informations diffusées sur ce site, dont il se réserve le droit de corriger, à tout moment et sans préavis, le contenu.',
                            ),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'L\'éditeur ne peut être tenu responsable des dommages directs ou indirects causés au matériel de l\'utilisateur lors de l\'accès au site.',
                            ),
                          ],
                        ),
                        
                        // Droit applicable
                        PrivacyPolicySection(
                          title: 'Droit applicable',
                          children: [
                            _buildParagraph(
                              'Tout litige en relation avec l\'utilisation du site est soumis au droit français. En dehors des cas où la loi ne le permet pas, il est fait attribution exclusive de juridiction aux tribunaux compétents de Paris.',
                            ),
                          ],
                        ),
                        
                        // Contact
                        PrivacyPolicySection(
                          title: 'Nous contacter',
                          children: [
                            _buildParagraph(
                              'Pour toute question concernant ces mentions légales :',
                            ),
                            const SizedBox(height: 16),
                            _buildContactInfo('Email', 'legal@pocketwise.com'),
                            _buildContactInfo('Adresse', '123 Rue de l\'Innovation, 75000 Paris, France'),
                            _buildContactInfo('Téléphone', '+33 1 23 45 67 89'),
                            const SizedBox(height: 16),
                            _buildParagraph(
                              'Dernière mise à jour : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                              isBold: true,
                            ),
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