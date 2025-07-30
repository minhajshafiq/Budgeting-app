import 'transaction.dart';

enum PocketType {
  needs,        // 50% - Besoins essentiels
  wants,        // 30% - Envies/Loisirs
  savings,      // 20% - Épargne/Objectifs
  custom        // Pocket personnalisé
}

enum SavingsGoalType {
  emergency,    // Fonds d'urgence
  vacation,     // Vacances
  house,        // Achat immobilier
  car,          // Véhicule
  investment,   // Investissements
  retirement,   // Retraite
  education,    // Éducation
  other         // Autre objectif
}

class Pocket {
  final String id;
  final String name;
  final String icon;
  final String color;
  final double budget;
  final double spent;
  final List<PocketTransaction> transactions;
  final DateTime createdAt;
  final PocketType type;
  final SavingsGoalType? savingsGoalType;
  final double? targetAmount;
  final DateTime? targetDate;

  Pocket({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
    this.spent = 0.0,
    this.transactions = const [],
    required this.createdAt,
    this.type = PocketType.custom,
    this.savingsGoalType,
    this.targetAmount,
    this.targetDate,
  });

  double get remainingBudget => budget - spent;
  double get progressPercentage => budget > 0 ? (spent / budget * 100).clamp(0, 100) : 0;
  bool get isOverBudget => spent > budget;
  
  // Nouveau getter pour identifier les pockets d'épargne
  bool get isSavingsPocket => type == PocketType.savings;
  
  // Pour les épargnes, "spent" représente le montant épargné (positif)
  double get savedAmount => isSavingsPocket ? spent : 0.0;
  double get savingsProgress => isSavingsPocket && targetAmount != null && targetAmount! > 0 
      ? (savedAmount / targetAmount! * 100).clamp(0, 100) 
      : progressPercentage;

  // Getter pour le libellé du type
  String get typeLabel {
    switch (type) {
      case PocketType.needs:
        return 'Besoins essentiels';
      case PocketType.wants:
        return 'Envies & Loisirs';
      case PocketType.savings:
        return 'Épargne & Objectifs';
      case PocketType.custom:
        return 'Personnalisé';
    }
  }

  // Getter pour le libellé du type d'épargne
  String? get savingsGoalLabel {
    if (savingsGoalType == null) return null;
    switch (savingsGoalType!) {
      case SavingsGoalType.emergency:
        return 'Fonds d\'urgence';
      case SavingsGoalType.vacation:
        return 'Vacances';
      case SavingsGoalType.house:
        return 'Achat immobilier';
      case SavingsGoalType.car:
        return 'Véhicule';
      case SavingsGoalType.investment:
        return 'Investissements';
      case SavingsGoalType.retirement:
        return 'Retraite';
      case SavingsGoalType.education:
        return 'Éducation';
      case SavingsGoalType.other:
        return 'Autre objectif';
    }
  }

  // Ajouter une transaction à ce pocket
  Pocket addTransaction(PocketTransaction transaction) {
    final newTransactions = List<PocketTransaction>.from(transactions)..add(transaction);
    final newSpent = spent + transaction.amount;
    return copyWith(
      transactions: newTransactions,
      spent: newSpent,
    );
  }

  // Méthode spécifique pour ajouter un dépôt d'épargne
  Pocket addSavingsDeposit(PocketTransaction savingsDeposit) {
    if (!isSavingsPocket) {
      throw Exception('Les dépôts d\'épargne ne peuvent être ajoutés qu\'aux pockets d\'épargne');
    }
    
    final newTransactions = List<PocketTransaction>.from(transactions)..add(savingsDeposit);
    final newSpent = spent + savingsDeposit.amount; // Pour l'épargne, "spent" = montant épargné
    return copyWith(
      transactions: newTransactions,
      spent: newSpent,
    );
  }

  // Empêcher l'ajout de transactions normales aux pockets d'épargne
  Pocket addExpenseTransaction(PocketTransaction transaction) {
    if (isSavingsPocket) {
      throw Exception('Les pockets d\'épargne n\'acceptent que les dépôts d\'épargne. Utilisez addSavingsDeposit()');
    }
    
    return addTransaction(transaction);
  }

