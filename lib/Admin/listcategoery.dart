import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class Listcategoery extends StatefulWidget {
  const Listcategoery({super.key});

  @override
  State<Listcategoery> createState() => _ListcategoeryState();
}

class _ListcategoeryState extends State<Listcategoery> {
  List categories = [];
  List subcategories = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      setState(() {
        isLoading = false;
        errorMessage = "BASE_URL is not set in .env";
      });
      return;
    }

    try {
      final categoryResponse = await http.get(Uri.parse("$baseUrl/categories/"));
      final subcategoryResponse = await http.get(Uri.parse("$baseUrl/subcategories/"));

      if (categoryResponse.statusCode == 200 && subcategoryResponse.statusCode == 200) {
        setState(() {
          categories = json.decode(categoryResponse.body) as List;
          subcategories = json.decode(subcategoryResponse.body) as List;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Failed to fetch categories or subcategories";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Error fetching data: $e";
      });
    }
  }

  Future<void> updateCategory(int id, String newName) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/categories/$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": newName}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update category")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteCategory(int id) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      final response = await http.delete(Uri.parse("$baseUrl/categories/$id/"));

      if (response.statusCode == 204) {
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete category")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> updateSubcategory(int id, String newName, int categoryId) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/subcategories/$id/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": newName, "category": categoryId}),
      );

      if (response.statusCode == 200) {
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to update subcategory")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteSubcategory(int id) async {
    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    try {
      final response = await http.delete(Uri.parse("$baseUrl/subcategories/$id/"));

      if (response.statusCode == 204) {
        fetchData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to delete subcategory")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void showEditCategoryDialog(int id, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Category"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Category Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateCategory(id, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void showEditSubcategoryDialog(int id, String currentName, int categoryId) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Subcategory"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Subcategory Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              updateSubcategory(id, controller.text, categoryId);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Categories & Subcategories")),
        body: Center(child: Text(errorMessage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Categories & Subcategories")),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Categories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ...categories.map((category) => ListTile(
                  title: Text(category['name'] ?? 'Unnamed'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => showEditCategoryDialog(category['id'], category['name'])),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteCategory(category['id'])),
                    ],
                  ),
                )),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Subcategories", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            ...subcategories.map((subcat) {
              final parent = categories.firstWhere(
                (cat) => cat['id'] == subcat['category'],
                orElse: () => {'name': 'Unknown'},
              );
              return ListTile(
                title: Text(subcat['name'] ?? 'Unnamed'),
                subtitle: Text("Category: ${parent['name']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => showEditSubcategoryDialog(subcat['id'], subcat['name'], subcat['category'])),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => deleteSubcategory(subcat['id'])),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
