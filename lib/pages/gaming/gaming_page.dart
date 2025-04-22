import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Import the package
import 'package:my_app/pages/gaming/snake_n_ladder.dart'; // Import the Snake and Ladder page
import 'package:my_app/pages/gaming/memory_game.dart'; // Import the Memory page
import 'package:my_app/pages/gaming/chess.dart'; // Import the Chess page

class GamingPage extends StatelessWidget {
  const GamingPage({super.key});

  // Navigate to a specific game
  void _navigateToGame(BuildContext context, String gameName) {
    switch (gameName) {
      case 'Memory Game':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MemoryPage()),
        );
        break;
      case 'Snake and Ladder':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SnakeAndLadderPage()),
        );
        break;
      case 'Chess':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChessPage()), // Navigate to ChessPage
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Games', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 255, 140, 82).withOpacity(
          0.8,
        ), // Match the app's theme
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two columns for a balanced layout
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          children: [
            _buildGameCard(
              context: context,
              title: 'Memory Game',
              icon: Icons.memory, // Already correct, no change needed
              color: Colors.blue,
            ),
            _buildGameCard(
              context: context,
              title: 'Snake and Ladder',
              icon: Icons.casino, // Represents games/dice for Snake and Ladder
              color: Colors.green,
            ),
            _buildGameCard(
              context: context,
              title: 'Chess',
              icon: FontAwesomeIcons.chess, // Use FontAwesomeIcons for chess
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build game cards
  Widget _buildGameCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToGame(context, title),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}