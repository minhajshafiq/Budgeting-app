import 'package:flutter/foundation.dart';

class UserProvider extends ChangeNotifier {
  String _firstName = '';
  String _lastName = '';
  String _email = '';
  bool _isLoggedIn = false;

  // Getters
  String get firstName => _firstName;
  String get lastName => _lastName;
  String get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  String get fullName => _firstName.isEmpty && _lastName.isEmpty 
    ? 'Utilisateur' 
    : '$_firstName $_lastName'.trim();
  
  // Méthode pour générer les initiales
  String get initials {
    if (_firstName.isEmpty && _lastName.isEmpty) {
      return 'U'; // U pour Utilisateur par défaut
    }
    String firstInitial = _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '';
    String lastInitial = _lastName.isNotEmpty ? _lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  // Méthodes pour mettre à jour les informations utilisateur
  void updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    _email = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  void updateFirstName(String firstName) {
    _firstName = firstName;
    notifyListeners();
  }

  void updateLastName(String lastName) {
    _lastName = lastName;
    notifyListeners();
  }

  void updateEmail(String email) {
    _email = email;
    notifyListeners();
  }

  // Méthode de déconnexion
  void logout() {
    _firstName = '';
    _lastName = '';
    _email = '';
    _isLoggedIn = false;
    notifyListeners();
  }
} 