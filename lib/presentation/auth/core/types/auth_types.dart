// Types d'authentification pour l'application

class LoginData {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginData({
    required this.email,
    required this.password,
    this.rememberMe = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'rememberMe': rememberMe,
    };
  }

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rememberMe: json['rememberMe'] ?? false,
    );
  }

  @override
  String toString() {
    return 'LoginData(email: $email)';
  }
}

class SignupData {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final Map<String, dynamic>? notificationPreferences;
  final List<String>? incomeTypes;
  final List<String>? financialGoals;
  final String? comfortLevel;
  final String? trackingFrequency;

  const SignupData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.dateOfBirth,
    this.notificationPreferences,
    this.incomeTypes,
    this.financialGoals,
    this.comfortLevel,
    this.trackingFrequency,
  });

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'notificationPreferences': notificationPreferences,
      'incomeTypes': incomeTypes,
      'financialGoals': financialGoals,
      'comfortLevel': comfortLevel,
      'trackingFrequency': trackingFrequency,
    };
  }

  factory SignupData.fromJson(Map<String, dynamic> json) {
    return SignupData(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phoneNumber: json['phoneNumber'],
      dateOfBirth: json['dateOfBirth'] != null 
          ? DateTime.parse(json['dateOfBirth']) 
          : null,
      notificationPreferences: json['notificationPreferences'],
      incomeTypes: json['incomeTypes'] != null 
          ? List<String>.from(json['incomeTypes']) 
          : null,
      financialGoals: json['financialGoals'] != null 
          ? List<String>.from(json['financialGoals']) 
          : null,
      comfortLevel: json['comfortLevel'],
      trackingFrequency: json['trackingFrequency'],
    );
  }

  SignupData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phoneNumber,
    DateTime? dateOfBirth,
    Map<String, dynamic>? notificationPreferences,
    List<String>? incomeTypes,
    List<String>? financialGoals,
    String? comfortLevel,
    String? trackingFrequency,
  }) {
    return SignupData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      notificationPreferences: notificationPreferences ?? this.notificationPreferences,
      incomeTypes: incomeTypes ?? this.incomeTypes,
      financialGoals: financialGoals ?? this.financialGoals,
      comfortLevel: comfortLevel ?? this.comfortLevel,
      trackingFrequency: trackingFrequency ?? this.trackingFrequency,
    );
  }

  @override
  String toString() {
    return 'SignupData(firstName: $firstName, lastName: $lastName, email: $email)';
  }
} 