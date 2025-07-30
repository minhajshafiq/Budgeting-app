import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/constants/constants.dart';
import '../../../widgets/modern_animations.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/balance_card.dart';
import '../widgets/weekly_spending_card.dart';
import '../widgets/home_navigation.dart';
import '../widgets/recent_transactions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late HomeController _homeController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    // Initialiser le provider de transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
      transactionProvider.initialize();
      
      // Déclencher les analyses de notifications après l'initialisation
      Future.delayed(const Duration(seconds: 2), () {
        transactionProvider.performComprehensiveAnalysis([]);
      });
    });
    
    // Initialiser le contrôleur
    _initializeController();
  }
  
  void _initializeController() {
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    final notificationService = NotificationService();
    
    _homeController = HomeController(transactionProvider, notificationService);
    _homeController.initialize(this);
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _homeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppPadding.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                
                // Header avec RepaintBoundary pour optimiser les redraws
                RepaintBoundary(
                  child: SlideInAnimation(
                    beginOffset: const Offset(0, -0.3),
                    duration: const Duration(milliseconds: 600),
                    child: HomeHeader(
                      onNotificationTap: () {
                        _homeController.navigateToNotifications(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Carte de solde avec RepaintBoundary
                RepaintBoundary(
                  child: SlideInAnimation(
                    beginOffset: const Offset(-0.3, 0),
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 700),
                    child: BalanceCard(
                      onTap: () {
                        _homeController.navigateToTransactionHistory(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Carte des dépenses hebdomadaires avec RepaintBoundary
                RepaintBoundary(
                  child: SlideInAnimation(
                    beginOffset: const Offset(0.3, 0),
                    delay: const Duration(milliseconds: 400),
                    duration: const Duration(milliseconds: 700),
                    child: WeeklySpendingCard(
                      animation: _isInitialized ? _homeController.fadeAnimation : null,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Navigation avec RepaintBoundary
                RepaintBoundary(
                  child: SlideInAnimation(
                    beginOffset: const Offset(0, 0.3),
                    delay: const Duration(milliseconds: 600),
                    duration: const Duration(milliseconds: 800),
                    child: HomeNavigation(
                      onHistoryTap: () {
                        _homeController.navigateToTransactionHistory(context);
                      },
                      onReportsTap: () {
                        _homeController.navigateToStatistics(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Transactions récentes avec RepaintBoundary
                RepaintBoundary(
                  child: SlideInAnimation(
                    beginOffset: const Offset(0, 0.3),
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 700),
                    child: const RecentTransactions(),
                  ),
                ),
                
                // Espace en bas pour la barre de navigation
                SizedBox(height: Platform.isAndroid ? 100 : 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 