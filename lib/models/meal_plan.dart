import 'dart:convert';

import 'food.dart';

class MealPlan {

  // attributes
  int? id;
  late DateTime date;
  late List <Food> mealSelection;
  late int totalCalories;

  MealPlan({
    this.id,
    required this.date,
    required this.mealSelection,
  }) : totalCalories = calculateTotalCalories(mealSelection);

  // calculate total calories based on food in list
  static int calculateTotalCalories(List<Food> mealSelection) {
    int total = 0;
    for (var foodItem in mealSelection) {
      total += foodItem.calories;
    }
    return total;
  }

  // map to json to insert into database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'mealSelection': mealSelection.map((foodItem) => foodItem.toJson()).toList(),
      'totalCalories': totalCalories,
    };
  }

  // retrieve from database and map to object
  factory MealPlan.fromJson(Map<String, dynamic> json) {
    final String itemsJsonString = json['Items'] as String;
    final List<dynamic> mealSelectionData = jsonDecode(itemsJsonString);

    final List<Food> mealSelection = mealSelectionData
        .map((foodItemData) => Food.fromJson(foodItemData as Map<String, dynamic>))
        .toList();

    return MealPlan(
      id: json['id'] as int?,
      date: DateTime.parse(json['date'] as String),
      mealSelection: mealSelection,
    );
  }
}

