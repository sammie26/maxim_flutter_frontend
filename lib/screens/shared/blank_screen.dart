import 'package:flutter/material.dart';
import 'package:maxim___frontend/theme/app_theme.dart';

class BlankPage extends StatelessWidget {
  const BlankPage(this.title, {super.key});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: AppColors.kDarkBackground),
        ),
        backgroundColor: AppColors.kLightBackground,
        iconTheme: const IconThemeData(color: AppColors.kDarkBackground),
        elevation: 0,
      ),
      body: Center(child: Text('You navigated to $title.')),
    );
  }
}
