import 'package:flutter/material.dart';

class NavigationService extends ChangeNotifier {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Clé de navigation globale pour accéder au Navigator depuis n'importe où
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  final List<int> _navigationHistory = [0]; // Commence par la page d'accueil
  int _currentIndex = 0;

  List<int> get navigationHistory => List.unmodifiable(_navigationHistory);
  int get currentIndex => _currentIndex;

  // Navigue vers une nouvelle page et met à jour l'historique
  void navigateToIndex(int index) {
    if (_currentIndex != index) {
      // Supprime l'index de l'historique s'il existe déjà
      _navigationHistory.removeWhere((item) => item == index);
      // Ajoute le nouvel index à la fin
      _navigationHistory.add(index);
      _currentIndex = index;
      notifyListeners();
    }
  }

  // Navigation globale avec routes nommées
  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  // Navigation globale avec remplacement
  Future<dynamic> navigateToReplacement(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(routeName, arguments: arguments);
  }

  // Navigation globale avec suppression de toutes les routes précédentes
  Future<dynamic> navigateToAndRemoveUntil(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName, 
      (Route<dynamic> route) => false, 
      arguments: arguments
    );
  }

  // Revient à la page précédente dans l'historique
  int? goBack() {
    if (_navigationHistory.length > 1) {
      // Supprime la page actuelle
      _navigationHistory.removeLast();
      // Récupère la page précédente
      _currentIndex = _navigationHistory.last;
      notifyListeners();
      return _currentIndex;
    }
    return null; // Pas de page précédente disponible
  }

  // Vérifie s'il y a une page précédente
  bool canGoBack() {
    return _navigationHistory.length > 1;
  }

  // Obtient l'index de la page précédente sans naviguer
  int? getPreviousIndex() {
    if (_navigationHistory.length > 1) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }

  // Réinitialise l'historique de navigation
  void resetHistory() {
    _navigationHistory.clear();
    _navigationHistory.add(0); // Page d'accueil par défaut
    _currentIndex = 0;
    notifyListeners();
  }

  // Obtient le nom de la page en fonction de l'index
  String getPageName(int index) {
    switch (index) {
      case 0:
        return 'Accueil';
      case 1:
        return 'Statistiques';
      case 2:
        return 'Transactions';
      case 3:
        return 'Paramètres';
      default:
        return 'Page inconnue';
    }
  }
} 