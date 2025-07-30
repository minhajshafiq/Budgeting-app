import 'package:flutter/material.dart';

class TermsOfServiceController extends ChangeNotifier {
  bool _isLoading = false;
  
  // Getters
  bool get isLoading => _isLoading;
} 