import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

class WaterTaken extends StatefulWidget {
  final double waterConsumed;
  final String lastSeen;
  final double waterTarget;

  const WaterTaken({Key? key, this.waterConsumed = 0.0, this.lastSeen = "20:09:49", this.waterTarget = 2000.0}) : super(key: key);

  @override
  _WaterTakenState createState() => _WaterTakenState();
}

class _WaterTakenState extends State<WaterTaken> {
  final int _coffee = 180;
  final int _waterGlass = 250;
  final int _waterBottle = 500;
  final int _jug = 750;

  late double waterConsumed;
  late String lastSeen;
  late double waterTarget;

  @override
  void initState() {
    super.initState();
    waterConsumed = widget.waterConsumed;
    lastSeen = widget.lastSeen;
    waterTarget = widget.waterTarget;
  }

  String currentTime() {
    var now = DateTime.now();
    var formatter = DateFormat('HH:mm:ss');
    return formatter.format(now);
  }

  void _addWater(int amount) {
    setState(() {
      waterConsumed = (waterConsumed + amount).clamp(0.0, double.infinity);
      lastSeen = currentTime();
    });
  }

  void _saveAndReturn() {
    final result = {
      'waterConsumed': waterConsumed,
      'lastSeen': lastSeen,
      'waterTarget': waterTarget,
    };
    print("WaterTaken: Saving and returning data: $result");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved ${waterConsumed.toStringAsFixed(0)} ml")),
    );
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    double progress = waterTarget > 0 ? (waterConsumed / waterTarget).clamp(0.0, 1.0) : 0.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hydration Tracker",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2196F3),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                          offset: const Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: const Color(0xFF2196F3),
                        width: 4,
                      ),
                    ),
                    child: LiquidCircularProgressIndicator(
                      value: progress,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                      backgroundColor: Colors.white,
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      direction: Axis.vertical,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Today's Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${(progress * 100).toStringAsFixed(1)}%",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${waterConsumed.toStringAsFixed(1)} ml / ${waterTarget.toString()} ml",
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Add Water Intake",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWaterButton(Icons.coffee, _coffee, const Color(0xFFE1BEE7), "180 ml"),
                      _buildWaterButton(Icons.wine_bar, _waterGlass, const Color(0xFFB3E5FC), "250 ml"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildWaterButton(Icons.local_drink, _waterBottle, const Color(0xFFC8E6C9), "500 ml"),
                      _buildWaterButton(Icons.local_drink, _jug, const Color(0xFFFFE0B2), "750 ml"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    child: ElevatedButton(
                      onPressed: _saveAndReturn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        "Save Progress",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterButton(IconData icon, int amount, Color color, String label) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _addWater(amount),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.black87, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}