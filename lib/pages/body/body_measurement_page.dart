import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/services/api_service.dart';

class BodyMeasurementPage extends StatefulWidget {
  const BodyMeasurementPage({super.key});

  @override
  State<BodyMeasurementPage> createState() => _BodyMeasurementPageState();
}

class _BodyMeasurementPageState extends State<BodyMeasurementPage> {
  String? _selectedGender;
  double _height = 186.0;
  double _weight = 70.0;
  int _age = 19;
  String? _selectedGoal;
  String? _activityLevel;
  bool _showResults = false;
  double? _bmi;

  @override
  void initState() {
    super.initState();
    _loadExistingMeasurement();
  }

  Future<void> _loadExistingMeasurement() async {
    try {
      print('Loading existing user data');
      final data = await ApiService().getUserData();
      print('Loaded user data: $data');
      final body = data['body_measurement'];
      if (body != null) {
        setState(() {
          _selectedGender = body['gender'];
          _height = (body['height'] ?? _height).toDouble();
          _weight = (body['weight'] ?? _weight).toDouble();
          _age = (body['age'] ?? _age).toInt();
          _selectedGoal = body['goal'];
          _activityLevel = body['activity_level'];
          _bmi = body['bmi']?.toDouble();
        });
      }
    } catch (e) {
      print("Error loading existing body data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurement', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your details to calculate your BMI and set your goals',
                style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32)),
              ),
              const SizedBox(height: 20),
              _buildGenderSelection(),
              const SizedBox(height: 20),
              _buildHeightSlider(),
              const SizedBox(height: 20),
              _buildWeightAndAgeRow(),
              const SizedBox(height: 20),
              _buildGoalSelection(),
              const SizedBox(height: 20),
              _buildActivityLevelSelection(),
              const SizedBox(height: 20),
              if (_showResults && _bmi != null) _buildResultsCard(),
              const SizedBox(height: 20),
              _buildCalculateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text('Select Gender', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 16)),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _genderOption('FEMALE', const Color(0xFFE91E63), Icons.female),
            const SizedBox(width: 16),
            _genderOption('MALE', const Color(0xFF2196F3), Icons.male),
          ],
        ),
      ],
    );
  }

  Widget _genderOption(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: _selectedGender == label ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _selectedGender == label ? color : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(fontSize: 16, color: _selectedGender == label ? color : Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightSlider() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Height', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('${_height.toStringAsFixed(1)} cm', 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(width: 8),
              Text('(${(_height * 0.0328084).toStringAsFixed(2)} ft)', 
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          Slider(
            value: _height,
            min: 100.0,
            max: 250.0,
            divisions: 150,
            activeColor: const Color(0xFF4CAF50),
            inactiveColor: Colors.grey.shade300,
            label: _height.toStringAsFixed(1),
            onChanged: (value) => setState(() => _height = value),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightAndAgeRow() {
    return Row(
      children: [
        Expanded(child: _buildWeightBox()),
        const SizedBox(width: 16),
        Expanded(child: _buildAgeBox()),
      ],
    );
  }

  Widget _buildWeightBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weight', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_weight.toStringAsFixed(0), 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
              const Text(' kg', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.remove, () => setState(() => _weight--)),
              const SizedBox(width: 16),
              _buildControlButton(Icons.add, () => setState(() => _weight++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAgeBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Age', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_age.toString(), 
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildControlButton(Icons.remove, () => setState(() => _age--)),
              const SizedBox(width: 16),
              _buildControlButton(Icons.add, () => setState(() => _age++)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF4CAF50)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildGoalSelection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What is your goal?', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedGoal,
            hint: const Text('Select your goal', style: TextStyle(color: Colors.grey)),
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87),
            items: <String>['Lose Weight', 'Gain Weight', 'Maintain Weight']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (String? newValue) => setState(() => _selectedGoal = newValue),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelSelection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('How active are you?', style: TextStyle(fontSize: 16, color: Color(0xFF2E7D32))),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _activityLevel,
            hint: const Text('Select activity level', style: TextStyle(color: Colors.grey)),
            isExpanded: true,
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black87),
            items: <String>['Sedentary', 'Lightly Active', 'Moderately Active', 'Very Active']
                .map((String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ))
                .toList(),
            onChanged: (String? newValue) => setState(() => _activityLevel = newValue),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Results', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
            const SizedBox(height: 12),
            _buildResultRow('BMI', _bmi!.toStringAsFixed(2)),
            _buildResultRow('Goal', _selectedGoal!),
            _buildResultRow('Activity Level', _activityLevel!),
            const SizedBox(height: 12),
            Text(
              _bmi! < 18.5
                  ? 'Underweight'
                  : _bmi! < 25
                      ? 'Normal'
                      : _bmi! < 30
                          ? 'Overweight'
                          : 'Obese',
              style: TextStyle(
                fontSize: 18,
                color: _bmi! < 18.5 || _bmi! >= 30 ? const Color(0xFFE91E63) : const Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedGender == null || _selectedGoal == null || _activityLevel == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please complete all fields')),
            );
            return;
          }

          _bmi = _weight / ((_height / 100) * (_height / 100));

          final userData = {
            "uid": FirebaseAuth.instance.currentUser?.uid,
            "body_measurement": {
              "gender": _selectedGender,
              "height": _height,
              "weight": _weight,
              "age": _age,
              "goal": _selectedGoal,
              "activity_level": _activityLevel,
              "bmi": _bmi,
              "last_measured": DateFormat('dd-MMM-yyyy').format(DateTime.now()),
            },
          };

          try {
            print('Saving user data: $userData');
            await ApiService().saveUserData(userData);
            print('User data saved successfully');
            setState(() => _showResults = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data saved and BMI calculated')),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pop(context, userData['body_measurement']);
            });
          } catch (e) {
            print("Error saving body data: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to save data')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: const Text('Calculate', style: TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}