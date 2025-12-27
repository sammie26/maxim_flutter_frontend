import 'package:flutter/material.dart';


class BankTile extends StatelessWidget {
  final String name;
  final IconData logo;


  const BankTile({required this.name, required this.logo, super.key});


  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(logo, size: 36),
      title: Text(name),
      onTap: () {},
    );
  }
}