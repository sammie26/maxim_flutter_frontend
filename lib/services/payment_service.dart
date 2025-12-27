import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/transaction.dart';

// var betweenUsers = PaymentRequest(amount: 15000, keycloakId: FROMAUTH, type: TransactionType.p2p_sent, providerName: "Sent from layla", recipientId:"asdasd");

// var payBill = PaymentRequest(amount: 15000, keycloakId: FROMAUTH, type: TransactionType.bill_pay, providerName: "Telecom - We monthly Payment");

// var payMoneyToSelf = PaymentRequest(amount: 15000, keycloakId: FROMAUTH, type: TransactionType.p2p_received, providerName: "");

// PaymentService.sendPayment(myPaymentRequest);

class PaymentRequest {
  final double amount;
  final String keycloakId;
  final TransactionType type;
  final String providerName;
  final String cardId;
  final String? recipientId;

  PaymentRequest._({
    required this.amount,
    required this.keycloakId,
    required this.type,
    required this.providerName,
    required this.cardId,
    this.recipientId,
  });

  factory PaymentRequest({
    required double amount,
    required String keycloakId,
    required TransactionType type,
    required String providerName,
    required String cardId,
    String? recipientId,
  }) {
    if (type == TransactionType.p2p_sent &&
        (recipientId == null || recipientId.isEmpty)) {
      throw ArgumentError("Recipient ID is mandatory for P2P transfers.");
    }

    return PaymentRequest._(
      amount: amount,
      keycloakId: keycloakId,
      type: type,
      recipientId: recipientId,
      cardId: cardId,
      providerName: providerName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'keycloakId': keycloakId,
      'type': type.name,
      'providerName': providerName,
      'cardId': cardId,
      if (recipientId != null) 'recipientId': recipientId,
    };
  }
}

class PaymentService {
  // ✅ The "Magic IP" for Android Emulator to bridge to your PC's localhost
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  Future<Map<String, dynamic>> sendPayment(
    PaymentRequest paymentRequest,
  ) async {
    final String _endpoint = '$_baseUrl/send-payment';
    print('📡 Sending Payment to:$_endpoint');

    try {
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(paymentRequest.toJson()),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception('User account not found. Please try logging in again.');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception(
        'Cannot reach the server. Make sure your backend is running on port 3000.',
      );
    } catch (e) {
      throw Exception('Connection error: $e');
    }
  }
}
