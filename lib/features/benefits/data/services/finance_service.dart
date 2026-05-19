import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:universal_io/io.dart';

class FinanceService {
  static const String baseUrl =
      'http://localhost:8080/api/v1'; // Use Gateway port

  Future<Map<String, dynamic>> extractReceiptData(dynamic imageInput) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/ocr/extract'),
    );

    if (kIsWeb) {
      // imageInput should be Uint8List on Web
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageInput,
          filename: 'receipt.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      // imageInput should be File on Mobile
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageInput.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to extract data: ${response.body}');
    }
  }

  Future<void> createExpense(Map<String, dynamic> expenseData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(expenseData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create expense: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> getSolvabilityScore(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/solvability/$userId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get solvability score');
    }
  }

  Future<List<dynamic>> getUserExpenses(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/user/$userId'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      throw Exception('Failed to load expenses');
    }
  }
}
