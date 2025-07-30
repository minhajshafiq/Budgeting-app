import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';
import '../screens/main_screen.dart';

class AuthGuard extends StatelessWidget {
  final Widget? child;
  const AuthGuard({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthStateProvider>(
      builder: (context, authStateProvider, child) {
        debugPrint('🔐 AuthGuard - État: ${authStateProvider.state}, Authentifié: ${authStateProvider.isAuthenticated}');
        
        // Afficher un indicateur de chargement pendant la vérification
        if (authStateProvider.state == AuthState.initial || authStateProvider.state == AuthState.loading) {
          debugPrint('⏳ AuthGuard - Affichage de l\'écran de chargement');
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Chargement...',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Si l'utilisateur n'est pas authentifié, afficher la page d'accueil
        if (!authStateProvider.isAuthenticated || authStateProvider.currentUser == null) {
          debugPrint('🔓 AuthGuard - Redirection vers la page d\'accueil');
          return const WelcomeAuthPage();
        }

        // Si l'utilisateur est authentifié, afficher l'écran principal
        debugPrint('🔒 AuthGuard - Affichage de l\'écran principal');
        return child ?? const MainScreen();
      },
      child: child,
    );
  }
}

// Page d'accueil avec choix entre login et signup
class WelcomeAuthPage extends StatelessWidget {
  const WelcomeAuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              // Logo ou titre
              const Icon(
                Icons.account_balance_wallet,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              Text(
                'Bienvenue !',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
              ),
                textAlign: TextAlign.center,
            ),
              const SizedBox(height: 8),
              Text(
                'Gérez votre budget en toute simplicité',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
              ),
                textAlign: TextAlign.center,
            ),
              const SizedBox(height: 48),
            
              // Bouton Connexion
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Se connecter',
              style: TextStyle(
                fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bouton Inscription
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.blue,
                    side: const BorderSide(color: Colors.blue),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Créer un compte',
              style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
} 