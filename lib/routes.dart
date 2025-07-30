import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'presentation/auth/screens/login/login_page.dart';
import 'presentation/auth/screens/signup/signup_page_modular.dart';
import 'presentation/settings/screens/accounts_screen.dart';
import 'presentation/settings/screens/privacy_policy_screen.dart';
import 'presentation/settings/screens/terms_of_service_screen.dart';
import 'presentation/settings/screens/legal_notices_screen.dart';
import 'presentation/notifications/screens/notifications_screen.dart';
import 'presentation/statistics/screens/statistics_screen.dart';
import 'presentation/transactions_history/screens/transaction_history_screen.dart';
import 'presentation/pockets/pockets_list/screens/pockets_list_page.dart';
import 'presentation/pockets/pocket_details/screens/pocket_detail_screen.dart';
import 'data/models/pocket.dart';
import 'data/models/transaction.dart';
import 'widgets/auth_guard.dart';

// Import des pages d'ajout de pockets
import 'screens/add_pocket/pocket_category_page.dart';
import 'screens/add_pocket/pocket_details_page.dart';
import 'screens/add_pocket/savings_details_page.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const AuthGuard(child: MainScreen()));
    case '/login':
      return MaterialPageRoute(builder: (_) => const LoginPage());
    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignupPageModular());
    case '/accounts':
      return MaterialPageRoute(builder: (_) => const AccountsScreen());
    case '/privacy_policy':
      return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
    case '/terms_of_service':
      return MaterialPageRoute(builder: (_) => const TermsOfServiceScreen());
    case '/legal_notices':
      return MaterialPageRoute(builder: (_) => const LegalNoticesScreen());
    case '/notifications':
      return MaterialPageRoute(builder: (_) => const NotificationsScreen());
    case '/statistics':
      return MaterialPageRoute(builder: (_) => const StatisticsScreen());
    case '/transactions_history':
      return MaterialPageRoute(builder: (_) => const TransactionHistoryScreen());
    case '/pockets':
      return MaterialPageRoute(builder: (_) => const PocketsListPage());
    case '/pocket_detail':
      final args = settings.arguments;
      if (args is Pocket) {
        return MaterialPageRoute(builder: (_) => PocketDetailScreen(pocket: args));
      } else {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Argument Pocket requis pour /pocket_detail')),
          ),
        );
      }
    
    // Routes pour l'ajout de pockets
    case '/add_pocket/category':
      return MaterialPageRoute(builder: (_) => const PocketCategoryPage());
    
    case '/add-pocket/details':
      final args = settings.arguments;
      if (args is Map<String, dynamic> && args['category'] != null) {
        return MaterialPageRoute(
          builder: (_) => PocketDetailsPage(
            category: args['category'] as PocketType,
          ),
        );
      } else {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Argument category requis pour /add-pocket/details')),
          ),
        );
      }
    
    case '/add-savings/details':
      return MaterialPageRoute(builder: (_) => const SavingsDetailsPage());
    
    // Routes pour les autres pages d'ajout de pockets
    // Note: Ces pages utilisent la navigation directe avec MaterialPageRoute
    // car elles ont des paramètres requis complexes qui sont passés
    // directement lors de la navigation entre les étapes
    
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Route inconnue : \'${settings.name}\''),
          ),
        ),
      );
  }
} 