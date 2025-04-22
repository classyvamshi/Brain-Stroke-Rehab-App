import 'package:flutter/material.dart';
import 'package:my_app/pages/result_page.dart';

const Color inactiveCard = Color(0xFFFFFFFF);
var exerciseList = [
  "Little to no exercise",
  "Light exercise (1–3 days per week)",
  "Moderate exercise (3–5 days per week)",
  "Heavy exercise (6–7 days per week)",
  "Very heavy exercise (twice per day)"
];
var goalList = [
  "Maintain current weight",
  "Lose 0.5kg per week",
  "Lose 1kg per week",
  "Gain 0.5kg per week",
  "Gain 1kg per week"
];

class GoalsPage extends StatefulWidget {
  final String gender;
  final double height;
  final double weight;
  final int age;

  const GoalsPage({
    super.key,
    required this.gender,
    required this.height,
    required this.weight,
    required this.age,
  });

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  String _exerciseLevel = exerciseList[0]; // Default to first option
  String _calorieGoal = goalList[0]; // Default to first option
  late String gender;
  late double height, weight;
  late int age;

  @override
  void initState() {
    gender = widget.gender;
    height = widget.height;
    weight = widget.weight;
    age = widget.age;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Goals"),
        backgroundColor: Colors.cyan, // Matches AimPage's app bar color
      ),
      backgroundColor: const Color(0xFFF2F3F8), // Light grey background from AimPage
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Add padding to avoid content hitting edges
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              color: Colors.cyan[200], // Light cyan note box
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Note: ",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Choose the following option to know your goals on your health for this week",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  decoration: BoxDecoration(
                    color: inactiveCard, // White background
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black45.withOpacity(0.2),
                        offset: const Offset(1.1, 4.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Exercise Scale",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Roboto',
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        thickness: 1,
                        color: Colors.grey,
                        indent: 25,
                        endIndent: 25,
                      ),
                      ...exerciseList.map((exercise) => ListTile(
                            title: Text(exercise, style: const TextStyle(fontSize: 18)),
                            leading: Radio(
                              value: exercise,
                              groupValue: _exerciseLevel,
                              onChanged: (String? value) {
                                setState(() {
                                  _exerciseLevel = value!;
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Add spacing between sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: inactiveCard, // White background
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.black45.withOpacity(0.2),
                        offset: const Offset(1.1, 4.0),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        "Calorie Goal",
                        style: TextStyle(
                          fontSize: 25,
                          fontFamily: 'Roboto',
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(
                        height: 2,
                        thickness: 1,
                        color: Colors.grey,
                        indent: 25,
                        endIndent: 25,
                      ),
                      ...goalList.map((goal) => ListTile(
                            title: Text(goal, style: const TextStyle(fontSize: 18)),
                            leading: Radio(
                              value: goal,
                              groupValue: _calorieGoal,
                              onChanged: (String? value) {
                                setState(() {
                                  _calorieGoal = value!;
                                });
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              if (_exerciseLevel != null && _calorieGoal != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResultPage(
                      gender: gender,
                      height: height,
                      weight: weight,
                      age: age,
                      exerciseLevel: _exerciseLevel!,
                      calorieGoal: _calorieGoal!,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select both options')),
                );
              }
            },
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.cyan,
              ),
              child: Column(
                children: const <Widget>[
                  Text(
                    'Calculate',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}