// lib/login_page.dart
import 'dart:convert';

import 'package:advertising_app/Admin/Adminhome.dart';
import 'package:advertising_app/home.dart';
import 'package:advertising_app/sigincontroller.dart';
import 'package:advertising_app/signup.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);

    try {
      var response = await ApiService.login(
        _identifierController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response.statusCode == 200) {
        String body = await response.stream.bytesToString();
        print("Login Success: $body");

        final data = jsonDecode(body);
        String accessToken = data['access'] ?? ''; // Adjust key if needed

        // ✅ Save access token and full user data in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access', accessToken);
        await prefs.setString('user_data', body);

        final user = data['user'];
        bool isStaff = user['is_staff'] ?? false;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Login successful")));
        if (isStaff) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        }
      } else {
        print("Error: ${response.reasonPhrase}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      print("Exception: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login", style: TextStyle(color: Colors.black12)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _identifierController,
              decoration: const InputDecoration(labelText: "Email or Phone"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Login"),
            ),
            SizedBox(height: 10),
            signupbutton(),
          ],
        ),
      ),
    );
  }
}

Widget signupbutton() {
  return Builder(
    builder: (BuildContext context) {
      return TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignUpPage()),
          );
        },
        child: Text('signup'),
      );
    },
  );
}
