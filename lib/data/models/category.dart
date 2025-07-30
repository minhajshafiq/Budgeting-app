import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isIncomeCategory;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isIncomeCategory = false,
    this.sortOrder = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    bool? isIncomeCategory,
    int? sortOrder,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isIncomeCategory: isIncomeCategory ?? this.isIncomeCategory,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon.codePoint,
      'color': color.value,
      'isIncomeCategory': isIncomeCategory,
      'sortOrder': sortOrder,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['icon'], fontFamily: 'HugeIcons'),
      color: Color(json['color']),
      isIncomeCategory: json['isIncomeCategory'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name)';
}

// Catégories prédéfinies
class DefaultCategories {
  // Catégories de revenus
  static const List<Category> incomeCategories = [
    Category(
      id: 'income_salary',
      name: 'Salaire',
      icon: HugeIcons.strokeRoundedMoney01,
      color: Color(0xFF4CAF50),
      isIncomeCategory: true,
      sortOrder: 1,
    ),
    Category(
      id: 'income_freelance',
      name: 'Freelance',
      icon: HugeIcons.strokeRoundedBriefcase01,
      color: Color(0xFF2196F3),
      isIncomeCategory: true,
      sortOrder: 2,
    ),
    Category(
      id: 'income_investment',
      name: 'Investissement',
      icon: HugeIcons.strokeRoundedArrowUp01,
      color: Color(0xFF9C27B0),
      isIncomeCategory: true,
      sortOrder: 3,
    ),
    Category(
      id: 'income_gift',
      name: 'Cadeau',
      icon: HugeIcons.strokeRoundedGift,
      color: Color(0xFFE91E63),
      isIncomeCategory: true,
      sortOrder: 4,
    ),
    Category(
      id: 'income_bonus',
      name: 'Prime',
      icon: HugeIcons.strokeRoundedStar,
      color: Color(0xFFFF9800),
      isIncomeCategory: true,
      sortOrder: 5,
    ),
    Category(
      id: 'income_rental',
      name: 'Location',
      icon: HugeIcons.strokeRoundedHome01,
      color: Color(0xFF795548),
      isIncomeCategory: true,
      sortOrder: 6,
    ),
    Category(
      id: 'income_refund',
      name: 'Remboursement',
      icon: HugeIcons.strokeRoundedArrowLeft01,
      color: Color(0xFF607D8B),
      isIncomeCategory: true,
      sortOrder: 7,
    ),
    Category(
      id: 'income_other',
      name: 'Autre',
      icon: HugeIcons.strokeRoundedMoreHorizontal,
      color: Color(0xFF9E9E9E),
      isIncomeCategory: true,
      sortOrder: 8,
    ),
  ];

  // Catégories de dépenses
  static const List<Category> expenseCategories = [
    Category(
      id: 'expense_food',
      name: 'Alimentation',
      icon: HugeIcons.strokeRoundedRestaurant01,
      color: Color(0xFFFF5722),
      sortOrder: 1,
    ),
    Category(
      id: 'expense_transport',
      name: 'Transport',
      icon: HugeIcons.strokeRoundedCar01,
      color: Color(0xFF3F51B5),
      sortOrder: 2,
    ),
    Category(
      id: 'expense_housing',
      name: 'Logement',
      icon: HugeIcons.strokeRoundedHome01,
      color: Color(0xFF795548),
      sortOrder: 3,
    ),
    Category(
      id: 'expense_health',
      name: 'Santé',
      icon: HugeIcons.strokeRoundedMedicine01,
      color: Color(0xFFE91E63),
      sortOrder: 4,
    ),
    Category(
      id: 'expense_entertainment',
      name: 'Divertissement',
      icon: HugeIcons.strokeRoundedGameController01,
      color: Color(0xFF9C27B0),
      sortOrder: 5,
    ),
    Category(
      id: 'expense_shopping',
      name: 'Shopping',
      icon: HugeIcons.strokeRoundedShoppingBag01,
      color: Color(0xFF2196F3),
      sortOrder: 6,
    ),
    Category(
      id: 'expense_education',
      name: 'Éducation',
      icon: HugeIcons.strokeRoundedBook01,
      color: Color(0xFF4CAF50),
      sortOrder: 7,
    ),
    Category(
      id: 'expense_subscription',
      name: 'Abonnements',
      icon: HugeIcons.strokeRoundedCalendar01,
      color: Color(0xFFFF9800),
      sortOrder: 8,
    ),
    Category(
      id: 'expense_gift',
      name: 'Cadeaux',
      icon: HugeIcons.strokeRoundedGift,
      color: Color(0xFFE91E63),
      sortOrder: 9,
    ),
    Category(
      id: 'expense_travel',
      name: 'Voyage',
      icon: HugeIcons.strokeRoundedAirplane01,
      color: Color(0xFF00BCD4),
      sortOrder: 10,
    ),
    Category(
      id: 'expense_other',
      name: 'Autre',
      icon: HugeIcons.strokeRoundedMoreHorizontal,
      color: Color(0xFF9E9E9E),
      sortOrder: 11,
    ),
  ];

  // Toutes les catégories
  static List<Category> get allCategories => [
    ...incomeCategories,
    ...expenseCategories,
  ];

  // Méthodes utilitaires
  static Category? getCategoryById(String id) {
    try {
      return allCategories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Category> getCategoriesForType({required bool isIncome}) {
    return isIncome ? incomeCategories : expenseCategories;
  }

  static Category get defaultIncomeCategory => incomeCategories.first;
  static Category get defaultExpenseCategory => expenseCategories.first;
} 