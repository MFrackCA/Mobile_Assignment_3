import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../db/databasehelper.dart';
import '../models/food.dart';
import '../models/meal_plan.dart';
import 'add_food_screen.dart';

class UpdateMealPlanScreen extends StatefulWidget {
  final MealPlan existingMealPlan;

  const UpdateMealPlanScreen({Key? key, required this.existingMealPlan}) : super(key: key);

  @override
  State<UpdateMealPlanScreen> createState() => _UpdateMealPlanScreenState();
}

class _UpdateMealPlanScreenState extends State<UpdateMealPlanScreen> {
  late DateTime selectedDate;
  late List<Food> selectedFoods;
  TextEditingController maxCalorieController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedDate = widget.existingMealPlan.date;
    selectedFoods = List.from(widget.existingMealPlan.mealSelection);
    maxCalorieController.text = widget.existingMealPlan.totalCalories.toString();
  }

  // Method to update an existing meal plan
  void _updateMealPlan() async {
    if (maxCalorieController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please set Max Calories Goal");
      return;
    }

    int totalCalories = selectedFoods.fold(0, (sum, food) => sum + food.calories);
    int? maxCalories = int.tryParse(maxCalorieController.text);

    if (maxCalories != null && totalCalories > maxCalories) {
      Fluttertoast.showToast(msg: "Cannot save Total Calories higher than Max Calories Goal");
      return;
    }

    MealPlan updatedMealPlan = MealPlan(
      id: widget.existingMealPlan.id,
      date: selectedDate,
      mealSelection: selectedFoods,
    );
    await DatabaseHelper.updateMealPlan(updatedMealPlan);
    Fluttertoast.showToast(msg: "Meal plan updated successfully");
    Navigator.of(context).pop(true);
  }

  // Method to remove food from the selected food list
  void _removeFood(int i) {
    setState(() {
      selectedFoods.removeAt(i);
    });
  }

  // Method to select a date
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Meal Plan'),
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
          onPressed: _updateMealPlan,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          child: const Text('Update Meal Plan'),
        ),
      ),
    );
  }
}
