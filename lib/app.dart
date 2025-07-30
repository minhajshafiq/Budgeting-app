import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/constants.dart';
import 'core/config/supabase_config.dart';
import 'utils/performance_utils.dart';
import 'core/di/dependency_injection.dart';
import 'providers/index.dart';
import 'core/providers/auth_state_provider.dart';
import 'presentation/providers/transaction_provider_clean.dart';
import 'widgets/auth_guard.dart';
import 'utils/theme_provider.dart';
import 'utils/user_provider.dart';
import 'utils/navigation_service.dart';
import 'routes.dart';

final NavigationService navigationService = NavigationService();

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;
  String? _error;
  late ThemeProvider themeProvider;
  late UserProvider userProvider;
  late TransactionProvider transactionProvider;
  late TransactionProviderClean transactionProviderClean;
  late AuthStateProvider authStateProvider;
  late SubscriptionProvider subscriptionProvider;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      await initializeDateFormatting('fr_FR', null);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      if (!SupabaseConfig.isConfigured) {
        throw Exception('Configuration Supabase invalide. Vérifiez vos clés dans lib/core/config/supabase_config.dart');
      }
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
      await di.initialize();
      themeProvider = ThemeProvider();
      userProvider = UserProvider();
      transactionProvider = TransactionProvider();
      transactionProviderClean = di.transactionProviderClean;
      authStateProvider = di.authStateProvider;
      subscriptionProvider = SubscriptionProvider();
      themeProvider.initialize();
      await authStateProvider.checkAuthStatus();
      if (authStateProvider.isAuthenticated && authStateProvider.currentUser != null) {
        transactionProvider.initializeWithUser(authStateProvider.currentUser!.id.value);
      }
      subscriptionProvider.initializePlans();
      if (authStateProvider.isAuthenticated) {
        subscriptionProvider.fetchCurrentSubscription();
      }
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Erreur de configuration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Impossible d\'initialiser l\'application. Vérifiez votre configuration.', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Text('Erreur: $_error', style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => themeProvider, lazy: false),
        ChangeNotifierProvider<UserProvider>(create: (_) => userProvider, lazy: true),
        ChangeNotifierProvider<TransactionProvider>(create: (_) => transactionProvider, lazy: false),
        ChangeNotifierProvider<TransactionProviderClean>(create: (_) => transactionProviderClean, lazy: false),
        ChangeNotifierProvider<AuthStateProvider>(create: (_) => authStateProvider, lazy: false),
        ChangeNotifierProvider<SubscriptionProvider>(create: (_) => subscriptionProvider, lazy: false),
        Provider<NavigationService>(create: (_) => navigationService),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Gestion de Budget',
            debugShowCheckedModeBanner: false,
            theme: _buildOptimizedLightTheme(),
            darkTheme: _buildOptimizedDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            navigatorKey: navigationService.navigatorKey,
            onGenerateRoute: generateRoute,
            initialRoute: '/',
          );
        },
      ),
    );
  }

  ThemeData _buildOptimizedLightTheme() {
    return lightTheme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          animationDuration: const Duration(milliseconds: 150),
        ),
      ),
    );
  }

  ThemeData _buildOptimizedDarkTheme() {
    return darkTheme.copyWith(
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          animationDuration: const Duration(milliseconds: 150),
        ),
      ),
    );
  }
} 