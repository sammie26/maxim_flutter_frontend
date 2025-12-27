import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service class to handle secure storage of the JWT access token.
/// Uses FlutterSecureStorage, which utilizes platform-specific secure
/// storage (Keychain on iOS, Keystore on Android).
class SecureTokenService {
  // Use a singleton instance of FlutterSecureStorage
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // Key for the JWT access token
  static const String _tokenKey = 'auth_access_token';

  /// Saves the JWT token securely.
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    print('Token successfully saved.');
  }

  /// Retrieves the JWT token securely.
  Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }

  /// Deletes the JWT token from secure storage (e.g., on logout).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token successfully deleted.');
  }
}