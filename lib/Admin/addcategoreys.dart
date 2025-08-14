import 'dart:convert';
import 'package:advertising_app/Admin/listcategoery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List categories = [];
  List subcategories = [];
  bool isLoading = true;
  String errorMessage = '';

  final TextEditingController categoryController = TextEditingController();
  final TextEditingController subcategoryController = TextEditingController();
  int? selectedCategoryId;

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
      final categoryResponse = await http.get(
        Uri.parse("${baseUrl}/categories/"),
      );
      final subcategoryResponse = await http.get(
        Uri.parse("${baseUrl}/subcategories/"),
      );

      if (categoryResponse.statusCode == 200 &&
          subcategoryResponse.statusCode == 200) {
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

  Future<void> createCategory() async {
    final String name = categoryController.text.trim();
    if (name.isEmpty) return;

    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/categories/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name}),
      );

      if (response.statusCode == 201) {
        categoryController.clear();
        fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create category")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> createSubcategory() async {
    final String name = subcategoryController.text.trim();
    if (name.isEmpty || selectedCategoryId == null) return;

    final String baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse("${baseUrl}/subcategories/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "category": selectedCategoryId}),
      );

      if (response.statusCode == 201) {
        subcategoryController.clear();
        selectedCategoryId = null;
        fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subcategory created successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create subcategory")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
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
      appBar: AppBar(
        title: const Text("Add Category & Subcategory"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Listcategoery()),
              );
            },
            icon: const Icon(Icons.list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Category Creation
                const Text(
                  "Add Category",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          hintText: "Enter category name",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.green),
                      onPressed: createCategory,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                /// Subcategory Creation
                const Text(
                  "Add Subcategory",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<int>(
                  hint: const Text("Select Category"),
                  value: selectedCategoryId,
                  items: categories.map((cat) {
                    return DropdownMenuItem<int>(
                      value: cat['id'],
                      child: Text(cat['name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedCategoryId = val),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: subcategoryController,
                        decoration: const InputDecoration(
                          hintText: "Enter subcategory name",
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                      onPressed: createSubcategory,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
