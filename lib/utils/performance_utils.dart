import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';

class PerformanceUtils {
  static Timer? _debounceTimer;
  
  static void debounce(VoidCallback callback, Duration duration) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }
  
  static void cancelDebounce() {
    _debounceTimer?.cancel();
  }
}

class PerformanceConstants {
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  static const Duration tapDebounce = Duration(milliseconds: 300);
}

class MemoryManager {
  static final Set<String> _activeRoutes = HashSet<String>();
  static int _widgetCount = 0;
  
  static void addActiveRoute(String routeName) {
    _activeRoutes.add(routeName);
  }
  
  static void removeActiveRoute(String routeName) {
    _activeRoutes.remove(routeName);
  }
  
  static void incrementWidgetCount() {
    _widgetCount++;
  }
  
  static void decrementWidgetCount() {
    if (_widgetCount > 0) {
      _widgetCount--;
    }
  }
  
  static Set<String> get activeRoutes => Set.unmodifiable(_activeRoutes);
  static int get widgetCount => _widgetCount;
  
  static void clear() {
    _activeRoutes.clear();
    _widgetCount = 0;
  }
} 