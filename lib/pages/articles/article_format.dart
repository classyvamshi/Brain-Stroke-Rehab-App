import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Article extends StatelessWidget {
  final String? author;
  final String description;
  final String url;
  final String? imageUrl;
  final String title;

  const Article(this.author, this.description, this.url, this.imageUrl, this.title, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;

    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              const Icon(
                Icons.article,
                size: 50,
                color: Colors.black,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF02315E),
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height / 60),
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              errorBuilder: (context, error, stackTrace) {
                return const Text('Image failed to load');
              },
            ),
          SizedBox(height: height / 60),
          if (author != null && author!.isNotEmpty)
            Text(
              '- by $author',
              style: const TextStyle(fontSize: 14),
            ),
          SizedBox(height: height / 30),
          Container(
            padding: const EdgeInsets.all(25.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              description,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
          ),
          TextButton(
            onPressed: () => _launchURL(context, url),
            child: const Text(
              'Click here to read more',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(
            height: height / 60,
            child: const Divider(
              color: Colors.black,
              thickness: 3.0,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    if (urlString.isEmpty) {
      _showErrorSnackBar(context, 'No URL provided');
      return;
    }

    final Uri uri = Uri.parse(urlString);
    print('Attempting to launch URL: $urlString'); // Debug log

    try {
      // Primary attempt: Use external application mode
      if (await canLaunchUrl(uri)) {
        print('canLaunchUrl returned true for $urlString');
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        print('URL launched successfully: $urlString');
      } else {
        print('canLaunchUrl returned false for $urlString');
        // Fallback: Try platform default mode
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
        );
        print('Fallback URL launched successfully: $urlString');
      }
    } catch (e) {
      print('Error launching $urlString: $e'); // Debug log
      _showErrorSnackBar(context, 'Error launching URL: $e');
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}