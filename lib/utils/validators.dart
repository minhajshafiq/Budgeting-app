extension StringValidators on String {
  String? validateName({required String fieldName}) {
    if (isEmpty) {
      return '$fieldName est requis';
    }
    if (length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s-]+$').hasMatch(this)) {
      return '$fieldName ne doit contenir que des lettres';
    }
    return null;
  }

  String? get validateEmail {
    if (isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(this)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? validatePassword() {
    if (isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (length < 8) {
      return 'Le mot de passe doit contenir au moins 8 caractères';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(this)) {
      return 'Le mot de passe doit contenir au moins une minuscule, une majuscule et un chiffre';
    }
    return null;
  }
} 