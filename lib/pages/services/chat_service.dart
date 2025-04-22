import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ChatService {
  final String baseUrl = "http://192.168.57.207:8000";

  Future<String> sendMessage(String message) async {
    final response = await http.post(
      Uri.parse("$baseUrl/chat"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({'query': message}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      throw Exception('Failed to load response');
    }
  }

  Future<String> sendAudio(File audioFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/process-audio"),
    );
    request.files.add(
      await http.MultipartFile.fromPath('file', audioFile.path),
    );

    var response = await request.send();
    var responseData = await response.stream.bytesToString();
    var jsonResponse = jsonDecode(responseData);

    if (response.statusCode == 200) {
      return jsonResponse['response'] ?? "Error processing audio.";
    } else {
      throw Exception('Failed to process audio');
    }
  }
}
