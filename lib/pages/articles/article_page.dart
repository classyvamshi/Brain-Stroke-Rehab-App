import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:my_app/pages/articles/article_format.dart';

class Articles extends StatefulWidget {
  const Articles({Key? key}) : super(key: key);

  @override
  State<Articles> createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  final http.Client client = http.Client();
  List<Widget> articles = [];
  bool isLoading = true;

  final String date = DateFormat('yyyy-MM-dd').format(DateTime(
    DateTime.now().year,
    DateTime.now().month - 1,
    DateTime.now().day + 1,
  ));

  Future<Map<String, dynamic>> _retrieveArticles() async {
    final url = Uri.parse(
      'https://newsapi.org/v2/everything?q=depression%20or%20anxiety%20or%20mental%20health&from=$date&sortBy=publishedAt&apiKey=47764c0938d24be380f64d387a006bc3',
    );
    try {
      final response = await client.get(url);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching articles: $e');
    }
  }

  Future<void> _loadArticles() async {
    setState(() => isLoading = true);
    try {
      final data = await _retrieveArticles();
      final articlesList = data['articles'] as List<dynamic>? ?? [];
      setState(() {
        articles = articlesList.take(50).map((article) {
          return Article(
            article['author'] as String?,
            article['description'] as String? ?? 'No description available',
            article['url'] as String? ?? '',
            article['urlToImage'] as String?,
            article['title'] as String? ?? 'Untitled',
          );
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading articles: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Mental Health Articles',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 255, 82, 206),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 255, 82, 206),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading articles...',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : articles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.article_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No articles found',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadArticles,
                    color: const Color.fromARGB(255, 255, 82, 206),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      itemCount: articles.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) => articles[index],
                    ),
                  ),
      ),
    );
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }
}