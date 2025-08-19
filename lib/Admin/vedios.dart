import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UploadVideoPage extends StatefulWidget {
  const UploadVideoPage({super.key});

  @override
  State<UploadVideoPage> createState() => _UploadVideoPageState();
}

class _UploadVideoPageState extends State<UploadVideoPage> {
  final TextEditingController _videoUrlController = TextEditingController();
  final TextEditingController _videoNameController = TextEditingController();
  String? _selectedCategory;

  final List<String> categories = [
    "Education",
    "Entertainment",
    "Music",
    "Sports",
    "Technology",
    "Lifestyle",
  ];

  bool _isLoading = false;

  Future<void> uploadVideo() async {
    if (_videoUrlController.text.isEmpty ||
        _videoNameController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('access');

    final String baseUrl = dotenv.env['BASE_URL'] ?? "";
    final url = Uri.parse("$baseUrl/videos/");

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    var body = json.encode({
      "video_url": _videoUrlController.text.trim(),
      "video_name": _videoNameController.text.trim(),
      "category": _selectedCategory,
    });

    try {
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video uploaded successfully ✅")),
        );
        _videoUrlController.clear();
        _videoNameController.clear();
        setState(() {
          _selectedCategory = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Video")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _videoUrlController,
              decoration: const InputDecoration(
                labelText: "Video URL",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _videoNameController,
              decoration: const InputDecoration(
                labelText: "Video Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: uploadVideo,
                    child: const Text("Upload Video"),
                  ),
          ],
        ),
      ),
    );
  }
}
