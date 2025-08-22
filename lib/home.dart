// import 'dart:convert';
// import 'package:advertising_app/sigin.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   Map<String, dynamic>? user;
//   final baseUrl = dotenv.env['BASE_URL'];
//   String? accessToken;

//   @override
//   void initState() {
//     super.initState();
//     _loadUser();
//   }

//   Future<void> _loadUser() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userData = prefs.getString('user_data');
//     String? token = prefs.getString('access');

//     if (userData != null) {
//       final decoded = json.decode(userData);
//       setState(() {
//         user = decoded['user'];
//         accessToken = token;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (user == null) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome, ${user!['username']}"),
//         actions: [
//           ElevatedButton(
//             onPressed: () async {
//               SharedPreferences prefs = await SharedPreferences.getInstance();

//               // Clear saved user and token
//               await prefs.remove('access');
//               await prefs.remove('user_data');

//               // Optionally clear all
//               // await prefs.clear();

//               // Navigate back to login and remove all previous routes
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginPage()),
//                 (route) => false,
//               );
//             },
//             child: const Text("Logout"),
//           ),
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (user!['profile_image'] != null &&
//                 user!['profile_image'].toString().isNotEmpty)
//               CircleAvatar(
//                 radius: 50,
//                 backgroundImage: NetworkImage(
//                   "$baseUrl${user!['profile_image']}",
//                 ),
//               ),
//             const SizedBox(height: 20),
//             Text("Name: ${user!['username']}"),
//             Text("Email: ${user!['email']}"),
//             const SizedBox(height: 20),
//             Text("Access Token: $accessToken"),
//           ],
//         ),
//       ),
//     );
//   }
// }
