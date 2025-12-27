import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart'; 
import 'package:flutter/services.dart'; 
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  final String _issuer = 'http://10.0.2.2:8080/realms/MaximRealm';
  final String _clientId = 'maxim-mobile-app';
  final String _redirectUrl = 'maxim://login-callback';

  final AuthorizationServiceConfiguration _serviceConfig = const AuthorizationServiceConfiguration(
    authorizationEndpoint: 'http://10.0.2.2:8080/realms/MaximRealm/protocol/openid-connect/auth',
    tokenEndpoint: 'http://10.0.2.2:8080/realms/MaximRealm/protocol/openid-connect/token',
    endSessionEndpoint: 'http://10.0.2.2:8080/realms/MaximRealm/protocol/openid-connect/logout',
  );

  String get _backendUrl {
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:3000/api/users/onboard';
  }

  ///  Handles Login and Returns Map for AuthProvider integration
  Future<Map<String, dynamic>?> login(BuildContext context) async {
    try {
      print("🚀 [DEBUG] Initiating login with scheme: maxim");
      
      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
          promptValues: ['login'], 
          allowInsecureConnections: true,
        ),
      );

      if (result == null) {
        _showSnackBar(context, "⚠️ Login cancelled or returned no data.", Colors.orange);
        return null;
      }

      await _secureStorage.write(key: 'access_token', value: result.accessToken);
      await _secureStorage.write(key: 'id_token', value: result.idToken);

      _showSnackBar(context, "✅ Handshake successful! Syncing...", Colors.green);
      
      // 1. Decode the Token to get the Keycloak ID (sub)
      final parts = result.idToken!.split('.');
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final String keycloakId = payload['sub'];

      // 2. Sync with Backend and get status
      bool isNewUser = await _sendUserToBackend(result.idToken!);
      String status = isNewUser ? 'NEW' : 'EXISTING';

      // 3. Return the Map to fix the WelcomeScreen type error
      return {
        'sub': keycloakId,
        'status': status,
        'email': payload['email'],
      };

    } on PlatformException catch (e) {
      _showSnackBar(context, "🛑 Android Error: ${e.message}", Colors.red);
      return null;
    } catch (e) {
      _showSnackBar(context, "❌ Error: $e", Colors.red);
      return null;
    }
  }

  Future<void> logout() async {
    try {
      String? idToken = await _secureStorage.read(key: 'id_token');
      if (idToken != null) {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken, 
            postLogoutRedirectUrl: _redirectUrl,
            serviceConfiguration: _serviceConfig,
          ),
        );
      }
      await _secureStorage.deleteAll();
    } catch (e) {
      print("❌ Logout failed: $e");
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<bool> _sendUserToBackend(String idToken) async {
    try {
      final parts = idToken.split('.');
      final payload = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'keycloak_id': payload['sub'], 
          'email': payload['email'],
          'phone_number': payload['phone_number'], 
          'dob': payload['dob'] ?? '1900-01-01', // Fallback for null dob
        }),
      );
      
      // If status is 201, the Node.js backend created a new user
      return response.statusCode == 201; 
    } catch (e) {
      print("❌ Backend Sync Error: $e");
      return false;
    }
  }
}