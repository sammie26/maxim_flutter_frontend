import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maxim___frontend/models/card.dart';
import 'package:maxim___frontend/services/card_service.dart';
import 'package:maxim___frontend/providers/auth_provider.dart';
import 'package:maxim___frontend/theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'payment_receipt_screen.dart';

class EnterAmountScreen extends StatefulWidget {
  final String recipientUuid; // ✅ Added to match SendMoneyScreen
  final String recipientName;

  const EnterAmountScreen({
    super.key,
    required this.recipientUuid,
    required this.recipientName,
  });

  @override
  State<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends State<EnterAmountScreen> {
  CardData? _selectedCard;
  final TextEditingController _amountController = TextEditingController();
  final CardService _cardService = CardService();

  late Future<List<CardData>> _cardsFuture;
  String _amountError = '';
  double _currentAmount = 0.0;
  final double _minAmount = 1.0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).userId;
    _cardsFuture = _cardService.fetchUserCards(userId);
    _amountController.addListener(_validateAmount);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    if (_selectedCard == null) return;

    setState(() {
      final text = _amountController.text.replaceAll(',', '');
      _currentAmount = double.tryParse(text) ?? 0.0;

      if (_currentAmount > _selectedCard!.balance) {
        _amountError =
            'Amount exceeds card balance (EGP ${_selectedCard!.balance.toStringAsFixed(2)})';
      } else if (_currentAmount > 0 && _currentAmount < _minAmount) {
        _amountError =
            'Minimum transfer amount is EGP ${_minAmount.toStringAsFixed(2)}';
      } else {
        _amountError = '';
      }
    });
  }

  // ✅ DYNAMIC PAYMENT LOGIC (Communicating with server.js)
  Future<void> _handleSend() async {
    _validateAmount();

    if (_amountError.isEmpty && _currentAmount > 0 && _selectedCard != null) {
      setState(() => _isProcessing = true);

      final keycloakId = Provider.of<AuthProvider>(context, listen: false).userId;

      try {
        final response = await http.post(
          Uri.parse("http://10.0.2.2:3000/api/send-payment"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "amount": _currentAmount.toString(),
            "keycloakId": keycloakId,
            "recipientId": widget.recipientUuid, // ✅ Uses the UUID from selection
            "type": "p2p_sent",
            "cardId": _selectedCard!.id,
            "providerName": "Maxim Internal",
          }),
        );

        if (mounted) {
          setState(() => _isProcessing = false);

          if (response.statusCode == 201) {
            // ✅ Successful Payment - Route to Receipt
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PaymentReceiptScreen(
                  recipientName: widget.recipientName,
                  amount: _currentAmount,
                  transactionDate: DateTime.now(),
                  // In a real app, bankDetails/reference would come from the server response
                  bankDetails: const BankDetails(
                    accountA: '026073150',
                    accountB: '2715500356',
                    reference: 'REF-MAXIM-SUCCESS',
                  ),
                  transactionNote: 'Payment to ${widget.recipientName} successful.',
                ),
              ),
            );
          } else {
            final errorData = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(errorData['error'] ?? "Transaction Failed")),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Connection Error: Server unreachable")),
          );
        }
      }
    } else if (_currentAmount == 0) {
      setState(() => _amountError = 'Please enter an amount.');
    }
  }

  void _navigateToBlankPage(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(color: AppColors.kDarkBackground)),
            backgroundColor: AppColors.kLightBackground,
            iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
            elevation: 0,
          ),
          body: Center(child: Text('You navigated to $title')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      body: FutureBuilder<List<CardData>>(
        future: _cardsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.kDarkBackground));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildErrorState();
          }

          final List<CardData> userCards = snapshot.data!;
          _selectedCard ??= userCards.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildTitle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildRecipientConfirmation(),
                      const SizedBox(height: 32),
                      _buildCardSelectionDropdown(userCards),
                      const SizedBox(height: 32),
                      _buildAmountInput(),
                    ],
                  ),
                ),
              ),
              _buildSendButton(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.credit_card_off, size: 64, color: AppColors.kDullTextColor),
            const SizedBox(height: 16),
            const Text(
              "No Active Cards Found",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "You need an active card with a balance to send money.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kDarkBackground),
              onPressed: () => Navigator.pop(context),
              child: const Text("Go Back", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        bottom: 20,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kDarkBackground,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
          ),
          GestureDetector(
            onTap: () => _navigateToBlankPage(context, 'Profile'),
            child: const Icon(Icons.person_outline, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        'Enter Amount',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
      ),
    );
  }

  Widget _buildRecipientConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sending to:',
          style: TextStyle(fontSize: 14, color: AppColors.kDullTextColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.kDarkBackground,
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              widget.recipientName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.kDarkBackground),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardSelectionDropdown(List<CardData> cards) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.kDullTextColor.withOpacity(.2), width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<CardData>(
          value: _selectedCard,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.kDullTextColor),
          onChanged: (CardData? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedCard = newValue;
                _validateAmount();
              });
            }
          },
          items: cards.map<DropdownMenuItem<CardData>>((CardData card) {
            return DropdownMenuItem<CardData>(
              value: card,
              child: Row(
                children: [
                  const Icon(Icons.credit_card, color: AppColors.kDarkBackground, size: 20),
                  const SizedBox(width: 12),
                  Text('${card.name} (••${card.lastFour})'),
                  const Spacer(),
                  Text(
                    'EGP ${card.balance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 14, color: AppColors.kDullTextColor),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount to Send',
          style: TextStyle(fontSize: 14, color: AppColors.kDullTextColor, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
          decoration: InputDecoration(
            prefixText: 'EGP ',
            prefixStyle: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.kDarkBackground),
            hintText: '0.00',
            border: InputBorder.none,
            errorText: _amountError.isNotEmpty ? _amountError : null,
            errorStyle: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
          ),
        ),
        Divider(color: AppColors.kDullTextColor.withOpacity(.5), height: 1),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    final bool isDisabled = _amountError.isNotEmpty || _currentAmount <= 0 || _isProcessing;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      child: GestureDetector(
        onTap: isDisabled ? null : _handleSend,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: isDisabled ? AppColors.kDarkBackground.withOpacity(.5) : AppColors.kDarkBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: _isProcessing
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                : const Text(
                    'Send',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}