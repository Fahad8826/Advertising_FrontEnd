
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageUploadPage extends StatefulWidget {
  const ImageUploadPage({super.key});

  @override
  State<ImageUploadPage> createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  bool _isUploading = false;
  bool _isLoadingDropdowns = true;

  List categories = [];
  List subcategories = [];
  int? selectedCategoryId;
  int? selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    fetchCategoriesAndSubcategories();
  }

  Future<void> fetchCategoriesAndSubcategories() async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      final categoryRes = await http.get(Uri.parse('$baseUrl/categories/'));
      final subcategoryRes = await http.get(
        Uri.parse('$baseUrl/subcategories/'),
      );

      if (categoryRes.statusCode == 200 && subcategoryRes.statusCode == 200) {
        setState(() {
          categories = json.decode(categoryRes.body);
          subcategories = json.decode(subcategoryRes.body);
          _isLoadingDropdowns = false;
        });
      } else {
        throw Exception("Failed to load categories or subcategories");
      }
    } catch (e) {
      setState(() {
        _isLoadingDropdowns = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error loading categories: $e")));
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null ||
        selectedCategoryId == null ||
        selectedSubcategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select image, category, and subcategory!'),
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access'); // token saved after login

    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('You must log in first!')));
      setState(() => _isUploading = false);
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['BASE_URL']}/images/'),
      );

      request.headers.addAll({'Authorization': 'Bearer $token'});

      request.fields['category'] = selectedCategoryId.toString();
      request.fields['subcategory'] = selectedSubcategoryId.toString();

      request.files.add(
        await http.MultipartFile.fromPath('image', _image!.path),
      );

      final response = await request.send();
      final resBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploaded successfully!')),
        );
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unauthorized. Please log in again.')),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $resBody')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }

    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDropdowns) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Upload Image")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: selectedCategoryId,
              decoration: const InputDecoration(labelText: "Select Category"),
              items: categories
                  .map<DropdownMenuItem<int>>(
                    (cat) => DropdownMenuItem<int>(
                      value: cat['id'],
                      child: Text(cat['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategoryId = value;
                  selectedSubcategoryId = null;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: selectedSubcategoryId,
              decoration: const InputDecoration(
                labelText: "Select Subcategory",
              ),
              items: subcategories
                  .where((sub) => sub['category'] == selectedCategoryId)
                  .map<DropdownMenuItem<int>>(
                    (sub) => DropdownMenuItem<int>(
                      value: sub['id'],
                      child: Text(sub['name']),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedSubcategoryId = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadImage,
              child: _isUploading
                  ? const CircularProgressIndicator()
                  : const Text("Upload Image"),
            ),
          ],
        ),
      ),
    );
  }
}
