import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:my_flutter_app/presentation/auth/core/types/auth_types.dart';

class SignupDataManager extends ChangeNotifier {
  // Contrôleurs de texte
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  // Messages d'erreur
  String? _firstNameError;
  String? _lastNameError;
  String? _emailError;
  String? _passwordError;
  
  // Données personnelles
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String? _phoneNumber;
  DateTime? _dateOfBirth;
  
  // Préférences de notification
  Map<String, dynamic>? _notificationPreferences;
  
  // Types de revenus
  List<String>? _incomeTypes;
  
  // Objectifs financiers
  List<String>? _financialGoals;
  
  // Niveau de confort
  String? _comfortLevel;
  
  // Fréquence de suivi
  String? _trackingFrequency;
  
  // État de progression
  int _currentStep = 0;
  final int _totalSteps = 8;
  
  // Validation
  bool _isValidating = false;
  String? _validationError;
  
  // Validation du mot de passe
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _digitRegex = RegExp(r'[0-9]');
  static const String _specialChars = '!@#\$%^&*()_+={}[]|\\:";\'<>?,./-';
  
  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  String get password => _password;
  String? get phoneNumber => _phoneNumber;
  DateTime? get dateOfBirth => _dateOfBirth;
  Map<String, dynamic>? get notificationPreferences => _notificationPreferences;
  List<String>? get incomeTypes => _incomeTypes;
  List<String>? get financialGoals => _financialGoals;
  String? get comfortLevel => _comfortLevel;
  String? get trackingFrequency => _trackingFrequency;
  int get currentStep => _currentStep;
  int get totalSteps => _totalSteps;
  bool get isValidating => _isValidating;
  String? get validationError => _validationError;
  
  // Getters pour les erreurs
  String? get firstNameError => _firstNameError;
  String? get lastNameError => _lastNameError;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;
  
  // Setters pour les erreurs
  set firstNameError(String? value) {
    _firstNameError = value;
    notifyListeners();
  }
  
  set lastNameError(String? value) {
    _lastNameError = value;
    notifyListeners();
  }
  
  set emailError(String? value) {
    _emailError = value;
    notifyListeners();
  }
  
  set passwordError(String? value) {
    _passwordError = value;
    notifyListeners();
  }
  
  // Progression
  double get progress => _currentStep / _totalSteps;
  bool get isFirstStep => _currentStep == 0;
  bool get isLastStep => _currentStep == _totalSteps - 1;
  bool get canGoNext => _currentStep < _totalSteps - 1;
  bool get canGoPrevious => _currentStep > 0;
  
  // Méthodes de validation de mot de passe
  bool isPasswordValid(String password) {
    if (password.length < 12) return false;
    if (!_uppercaseRegex.hasMatch(password)) return false;
    if (!_lowercaseRegex.hasMatch(password)) return false;
    if (!_digitRegex.hasMatch(password)) return false;
    
    for (int i = 0; i < password.length; i++) {
      if (_specialChars.contains(password[i])) {
        return true;
      }
    }
    return false;
  }
  
  bool hasMinLength(String password) => password.length >= 12;
  bool hasUppercase(String password) => _uppercaseRegex.hasMatch(password);
  bool hasLowercase(String password) => _lowercaseRegex.hasMatch(password);
  bool hasDigit(String password) => _digitRegex.hasMatch(password);
  bool hasSpecialChar(String password) {
    for (int i = 0; i < password.length; i++) {
      if (_specialChars.contains(password[i])) {
        return true;
      }
    }
    return false;
  }
  
