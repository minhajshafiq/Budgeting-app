import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utilitaires pour optimiser les performances de l'application
class PerformanceUtils {
  // Cache pour les images réseau
  static final Map<String, ImageProvider> _imageCache = {};
  
  // Limite du cache d'images (nombre d'images maximum)
  static const int _maxCacheSize = 50;
  
  // Monitoring des performances
  static final Map<String, int> _operationCounts = {};
  static final Map<String, DateTime> _operationStartTimes = {};
  static final List<PerformanceMetric> _metrics = [];
  
  /// Obtient une image depuis le cache ou la charge si nécessaire
  static ImageProvider getCachedNetworkImage(String url) {
    // Nettoyer le cache si trop plein
    if (_imageCache.length >= _maxCacheSize) {
      _cleanCache();
    }
    
    // Retourner depuis le cache ou créer une nouvelle instance
    return _imageCache.putIfAbsent(url, () => NetworkImage(url));
  }
  
  /// Nettoie le cache d'images (garde les 30 plus récentes)
  static void _cleanCache() {
    if (_imageCache.length > 30) {
      final keysToRemove = _imageCache.keys.take(_imageCache.length - 30).toList();
      for (final key in keysToRemove) {
        _imageCache.remove(key);
      }
    }
  }
  
  /// Vide complètement le cache d'images
  static void clearImageCache() {
    _imageCache.clear();
  }
  
  /// Pré-charge une image dans le cache
  static Future<void> precacheNetworkImage(String url, BuildContext context) async {
    try {
      final imageProvider = getCachedNetworkImage(url);
      await precacheImage(imageProvider, context);
    } catch (e) {
      debugPrint('Erreur lors du pré-chargement de l\'image: $e');
    }
  }
  
  /// Débounce function pour limiter les appels fréquents
  static Map<String, Timer?> _debounceTimers = {};
  
  static void debounce(String key, Duration delay, VoidCallback callback) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }
  
  /// Nettoie tous les timers de debounce
  static void clearDebounceTimers() {
    for (final timer in _debounceTimers.values) {
      timer?.cancel();
    }
    _debounceTimers.clear();
  }
  
  /// Monitoring des performances
  static void startOperation(String operationName) {
    _operationStartTimes[operationName] = DateTime.now();
    _operationCounts[operationName] = (_operationCounts[operationName] ?? 0) + 1;
  }
  
  static void endOperation(String operationName) {
    final startTime = _operationStartTimes[operationName];
    if (startTime != null) {
      final duration = DateTime.now().difference(startTime);
      _metrics.add(PerformanceMetric(
        operation: operationName,
        duration: duration,
        timestamp: DateTime.now(),
      ));
      _operationStartTimes.remove(operationName);
    }
  }
  
  /// Obtient les statistiques de performance
  static Map<String, dynamic> getPerformanceStats() {
    final stats = <String, dynamic>{};
    
    // Statistiques des opérations
    for (final entry in _operationCounts.entries) {
      final operationMetrics = _metrics.where((m) => m.operation == entry.key).toList();
      if (operationMetrics.isNotEmpty) {
        final avgDuration = operationMetrics
            .map((m) => m.duration.inMilliseconds)
            .reduce((a, b) => a + b) / operationMetrics.length;
        
        stats[entry.key] = {
          'count': entry.value,
          'avgDuration': '${avgDuration.toStringAsFixed(2)}ms',
          'totalDuration': '${operationMetrics.map((m) => m.duration.inMilliseconds).reduce((a, b) => a + b)}ms',
        };
      }
    }
    
    // Statistiques du cache
    stats['imageCache'] = {
      'size': _imageCache.length,
      'maxSize': _maxCacheSize,
    };
    
    // Statistiques des timers
    stats['debounceTimers'] = {
      'activeCount': _debounceTimers.values.where((t) => t?.isActive ?? false).length,
      'totalCount': _debounceTimers.length,
    };
    
    return stats;
  }
  
  /// Nettoie les métriques anciennes (plus de 1 heure)
  static void cleanOldMetrics() {
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _metrics.removeWhere((metric) => metric.timestamp.isBefore(oneHourAgo));
  }
}

/// Métrique de performance
class PerformanceMetric {
  final String operation;
  final Duration duration;
  final DateTime timestamp;
  
  PerformanceMetric({
    required this.operation,
    required this.duration,
    required this.timestamp,
  });
}

/// Timer personnalisé pour les opérations de debounce
class Timer {
  final Duration _duration;
  final VoidCallback _callback;
  late final Future _future;
  bool _isActive = true;
  