  // Supprimer une transaction de ce pocket
  Pocket removeTransaction(String transactionId) {
    // Trouver la transaction à supprimer
    final transactionToRemove = transactions.firstWhere(
      (t) => t.id == transactionId || t.transactionId == transactionId,
      orElse: () => throw Exception('Transaction non trouvée'),
    );
    
    // Créer une nouvelle liste sans la transaction
    final newTransactions = List<PocketTransaction>.from(transactions)
      ..removeWhere((t) => t.id == transactionId || t.transactionId == transactionId);
    
    // Recalculer le montant dépensé
    final newSpent = spent - transactionToRemove.amount;
    
    return copyWith(
      transactions: newTransactions,
      spent: newSpent,
    );
  }

  Pocket copyWith({
    String? id,
    String? name,
    String? icon,
    String? color,
    double? budget,
    double? spent,
    List<PocketTransaction>? transactions,
    DateTime? createdAt,
    PocketType? type,
    SavingsGoalType? savingsGoalType,
    double? targetAmount,
    DateTime? targetDate,
  }) {
    return Pocket(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      budget: budget ?? this.budget,
      spent: spent ?? this.spent,
      transactions: transactions ?? this.transactions,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      savingsGoalType: savingsGoalType ?? this.savingsGoalType,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'budget': budget,
      'spent': spent,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'type': type.name,
      'savingsGoalType': savingsGoalType?.name,
      'targetAmount': targetAmount,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  // Fonction utilitaire pour parser les dates de manière sûre
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Erreur parsing DateTime: $value - $e');
        return null;
      }
    }
    return null;
  }

  factory Pocket.fromJson(Map<String, dynamic> json) {
    return Pocket(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      budget: json['budget'].toDouble(),
      spent: json['spent']?.toDouble() ?? 0.0,
      transactions: (json['transactions'] as List?)
          ?.map((t) => PocketTransaction.fromJson(t))
          .toList() ?? [],
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      type: PocketType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PocketType.custom,
      ),
      savingsGoalType: json['savingsGoalType'] != null
          ? SavingsGoalType.values.firstWhere(
              (e) => e.name == json['savingsGoalType'],
              orElse: () => SavingsGoalType.other,
            )
          : null,
      targetAmount: json['targetAmount']?.toDouble(),
      targetDate: _parseDateTime(json['targetDate']),
    );
  }
}

class PocketTransaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String? description;
  final String? categoryId;
  final String? transactionId;
  final String? icon;
  final String? color;
  final TransactionType? type;

  PocketTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    this.description,
    this.categoryId,
    this.transactionId,
    this.icon,
    this.color,
    this.type,
  });

  // Getter pour identifier les dépôts d'épargne
  bool get isSavingsDeposit => type == TransactionType.savings_deposit;

  // Créer une PocketTransaction à partir d'une Transaction
  factory PocketTransaction.fromTransaction(dynamic transaction) {
    return PocketTransaction(
      id: 'pt_${DateTime.now().millisecondsSinceEpoch}',
      title: transaction.title,
      amount: transaction.amount,
      date: transaction.date,
      description: transaction.description,
      categoryId: transaction.categoryId,
      transactionId: transaction.id,
      // Ces valeurs peuvent être définies plus tard si nécessaire
      icon: null,
      color: null,
      type: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'categoryId': categoryId,
      'transactionId': transactionId,
      'icon': icon,
      'color': color,
      'type': type?.name,
    };
  }

  factory PocketTransaction.fromJson(Map<String, dynamic> json) {
    return PocketTransaction(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      date: Pocket._parseDateTime(json['date']) ?? DateTime.now(),
      description: json['description'],
      categoryId: json['categoryId'],
      transactionId: json['transactionId'],
      icon: json['icon'],
      color: json['color'],
      type: json['type'] != null ? TransactionType.values.firstWhere((e) => e.name == json['type']) : null,
    );
  }
} 