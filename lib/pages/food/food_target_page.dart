import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_app/services/api_service.dart';

class FoodTargetPage extends StatefulWidget {
  const FoodTargetPage({super.key});

  @override
  State<FoodTargetPage> createState() => _FoodTargetPageState();
}

class _FoodTargetPageState extends State<FoodTargetPage> {
  final TextEditingController breakfastCaloriesController = TextEditingController();
  final TextEditingController lunchCaloriesController = TextEditingController();
  final TextEditingController snackCaloriesController = TextEditingController();
  final TextEditingController dinnerCaloriesController = TextEditingController();

  final ApiService apiService = ApiService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTargets();
  }

  Future<void> _loadTargets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await apiService.getUserData();

      if (!mounted) return;

      final mealTargets = data['meal_targets'] ?? {};

      setState(() {
        breakfastCaloriesController.text = (mealTargets['breakfast_calories_target'] ?? 0.0).toString();
        lunchCaloriesController.text = (mealTargets['lunch_calories_target'] ?? 0.0).toString();
        snackCaloriesController.text = (mealTargets['snack_calories_target'] ?? 0.0).toString();
        dinnerCaloriesController.text = (mealTargets['dinner_calories_target'] ?? 0.0).toString();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading targets: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load targets')),
        );
      }
    }
  }

  Future<void> _saveTargets() async {
    try {
      final userData = {
        "uid": FirebaseAuth.instance.currentUser?.uid,
        "meal_targets": {
          "breakfast_calories_target": double.tryParse(breakfastCaloriesController.text) ?? 0.0,
          "lunch_calories_target": double.tryParse(lunchCaloriesController.text) ?? 0.0,
          "snack_calories_target": double.tryParse(snackCaloriesController.text) ?? 0.0,
          "dinner_calories_target": double.tryParse(dinnerCaloriesController.text) ?? 0.0,
        },
      };

      await apiService.saveUserData(userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Targets saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print("Error saving targets: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save targets')),
        );
      }
    }
  }

  @override
  void dispose() {
    breakfastCaloriesController.dispose();
    lunchCaloriesController.dispose();
    snackCaloriesController.dispose();
    dinnerCaloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Meal Targets"),
        backgroundColor: Colors.cyan,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMealTargetCard("Breakfast", breakfastCaloriesController, Colors.pink, Icons.egg),
                      _buildMealTargetCard("Lunch", lunchCaloriesController, Colors.green, Icons.restaurant),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMealTargetCard("Snack", snackCaloriesController, Colors.orange, Icons.local_dining),
                      _buildMealTargetCard("Dinner", dinnerCaloriesController, Colors.purple, Icons.fastfood),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: GestureDetector(
                      onTap: _saveTargets,
                      child: Container(
                        height: 50,
                        width: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.cyan.shade500,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              spreadRadius: 1,
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            "Save",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildMealTargetCard(String meal, TextEditingController controller, Color color, IconData icon) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            meal,
            style: const TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 100,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: "0 kcal",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}