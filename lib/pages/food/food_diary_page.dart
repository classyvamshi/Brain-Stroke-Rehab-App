import 'package:flutter/material.dart';
import 'package:my_app/services/api_service.dart';
import 'package:my_app/pages/food/add_food_page.dart';
import 'package:intl/intl.dart';

class FoodDiaryPage extends StatefulWidget {
  const FoodDiaryPage({Key? key}) : super(key: key);

  @override
  State<FoodDiaryPage> createState() => _FoodDiaryPageState();
}

class _FoodDiaryPageState extends State<FoodDiaryPage> {
  final ApiService apiService = ApiService();
  Map<String, List<Map<String, dynamic>>> foodEntriesByMeal = {
    'Breakfast': [],
    'Lunch': [],
    'Snack': [],
    'Dinner': [],
  };
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadFoodEntries();
  }

  Future<void> _loadFoodEntries() async {
    try {
      final entries = await apiService.getFoodEntries(
        DateFormat('yyyy-MM-dd').format(selectedDate),
      );
      setState(() {
        foodEntriesByMeal = {
          'Breakfast': [],
          'Lunch': [],
          'Snack': [],
          'Dinner': [],
        };
        for (var entry in entries) {
          final mealType = entry['meal_type'] as String;
          if (foodEntriesByMeal.containsKey(mealType)) {
            foodEntriesByMeal[mealType]!.add(entry);
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading food entries: $e')),
      );
    }
  }

  Future<void> _addFood(String mealType) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddFoodPage(mealType: mealType),
      ),
    );

    if (result != null) {
      await _loadFoodEntries();
    }
  }

  Widget _buildMealSection(String mealType, Color color, IconData icon) {
    final entries = foodEntriesByMeal[mealType]!;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                mealType,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3A4A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          entries.isEmpty
              ? const Text(
                  "No foods added",
                  style: TextStyle(color: Colors.grey),
                )
              : Column(
                  children: entries.map((entry) {
                    return ListTile(
                      title: Text(entry['name'] ?? 'Unknown'),
                      subtitle: Text(
                        "Calories: ${entry['calories']?.toStringAsFixed(1) ?? '0'} kcal, "
                        "Carbs: ${entry['carbs']?.toStringAsFixed(1) ?? '0'}g, "
                        "Protein: ${entry['protein']?.toStringAsFixed(1) ?? '0'}g, "
                        "Fat: ${entry['fat']?.toStringAsFixed(1) ?? '0'}g",
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _addFood(mealType),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text("Add $mealType Food"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Diary'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM d, y').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null && picked != selectedDate) {
                        setState(() {
                          selectedDate = picked;
                        });
                        await _loadFoodEntries();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildMealSection("Breakfast", Colors.pink, Icons.egg),
              _buildMealSection("Lunch", Colors.green, Icons.restaurant),
              _buildMealSection("Snack", Colors.orange, Icons.local_dining),
              _buildMealSection("Dinner", Colors.purple, Icons.fastfood),
            ],
          ),
        ),
      ),
    );
  }
}