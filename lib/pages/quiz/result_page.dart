import 'package:flutter/material.dart';

class ResultPage extends StatelessWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;
  final String exerciseLevel;
  final String calorieGoal;

  const ResultPage({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
    required this.exerciseLevel,
    required this.calorieGoal,
  });

  double calculateBMI(double weight, double height) {
    return weight / ((height / 100) * (height / 100)); // weight in kg, height in cm
  }

  double calculateBMR(String gender, double weight, double height, int age) {
    if (gender == 'MALE') {
      return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age);
    } else {
      return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age);
    }
  }

  double calculateDailyCalories(double bmr, String exerciseLevel) {
    switch (exerciseLevel) {
      case 'Little to no exercise':
        return bmr * 1.2;
      case 'Light exercise (1-3 days per week)':
        return bmr * 1.375;
      case 'Moderate exercise (3-5 days per week)':
        return bmr * 1.55;
      case 'Heavy exercise (5-7 days per week)':
        return bmr * 1.725;
      case 'Very heavy exercise (twice per day)':
        return bmr * 1.9;
      default:
        return bmr * 1.2;
    }
  }

  String getBMIStatus(double bmi) {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal weight";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calculateBMI(weight, height);
    final bmr = calculateBMR(gender, weight, height, age);
    final dailyCalories = calculateDailyCalories(bmr, exerciseLevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Result',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.cyan, // Matches the cyan app bar in the image
        elevation: 0, // Removes shadow for a cleaner look
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange, Colors.yellow], // Orange gradient background
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Result',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              // BMI Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Body Mass Weight',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMI Value: ${bmi.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      'You have ${getBMIStatus(bmi)} body weight. Good Job!!',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // BMR Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basal Metabolic Rate',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'BMR Value: ${bmr.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    Text(
                      'Current Calorie: ${dailyCalories.toStringAsFixed(2)} (as per activity)',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Daily Calories (optional, based on the image)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daily Calories Required',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${dailyCalories.toStringAsFixed(2)} (as per activity)',
                      style: const TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Recalculate logic here (e.g., navigate back to BodyMeasurementPage)
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan, // Cyan for Recalculate
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Recalculate',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Save results (e.g., using SharedPreferences or Firebase)
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Red for Save
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}