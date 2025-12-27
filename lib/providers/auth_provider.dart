import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _keycloakId;
  Map<String, dynamic>? _userData;

  // ✅ Getter for the ID (used for API calls)
  String get userId => _keycloakId ?? "";
  
  // ✅ Getter for user data
  // Returns an empty map if null to prevent crashes in the UI
  Map<String, dynamic> get userData => _userData ?? {};

  // Check if someone is actually logged in
  bool get isAuthenticated => _keycloakId != null;

  // 🚀 The Login Method
  void setSession(String uuid, Map<String, dynamic> data) {
    _keycloakId = uuid;
    _userData = data;
    
    // ✅ DEBUG: Helps you verify if 'given_name' and 'family_name' exist
    print("👤 AuthProvider: Session set for $uuid");
    print("🔑 Data received: ${data.keys.toList()}");
    
    notifyListeners(); 
  }

  // 🚪 The Logout Method
  void logout() {
    _keycloakId = null;
    _userData = null;
    notifyListeners();
  }
}