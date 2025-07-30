import 'package:flutter/material.dart';
import '../../../core/widgets/smart_back_button.dart';

class TermsOfServiceHeader extends StatelessWidget {
  const TermsOfServiceHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 40,
        child: Stack(
          children: [
            // Bouton de retour smart à gauche
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: SmartBackButton(),
            ),
            
            // Titre centré
            Center(
              child: Text(
                'Conditions d\'utilisation',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 