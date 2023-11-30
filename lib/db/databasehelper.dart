import 'dart:convert';

import 'package:assign3_calorie_calculator/models/meal_plan.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/food.dart';

class DatabaseHelper {
  static const int _version = 1;
  static const String _dbname = "Assignment3.db";

  // Create Database
  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbname),
        onCreate: (db, version) async {
          await _createFoodTable(db);
          await _createMealPlanTable(db);
        },
        version: _version);
  }

  // Food table Schema
  static Future<void> _createFoodTable(Database db) async {
    await db.execute(
      "CREATE TABLE Food ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "item TEXT NOT NULL,"
          "calories INTEGER NOT NULL);",
    );
  }
  // Meal plan Table Schema
  static Future<void> _createMealPlanTable(Database db) async {
    await db.execute(
      "CREATE TABLE MealPlan ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "date TEXT NOT NULL,"
          "Items TEXT NOT NULL,"
          "totalCalories INTEGER NOT NULL);",
    );
  }
  // Add food
  static Future<int> addFood(Food food) async {
    final db = await _getDB();
    return await db.insert("Food", food.toJson());
  }
  // Delete food
  static Future<int> deleteFood(Food food) async {
    final db = await _getDB();
    return await db.delete("Food",
      where: 'id = ?',
      whereArgs: [food.id]
    );
  }
  // Get all food items from Database
  static Future<List<Food>?> getAllFood() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> foodList = await db.query("Food");
    if(foodList.isEmpty) {
      return null;
    }
    return List.generate(foodList.length, (index) => Food.fromJson(foodList[index]));
  }

  //Save meal plan
  static Future<int> saveMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();

    String mealSelectionJson = jsonEncode(mealPlan.mealSelection.map((food) => food.toJson()).toList());

    Map<String, dynamic> mealPlanData = {
      'date': mealPlan.date.toIso8601String(),
      'Items': mealSelectionJson, // Saving the serialized JSON string
      'totalCalories': mealPlan.totalCalories,
    };

    // Insert the meal plan into the database
    return await db.insert("MealPlan", mealPlanData);
  }

  // Update Meal Plan
  static Future<void> updateMealPlan(MealPlan mealPlan) async {
    final db = await _getDB();
    await db.update(
      'MealPlan',
      mealPlan.toJson(),
      where: 'id = ?',
      whereArgs: [mealPlan.id],
    );
  }

  // Delete food
  static Future<void> deleteMealPlan(int id) async {
    final db = await _getDB();
    await db.delete(
      'MealPlan',
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  // Get all Meal Plans from Database
  static Future<List<MealPlan>> getAllMealPlans() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> mealPlansList = await db.query("MealPlan");
    return List.generate(mealPlansList.length, (i) {
      return MealPlan.fromJson(mealPlansList[i]);
    });
  }

}
