import 'dart:convert';

import 'package:advertising_app/Admin/Adminhome.dart';
import 'package:advertising_app/home.dart';
import 'package:advertising_app/sigin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  String? accessToken;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('access');
    String? userJson = prefs.getString('user_data');

    setState(() {
      accessToken = token;
      if (userJson != null) {
        userData = jsonDecode(userJson);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (accessToken != null && userData != null) {
      print("User Data from SharedPreferences: $userData");
      print("Access Token: $accessToken");

      bool isStaff = userData!['user']['is_staff'] ?? false;

      // Navigate based on is_staff
      if (isStaff) {
        return const HomePage(); // regular user
      } else {
        return const AdminHomePage(); // admin user
      }
    } else {
      return const LoginPage();
    }
  }
}
