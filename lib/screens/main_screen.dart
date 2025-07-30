import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:hugeicons/hugeicons.dart';
import '../core/widgets/custom_navbar.dart';
import '../core/widgets/fade_through_transition.dart';
import '../utils/navigation_service.dart';
import '../utils/user_provider.dart';
import '../core/services/user_session_sync.dart';
import '../presentation/home/screens/home_screen.dart';
import '../presentation/statistics/screens/statistics_screen.dart';
import '../presentation/transactions_history/screens/transaction_history_screen.dart';

import '../presentation/pockets/pockets_list/index.dart';
import 'add_pocket/pocket_category_page.dart';
import 'package:my_flutter_app/presentation/notifications/screens/notifications_screen.dart';
import 'package:my_flutter_app/core/providers/auth_state_provider.dart';
import 'package:my_flutter_app/presentation/settings/screens/accounts_screen.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late NavigationService _navigationService;
  final List<Widget> _screens = [
    const HomeScreen(),
    const StatisticsScreen(),
    const PocketsListPage(), // Page des pockets
    const AccountsScreen(), // Page de compte implémentée
  ];
  
  // Service de synchronisation des sessions utilisateur
  final UserSessionSync _userSessionSync = UserSessionSync();
  
  @override
  void initState() {
    super.initState();
    _navigationService = NavigationService();
    
    // Synchroniser les informations utilisateur seulement au premier lancement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncUserSession();
    });
  }
  
  // Méthode pour synchroniser les informations utilisateur et initialiser les providers
  void _syncUserSession() {
    final authStateProvider = Provider.of<AuthStateProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    // Synchroniser les informations utilisateur et initialiser les providers
    // (la synchronisation intelligente se fera automatiquement si nécessaire)
    _userSessionSync.syncUserInfoAndInitializeProviders(context, authStateProvider, userProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _navigationService,
      child: Consumer<NavigationService>(
        builder: (context, navigationService, child) {
          // Ne pas afficher le bouton + sur la page de statistiques (index 1)
          final bool showAddButton = navigationService.currentIndex != 1;
          
          // Icône personnalisée selon la page
          IconData? getCustomAddIcon() {
            switch (navigationService.currentIndex) {
              case 2: // Pockets page
                return HugeIcons.strokeRoundedWallet01; // Icône de wallet pour ajouter une pocket
              default:
                return HugeIcons.strokeRoundedAdd01; // Icône d'ajout standard pour les autres pages
            }
          }
          
          return Scaffold(
            body: Stack(
              children: [
                // Contenu principal de l'écran - affichage direct sans animation
                _screens[navigationService.currentIndex],
                

                
                // Barre de navigation positionnée en bas
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: Platform.isAndroid 
                    ? MediaQuery.of(context).padding.bottom // Au-dessus de la barre de navigation Android
                    : 0, // Position normale pour iOS
                  child: CustomNavBar(
                    currentIndex: navigationService.currentIndex,
                    onTap: (index) {
                      navigationService.navigateToIndex(index);
                    },
                    onAddPressed: navigationService.currentIndex == 2
                        ? () => _navigateToAddPocket()
                        : null,
                    showAddButton: showAddButton,
                    customAddIcon: getCustomAddIcon(),
                    enableHapticFeedback: true,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Navigation vers la création d'une nouvelle pocket
  /// Cette fonction est appelée uniquement depuis la page Pockets (index 2)
  void _navigateToAddPocket() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/add_pocket/category');
  }


}
