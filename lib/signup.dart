import 'dart:io';
import 'package:advertising_app/Admin/Adminhome.dart';
import 'package:advertising_app/home.dart';
import 'package:advertising_app/signupcontroller.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  String username = '';
  String phone = '';
  String email = '';
  String password = '';
  bool isStaff = false;
  File? profileImage;
  File? logo;

  Future<void> pickImage(bool isProfile) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          profileImage = File(pickedFile.path);
        } else {
          logo = File(pickedFile.path);
        }
      });
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      var response = await SignUpService.registerUser(
        username: username,
        phone: phone,
        email: email,
        password: password,
        isStaff: isStaff,
        profileImage: profileImage,
        logo: logo,
      );

      if (response.statusCode == 201) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminHomePage()),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Sign Up Successful')));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (val) => username = val,
                  validator: (val) => val!.isEmpty ? 'Enter username' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => phone = val,
                  validator: (val) => val!.isEmpty ? 'Enter phone' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => email = val,
                  validator: (val) => val!.isEmpty ? 'Enter email' : null,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (val) => password = val,
                  validator: (val) => val!.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('Staff Member'),
                    Checkbox(
                      value: isStaff,
                      onChanged: (val) {
                        setState(() {
                          isStaff = val!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => pickImage(true),
                  child: Text(
                    profileImage == null
                        ? 'Pick Profile Image'
                        : 'Change Profile Image',
                  ),
                ),
                if (profileImage != null)
                  Image.file(profileImage!, height: 100),
                ElevatedButton(
                  onPressed: () => pickImage(false),
                  child: Text(logo == null ? 'Pick Logo' : 'Change Logo'),
                ),
                if (logo != null) Image.file(logo!, height: 100),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: submitForm,
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
