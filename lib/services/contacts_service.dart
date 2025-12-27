import 'dart:convert';
import 'package:http/http.dart' as http;

class Contact {
  final String contactUuid;
  final String email;
  final String phoneNumber;
  final bool isFriend;
  final bool isFavorite;
  final DateTime? lastContactedAt; // Parsed for better utility

  Contact({
    required this.contactUuid,
    required this.email,
    required this.phoneNumber,
    required this.isFriend,
    required this.isFavorite,
    this.lastContactedAt,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      contactUuid: json["contact_uuid"] as String,
      email: json["email"] as String,
      phoneNumber: json["phone_number"] as String,
      isFriend: json["is_friend"] as bool? ?? false,
      isFavorite: json["is_favorite"] as bool? ?? false,
      // Safely parse the ISO 8601 string
      lastContactedAt: json["last_contacted_at"] != null 
          ? DateTime.parse(json["last_contacted_at"]) 
          : null,
    );
  }
}

class ContactsService {
  // Use 10.0.2.2 for Android Emulator to reach localhost on your computer
  final String baseUrl = "http://10.0.2.2:3000/api/contacts";

  Future<List<Contact>> fetchContacts(String keycloakId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$keycloakId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Contact.fromJson(json)).toList();
      } else {
        // Detailed error to help debugging
        print('❌ Server Error: ${response.statusCode} - ${response.body}');
        throw Exception(
          'Server returned ${response.statusCode}: Failed to load cards',
        );
      }
    } catch (e) {
      print('❌ Connection Error: $e');
      throw Exception('Failed to load cards: $e');
    }
  }

  Future<String> addContact({
    required String keycloakId,
    required String contactIdentifier, //email or phone number in db
    bool isFavorite = false,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/add"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "keycloakId": keycloakId,
        "contactIdentifier": contactIdentifier,
        "isFavorite": isFavorite,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data["message"];
    } else if (response.statusCode == 409) {
      throw Exception('This card is already registered.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add card');
    }
  }
}
