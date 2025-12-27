// lib/models/dashboard_model.dart

class DashboardModel {
  final UserProfileModel user;
  final WalletModel wallet;
  final RewardsModel rewards;
  final CardModel? card; // Card can be null
  final List<TransactionModel> recentTransactions;

  DashboardModel({
    required this.user,
    required this.wallet,
    required this.rewards,
    this.card,
    required this.recentTransactions,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: UserProfileModel.fromJson(json['user']),
      wallet: WalletModel.fromJson(json['wallet']),
      rewards: RewardsModel.fromJson(json['rewards']),
      card: json['card'] != null ? CardModel.fromJson(json['card']) : null,
      recentTransactions: (json['recentTransactions'] as List)
          .map((i) => TransactionModel.fromJson(i))
          .toList(),
    );
  }
}

// Helper Models

class UserProfileModel {
  final String fullName;
  final String email;
  UserProfileModel({required this.fullName, required this.email});
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      fullName: json['fullName'] ?? 'User',
      email: json['email'] ?? '',
    );
  }
}

class WalletModel {
  final double balance;
  WalletModel({required this.balance});
  factory WalletModel.fromJson(Map<String, dynamic> json) {
    // Assuming balance is stored as a double/decimal in SQL and returned as num/double
    return WalletModel(
      balance: (json['balance'] ?? 0.0).toDouble(), 
    );
  }
}

class RewardsModel {
  final int points;
  final int xp;
  final int level;
  RewardsModel({required this.points, required this.xp, required this.level});
  factory RewardsModel.fromJson(Map<String, dynamic> json) {
    return RewardsModel(
      points: json['points'] ?? 0,
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
    );
  }
}

class CardModel {
  final String cardNumber;
  final String expiryDate;
  CardModel({required this.cardNumber, required this.expiryDate});
  factory CardModel.fromJson(Map<String, dynamic> json) {
    // Note: Masking/formatting the card number should happen in the UI layer
    return CardModel(
      cardNumber: json['card_number'] ?? '',
      expiryDate: json['expiry_date'] ?? '',
    );
  }
}

class TransactionModel {
  final int txId;
  final double amount;
  final String description;
  final String type; // e.g., 'credit', 'debit'
  final DateTime createdAt;
  
  TransactionModel({
    required this.txId,
    required this.amount,
    required this.description,
    required this.type,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      txId: json['tx_id'],
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? 'N/A',
      type: json['type'] ?? 'N/A',
      createdAt: DateTime.parse(json['created_at']), // Assuming SQL Server returns a standard datetime string
    );
  }
}