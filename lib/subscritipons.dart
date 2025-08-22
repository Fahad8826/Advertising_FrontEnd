// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class SubscriptionManagementPage extends StatefulWidget {
//   const SubscriptionManagementPage({Key? key}) : super(key: key);

//   @override
//   State<SubscriptionManagementPage> createState() =>
//       _SubscriptionManagementPageState();
// }

// class _SubscriptionManagementPageState
//     extends State<SubscriptionManagementPage> {
//   String? accessToken;
//   List users = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchUsers();
//   }

//   Future<void> _loadTokenAndFetchUsers() async {
//     final prefs = await SharedPreferences.getInstance();
//     accessToken = prefs.getString('access');
//     await fetchUsers();
//   }

//   Future<void> fetchUsers() async {
//     setState(() => isLoading = true);

//     final url = Uri.parse("${dotenv.env['BASE_URL']}/users/");
//     try {
//       final response = await http.get(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $accessToken",
//         },
//       );

//       if (response.statusCode == 200) {
//         final usersData = jsonDecode(response.body);
//         setState(() {
//           users = usersData;
//           isLoading = false;
//         });
//       } else {
//         setState(() => isLoading = false);
//         print("Error fetching users: ${response.body}");
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       print("Exception: $e");
//     }
//   }

//   Future<void> assignSubscription(int userId, String plan) async {
//     final url = Uri.parse("${dotenv.env['BASE_URL']}/subscriptions/");
//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $accessToken",
//         },
//         body: jsonEncode({"user_id": userId, "plan": plan}),
//       );

//       if (response.statusCode == 201) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Subscription assigned successfully")),
//         );
//         fetchUsers();
//       } else {
//         print("Error assigning subscription: ${response.body}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }

//   Future<void> revokeSubscription(int subscriptionId) async {
//     final url = Uri.parse(
//       "${dotenv.env['BASE_URL']}/subscriptions/$subscriptionId/",
//     );
//     try {
//       final response = await http.delete(
//         url,
//         headers: {"Authorization": "Bearer $accessToken"},
//       );

//       if (response.statusCode == 204) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Subscription revoked successfully")),
//         );
//         fetchUsers();
//       } else {
//         print("Error revoking subscription: ${response.body}");
//       }
//     } catch (e) {
//       print("Exception: $e");
//     }
//   }

//   void _showAssignDialog(int userId) {
//     String? selectedPlan;

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Assign Subscription"),
//         content: DropdownButtonFormField<String>(
//           value: selectedPlan,
//           hint: const Text("Select a plan"),
//           items: const [
//             DropdownMenuItem(value: "monthly", child: Text("Monthly")),
//             DropdownMenuItem(value: "yearly", child: Text("Yearly")),
//           ],
//           onChanged: (val) {
//             selectedPlan = val;
//           },
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Cancel"),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (selectedPlan != null) {
//                 assignSubscription(userId, selectedPlan!);
//                 Navigator.pop(context);
//               }
//             },
//             child: const Text("Assign"),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Subscription Management")),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: users.length,
//               itemBuilder: (context, index) {
//                 final user = users[index];
//                 final subscription =
//                     user['subscriptions']; // assume backend includes it

//                 return Card(
//                   margin: const EdgeInsets.all(8),
//                   child: ListTile(
//                     title: Text(user['username']),
//                     subtitle: Text(
//                       subscription != null
//                           ? "Plan: ${subscription['plan']} | Exp: ${subscription['end_date']}"
//                           : "No Subscription",
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         if (subscription == null )
//                           IconButton(
//                             icon: const Icon(Icons.add),
//                             onPressed: () => _showAssignDialog(user['id']),
//                           ),
//                         if (subscription != null)
//                           IconButton(
//                             icon: const Icon(Icons.cancel, color: Colors.red),
//                             onPressed: () =>
//                                 revokeSubscription(subscription['id']),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionManagementPage extends StatefulWidget {
  const SubscriptionManagementPage({Key? key}) : super(key: key);

  @override
  State<SubscriptionManagementPage> createState() =>
      _SubscriptionManagementPageState();
}

class _SubscriptionManagementPageState
    extends State<SubscriptionManagementPage> {
  String? accessToken;
  List users = [];
  bool isLoading = true;

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
    setState(() => isLoading = true);

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
        final usersData = jsonDecode(response.body);

        // 🔥 filter out staff users here
        final nonStaffUsers = usersData
            .where((u) => u['is_staff'] == false)
            .toList();

        setState(() {
          users = nonStaffUsers;
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

  Future<void> assignSubscription(int userId, String plan) async {
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
          const SnackBar(content: Text("Subscription assigned successfully")),
        );
        fetchUsers();
      } else {
        print("Error assigning subscription: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  Future<void> revokeSubscription(int subscriptionId) async {
    final url = Uri.parse(
      "${dotenv.env['BASE_URL']}/subscriptions/$subscriptionId/",
    );
    try {
      final response = await http.delete(
        url,
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription revoked successfully")),
        );
        fetchUsers();
      } else {
        print("Error revoking subscription: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  void _showAssignDialog(int userId) {
    String? selectedPlan;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Assign Subscription"),
        content: DropdownButtonFormField<String>(
          value: selectedPlan,
          hint: const Text("Select a plan"),
          items: const [
            DropdownMenuItem(value: "monthly", child: Text("Monthly")),
            DropdownMenuItem(value: "yearly", child: Text("Yearly")),
          ],
          onChanged: (val) {
            selectedPlan = val;
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedPlan != null) {
                assignSubscription(userId, selectedPlan!);
                Navigator.pop(context);
              }
            },
            child: const Text("Assign"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Subscription Management")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final subscription = user['subscriptions'];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(user['username']),
                    subtitle: Text(
                      subscription != null
                          ? "Plan: ${subscription['plan']} | Exp: ${subscription['end_date']}"
                          : "No Subscription",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (subscription == null)
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showAssignDialog(user['id']),
                          ),
                        if (subscription != null)
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            onPressed: () =>
                                revokeSubscription(subscription['id']),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