  // Méthodes de mise à jour des données
  void updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
  }) {
    if (firstName != null) _firstName = firstName;
    if (lastName != null) _lastName = lastName;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (dateOfBirth != null) _dateOfBirth = dateOfBirth;
    notifyListeners();
  }
  
  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }
  
  void updatePassword(String password) {
    _password = password;
    notifyListeners();
  }
  
  void updateNotificationPreferences(Map<String, dynamic> preferences) {
    _notificationPreferences = preferences;
    notifyListeners();
  }
  
  void updateIncomeTypes(List<String> types) {
    _incomeTypes = types;
    notifyListeners();
  }
  
  void updateFinancialGoals(List<String> goals) {
    _financialGoals = goals;
    notifyListeners();
  }
  
  void updateComfortLevel(String level) {
    _comfortLevel = level;
    notifyListeners();
  }
  
  void updateTrackingFrequency(String frequency) {
    _trackingFrequency = frequency;
    notifyListeners();
  }
  
  // Navigation
  void nextStep() {
    if (canGoNext) {
      _currentStep++;
      _validationError = null;
      notifyListeners();
    }
  }
  
  void previousStep() {
    if (canGoPrevious) {
      _currentStep--;
      _validationError = null;
      notifyListeners();
    }
  }
  
  void goToStep(int step) {
    if (step >= 0 && step < _totalSteps) {
      _currentStep = step;
      _validationError = null;
      notifyListeners();
    }
  }
  
  // Validation
  Future<bool> validateCurrentStep() async {
    _isValidating = true;
    _validationError = null;
    
    // Synchroniser les données avec les contrôleurs
    _firstName = firstNameController.text.trim();
    _lastName = lastNameController.text.trim();
    _email = emailController.text.trim();
    _password = passwordController.text;
    
    notifyListeners();
    
    try {
      switch (_currentStep) {
        case 0: // Informations personnelles
          if (_firstName.isEmpty) {
            _firstNameError = 'Le prénom est requis';
            _validationError = 'Le prénom est requis';
            return false;
          }
          if (_lastName.isEmpty) {
            _lastNameError = 'Le nom est requis';
            _validationError = 'Le nom est requis';
            return false;
          }
          break;
          
        case 1: // Email
          if (_email.isEmpty) {
            _emailError = 'L\'email est requis';
            _validationError = 'L\'email est requis';
            return false;
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(_email)) {
            _emailError = 'Format d\'email invalide';
            _validationError = 'Format d\'email invalide';
            return false;
          }
          break;
          
        case 2: // Mot de passe
          if (_password.isEmpty) {
            _passwordError = 'Le mot de passe est requis';
            _validationError = 'Le mot de passe est requis';
            return false;
          }
          if (!isPasswordValid(_password)) {
            _passwordError = 'Le mot de passe ne respecte pas les critères de sécurité';
            _validationError = 'Le mot de passe ne respecte pas les critères de sécurité';
            return false;
          }
          break;
          
        case 3: // Types de revenus
          if (_incomeTypes == null || _incomeTypes!.isEmpty) {
            _validationError = 'Veuillez sélectionner au moins un type de revenu';
            return false;
          }
          break;
          
        case 4: // Objectifs financiers
          if (_financialGoals == null || _financialGoals!.isEmpty) {
            _validationError = 'Veuillez sélectionner au moins un objectif financier';
            return false;
          }
          break;
          
        case 5: // Niveau de confort
          if (_comfortLevel == null || _comfortLevel!.isEmpty) {
            _validationError = 'Veuillez sélectionner votre niveau de confort';
            return false;
          }
          break;
          
        case 6: // Notifications
          // Les notifications sont optionnelles
          break;
          
        case 7: // Fréquence de suivi
          if (_trackingFrequency == null || _trackingFrequency!.isEmpty) {
            _validationError = 'Veuillez sélectionner une fréquence de suivi';
            return false;
          }
          break;
      }
      
      // Effacer les erreurs si la validation réussit
      _firstNameError = null;
      _lastNameError = null;
      _emailError = null;
      _passwordError = null;
      
      return true;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }
  
  // Création de SignupData
  SignupData toSignupData() {
    return SignupData(
      firstName: _firstName,
      lastName: _lastName,
      email: _email,
      password: _password,
      phoneNumber: _phoneNumber,
      dateOfBirth: _dateOfBirth,
      notificationPreferences: _notificationPreferences,
      incomeTypes: _incomeTypes,
      financialGoals: _financialGoals,
      comfortLevel: _comfortLevel,
      trackingFrequency: _trackingFrequency,
    );
  }
  
  // Réinitialisation
  void reset() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _password = '';
    _phoneNumber = null;
    _dateOfBirth = null;
    _notificationPreferences = null;
    _incomeTypes = null;
    _financialGoals = null;
    _comfortLevel = null;
    _trackingFrequency = null;
    _currentStep = 0;
    _validationError = null;
    notifyListeners();
  }
  
  // Nettoyage
  void clearSensitiveData() {
    passwordController.clear();
  }
  
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
  
  // Vérification de complétude
  bool get isComplete {
    return _firstName.isNotEmpty &&
           _lastName.isNotEmpty &&
           _email.isNotEmpty &&
           _password.isNotEmpty &&
           _incomeTypes != null &&
           _incomeTypes!.isNotEmpty &&
           _financialGoals != null &&
           _financialGoals!.isNotEmpty &&
           _comfortLevel != null &&
           _comfortLevel!.isNotEmpty &&
           _trackingFrequency != null &&
           _trackingFrequency!.isNotEmpty;
  }
}

// Extension pour la validation
extension StringValidation on String {
  String? validateName({required String fieldName}) {
    if (isEmpty) {
      return '$fieldName est requis';
    }
    if (length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(this)) {
      return '$fieldName ne doit contenir que des lettres, espaces et tirets';
    }
    return null;
  }
  
  String? get validateEmail {
    if (isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this)) {
      return 'Veuillez entrer un email valide';
    }
    return null;
  }
} 