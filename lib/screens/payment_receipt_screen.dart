// payment_receipt_screen.dart

import 'package:flutter/material.dart';
import "package:maxim___frontend/theme/app_theme.dart";

// Mock Data Structure for Bank Details (similar to what you'd pass)
class BankDetails {
  final String accountA;
  final String accountB;
  final String reference;

  const BankDetails({
    required this.accountA,
    required this.accountB,
    required this.reference,
  });
}

class PaymentReceiptScreen extends StatelessWidget {
  // Required data to display on the receipt
  final String recipientName;
  final double amount;
  final DateTime transactionDate;
  final BankDetails bankDetails;
  final String transactionNote;

  const PaymentReceiptScreen({
    super.key,
    required this.recipientName,
    required this.amount,
    required this.transactionDate,
    required this.bankDetails,
    required this.transactionNote,
  });

  // Helper method to format date and time
  String _formatDateTime() {
    final date =
        '${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.year}';
    final time =
        '${transactionDate.hour.toString().padLeft(2, '0')}:${transactionDate.minute.toString().padLeft(2, '0')}';
    return '$date · $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.kLightBackground, // Match the outer screen background
      body: Column(
        children: [
          // 1. Dark Receipt Area (Inspired by image_6ddcc7.png)
          _buildReceiptHeader(context),

          // 2. Scrollable Details Area (White/Gray area at the bottom of the image)
          Expanded(
            child: Container(
              color: AppColors.kLightBackground,
              // Add a section here if there are more details to show below the dark curve
              child: const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptHeader(BuildContext context) {
    // The curved, dark background that contains the main receipt details
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 30, // Padding below the content to make room for the curve
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.kDarkBackground,
        // Using a CustomClipper or similar shape is complex,
        // so we use a large BorderRadius for a similar feel, or a ClipPath:
        // For simplicity, we'll use a standard, large bottom radius here.
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(80),
          bottomRight: Radius.circular(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header Bar (X, Title, Share Icon)
          _buildHeaderBar(context),
          const SizedBox(height: 30),

          // Confirmation Icon
          _buildConfirmationIcon(),
          const SizedBox(height: 24),

          // Payment Confirmation Text
          _buildConfirmationText(),
          const SizedBox(height: 30),

          // Date and Amount Details
          _buildDetailRow('Date', _formatDateTime()),
          const SizedBox(height: 12),
          _buildDetailRow('Amount', 'EGP ${amount.toStringAsFixed(2)}'),
          const SizedBox(height: 30),

          // Bank Details
          _buildBankDetails(),
          const SizedBox(height: 30),

          // Note Section
          _buildNoteSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Close Button (X)
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.close,
            color: AppColors.kAccentWhite,
            size: 28,
          ),
        ),

        // Title
        const Text(
          'Payment Receipt',
          style: TextStyle(
            color: AppColors.kAccentWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Share Icon
        const Icon(Icons.ios_share, color: AppColors.kAccentWhite, size: 24),
      ],
    );
  }

  Widget _buildConfirmationIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.kAccentWhite, width: 3),
      ),
      child: const Center(
        child: Icon(Icons.check, color: AppColors.kAccentWhite, size: 48),
      ),
    );
  }

  Widget _buildConfirmationText() {
    return Column(
      children: [
        const Text(
          'Payment Confirmed',
          style: TextStyle(
            color: AppColors.kAccentWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Successfully paid to $recipientName.',
          style: TextStyle(
            color: AppColors.kAccentGrey.withValues(alpha: .8),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.kAccentGrey,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.kAccentWhite,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBankDetails() {
    // The image doesn't provide a title for this section,
    // but based on the content we'll add 'Bank Details' for clarity.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bank Details',
          style: TextStyle(
            color: AppColors.kAccentGrey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildDetailText(bankDetails.accountA),
        _buildDetailText(bankDetails.accountB),
        _buildDetailText(bankDetails.reference),
      ],
    );
  }

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Note',
          style: TextStyle(
            color: AppColors.kAccentGrey,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          transactionNote,
          style: TextStyle(
            color: AppColors.kAccentGrey.withValues(alpha: .8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.kAccentWhite,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
