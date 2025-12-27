enum CardStatus { active, frozen, terminated }
enum CardColor { orange, pink, black }

class CardData {
  final String id;
  final String name;
  final String number;
  final String lastFour;
  final String expiry;
  final String cvv;
  final double balance;
  final CardColor color;
  final CardStatus status;
      
  const CardData({
    required this.id,
    required this.name,
    required this.number,
    required this.lastFour,
    required this.expiry,
    required this.cvv,
    required this.balance,
    required this.color,
    required this.status,
  });

  // Helper to map DB color to your Asset paths
  String get imagePath {
    switch (color) {
      case CardColor.pink: return 'lib/assets/card_pink.png';
      case CardColor.black: return 'lib/assets/card_dark.png';
      case CardColor.orange: 
      default: return 'lib/assets/card_orange.png';
    }
  }

  factory CardData.fromJson(Map<String, dynamic> json) {
    return CardData(
      id: json['id'],
      name: json['card_name'],
      number: json['card_number'], // Full number for details
      lastFour: json['last_four'],
      expiry: json['expiry_date'].toString().substring(0, 7), // YYYY-MM format
      cvv: json['cvv'],
      balance: double.parse(json['balance'].toString()),
      color: CardColor.values.firstWhere((e) => e.name == json['color']),
      status: CardStatus.values.firstWhere((e) => e.name == json['status']),
    );
  }
}