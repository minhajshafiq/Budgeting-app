import 'package:flutter/material.dart';

class NavigationService extends ChangeNotifier {
  int _currentIndex = 0;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  int get currentIndex => _currentIndex;

  void navigateToIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
} 