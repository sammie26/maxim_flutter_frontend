import 'package:flutter/material.dart';

class Tier {
  final String name;
  final int xpRequired;
  final int xpPerPayment;
  final Color color;
  final IconData icon;
  final List<String> features;

  Tier({
    required this.name,
    required this.xpRequired,
    required this.xpPerPayment,
    required this.color,
    required this.icon,
    required this.features,
  });
}
