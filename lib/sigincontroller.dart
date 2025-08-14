import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<http.StreamedResponse> login(
    String identifier,
    String password,
  ) async {
    final baseUrl = dotenv.env['BASE_URL']; // Load here, not at top-level
    if (baseUrl == null || baseUrl.isEmpty) {
      throw Exception("BASE_URL is not set in .env");
    }

    var headers = {'Content-Type': 'application/json'};
    var request = http.Request('POST', Uri.parse('$baseUrl/login/'));
    request.body = json.encode({
      "identifier": identifier,
      "password": password,
    });
    request.headers.addAll(headers);

    return await request.send();
  }
}
