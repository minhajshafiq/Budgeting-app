class Validators {
  // Validation d'email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Adresse email invalide';
    }
    
    return null;
  }

  // Validation de mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    
    if (value.length < 12) {
      return 'Au moins 12 caractères requis';
    }
    
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule requise';
    }
    
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Au moins une minuscule requise';
    }
    
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Au moins un chiffre requis';
    }
    
    // Vérifier la présence d'un caractère spécial
    final specialChars = '!@#\$%^&*()_+={}[]|\\:";\'<>?,./-';
    if (!value.split('').any((char) => specialChars.contains(char))) {
      return 'Au moins un caractère spécial requis';
    }
    
    return null;
  }

  // Validation de confirmation de mot de passe
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Confirmation requise';
    }
    
    if (value != password) {
      return 'Les mots de passe ne correspondent pas';
    }
    
    return null;
  }

  // Validation de nom/prénom
  static String? validateName(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName est requis';
    }
    
    if (value.trim().length < 2) {
      return '$fieldName doit contenir au moins 2 caractères';
    }
    
    if (value.trim().length > 50) {
      return '$fieldName ne peut pas dépasser 50 caractères';
    }
    
    // Vérifier que ce ne sont que des lettres et espaces
    if (!RegExp(r'^[a-zA-ZÀ-ÿ\s]+$').hasMatch(value.trim())) {
      return '$fieldName ne peut contenir que des lettres';
    }
    
    return null;
  }

  // Validation de numéro de téléphone
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optionnel
    }
    
    // Supprimer tous les espaces et caractères spéciaux
    final cleanNumber = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    
    // Vérifier le format français (10 chiffres commençant par 0)
    if (!RegExp(r'^0[1-9][0-9]{8}$').hasMatch(cleanNumber)) {
      return 'Numéro de téléphone invalide (format: 0X XX XX XX XX)';
    }
    
    return null;
  }

  // Validation de montant
  static String? validateAmount(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Montant requis';
    }
    
    final amount = double.tryParse(value.replaceAll(',', '.'));
    if (amount == null) {
      return 'Montant invalide';
    }
    
    if (amount <= 0) {
      return 'Le montant doit être positif';
    }
    
    if (min != null && amount < min) {
      return 'Montant minimum: ${min.toStringAsFixed(2)}€';
    }
    
    if (max != null && amount > max) {
      return 'Montant maximum: ${max.toStringAsFixed(2)}€';
    }
    
    return null;
  }

  // Validation de date de naissance
  static String? validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return null; // Optionnel
    }
    
    final now = DateTime.now();
    final age = now.year - value.year;
    
    if (value.isAfter(now)) {
      return 'La date ne peut pas être dans le futur';
    }
    
    if (age < 13) {
      return 'Vous devez avoir au moins 13 ans';
    }
    
    if (age > 120) {
      return 'Date de naissance invalide';
    }
    
    return null;
  }

  // Validation générique de champ requis
  static String? validateRequired(String? value, {String fieldName = 'Ce champ'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  // Validation de longueur
  static String? validateLength(String? value, {
    int? min,
    int? max,
    String fieldName = 'Ce champ',
  }) {
    if (value == null) return null;
    
    final length = value.trim().length;
    
    if (min != null && length < min) {
      return '$fieldName doit contenir au moins $min caractères';
    }
    
    if (max != null && length > max) {
      return '$fieldName ne peut pas dépasser $max caractères';
    }
    
    return null;
  }

  // Combinateur de validateurs
  static String? Function(String?) combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

// Extensions pour faciliter l'utilisation
extension StringValidation on String? {
  String? get validateEmail => Validators.validateEmail(this);
  String? get validatePassword => Validators.validatePassword(this);
  String? validateName({String fieldName = 'Ce champ'}) => 
      Validators.validateName(this, fieldName: fieldName);
  String? get validatePhoneNumber => Validators.validatePhoneNumber(this);
  String? validateAmount({double? min, double? max}) => 
      Validators.validateAmount(this, min: min, max: max);
  String? validateRequired({String fieldName = 'Ce champ'}) => 
      Validators.validateRequired(this, fieldName: fieldName);
} 