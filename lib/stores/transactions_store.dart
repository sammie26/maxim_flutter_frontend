// import 'package:maxim___frontend/models/transaction.dart';

// final Map<String, List<TransactionData>> transactions = {
//   'May 15 2025': [
//     const TransactionData(
//       title: 'Coffee',
//       type: TransactionType.paid,
//       date: 'May 15',
//       amount: '172.23',
//     ),
//     const TransactionData(
//       title: 'Birthday Present',
//       type: TransactionType.received,
//       date: 'May 15',
//       amount: '10,172.23',
//     ),
//   ],
//   'May 14 2025': [
//     const TransactionData(
//       title: 'Online Subscription',
//       type: TransactionType.paid,
//       date: 'May 14',
//       amount: '500.00',
//     ),
//     const TransactionData(
//       title: 'Salary Deposit',
//       type: TransactionType.received,
//       date: 'May 14',
//       amount: '15,000.00',
//     ),
//     const TransactionData(
//       title: 'Dinner at Local Bistro',
//       type: TransactionType.paid,
//       date: 'May 14',
//       amount: '450.00',
//     ),
//   ],
// };

// Map<String, List<TransactionData>> getFilteredTransactions(String searchQuery) {
//   if (searchQuery.isEmpty) {
//     return transactions;
//   }

//   final String query = searchQuery.toLowerCase();
//   final Map<String, List<TransactionData>> filteredMap = {};

//   transactions.forEach((date, transactions) {
//     final List<TransactionData> dayTransactions = transactions
//         .where((t) => t.title.toLowerCase().contains(query))
//         .toList();

//     if (dayTransactions.isNotEmpty) {
//       filteredMap[date] = dayTransactions;
//     }
//   });

//   return filteredMap;
// }
