import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl = 'http://192.168.57.207:8001';
  final String apiPrefix = '/api';

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        throw Exception('User not authenticated');
      }
      final endpoint = '$apiPrefix/user/$uid';
      print('Attempting to connect to: $baseUrl$endpoint');
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        return {}; // Return empty map for new users
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getUserData: $e');
      return {}; // Return empty map on error
    }
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final endpoint = '$apiPrefix/user';
      final payload = json.encode(userData);
      print('Attempting to save data to: $baseUrl$endpoint');
      print('Data to save: $payload');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: payload,
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to save user data: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error in saveUserData: $e');
      throw Exception('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>> getNutritionData(String foodName) async {
    try {
      final endpoint = '$apiPrefix/nutrition?food=$foodName';
      print('Attempting to get nutrition data from: $baseUrl$endpoint');
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load nutrition data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getNutritionData: $e');
      throw Exception('Error fetching nutrition data: $e');
    }
  }

  Future<void> saveFoodEntry(Map<String, dynamic> foodData) async {
    try {
      final endpoint = '$apiPrefix/food';
      print('Attempting to save food entry to: $baseUrl$endpoint');
      print('Food data to save: $foodData');

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(foodData),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to save food entry: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in saveFoodEntry: $e');
      throw Exception('Error saving food entry: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodEntries(String date) async {
    try {
      final endpoint = '$apiPrefix/food?date=$date';
      print('Attempting to get food entries from: $baseUrl$endpoint');
      final response = await http.get(Uri.parse('$baseUrl$endpoint'));
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load food entries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFoodEntries: $e');
      throw Exception('Error fetching food entries: $e');
    }
  }
}