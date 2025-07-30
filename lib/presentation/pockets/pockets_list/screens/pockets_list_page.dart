import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/smart_back_button.dart';
import '../../../../providers/transaction_provider.dart';
import '../../../../data/models/pocket.dart';
import '../controllers/pockets_list_controller.dart';
import '../widgets/budget_summary_card.dart';
import '../widgets/pockets_group.dart';

class PocketsListPage extends StatefulWidget {
  const PocketsListPage({super.key});

  @override
  State<PocketsListPage> createState() => _PocketsListPageState();
}

class _PocketsListPageState extends State<PocketsListPage> with TickerProviderStateMixin, WidgetsBindingObserver {
  late PocketsListController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = PocketsListController();
    _controller.initializeAnimations(this);
  }

  bool _hasInitialized = false;
  bool _hasLoadedData = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Charger les données seulement une fois au début
    if (!_hasLoadedData) {
      _hasLoadedData = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _loadDataAsync();
        }
      });
    }
    
    // Forcer une mise à jour quand on revient sur la page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _forceRefreshPockets();
      }
    });
  }

  // Charger les données de manière asynchrone
  Future<void> _loadDataAsync() async {
    // Délai pour permettre à l'UI de se charger d'abord
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (mounted) {
      // Charger les données et forcer le rafraîchissement
      _controller.loadDataAndCheckCompliance(context);
      
      // Forcer une synchronisation après un délai pour s'assurer que les nouvelles pockets sont visibles
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _controller.refreshPocketsList(context);
      }
    }
  }

  // Debounce pour éviter les mises à jour répétées
  Timer? _updateTimer;
  bool _isUpdating = false;
  
  void _debouncedUpdatePockets() {
    if (_isUpdating) {
      print('⏭️ Mise à jour déjà en cours, ignorée');
      return;
    }
    
    _updateTimer?.cancel();
    _updateTimer = Timer(const Duration(milliseconds: 1000), () async {
      if (mounted && !_isUpdating) {
        _isUpdating = true;
        try {
          await _controller.updatePocketsFromTransactions(context);
        } finally {
          _isUpdating = false;
        }
      }
    });
  }

  // Forcer le rafraîchissement des pockets
  Future<void> _forceRefreshPockets() async {
    print('🔄 Forçage du rafraîchissement des pockets');
    if (mounted) {
      await _controller.refreshPocketsList(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Rafraîchir les données quand l'app revient au premier plan
    if (state == AppLifecycleState.resumed && mounted) {
      _forceRefreshPockets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ChangeNotifierProvider.value(
      value: _controller,
              child: Consumer2<TransactionProvider, PocketsListController>(
          builder: (context, transactionProvider, pocketsController, child) {
            // Mettre à jour les pockets quand les transactions changent (avec debounce)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _debouncedUpdatePockets();
            });
            
            // Forcer une mise à jour quand on revient sur la page
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_hasInitialized) {
                _hasInitialized = true;
                _forceRefreshPockets();
              }
            });
          
          return Scaffold(
            backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
            body: Stack(
              children: [
                // Gradient de fond moderne
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.backgroundDark : const Color(0xFFF8FAFC),
                  ),
                ),
                
                // Contenu principal
                SafeArea(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Forcer le rafraîchissement de la liste des pockets
                      await _controller.refreshPocketsList(context);
                    },
                    color: AppColors.primary,
                    backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: AppPadding.screen,
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          
                          // Header simple en haut
                          AnimatedBuilder(
                            animation: _controller.fadeAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - _controller.fadeAnimation.value) * 20),
                                child: Opacity(
                                  opacity: _controller.fadeAnimation.value.clamp(0.0, 1.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const SmartBackButton(),
                                      Text(
                                        'Mes Pockets',
                                        style: AppTextStyles.title(context),
                                      ),
                                      const SizedBox(width: 40), // Pour équilibrer l'espace
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Carte de résumé moderne
                          AnimatedBuilder(
                            animation: _controller.slideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, (1 - _controller.slideAnimation.value) * 50),
                                child: Opacity(
                                  opacity: _controller.slideAnimation.value.clamp(0.0, 1.0),
                                  child: BudgetSummaryCard(
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 32),

                          // Titre des pockets avec animation
                          AnimatedBuilder(
                            animation: _controller.slideAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(-20 * (1 - _controller.slideAnimation.value), 0),
                                child: Opacity(
                                  opacity: _controller.slideAnimation.value.clamp(0.0, 1.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Vos Pockets',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.primary.withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Text(
                                          '${_controller.pockets.length}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),

                          // Liste des pockets avec animations en cascade
                          _buildModernPocketsList(isDark),
                  
                          const SizedBox(height: 120), // Espace pour la navbar
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernPocketsList(bool isDark) {
    // Grouper les pockets par type
    final groupedPockets = <PocketType, List<Pocket>>{
      PocketType.needs: _controller.pockets.where((p) => p.type == PocketType.needs).toList(),
      PocketType.wants: _controller.pockets.where((p) => p.type == PocketType.wants).toList(),
      PocketType.savings: _controller.pockets.where((p) => p.type == PocketType.savings).toList(),
    };

    return Column(
      children: groupedPockets.entries.map((entry) {
        final type = entry.key;
        final typePockets = entry.value;
        
        return PocketsGroup(
          type: type,
          pockets: typePockets,
          controller: _controller,
          isDark: isDark,
          cardAnimationController: _controller.cardAnimationController,
        );
      }).toList(),
    );
  }
} 