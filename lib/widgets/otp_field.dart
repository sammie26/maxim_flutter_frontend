import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPField extends StatelessWidget {
  // Required input properties for the field manager
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autoFocus;

  const OTPField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autoFocus = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the fill state based on the controller's text
    final bool isFilled = controller.text.isNotEmpty;
    // Determine the border color based on focus
    final bool isFocused = focusNode.hasFocus;

    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        // Use user's custom fill color logic
        color: isFilled ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(10),
        // Enhance border to show focus
        border: Border.all(
          color: isFocused ? Colors.blue.shade700 : Colors.grey.shade300,
          width: isFocused ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        // Ensure only one digit can be entered
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: onChanged, // Send input events to the manager
        // Match the text style to your custom logic
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isFilled ? Colors.white : Colors.black,
        ),
        // Hide the default underline
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
      ),
    );
  }
}
