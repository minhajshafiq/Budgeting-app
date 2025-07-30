import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../data/models/pocket.dart';
import '../controllers/pocket_detail_controller.dart';
import '../widgets/pocket_header.dart';
import '../widgets/pocket_card.dart';
import '../widgets/stats_card.dart';
import '../widgets/transactions_list.dart';
import '../widgets/floating_action_button.dart';

class PocketDetailScreen extends StatefulWidget {
  final Pocket pocket;
  final Function(Pocket)? onPocketUpdated;

  const PocketDetailScreen({
    super.key,
    required this.pocket,
    this.onPocketUpdated,
  });

  @override
  State<PocketDetailScreen> createState() => _PocketDetailScreenState();
}

class _PocketDetailScreenState extends State<PocketDetailScreen> with TickerProviderStateMixin {
  late PocketDetailController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PocketDetailController();
    _controller.initialize(widget.pocket, this, onPocketUpdated: widget.onPocketUpdated);
  }

  @override
  void didUpdateWidget(PocketDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si le pocket a changé, réinitialiser le contrôleur
    if (oldWidget.pocket.id != widget.pocket.id || 
        oldWidget.pocket.transactions.length != widget.pocket.transactions.length ||
        oldWidget.pocket.spent != widget.pocket.spent) {
      print('🔄 DEBUG: Pocket mis à jour, réinitialisation du contrôleur');
      _controller.initialize(widget.pocket, this, onPocketUpdated: widget.onPocketUpdated);
    }
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
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _controller.getPocketColor().withValues(alpha: 0.05),
                (isDark ? AppColors.backgroundDark : AppColors.background).withValues(alpha: 0.95),
                isDark ? AppColors.backgroundDark : AppColors.background,
              ],
              stops: const [0.0, 0.3, 1.0],
            ),
          ),
          child: SafeArea(
            child: AnimatedBuilder(
              animation: _controller.fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _controller.fadeAnimation.value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - _controller.fadeAnimation.value) * 20),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: AppPadding.screen,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PocketHeader(
                              controller: _controller,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 32),
                            PocketCard(
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24),
                            StatsCard(
                              isDark: isDark,
                            ),
                            const SizedBox(height: 24),
                            TransactionsList(
                              controller: _controller,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: PocketFloatingActionButton(
          controller: _controller,
          isDark: isDark,
        ),
      ),
    );
  }
} 