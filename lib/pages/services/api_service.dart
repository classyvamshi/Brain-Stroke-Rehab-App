import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ApiService {
  final String baseUrl = "http://10.12.227.190:8000/api";

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to save user data');
      }
    } catch (e) {
      throw Exception('Error saving user data: $e');
    }
  }

  Future<Map<String, dynamic>> getUserData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<Map<String, dynamic>> getNutritionData(String foodName) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/nutrition?food=$foodName'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load nutrition data');
      }
    } catch (e) {
      throw Exception('Error fetching nutrition data: $e');
    }
  }

  Future<void> saveFoodEntry(Map<String, dynamic> foodData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/food'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(foodData),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to save food entry');
      }
    } catch (e) {
      throw Exception('Error saving food entry: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodEntries(String date) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/food?date=$date'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load food entries');
      }
    } catch (e) {
      throw Exception('Error fetching food entries: $e');
    }
  }

  Future<void> deleteFoodEntry(String entryId) async {
    final url = Uri.parse("$baseUrl/food/delete/$entryId");
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception("Failed to delete food entry");
    }
  }
}