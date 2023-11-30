import 'package:assign3_calorie_calculator/db/databasehelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import 'add_food_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MealPlanScreen extends StatefulWidget {

  //Existing meal plan for update
  final MealPlan? existingMealPlan;
  const MealPlanScreen({super.key, this.existingMealPlan});

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {


  DateTime selectedDate = DateTime.now();
  List<Food> selectedFoods = [];
  TextEditingController maxCalorieController = TextEditingController();

  // Calculate total calories of selected food items
  int calculateTotalCalories() {
    int total = 0;
    for (Food food in selectedFoods) {
      total += food.calories;
    }
    return total;
  }

  void _saveOrUpdateMealPlan() async {
    MealPlan mp = MealPlan(
      id: widget.existingMealPlan?.id, // Use existing ID if available
      date: selectedDate,
      mealSelection: selectedFoods,
    );

    if (widget.existingMealPlan == null) {
      await DatabaseHelper.saveMealPlan(mp);
      Fluttertoast.showToast(msg: "Successfully saved meal plan");
    } else {
      await DatabaseHelper.updateMealPlan(mp);
      Fluttertoast.showToast(msg: "Meal plan updated successfully");
    }

    Navigator.of(context).pop(true); // Indicate that an update was made
  }

  // remove food from selected food array
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
              ElevatedButton(
                onPressed: () => _selectDate(context),
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
              TextField(
                controller: maxCalorieController,
                decoration: const InputDecoration(
                  labelText: 'Max Calories',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20,),
              // Display selected foods here
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
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
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
                  backgroundColor: Colors.green,
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
        child: ElevatedButton(
          onPressed: () {
            _saveOrUpdateMealPlan(); // Call a method that handles both saving and updating
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: Text(widget.existingMealPlan == null ? 'Save Meal Plan' : 'Update Meal Plan'), // Dynamic text based on the context
        ),
      ),
    );
  }
  Future<void> _selectDate(BuildContext context) async {
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
