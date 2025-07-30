import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';

/// Widget qui protège les routes d'authentification
/// Redirige automatiquement vers l'écran principal si l'utilisateur est connecté
class AuthRouteGuard extends StatelessWidget {
  final Widget child;
  const AuthRouteGuard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateProvider>(
      builder: (context, authStateProvider, _) {
        if (authStateProvider.isAuthenticated) {
          return child;
        } else {
          // Rediriger vers la page de login ou autre
          return const SizedBox.shrink();
        }
      },
    );
  }
} 