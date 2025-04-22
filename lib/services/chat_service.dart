import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';

class ChatService {
  final String baseUrl = 'http://192.168.57.207:8000';

  Future<String> sendMessage(String message) async {
    try {
      print('Sending message to: $baseUrl/chat');
      print('Message content: $message');
      
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'query': message,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('response')) {
          return responseData['response'];
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Invalid request data';
        throw Exception('Validation error: $errorMessage');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Could not connect to the server. Please check your internet connection and server status.');
    } catch (e) {
      print('Error in sendMessage: $e');
      throw Exception('Error sending message: $e');
    }
  }

  Future<String> sendAudio(File audioFile) async {
    try {
      // Verify file exists and get info
      if (!await audioFile.exists()) {
        throw Exception('Audio file does not exist at path: ${audioFile.path}');
      }
      
      print('Sending audio to: $baseUrl/process-audio');
      print('Audio file path: ${audioFile.path}');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/process-audio'));
      
      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      // Add file
      final audioStream = http.ByteStream(audioFile.openRead());
      final audioLength = await audioFile.length();
      print('Audio file size: $audioLength bytes');
      
      final multipartFile = http.MultipartFile(
        'file', // Changed to match FastAPI parameter name
        audioStream,
        audioLength,
        filename: 'audio.wav', // Server expects WAV format
        contentType: MediaType('audio', 'wav'),
      );
      request.files.add(multipartFile);
      
      // Print request details
      print('Request files: ${request.files.map((f) => '${f.field}: ${f.filename}, ${f.contentType}')}');
      
      // Send request
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      print('Response status code: ${streamedResponse.statusCode}');
      
      // Get response
      final response = await http.Response.fromStream(streamedResponse);
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData.containsKey('response')) {
          return decodedData['response'];
        } else if (decodedData.containsKey('error')) {
          throw Exception(decodedData['error']);
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else if (response.statusCode == 422) {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Invalid request data';
        throw Exception('Validation error: $errorMessage');
      } else {
        print('Server error response: ${response.body}');
        throw Exception('Server error (${response.statusCode}): ${response.body}');
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet connection.');
    } on SocketException {
      throw Exception('Could not connect to the server. Please check your internet connection and server status.');
    } catch (e) {
      print('Error in sendAudio: $e');
      throw Exception('Error sending audio: $e');
    }
  }
} 