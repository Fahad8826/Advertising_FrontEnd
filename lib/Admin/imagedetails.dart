import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'image_model.dart';

class ImageDetailPage extends StatefulWidget {
  final ImageModel image;
  const ImageDetailPage({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageDetailPage> createState() => _ImageDetailPageState();
}

class _ImageDetailPageState extends State<ImageDetailPage> {
  late TextEditingController categoryController;
  late TextEditingController subcategoryController;
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    categoryController = TextEditingController(text: widget.image.category.toString());
    subcategoryController = TextEditingController(text: widget.image.subcategory.toString());
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  Future<void> updateImage() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must log in first")),
      );
      return;
    }

    final url = Uri.parse("${dotenv.env['BASE_URL']}/images/${widget.image.id}/");
    var request = http.MultipartRequest('PATCH', url);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['category'] = categoryController.text;
    request.fields['subcategory'] = subcategoryController.text;

    if (selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath('image', selectedImage!.path));
    }

    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image updated")));
      Navigator.pop(context, true);
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unauthorized. Please log in again.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update")));
    }
  }

  Future<void> deleteImage() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must log in first")),
      );
      return;
    }

    final url = Uri.parse("${dotenv.env['BASE_URL']}/images/${widget.image.id}/");
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image deleted")));
      Navigator.pop(context, true);
    } else if (response.statusCode == 401) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Unauthorized. Please log in again.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete")));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Image ${widget.image.id}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            selectedImage != null
                ? Image.file(selectedImage!, height: 150)
                : Image.network(widget.image.imageUrl, height: 150),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: subcategoryController,
              decoration: const InputDecoration(labelText: 'Subcategory'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Change Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateImage,
              child: const Text('Update Image'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: deleteImage,
              child: const Text('Delete Image'),
            ),
          ],
        ),
      ),
    );
  }
}
