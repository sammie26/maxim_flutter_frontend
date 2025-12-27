import 'package:flutter/material.dart';
import 'package:maxim___frontend/models/card.dart'; 
import 'package:maxim___frontend/theme/app_theme.dart';
import 'package:maxim___frontend/services/card_service.dart';

// --- 🔐 CHANGE PIN SCREEN ---
class ChangePinScreen extends StatefulWidget {
  final CardData card;
  const ChangePinScreen({super.key, required this.card});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _pinController = TextEditingController();
  final CardService _cardService = CardService();
  bool _isLoading = false;

  void _handlePinUpdate() async {
    if (_pinController.text.length < 4) return;
    
    setState(() => _isLoading = true);
    
    // 🎯 REAL DB CALL
    bool success = await _cardService.updateCardPin(widget.card.id, _pinController.text);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("PIN successfully updated.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update PIN. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: AppBar(
        title: const Text("Change PIN", style: TextStyle(color: AppColors.kDarkBackground)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Set a new 4-digit PIN for your card transactions.",
              style: TextStyle(color: AppColors.kDullTextColor, fontSize: 16),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              style: const TextStyle(fontSize: 24, letterSpacing: 16, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintText: "••••",
                filled: true,
                fillColor: AppColors.kAccentWhite,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _handlePinUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kDarkBackground,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text("Confirm New PIN", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ❄️ FREEZE CARD SCREEN ---
class FreezeCardScreen extends StatefulWidget {
  final CardData card;
  const FreezeCardScreen({super.key, required this.card});

  @override
  State<FreezeCardScreen> createState() => _FreezeCardScreenState();
}

class _FreezeCardScreenState extends State<FreezeCardScreen> {
  final CardService _cardService = CardService();
  bool _isLoading = false;

  void _toggleStatus() async {
    setState(() => _isLoading = true);
    
    String nextStatus = widget.card.status == CardStatus.frozen ? 'active' : 'frozen';
    bool success = await _cardService.updateCardStatus(widget.card.id, nextStatus);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Card is now ${nextStatus.toUpperCase()}")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to update status.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFrozen = widget.card.status == CardStatus.frozen;

    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.kDarkBackground)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Icon(isFrozen ? Icons.lock_open_rounded : Icons.ac_unit_rounded, size: 100, color: AppColors.kDarkBackground),
            const SizedBox(height: 24),
            Text(
              isFrozen ? "Unfreeze Card?" : "Freeze Card?",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              isFrozen 
                ? "This will re-enable all transactions for this card." 
                : "Freezing stops all new transactions until you unfreeze it manually.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.kDullTextColor, fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _toggleStatus,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kDarkBackground,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : Text(isFrozen ? "Unfreeze Now" : "Freeze Temporarily", style: const TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 🧨 TERMINATE CARD SCREEN ---
class TerminateCardScreen extends StatefulWidget {
  final CardData card;
  const TerminateCardScreen({super.key, required this.card});

  @override
  State<TerminateCardScreen> createState() => _TerminateCardScreenState();
}

class _TerminateCardScreenState extends State<TerminateCardScreen> {
  final CardService _cardService = CardService();
  bool _isLoading = false;

  void _handleTerminate() async {
    setState(() => _isLoading = true);
    bool success = await _cardService.terminateCard(widget.card.id);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context, true); 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Card Terminated Successfully.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error terminating card.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kLightBackground,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: AppColors.kDarkBackground)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Icon(Icons.report_problem_rounded, size: 100, color: Colors.red),
            const SizedBox(height: 24),
            const Text("Terminate Card?", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              "This action is permanent and cannot be undone. You will lose access to this card immediately.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.kDullTextColor, fontSize: 16),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleTerminate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading 
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                : const Text("Yes, Terminate Permanently", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context), 
              child: const Text("No, Keep Card", style: TextStyle(color: AppColors.kDarkBackground, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}