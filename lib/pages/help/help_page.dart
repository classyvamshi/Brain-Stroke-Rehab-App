import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Professional Help'),
        backgroundColor: Colors.cyan,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Neurologists',
              [
                _buildContactCard(
                  'Dr. K V Prasad',
                  'Neurology Specialist',
                  '+91 9876543210',
                  'prasad@gmail.com',
                ),
                _buildContactCard(
                  'Dr. G V Reddy',
                  'Stroke Specialist',
                  '+91 9876512345',
                  'reddy@gmail.com',
                ),
                _buildContactCard(
                  'Dr. Srinivas',
                  'Neurological Disorders',
                  '+91 8877554321',
                  'srinivas@gmail.com',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Nutritionists',
              [
                _buildContactCard(
                  'Dr. Kavya',
                  'Clinical Nutritionist',
                  '+91 8765432109',
                  'kavya@gmail.com',
                ),
                _buildContactCard(
                  'Dr. Lakshmi',
                  'Dietary Specialist',
                  '+91 7712321234',
                  'lakshmi@gmail.com',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Therapists',
              [
                _buildContactCard(
                  'Dr. Vamsi',
                  'Physical Therapist',
                  '+91 7731803775',
                  'vamsi@gmail.com',
                ),
                _buildContactCard(
                  'Dr. Vardhan',
                  'Occupational Therapist',
                  '+91 8411841184',
                  'vardhan@gmail.com',
                ),
                _buildContactCard(
                  'Dr. Satya',
                  'Speech Therapist',
                  '+91 9988776655',
                  'satya@gmail.com',
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildEmergencySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> contacts) {
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
        ...contacts,
      ],
    );
  }

  Widget _buildContactCard(String name, String specialization, String phone, String email) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              specialization,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 5),
                Text(phone),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.email, size: 16),
                const SizedBox(width: 5),
                Text(email),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencySection() {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 10),
            _buildEmergencyContact('Emergency Services', '108'),
            _buildEmergencyContact('Stroke Helpline', '1099'),
            _buildEmergencyContact('National Health Service', '104'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(String name, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.emergency, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(number),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 