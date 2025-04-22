//course,data,constanst,video-suggestions,courses,diff_styles,styles all codes belong to the tarining page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_app/pages/training/courses.dart';
import 'package:my_app/pages/training/video_suggestions.dart';
import 'package:my_app/pages/styles/diff_styles.dart';
import 'package:my_app/pages/models/course.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key});

  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text(
          "Training",
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add search functionality here if needed
            },
            icon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          Icon(
            Platform.isAndroid ? Icons.more_vert : Icons.more_horiz,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        children: const <Widget>[
          VideoSuggestions(),
          DiffStyles(),
          Courses(),
          SizedBox(height: 80),
        ],
      ),
    );
  }
}