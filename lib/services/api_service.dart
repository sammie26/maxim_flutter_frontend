import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:maxim___frontend/models/dashboard.dart';
import 'package:maxim___frontend/services/secure_token_service.dart'; // Import the new service

/// Service class for fetching dashboard data from the API.
class ApiService {
  // ⚠️ IMPORTANT: Set your backend API base URL here
  static const String _baseUrl = 'http://192.168.1.10:5000/api'; 
  
  final SecureTokenService _tokenService = SecureTokenService();
  
  // --- Public Methods ---

  /// Fetches the dashboard data from the protected API endpoint.
  Future<List<DashboardModel>> fetchDashboardData() async {
    final uri = Uri.parse('$_baseUrl/dashboard');
    
    // 1. Get the JWT token from secure storage
    final token = await _tokenService.getToken();

    if (token == null) {
      // Handle the case where the user is not logged in
      print('Authentication token is missing.');
      // You might want to throw an exception or navigate to the login screen
      throw Exception('User is not authenticated'); 
    }

    // 2. Prepare the headers, including the Authorization Bearer token
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        // Successful response
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DashboardModel.fromJson(json)).toList();

      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // 401 Unauthorized or 403 Forbidden: Token expired or invalid
        print('Token expired or invalid. Status: ${response.statusCode}');
        // Implement token refresh logic here or force user logout
        await _tokenService.deleteToken(); // Example: Logout
        throw Exception('Session expired. Please log in again.');

      } else {
        // Other HTTP error statuses (e.g., 500 Server Error)
        print('Failed to load dashboard data. Status: ${response.statusCode}');
        throw Exception('Failed to load data: Status ${response.statusCode}');
      }
    } catch (e) {
      // Network error (e.g., server unreachable)
      print('Network or parsing error: $e');
      throw Exception('Network error: $e');
    }
  }

  // Example: Login method to save the token after successful authentication
  Future<bool> login(String username, String password) async {
    final uri = Uri.parse('$_baseUrl/login');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final jsonBody = json.decode(response.body);
      // ⚠️ IMPORTANT: Update 'token' to match the key your API uses for the JWT
      final token = jsonBody['token'] as String?; 
      
      if (token != null) {
        await _tokenService.saveToken(token);
        return true;
      }
    }
    
    return false;
  }
}