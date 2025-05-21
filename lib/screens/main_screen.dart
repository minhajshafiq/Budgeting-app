import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';
import '../widgets/fade_through_transition.dart';
import 'home_page.dart';
import 'statistics_page.dart';
import 'transaction_history_page.dart';
import 'accounts_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomePage(),
    const StatisticsPage(),
    const TransactionHistoryPage(),
    const AccountsPage(), // Page de compte implémentée
  ];
  
  // Clés pour identifier chaque écran pour l'animation
  final List<Key> _screenKeys = [
    const Key('home_page'),
    const Key('statistics_page'),
    const Key('transaction_history_page'),
    const Key('accounts_page'),
  ];

  @override
  Widget build(BuildContext context) {
    // Ne pas afficher le bouton + sur la page de statistiques (index 1)
    final bool showAddButton = _currentIndex != 1;
    
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal de l'écran avec animation Fade Through
          FadeThroughTransition(
            key: const Key('screen_transition'),
            childKey: _screenKeys[_currentIndex],
            duration: const Duration(milliseconds: 300),
            child: _screens[_currentIndex],
          ),
          
          // Barre de navigation positionnée en bas
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              onAddPressed: () {
                showAddTransactionOptions(context);
              },
              showAddButton: showAddButton,
            ),
          ),
        ],
      ),
    );
  }
  
  void showAddTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF2E3A59),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.add_circle_outline, color: Colors.green),
              ),
              title: const Text('Ajouter un revenu', style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                // Logique pour ajouter un revenu
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.remove_circle_outline, color: Colors.red),
              ),
              title: const Text('Ajouter une dépense', style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                // Logique pour ajouter une dépense
              },
            ),
          ],
        ),
      ),
    );
  }
}
