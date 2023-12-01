import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_plan.dart';
import '../db/databasehelper.dart';
import '../screens/update_meal_plan_screen.dart';
import '../screens/meal_plan_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<MealPlan> savedPlans = [];
  String searchQuery = '';

  Future<void> _updateMealPlans() async {
    List<MealPlan> plans;
    if (searchQuery.isEmpty) {
      plans = await DatabaseHelper.getAllMealPlans();
    } else {
      plans = await DatabaseHelper.queryMealPlans(searchQuery);
    }
    setState(() {
      savedPlans = plans;
    });
  }

  @override
  void initState() {
    super.initState();
    _updateMealPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('Meal Plan App'),
        centerTitle: true,
        backgroundColor: Colors.green[700],
      ),
      body: Column(
        children: [
          Container(
            // search bar
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: 'Search by Date',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              // Update meal plans on date search
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  _updateMealPlans();
                });
              },
            ),
          ),
          Expanded(
            child: savedPlans.isEmpty
                ? const Center(
              child: Text(
                'No meal plans currently saved',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            )
                : ListView.separated(
              itemCount: savedPlans.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10), // Adds space between cards
              itemBuilder: (context, index) {
                MealPlan mealPlan = savedPlans[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
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
                      const Divider(color: Colors.black),
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
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateMealPlanScreen(existingMealPlan: mealPlan),
                            ),
                          );
                          _updateMealPlans();
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MealPlanScreen()),
          );
          _updateMealPlans();
        },
        child: const Icon(Icons.note_add),
      ),
    );
  }
}
