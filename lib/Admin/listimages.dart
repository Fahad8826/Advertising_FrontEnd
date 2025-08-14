import 'dart:convert';
import 'package:advertising_app/Admin/imagedetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'image_model.dart';

class ImageListPage extends StatefulWidget {
  const ImageListPage({Key? key}) : super(key: key);

  @override
  State<ImageListPage> createState() => _ImageListPageState();
}

class _ImageListPageState extends State<ImageListPage> {
  List<ImageModel> images = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/images/");
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        setState(() {
          images = data.map((e) => ImageModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load images');
      }
    } catch (e) {
      print("Error fetching images: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Images')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                return ListTile(
                  leading: Image.network(
                    img.imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text('ID: ${img.id}'),
                  subtitle: Text(
                    'Category: ${img.category}, Subcategory: ${img.subcategory}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ImageDetailPage(image: img),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
