import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class SignUpService {
  static Future<http.Response> registerUser({
    required String username,
    required String phone,
    required String email,
    required String password,
    required bool isStaff,
    File? profileImage,
    File? logo,
  }) async {
    String baseUrl = dotenv.env['BASE_URL'] ?? '';
    var uri = Uri.parse('$baseUrl/signup/');

    var request = http.MultipartRequest('POST', uri);

    request.fields['username'] = username;
    request.fields['phone'] = phone;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['is_staff'] = isStaff.toString();

    if (profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile_image',
        profileImage.path,
      ));
    }

    if (logo != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'logo',
        logo.path,
      ));
    }

    var streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
