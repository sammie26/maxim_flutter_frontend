import 'package:flutter/material.dart';
import 'package:maxim___frontend/models/service_provider.dart';

final List<ServiceProvider> availableProviders = [
  const ServiceProvider(
    id: 1,
    name: 'Electricity (Kahraba)',
    icon: Icons.lightbulb_outline,
  ),
  const ServiceProvider(
    id: 2,
    name: 'Mobile (Vodafone)',
    icon: Icons.phone_android,
  ),
  const ServiceProvider(
    id: 3,
    name: 'Water (Mayah)',
    icon: Icons.water_drop_outlined,
  ),
  const ServiceProvider(id: 4, name: 'Internet (TE Data)', icon: Icons.wifi),
];
