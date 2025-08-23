import 'package:advertising_app/Admin/addcategoreys.dart';
import 'package:advertising_app/Admin/listimages.dart';
import 'package:advertising_app/Admin/listusers.dart';
import 'package:advertising_app/Admin/uploadimage.dart';
import 'package:advertising_app/Admin/vedios.dart';
import 'package:advertising_app/sigin.dart';
import 'package:advertising_app/subscritipons.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'carousel.dart';

// Placeholder pages for each admin feature

// class ReportsPage extends StatelessWidget {
//   const ReportsPage({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Reports")),
//       body: const Center(child: Text("Reports Page")),
//     );
//   }
// }

// Main Admin Home Page
class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  // Logout function
  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access');
    await prefs.remove('user_data');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // Navigation function
  void _navigateToPage(String pageName) {
    Widget page;
    switch (pageName) {
      case 'Add Category':
        page = const CategoryPage();
        break;
      case 'Add Images':
        page = const ImageUploadPage();
        break;
      case 'List & Delete Images':
        page = const ImageListPage();
        break;
      case 'List All Users':
        page = const UsersPage();
        break;
      case 'Subscription':
        page = const SubscriptionManagementPage();
        break;
      case 'Upload Video':
        page = const UploadVideoPage();
        break;
      case 'Carousel':
        page = const CarouselUpdatePage();
        break;
      default:
        page = const Scaffold(body: Center(child: Text("Page not found")));
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  @override
  Widget build(BuildContext context) {
    // List of button names
    final List<Map<String, dynamic>> adminButtons = [
      {'title': 'Add Category', 'icon': Icons.category},
      {'title': 'Add Images', 'icon': Icons.add_photo_alternate},
      {'title': 'List & Delete Images', 'icon': Icons.photo_library},
      {'title': 'List All Users', 'icon': Icons.people},
      {'title': 'Subscription', 'icon': Icons.subscriptions},
      {'title': 'Upload Video', 'icon': Icons.video_call},
      {'title': 'Carousel', 'icon': Icons.analytics},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: adminButtons.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 buttons per row
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            final button = adminButtons[index];
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _navigateToPage(button['title']),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(button['icon'], size: 40, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    button['title'],
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
