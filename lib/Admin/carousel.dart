// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CarouselUpdatePage extends StatefulWidget {
//   const CarouselUpdatePage({super.key});
//
//   @override
//   State<CarouselUpdatePage> createState() => _CarouselUpdatePageState();
// }
//
// class _CarouselUpdatePageState extends State<CarouselUpdatePage> {
//   File? image1;
//   File? image2;
//   File? image3;
//   File? image4;
//
//   final picker = ImagePicker();
//   final String baseUrl = dotenv.env['BASE_URL'] ?? '';
//
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('access');
//   }
//
// // replace with your JWT token or pass dynamically
//
//   Future<void> pickImage(int index) async {
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//
//     if (pickedFile != null) {
//       setState(() {
//         if (index == 1) image1 = File(pickedFile.path);
//         if (index == 2) image2 = File(pickedFile.path);
//         if (index == 3) image3 = File(pickedFile.path);
//         if (index == 4) image4 = File(pickedFile.path);
//       });
//     }
//   }
//
//   Future<void> updateCarousel() async {
//     final token = await _getToken();
//     var headers = {
//       'Authorization': 'Bearer $token',
//     };
//     var request = http.MultipartRequest('PATCH', Uri.parse("${baseUrl}/carousels/1/"));
//
//     if (image1 != null) {
//       request.files.add(await http.MultipartFile.fromPath('image1', image1!.path));
//     }
//     if (image2 != null) {
//       request.files.add(await http.MultipartFile.fromPath('image2', image2!.path));
//     }
//     if (image3 != null) {
//       request.files.add(await http.MultipartFile.fromPath('image3', image3!.path));
//     }
//     if (image4 != null) {
//       request.files.add(await http.MultipartFile.fromPath('image4', image4!.path));
//     }
//
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       String resp = await response.stream.bytesToString();
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updated: $resp")));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.reasonPhrase}")));
//     }
//   }
//
//   Future<void> deleteImage(int index) async {
//     final token = await _getToken();
//     var headers = {
//       'Authorization': 'Bearer $token',
//     };
//     var request = http.MultipartRequest('PATCH', Uri.parse("${baseUrl}/carousels/1/"));
//
//     // Sending empty/null for that index
//     request.fields['image$index'] = '';
//
//     request.headers.addAll(headers);
//     http.StreamedResponse response = await request.send();
//
//     if (response.statusCode == 200) {
//       setState(() {
//         if (index == 1) image1 = null;
//         if (index == 2) image2 = null;
//         if (index == 3) image3 = null;
//         if (index == 4) image4 = null;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Deleted image $index")));
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${response.reasonPhrase}")));
//     }
//   }
//
//   Widget buildImagePicker(int index, File? image) {
//     return Column(
//       children: [
//         image != null
//             ? Image.file(image, width: 100, height: 100, fit: BoxFit.cover)
//             : Container(
//           width: 100,
//           height: 100,
//           color: Colors.grey[300],
//           child: const Icon(Icons.image, size: 40),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () => pickImage(index),
//               child: const Text("Pick"),
//             ),
//             const SizedBox(width: 8),
//             ElevatedButton(
//               onPressed: () => deleteImage(index),
//               child: const Text("Delete"),
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Update Carousel")),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             buildImagePicker(1, image1),
//             buildImagePicker(2, image2),
//             buildImagePicker(3, image3),
//             buildImagePicker(4, image4),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: updateCarousel,
//               child: const Text("Update Carousel"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CarouselUpdatePage extends StatefulWidget {
  const CarouselUpdatePage({super.key});

  @override
  State<CarouselUpdatePage> createState() => _CarouselUpdatePageState();
}

class _CarouselUpdatePageState extends State<CarouselUpdatePage> {
  File? image1;
  File? image2;
  File? image3;
  File? image4;

  String? image1Url;
  String? image2Url;
  String? image3Url;
  String? image4Url;

  final picker = ImagePicker();
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  @override
  void initState() {
    super.initState();
    fetchCarousel();
  }

  /// 🔹 Fetch existing carousel images
  Future<void> fetchCarousel() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$baseUrl/carousels/1/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        image1Url = data['image1'];
        image2Url = data['image2'];
        image3Url = data['image3'];
        image4Url = data['image4'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load carousel: ${response.reasonPhrase}")),
      );
    }
  }

  Future<void> pickImage(int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (index == 1) image1 = File(pickedFile.path);
        if (index == 2) image2 = File(pickedFile.path);
        if (index == 3) image3 = File(pickedFile.path);
        if (index == 4) image4 = File(pickedFile.path);
      });
    }
  }

  Future<void> updateCarousel() async {
    final token = await _getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest('PATCH', Uri.parse("$baseUrl/carousels/1/"));

    if (image1 != null) {
      request.files.add(await http.MultipartFile.fromPath('image1', image1!.path));
    }
    if (image2 != null) {
      request.files.add(await http.MultipartFile.fromPath('image2', image2!.path));
    }
    if (image3 != null) {
      request.files.add(await http.MultipartFile.fromPath('image3', image3!.path));
    }
    if (image4 != null) {
      request.files.add(await http.MultipartFile.fromPath('image4', image4!.path));
    }

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      await fetchCarousel(); // refresh with updated images
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Carousel updated successfully")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")));
    }
  }

  Future<void> deleteImage(int index) async {
    final token = await _getToken();
    var headers = {
      'Authorization': 'Bearer $token',
    };
    var request = http.MultipartRequest('PATCH', Uri.parse("$baseUrl/carousels/1/"));
    request.fields['image$index'] = ''; // send empty field

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      setState(() {
        if (index == 1) {
          image1 = null;
          image1Url = null;
        }
        if (index == 2) {
          image2 = null;
          image2Url = null;
        }
        if (index == 3) {
          image3 = null;
          image3Url = null;
        }
        if (index == 4) {
          image4 = null;
          image4Url = null;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Deleted image $index")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${response.reasonPhrase}")));
    }
  }

  Widget buildImagePicker(int index, File? image, String? imageUrl) {
    return Column(
      children: [
        if (image != null)
          Image.file(image, width: 100, height: 100, fit: BoxFit.cover)
        else if (imageUrl != null)
          Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover)
        else
          Container(
            width: 100,
            height: 100,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 40),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => pickImage(index),
              child: const Text("Pick"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => deleteImage(index),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Carousel")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildImagePicker(1, image1, image1Url),
            buildImagePicker(2, image2, image2Url),
            buildImagePicker(3, image3, image3Url),
            buildImagePicker(4, image4, image4Url),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateCarousel,
              child: const Text("Update Carousel"),
            ),
          ],
        ),
      ),
    );
  }
}
