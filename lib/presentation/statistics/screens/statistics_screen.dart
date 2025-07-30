import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../core/constants/constants.dart';
import '../../../core/widgets/smart_back_button.dart';
import '../../../widgets/modern_animations.dart';
import '../../../providers/transaction_provider.dart';
import '../controllers/statistics_controller.dart';
import '../widgets/chart_type_switcher.dart';
import '../widgets/expenses_card.dart';
import '../widgets/period_navigation.dart';
import '../widgets/transactions_list_card.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with TickerProviderStateMixin {
  late StatisticsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StatisticsController();
    
    // Initialiser le provider de transactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).initialize();
      _controller.initialize(this);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<StatisticsController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: AppPadding.screen,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header avec animation d'entrée
                      SlideInAnimation(
                        beginOffset: const Offset(0, -0.3),
                        duration: const Duration(milliseconds: 600),
                        child: controller.isInitialized 
                          ? FadeTransition(
                              opacity: controller.headerAnimation,
                              child: _buildHeader(context, controller, isDark),
                            )
                          : _buildHeader(context, controller, isDark),
                      ),
                      const SizedBox(height: 24),
                      
                      // Carte des dépenses avec animation
                      SlideInAnimation(
                        beginOffset: const Offset(0, 0.3),
                        delay: const Duration(milliseconds: 200),
                        duration: const Duration(milliseconds: 700),
                        child: Consumer<StatisticsController>(
                          builder: (context, ctrl, child) {
                            return ctrl.isInitialized 
                              ? FadeTransition(
                                  opacity: ctrl.cardAnimation,
                                  child: ExpensesCard(
                                    controller: ctrl,
                                    isDark: isDark,
                                  ),
                                )
                              : ExpensesCard(
                                  controller: ctrl,
                                  isDark: isDark,
                                );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Navigation temporelle avec animation
                      SlideInAnimation(
                        beginOffset: const Offset(-0.3, 0),
                        delay: const Duration(milliseconds: 400),
                        duration: const Duration(milliseconds: 600),
                        child: Consumer<StatisticsController>(
                          builder: (context, ctrl, child) {
                            return ctrl.isInitialized 
                              ? FadeTransition(
                                  opacity: ctrl.chartAnimation,
                                  child: PeriodNavigation(
                                    controller: ctrl,
                                    isDark: isDark,
                                  ),
                                )
                              : PeriodNavigation(
                                  controller: ctrl,
                                  isDark: isDark,
                                );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Liste des transactions avec animation séquentielle
                      Consumer<StatisticsController>(
                        builder: (context, ctrl, child) {
                          return TransactionsListCard(
                            controller: ctrl,
                            isDark: isDark,
                          );
                        },
                      ),
                      SizedBox(height: Platform.isAndroid ? 100 : 80),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, StatisticsController controller, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SmartBackButton(),
        Text(
          'Vos Statistiques',
          style: AppTextStyles.title(context),
        ),
        ChartTypeSwitcher(
          controller: controller,
          isDark: isDark,
        ),
      ],
    );
  }
} 