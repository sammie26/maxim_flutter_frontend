import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// The callback function signature to send the complete OTP code back
typedef OtpChangeCallback = void Function(String otp);

class FiveDigitOtpInput extends StatefulWidget {
  final OtpChangeCallback onOtpChanged;

  const FiveDigitOtpInput({required this.onOtpChanged, super.key});

  @override
  State<FiveDigitOtpInput> createState() => _FiveDigitOtpInputState();
}

class _FiveDigitOtpInputState extends State<FiveDigitOtpInput> {
  // 5 Controllers for 5 separate TextFormFields
  final List<TextEditingController> _controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  // 5 FocusNodes to manage focus between fields
  final List<FocusNode> _focusNodes = List.generate(5, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    // Add listener to each controller to update the overall OTP code
    for (int i = 0; i < 5; i++) {
      _controllers[i].addListener(() => _handleTextChange(i));
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // This function is called whenever text changes in any of the 5 fields
  void _handleTextChange(int index) {
    String currentOtp = _controllers.map((c) => c.text).join();
    widget.onOtpChanged(currentOtp);

    // Auto-advance logic
    if (_controllers[index].text.length == 1 && index < 4) {
      // Move to the next field
      _focusNodes[index + 1].requestFocus();
    } else if (_controllers[index].text.isEmpty && index > 0) {
      // Move to the previous field on deletion (optional UX improvement)
      _focusNodes[index - 1].requestFocus();
    }
  }

  // Helper widget to build each of the 5 input fields
  Widget _buildOtpBox(int index, BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: ValueListenableBuilder<TextEditingValue>(
        valueListenable: _controllers[index],
        builder: (context, value, child) {
          // Determine the border color based on focus or content
          Color borderColor;
          if (_focusNodes[index].hasFocus) {
            borderColor = Theme.of(context).primaryColor;
          } else if (value.text.isNotEmpty) {
            // Darken border when number is placed inside
            borderColor = Colors.grey.shade700;
          } else {
            borderColor = Colors.grey.shade400;
          }

          return TextFormField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1, // Only one digit per field
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            // When user pastes 5 digits, this ensures the first digit goes to the current field
            onChanged: (text) {
              if (text.length > 1) {
                // Handle paste or quick entry by putting the first char here
                _controllers[index].text = text.substring(0, 1);
              }
            },
            decoration: InputDecoration(
              counterText: "", // Hide the 1/1 character counter
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => _buildOtpBox(index, context)),
    );
  }
}
