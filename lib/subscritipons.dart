import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserSubscriptionPage extends StatefulWidget {
  const UserSubscriptionPage({super.key});

  @override
  State<UserSubscriptionPage> createState() => _UserSubscriptionPageState();
}

class _UserSubscriptionPageState extends State<UserSubscriptionPage> {
  List users = [];
  bool isLoading = true;
  String? accessToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchUsers();
  }

  Future<void> _loadTokenAndFetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access');
    await fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/users/");
    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          users = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        print("Error fetching users: ${response.body}");
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Exception: $e");
    }
  }

  void _showPlanDialog(int userId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Plan"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _planButton(userId, "monthly"),
              const SizedBox(height: 10),
              _planButton(userId, "yearly"),
            ],
          ),
        );
      },
    );
  }

  Widget _planButton(int userId, String plan) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        _createSubscription(userId, plan);
      },
      child: Text(plan.toUpperCase()),
    );
  }

  Future<void> _createSubscription(int userId, String plan) async {
    final url = Uri.parse("${dotenv.env['BASE_URL']}/subscriptions/");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({"user_id": userId, "plan": plan}),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subscription created for User $userId ($plan)")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Subscriptions")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['username'] ?? "Unknown"),
                  subtitle: Text(user['email'] ?? "No email"),
                  onTap: () => _showPlanDialog(user['id']),
                );
              },
            ),
    );
  }
}
