import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../utils/performance_utils.dart';
import '../core/utils/performance_utils.dart' as core;

/// Widget pour surveiller les performances de l'application (debug uniquement)
class PerformanceMonitor extends StatefulWidget {
  const PerformanceMonitor({super.key});

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  Map<String, dynamic> _stats = {};
  bool _isExpanded = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _updateStats();
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _updateStats();
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _updateStats() {
    setState(() {
      _stats = core.MemoryManager.getMemoryStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 10,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Card(
          color: Colors.black87,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📊 Performance',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                          onPressed: _updateStats,
                        ),
                      ],
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const Divider(color: Colors.white24),
                  _buildStatRow('Widgets actifs', '${_stats['widgetCount'] ?? 0}'),
                  _buildStatRow('Routes actives', '${_stats['activeRoutes'] ?? 0}'),
                  if (_stats['imageCache'] != null) ...[
                    _buildStatRow(
                      'Cache images',
                      '${_stats['imageCache']['size']}/${_stats['imageCache']['maxSize']}',
                    ),
                  ],
                  if (_stats['debounceTimers'] != null) ...[
                    _buildStatRow(
                      'Timers actifs',
                      '${_stats['debounceTimers']['activeCount']}/${_stats['debounceTimers']['totalCount']}',
                    ),
                  ],
                  const Divider(color: Colors.white24),
                  const Text(
                    'Actions rapides:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            core.PerformanceUtils.clearImageCache();
                            core.PerformanceUtils.clearDebounceTimers();
                            _updateStats();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const Text(
                            'Nettoyer',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            core.MemoryManager.performMemoryCleanup();
                            _updateStats();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          child: const Text(
                            'Cleanup',
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 