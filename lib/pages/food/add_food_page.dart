import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:intl/intl.dart'; // Added for DateFormat
import 'package:firebase_auth/firebase_auth.dart'; // Added for FirebaseAuth

class AddFoodPage extends StatefulWidget {
  final String mealType;
  const AddFoodPage({Key? key, required this.mealType}) : super(key: key);

  @override
  State<AddFoodPage> createState() => _AddFoodPageState();
}

class _AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController foodNameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController carbsController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fatController = TextEditingController();

  bool isLoading = false;

  Future<void> _getNutritionData() async {
    if (foodNameController.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await ApiService().getNutritionData(foodNameController.text);
      setState(() {
        caloriesController.text = data['calories']?.toString() ?? '';
        carbsController.text = data['carbs']?.toString() ?? '';
        proteinController.text = data['protein']?.toString() ?? '';
        fatController.text = data['fat']?.toString() ?? '';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching nutrition data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveFood() async {
    if (foodNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name')),
      );
      return;
    }

    try {
      final foodData = {
        'name': foodNameController.text,
        'calories': double.tryParse(caloriesController.text) ?? 0.0,
        'carbs': double.tryParse(carbsController.text) ?? 0.0,
        'protein': double.tryParse(proteinController.text) ?? 0.0,
        'fat': double.tryParse(fatController.text) ?? 0.0,
        'meal_type': widget.mealType,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'uid': FirebaseAuth.instance.currentUser?.uid,
      };

      await ApiService().saveFoodEntry(foodData);
      Navigator.pop(context, foodData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving food: $e')),
      );
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: unit,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.mealType}'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: foodNameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _getNutritionData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(isLoading ? 'Loading...' : 'Get Data'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInputField('Calories', caloriesController, 'kcal'),
            _buildInputField('Carbohydrates', carbsController, 'g'),
            _buildInputField('Protein', proteinController, 'g'),
            _buildInputField('Fat', fatController, 'g'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveFood,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    foodNameController.dispose();
    caloriesController.dispose();
    carbsController.dispose();
    proteinController.dispose();
    fatController.dispose();
    super.dispose();
  }
}