import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

class TransactionService {
  // ✅ The "Magic IP" for Android Emulator to bridge to your PC's localhost
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<Map<String, dynamic>> fetchTransactions(String userId) async {
    // 🕵️ DEBUG: This will print in your VS Code / Android Studio console
    // It helps you verify the app is sending the Keycloak ID (3dabced7...) 
    // and NOT a placeholder string
    print('📡 Fetching transactions from: $_baseUrl/transactions/$userId');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/transactions/$userId'),
      ).timeout(const Duration(seconds: 10)); // Added timeout for better UX

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Ensure balance is treated as a string as per your Node.js response
        return {
          'balance': data['balance'].toString(),
          'transactions': (data['transactions'] as List)
              .map((t) => TransactionModel.fromJson(t))
              .toList(),
        };
      } else if (response.statusCode == 404) {
        // This handles the case where the Keycloak ID exists but isn't in your DB yet
        throw Exception('User account not found. Please try logging in again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('Cannot reach the server. Make sure your backend is running on port 3000.');
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}