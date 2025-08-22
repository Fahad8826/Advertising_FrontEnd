import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class User {
  final int id;
  final String username;
  final String email;
  bool isActive;
  final bool isStaff;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
    this.isStaff = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? false,
      isStaff: json['is_staff'] ?? false,
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final String baseUrl = dotenv.env['BASE_URL'] ?? '';
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access');
  }

  Future<void> fetchUsers() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse("${baseUrl}/users/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users: ${response.body}');
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleUserStatus(User user) async {
    final token = await _getToken();
    final url = Uri.parse("${baseUrl}/edit-user/${user.id}/");

    try {
      final response = await http.patch(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"is_active": !user.isActive}),
      );

      if (response.statusCode == 200) {
        setState(() {
          user.isActive = !user.isActive;
        });
      } else {
        print("Failed to update user: ${response.body}");
      }
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Users")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.username[0].toUpperCase()),
                  ),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (user.isStaff == true)
                        ? null // disables toggle for staff/current user
                        : (value) {
                            toggleUserStatus(user); // your update API call
                          },
                  ),
                );
              },
            ),
    );
  }
}
