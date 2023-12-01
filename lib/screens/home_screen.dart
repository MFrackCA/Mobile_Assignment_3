import 'package:assign3_calorie_calculator/models/meal_plan.dart';
import 'package:assign3_calorie_calculator/screens/meal_plan_screen.dart';
import 'package:assign3_calorie_calculator/screens/update_meal_plan_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../db/databasehelper.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<MealPlan> savedPlans = [];


  Future<void> _updateMealPlans() async {
      List<MealPlan> plans = await DatabaseHelper.getAllMealPlans();
      setState(() {
        savedPlans = plans;
      });
  }

  @override
  void initState() {
    super.initState();
    _updateMealPlans();
  }

  // Home Page Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[500],
      appBar: AppBar(
        title: const Text('Meal Plan App'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: savedPlans.isEmpty
          ? const Center(
          child: Text(
              'No meal plans currently saved',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IndieFlower'
              )
          )
      )
          : ListView.builder(
        itemCount: savedPlans.length,
        itemBuilder: (context, index) {
          MealPlan mealPlan = savedPlans[index];
          return Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Meal Plan on ${DateFormat('yyyy-MM-dd').format(mealPlan.date)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Container(height: 1, color: Colors.black),  // Straight black line
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Total Calories: ${mealPlan.totalCalories}'),
                      ),
                      // Display meal plans on home
                      ...mealPlan.mealSelection.map(
                            (food) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text('${food.item} - ${food.calories} cal'),
                        ),
                      ),
                    ],
                  ),
                  // navigate to update meal plan screen
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateMealPlanScreen(existingMealPlan: mealPlan),
                      ),
                    );
                    _updateMealPlans();
                  },

                ),
                Align(
                  alignment: Alignment.centerRight,
                  // delete meal plan
                  child: IconButton(
                    icon: const Icon(Icons.delete,
                        color: Colors.red),
                    onPressed: () {
                      DatabaseHelper.deleteMealPlan(mealPlan.id!);
                      _updateMealPlans();
                    },
                  ),
                ),
              ],
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
        onPressed: () async {
          // Open MealPlanScreen and wait for it to return a result
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealPlanScreen()),
          );
          // Always refresh the list of meal plans when returning from MealPlanScreen
          _updateMealPlans();
        },
        elevation: 6.0,
        child: const Icon(
          Icons.note_add,
          size: 25.0,
        ),
      ),
    );
  }
}