  Timer(this._duration, this._callback) {
    _future = Future.delayed(_duration).then((_) {
      if (_isActive) {
        _callback();
      }
    });
  }
  
  void cancel() {
    _isActive = false;
  }
  
  bool get isActive => _isActive;
}

/// Widget optimisé pour afficher des images réseau avec cache
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  
  const OptimizedNetworkImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Image(
      image: PerformanceUtils.getCachedNetworkImage(imageUrl),
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return placeholder ?? 
               SizedBox(
                 width: width,
                 height: height,
                 child: const Center(
                   child: CircularProgressIndicator(strokeWidth: 2),
                 ),
               );
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? 
               SizedBox(
                 width: width,
                 height: height,
                 child: const Icon(Icons.error_outline),
               );
      },
    );
  }
}

/// Mixin pour optimiser les performances des StatefulWidget
mixin PerformanceOptimizedStateMixin<T extends StatefulWidget> on State<T> {
  bool _isMounted = false;
  
  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }
  
  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }
  
  /// Vérifie si le widget est toujours monté avant setState
  void safeSetState(VoidCallback fn) {
    if (_isMounted && mounted) {
      setState(fn);
    }
  }
  
  /// Exécute une action seulement si le widget est monté
  void ifMounted(VoidCallback action) {
    if (_isMounted && mounted) {
      action();
    }
  }
}

/// Widget optimisé pour les listes avec lazy loading
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  
  const OptimizedListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Optimisations pour les performances
      cacheExtent: 200.0, // Pré-charge les éléments dans un rayon de 200px
      addAutomaticKeepAlives: false, // Évite de garder tous les widgets en mémoire
      addRepaintBoundaries: true, // Optimise les repeints
    );
  }
}

/// Constantes pour les performances
class PerformanceConstants {
  // Durées des animations optimisées
  static const Duration fastAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Délais de debounce
  static const Duration searchDebounce = Duration(milliseconds: 300);
  static const Duration tapDebounce = Duration(milliseconds: 100);
  
  // Tailles de cache
  static const int maxImageCacheSize = 50;
  static const int maxListCacheSize = 100;
  
  // Rayons de cache pour les listes
  static const double listCacheExtent = 200.0;
  static const double gridCacheExtent = 400.0;
}

/// Extension pour optimiser les animations
extension OptimizedAnimations on AnimationController {
  /// Animation optimisée avec curve personnalisée
  Animation<T> createOptimizedAnimation<T>({
    required Tween<T> tween,
    Curve curve = Curves.easeInOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return tween.animate(CurvedAnimation(
      parent: this,
      curve: Interval(begin, end, curve: curve),
    ));
  }
}

/// Gestionnaire de mémoire pour optimiser l'utilisation
class MemoryManager {
  static int _widgetCount = 0;
  static final Set<String> _activeRoutes = {};
  
  /// Incrémente le compteur de widgets
  static void incrementWidgetCount() {
    _widgetCount++;
  }
  
  /// Décrémente le compteur de widgets
  static void decrementWidgetCount() {
    _widgetCount--;
    
    // Nettoyer le cache si peu de widgets actifs
    if (_widgetCount < 10) {
      _scheduleCleanup();
    }
  }
  
  /// Ajoute une route active
  static void addActiveRoute(String routeName) {
    _activeRoutes.add(routeName);
  }
  
  /// Supprime une route active
  static void removeActiveRoute(String routeName) {
    _activeRoutes.remove(routeName);
    
    // Nettoyer si peu de routes actives
    if (_activeRoutes.length <= 1) {
      _scheduleCleanup();
    }
  }
  
  /// Programme un nettoyage de la mémoire
  static void _scheduleCleanup() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_widgetCount < 10 && _activeRoutes.length <= 1) {
        performMemoryCleanup();
      }
    });
  }
  
  /// Effectue un nettoyage de la mémoire
  static void performMemoryCleanup() {
    // Nettoyer le cache d'images
    PerformanceUtils.clearImageCache();
    
    // Nettoyer les timers de debounce
    PerformanceUtils.clearDebounceTimers();
    
    // Nettoyer les métriques anciennes
    PerformanceUtils.cleanOldMetrics();
    
    debugPrint('Nettoyage mémoire effectué');
  }
  
  /// Obtient les statistiques de mémoire
  static Map<String, dynamic> getMemoryStats() {
    return {
      'widgetCount': _widgetCount,
      'activeRoutes': _activeRoutes.length,
      'imageCacheSize': PerformanceUtils._imageCache.length,
      'debounceTimersCount': PerformanceUtils._debounceTimers.length,
      'performanceStats': PerformanceUtils.getPerformanceStats(),
    };
  }
} 