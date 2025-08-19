import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User {
  final int id;
  final String username;
  final String email;
  bool isActive;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }
}

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final String baseUrl = "http://192.168.20.5:8000/users/";
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          users = data.map((json) => User.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print("Error fetching users: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> toggleUserStatus(User user) async {
    final url = Uri.parse("$baseUrl${user.id}/");
    try {
      final response = await http.patch(
        url,
        headers: {"Content-Type": "application/json"},
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
                  leading: CircleAvatar(child: Text(user.username[0].toUpperCase())),
                  title: Text(user.username),
                  subtitle: Text(user.email),
                  trailing: Switch(
                    value: user.isActive,
                    onChanged: (value) {
                      toggleUserStatus(user);
                    },
                  ),
                );
              },
            ),
    );
  }
}
