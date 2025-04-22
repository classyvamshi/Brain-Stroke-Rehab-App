import 'package:flutter/material.dart';

class InstructionsPage extends StatelessWidget {
  const InstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Instructions'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Food Tracking',
              [
                '1. Set your daily calorie and nutrient targets in the "Set Goals" section',
                '2. Add food items to your diary by selecting the meal type (Breakfast, Lunch, etc.)',
                '3. Enter food details manually or use the nutrition data lookup feature',
                '4. Track your progress throughout the day',
                '5. View your daily and weekly nutrition reports',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Stroke Prediction',
              [
                '1. Select a clear brain CT scan image',
                '2. Ensure the image is well-lit and focused',
                '3. Wait for the model to process the image',
                '4. Review the prediction results and probabilities',
                '5. Consult with a healthcare professional for proper diagnosis',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Chatbot Assistance',
              [
                '1. Type your questions about nutrition or health',
                '2. Use voice input for hands-free interaction',
                '3. Get instant responses about diet and health',
                '4. Save important conversations for future reference',
                '5. Use the chatbot for quick health-related queries',
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'General Tips',
              [
                '• Keep your app updated for the latest features',
                '• Regularly update your health goals',
                '• Maintain accurate food logging for best results',
                '• Consult healthcare professionals for medical advice',
                '• Use the app as a supplementary tool, not a replacement for professional care',
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.cyan,
          ),
        ),
        const SizedBox(height: 10),
        ...points.map((point) => Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(
                child: Text(
                  point,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }
} 