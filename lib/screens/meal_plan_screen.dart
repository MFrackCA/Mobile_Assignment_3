import 'package:assign3_calorie_calculator/db/databasehelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import 'add_food_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({super.key});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  DateTime selectedDate = DateTime.now();
  List<Food> selectedFoods = [];
  TextEditingController maxCalorieController = TextEditingController();

  // Method to save meal plan
  void saveMealPlan() async {

    // Warn user to set calories goal
    if (maxCalorieController.text.isEmpty){
      Fluttertoast.showToast(msg: "Please set Max Calories Goal");
      return;
    }

    // Total calories for selected food
    int totalCalories = selectedFoods.fold(0, (sum, food) => sum + food.calories);

    // Max Calories input
    int? maxCalories = int.tryParse(maxCalorieController.text);


    // Check if total calories less than max calories goal
    if (maxCalories != null && totalCalories > maxCalories) {
      Fluttertoast.showToast(msg: "Cannot save Total Calories higher then Max Calories Goal");
      return;
    }

    MealPlan mp = MealPlan(
      date: selectedDate,
      mealSelection: selectedFoods,
    );
    await DatabaseHelper.saveMealPlan(mp);
    Fluttertoast.showToast(msg: "Successfully saved meal plan");
    Navigator.of(context).pop(true);
  }

  // Method to remove food from the selected food list
  void _removeFood(int i) {
    setState(() {
      selectedFoods.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plan Screen'),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Select date button
            ElevatedButton(
              onPressed: () => selectDate(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
              ),
              child: Text(
                  DateFormat.yMd().format(selectedDate),
                  style: const TextStyle(fontSize: 30)
              ),
            ),
            const SizedBox(height: 30),
            // Max Calorie input
            TextField(
              controller: maxCalorieController,
              decoration: const InputDecoration(
                labelText: 'Max Calories',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20,),
            // Selected food items display
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.green,
                      width: 2.0
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ListView.separated(
                  itemCount: selectedFoods.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('${selectedFoods[index].item} - ${selectedFoods[index].calories} cal'),
                      // remove food item
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => _removeFood(index),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) =>
                  const Divider(
                    color: Colors.green,
                    thickness: 2.0,
                    height: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            // navigate to add food screen
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddFood()),
                );
                if (result != null && result is Food) {
                  setState(() {
                    selectedFoods.add(result);
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: const Text('Add Food'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        // Save new Meal Plan
        child: ElevatedButton(
          onPressed: saveMealPlan,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text('Save Meal Plan'),
        ),
      ),
    );
  }

  // Method to select a date
  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }
}
