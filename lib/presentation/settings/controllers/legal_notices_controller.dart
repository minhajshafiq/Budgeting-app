import 'package:flutter/material.dart';

class LegalNoticesController extends ChangeNotifier {
  bool _isLoading = false;
  
  // Getters
  bool get isLoading => _isLoading;
} 