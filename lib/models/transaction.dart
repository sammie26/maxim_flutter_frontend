// lib/models/transaction.dart

// Define the categories to match your PostgreSQL ENUM exactly
enum TransactionType { 
  bill_pay, 
  p2p_sent, 
  p2p_received, 
  cashback, 
  bnpl_repayment 
}

class TransactionModel {
  final String id;
  final String? cardId;
  final TransactionType type;
  final double amount;
  final String providerName;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    this.cardId,
    required this.type,
    required this.amount,
    required this.providerName,
    required this.createdAt,
  });

  // This factory constructor converts the JSON from your Node.js API 
  // into an actual TransactionModel object.
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      cardId: json['card_id'],
      // Logic to convert the string from SQL ENUM to Dart Enum
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.bill_pay, 
      ),
      amount: double.parse(json['amount'].toString()),
      providerName: json['provider_name'] ?? 'General',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}