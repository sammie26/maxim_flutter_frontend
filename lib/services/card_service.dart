import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/card.dart';

class AddCardRequestModel {
  final String keycloakId;
  final String cardName;
  final String cardNumber;
  final String cvv;
  final String expiryDate;
  final String pinHash;
  final String color;

  AddCardRequestModel({
    required this.keycloakId,
    required this.cardName,
    required this.cardNumber,
    required this.cvv,
    required this.expiryDate,
    required this.pinHash,
    required this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'keycloakId': keycloakId,
      'card_name': cardName,
      'card_number': cardNumber,
      'cvv': cvv,
      'expiry_date': expiryDate,
      'pin_hash': pinHash,
      'color': color,
    };
  }
}

class CardService {
  // Use 10.0.2.2 for Android Emulator to reach localhost on your computer
  final String baseUrl = "http://10.0.2.2:3000/api/cards";

  Future<List<CardData>> fetchUserCards(String keycloakId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$keycloakId'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => CardData.fromJson(json)).toList();
      } else {
        // Detailed error to help debugging
        print('❌ Server Error: ${response.statusCode} - ${response.body}');
        throw Exception('Server returned ${response.statusCode}: Failed to load cards');
      }
    } catch (e) {
      print('❌ Connection Error: $e');
      throw Exception('Failed to load cards: $e');
    }
  }

  Future<CardData> addCard(AddCardRequestModel addCard) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(addCard.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return CardData.fromJson(data['card']);
    } else if (response.statusCode == 409) {
      throw Exception('This card is already registered.');
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add card');
    }
  }

  Future<bool> updateCardPin(String cardId, String newPin) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$cardId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"pin_hash": newPin}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCardStatus(String cardId, String newStatus) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$cardId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> terminateCard(String cardId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$cardId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}