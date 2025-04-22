import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/pages/services/api_service.dart';
import 'package:my_app/pages/articles/article_page.dart';
import 'package:my_app/pages/gaming/gaming_page.dart';
import 'package:my_app/pages/quiz/quiz_page.dart';
import 'package:my_app/pages/prediction/prediction_page.dart';
import 'package:my_app/pages/auth/login_page.dart';
import 'package:my_app/pages/water/water_taken.dart';
import 'package:my_app/pages/body/body_measurement_page.dart';
import 'package:my_app/pages/training/training_page.dart';
import 'package:my_app/pages/food/food_target_page.dart';
import 'package:my_app/pages/chatbot/chatbot_page.dart';
import 'package:my_app/pages/food/food_diary_page.dart';
import 'package:my_app/pages/instructions/instructions_page.dart';
import 'package:my_app/pages/help/help_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final User? user = FirebaseAuth.instance.currentUser;
  AnimationController? animationController;
  DateTime selectedDate = DateTime.now();
  double waterConsumed = 0.0;
  String lastSeen = "00:00:00";
  String lastResetDate = "";
  double waterTarget = 2000.0;

  // Diet tracking variables
  double totalCaloriesEaten = 0.0;
  double caloriesBurned = 0.0;
  double carbsLeft = 0.0;
  double proteinLeft = 0.0;
  double fatLeft = 0.0;

  double breakfastCaloriesTarget = 0.0;
  double lunchCaloriesTarget = 0.0;
  double snackCaloriesTarget = 0.0;
  double dinnerCaloriesTarget = 0.0;

  // Body measurement fields
  String gender = "Not set";
  double height = 0.0;
  double weight = 0.0;
  int age = 0;
  String lastMeasured = "";
  String goal = "Not set";
  String activityLevel = "Not set";
  double bmi = 0.0;

  final ApiService apiService = ApiService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadDataFromMongoDB();
  }

  Future<void> _loadDataFromMongoDB() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await apiService.getUserData();
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Fetch food entries for today
      final foodEntries = await apiService.getFoodEntries(currentDate);

      setState(() {
        // Water data
        waterConsumed = (data['water_data']?['water_consumed'] as num?)?.toDouble() ?? 0.0;
        lastSeen = data['water_data']?['last_seen'] ?? currentTime();
        lastResetDate = data['water_data']?['last_reset_date'] ?? currentDate;
        waterTarget = (data['water_data']?['water_target'] as num?)?.toDouble() ?? 2000.0;

        // Meal targets
        breakfastCaloriesTarget = (data['meal_targets']?['breakfast_calories_target'] as num?)?.toDouble() ?? 0.0;
        lunchCaloriesTarget = (data['meal_targets']?['lunch_calories_target'] as num?)?.toDouble() ?? 0.0;
        snackCaloriesTarget = (data['meal_targets']?['snack_calories_target'] as num?)?.toDouble() ?? 0.0;
        dinnerCaloriesTarget = (data['meal_targets']?['dinner_calories_target'] as num?)?.toDouble() ?? 0.0;

        // Nutrient targets
        final nutrientTargets = data['nutrient_targets'] ?? {};
        final totalCarbs = (nutrientTargets['carbs'] as num?)?.toDouble() ?? 0.0;
        final totalProtein = (nutrientTargets['protein'] as num?)?.toDouble() ?? 0.0;
        final totalFat = (nutrientTargets['fat'] as num?)?.toDouble() ?? 0.0;

        // Calculate diet tracking from food entries
        totalCaloriesEaten = 0.0;
        double consumedCarbs = 0.0;
        double consumedProtein = 0.0;
        double consumedFat = 0.0;
        for (var entry in foodEntries) {
          totalCaloriesEaten += (entry['calories'] as num?)?.toDouble() ?? 0.0;
          consumedCarbs += (entry['carbs'] as num?)?.toDouble() ?? 0.0;
          consumedProtein += (entry['protein'] as num?)?.toDouble() ?? 0.0;
          consumedFat += (entry['fat'] as num?)?.toDouble() ?? 0.0;
        }
        caloriesBurned = (data['diet_tracking']?['calories_burned'] as num?)?.toDouble() ?? 0.0;

        carbsLeft = totalCarbs - consumedCarbs;
        proteinLeft = totalProtein - consumedProtein;
        fatLeft = totalFat - consumedFat;

        // Body measurement
        gender = data['body_measurement']?['gender'] ?? "Not set";
        height = (data['body_measurement']?['height'] as num?)?.toDouble() ?? 0.0;
        weight = (data['body_measurement']?['weight'] as num?)?.toDouble() ?? 0.0;
        age = (data['body_measurement']?['age'] as num?)?.toInt() ?? 0;
        lastMeasured = data['body_measurement']?['last_measured'] ?? "";
        goal = data['body_measurement']?['goal'] ?? "Not set";
        activityLevel = data['body_measurement']?['activity_level'] ?? "Not set";
        bmi = (data['body_measurement']?['bmi'] as num?)?.toDouble() ?? 0.0;

        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() {
        isLoading = false;
        waterConsumed = 0.0;
        lastSeen = currentTime();
        lastResetDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        waterTarget = 2000.0;
        gender = "Not set";
        height = 0.0;
        weight = 0.0;
        age = 0;
        lastMeasured = "";
        goal = "Not set";
        activityLevel = "Not set";
        bmi = 0.0;
        totalCaloriesEaten = 0.0;
        caloriesBurned = 0.0;
        carbsLeft = 0.0;
        proteinLeft = 0.0;
        fatLeft = 0.0;
      });
    }
  }

  Future<void> _saveDataToMongoDB() async {
    try {
      final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      // Ensure water data is valid
      if (lastSeen.isEmpty) lastSeen = currentTime();
      if (lastResetDate.isEmpty) lastResetDate = currentDate;

      // Handle daily reset locally
      if (lastResetDate != currentDate) {
        waterConsumed = 0.0;
        lastSeen = currentTime();
        lastResetDate = currentDate;
      }

      final userData = {
        "uid": user?.uid,
        "water_data": {
          "water_consumed": waterConsumed,
          "last_seen": lastSeen,
          "last_reset_date": lastResetDate,
          "water_target": waterTarget,
        },
        "meal_targets": {
          "breakfast_calories_target": breakfastCaloriesTarget,
          "lunch_calories_target": lunchCaloriesTarget,
          "snack_calories_target": snackCaloriesTarget,
          "dinner_calories_target": dinnerCaloriesTarget,
        },
        "diet_tracking": {
          "total_calories_eaten": totalCaloriesEaten,
          "calories_burned": caloriesBurned,
          "carbs_consumed": totalCaloriesEaten * 0.4 / 4,
          "protein_consumed": totalCaloriesEaten * 0.3 / 4,
          "fat_consumed": totalCaloriesEaten * 0.3 / 9,
        },
        "body_measurement": {
          "gender": gender != "Not set" ? gender : null,
          "height": height != 0.0 ? height : null,
          "weight": weight != 0.0 ? weight : null,
          "age": age != 0 ? age : null,
          "last_measured": lastMeasured.isNotEmpty ? lastMeasured : null,
          "goal": goal != "Not set" ? goal : null,
          "activity_level": activityLevel != "Not set" ? activityLevel : null,
          "bmi": bmi != 0.0 ? bmi : null,
        },
      };
      print("Saving user data: $userData");
      await apiService.saveUserData(userData);
      print("Data saved successfully: water_data=$waterConsumed, $lastSeen, $lastResetDate, $waterTarget");
    } catch (e) {
      print("Error saving data: $e");
    }
  }

  String currentTime() {
    var now = DateTime.now();
    var formatter = DateFormat('HH:mm:ss');
    return formatter.format(now);
  }

  void _showSetTargetDialog() {
    double newTarget = waterTarget;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Water Target'),
        content: TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Target (ml)',
            hintText: 'Enter target in milliliters (e.g., 2000 for 2L)',
          ),
          onChanged: (value) {
            newTarget = double.tryParse(value) ?? waterTarget;
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                waterTarget = newTarget > 0 ? newTarget : 2000.0;
                lastSeen = currentTime();
                lastResetDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
              });
              _saveDataToMongoDB();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void signUserOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage(onTap: null)),
    );
  }

  void _navigateToArticles() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const Articles()));
  }

  void _navigateToGaming() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const GamingPage()));
  }

  void _navigateToSelfAssessment() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          [
            "Do you feel sad or down most of the time?",
            "Have you lost interest in activities you used to enjoy?",
            "Do you have trouble sleeping or sleep too much?",
            "Do you feel tired or lack energy often?",
            "Do you have difficulty concentrating?"
          ],
          5,
          "Depression",
          [const Color.fromARGB(255, 91, 156, 45), const Color.fromARGB(255, 200, 31, 226)],
        ),
      ),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Self Assessment Result: ${value['disorder']} - ${value['risk']} Risk (Score: ${value['score']}/${value['total']})',
            ),
          ),
        );
      }
    });
  }

  void _navigateToSmartPrediction() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PredictionPage()),
    );
  }

  void _navigateToMeditation() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const TrainingPage()));
  }

  void _navigateToWaterTaken() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WaterTaken(
          waterConsumed: waterConsumed,
          lastSeen: lastSeen,
          waterTarget: waterTarget,
        ),
      ),
    );
    if (result != null && result is Map<String, dynamic>) {
      print("HomePage: Received water data from WaterTaken: $result");
      setState(() {
        waterConsumed = (result['waterConsumed'] as num?)?.toDouble() ?? waterConsumed;
        lastSeen = result['lastSeen'] as String? ?? currentTime();
        waterTarget = (result['waterTarget'] as num?)?.toDouble() ?? waterTarget;
        lastResetDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      });
      print("HomePage: Updated state - waterConsumed: $waterConsumed, lastSeen: $lastSeen, waterTarget: $waterTarget, lastResetDate: $lastResetDate");
      await _saveDataToMongoDB();
    } else {
      print("HomePage: No valid water data returned from WaterTaken");
    }
  }

  void _navigateToBodyMeasurement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BodyMeasurementPage(),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        gender = result['gender'] ?? "Not set";
        height = result['height']?.toDouble() ?? 0.0;
        weight = result['weight']?.toDouble() ?? 0.0;
        age = result['age'] ?? 0;
        lastMeasured = result['last_measured'] ?? "";
        goal = result['goal'] ?? "Not set";
        activityLevel = result['activity_level'] ?? "Not set";
        bmi = result['bmi']?.toDouble() ?? 0.0;
      });
      await _saveDataToMongoDB();
    }
  }

  void _navigateToChatbot() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatbotPage()));
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _loadDataFromMongoDB();
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("MindHeaven", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2D3A4A),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF2D3A4A),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xFF3B4A5C),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF3B4A5C), Color(0xFF2D3A4A)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 24,
                          color: Color(0xFF2D3A4A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.email?.split('@').first ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              _buildDrawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
              _buildDrawerItem(Icons.shield, 'Self Assessment', () {
                Navigator.pop(context);
                _navigateToSelfAssessment();
              }),
              _buildDrawerItem(Icons.help_outline, 'Instructions', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const InstructionsPage()),
                );
              }),
              _buildDrawerItem(Icons.contact_phone, 'Professional Help', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpPage()),
                );
              }),
              _buildDrawerItem(Icons.lightbulb, 'Smart Prediction', () {
                Navigator.pop(context);
                _navigateToSmartPrediction();
              }),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 20),
                  _buildDiaryHeader(context),
                  const SizedBox(height: 16),
                  _buildDietDetailsCard(context),
                  const SizedBox(height: 16),
                  _buildMealsTodayCard(context),
                  const SizedBox(height: 16),
                  _buildBodyMeasurementCard(context),
                  const SizedBox(height: 16),
                  _buildWaterCard(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(Icons.local_hospital, 'Vitals', Colors.pink),
              _buildNavItem(Icons.article, 'Article', Colors.grey, onTap: _navigateToArticles),
              _buildNavItem(Icons.videogame_asset, 'Gaming', Colors.grey, onTap: _navigateToGaming),
              _buildNavItem(Icons.self_improvement, 'Meditation', Colors.grey, onTap: _navigateToMeditation),
              _buildNavItem(Icons.chat_bubble_outline, 'Chatbot', Colors.grey, onTap: _navigateToChatbot),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3A4A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.waving_hand, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            "Hey ${user?.email?.split('@').first ?? 'User'}!",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiaryHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "My Diary",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A4A),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Text(
                  DateFormat('dd MMM').format(selectedDate),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D3A4A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFF2D3A4A)),
                  onPressed: () => _selectDate(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3A4A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDietDetailsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: Color(0xFF2D3A4A)),
                const SizedBox(width: 8),
                const Text(
                  "Diet Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDietMetric("Eaten", "${totalCaloriesEaten.toStringAsFixed(0)} kcal", Icons.local_fire_department, Colors.orange),
                _buildDietMetric("Burned", "${caloriesBurned.toStringAsFixed(0)} kcal", Icons.fitness_center, Colors.green),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDietMetric("Carbs left", "${carbsLeft.toStringAsFixed(0)}g", Icons.grain, Colors.blue),
                _buildDietMetric("Protein left", "${proteinLeft.toStringAsFixed(0)}g", Icons.food_bank, Colors.purple),
                _buildDietMetric("Fat left", "${fatLeft.toStringAsFixed(0)}g", Icons.water_drop, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsTodayCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.fastfood, color: Color(0xFF2D3A4A)),
                    const SizedBox(width: 8),
                    const Text(
                      "Meals Today",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3A4A),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FoodDiaryPage()),
                    ).then((_) {
                      _loadDataFromMongoDB();
                    });
                  },
                  child: const Text(
                    "See Details",
                    style: TextStyle(
                      color: Colors.cyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMealCard("Breakfast", "${breakfastCaloriesTarget.toStringAsFixed(0)} kcal", Colors.pink),
                _buildMealCard("Lunch", "${lunchCaloriesTarget.toStringAsFixed(0)} kcal", Colors.green),
                _buildMealCard("Snack", "${snackCaloriesTarget.toStringAsFixed(0)} kcal", Colors.orange),
                _buildMealCard("Dinner", "${dinnerCaloriesTarget.toStringAsFixed(0)} kcal", Colors.purple),
              ],
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodTargetPage()),
                );
                if (result == true) {
                  await _loadDataFromMongoDB();
                  setState(() {});
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, color: Color(0xFF2D3A4A)),
                    SizedBox(width: 8),
                    Text(
                      "Set Target",
                      style: TextStyle(
                        color: Color(0xFF2D3A4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.arrow_forward, color: Color(0xFF2D3A4A), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(String meal, String calories, Color color) {
    return Container(
      width: 70,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(_getMealIcon(meal), color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            meal,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2D3A4A),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            calories,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3A4A),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String meal) {
    switch (meal) {
      case "Breakfast":
        return Icons.egg;
      case "Lunch":
        return Icons.restaurant;
      case "Snack":
        return Icons.local_dining;
      case "Dinner":
        return Icons.fastfood;
      default:
        return Icons.food_bank;
    }
  }

  Widget _buildBodyMeasurementCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_weight, color: Color(0xFF2D3A4A)),
                const SizedBox(width: 8),
                const Text(
                  "Body Measurement",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMeasurementMetric(
                  "Weight",
                  weight > 0.0 ? "${weight.toStringAsFixed(2)} kg" : "Not set",
                  Icons.monitor_weight,
                  Colors.blue,
                ),
                _buildMeasurementMetric(
                  "Height",
                  height > 0.0 ? "${height.toStringAsFixed(1)} cm" : "Not set",
                  Icons.height,
                  Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMeasurementMetric(
                  "Gender",
                  gender,
                  Icons.person,
                  Colors.purple,
                ),
                _buildMeasurementMetric(
                  "BMI",
                  bmi > 0.0 ? bmi.toStringAsFixed(2) : "Not calculated",
                  Icons.calculate,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildMeasurementMetric(
                  "Goal",
                  goal,
                  Icons.flag,
                  Colors.red,
                ),
                _buildMeasurementMetric(
                  "Activity",
                  activityLevel,
                  Icons.directions_run,
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _navigateToBodyMeasurement,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit, color: Color(0xFF2D3A4A)),
                    const SizedBox(width: 8),
                    const Text(
                      "Update Measurements",
                      style: TextStyle(
                        color: Color(0xFF2D3A4A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(Icons.arrow_forward, color: Color(0xFF2D3A4A), size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementMetric(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3A4A),
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(BuildContext context) {
    final double progress = waterTarget > 0 ? (waterConsumed / waterTarget).clamp(0.0, 1.0) : 0.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.opacity, color: Color(0xFF2D3A4A)),
                const SizedBox(width: 8),
                const Text(
                  "Water Intake",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3A4A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 120,
                    width: 120,
                    child: CircularProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.cyan.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                      strokeWidth: 12,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3A4A),
                        ),
                      ),
                      Text(
                        "${waterConsumed.toStringAsFixed(0)} ml",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.cyan),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Prepare your stomach for lunch with one or two glasses of water",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2D3A4A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    "Last drink $lastSeen",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: _showSetTargetDialog,
                      child: const Text(
                        "Change Target",
                        style: TextStyle(
                          color: Color(0xFF2D3A4A),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: _navigateToWaterTaken,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D3A4A),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Aqua SmartBottle",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}