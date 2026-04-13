import 'package:flutter/material.dart';

class OrbitalBody {
  const OrbitalBody({
    required this.name,
    required this.orbitIndex,
    required this.color,
    required this.speed,
    required this.phase,
    required this.sizeMultiplier,
    required this.orbitalRadiusAu,
    required this.orbitalVelocityKmPerSec,
    this.textureAsset,
    this.hasAtmosphere = false,
  });

  final String name;
  final int orbitIndex;
  final Color color;
  final double speed;
  final double phase;
  final double sizeMultiplier;
  final double orbitalRadiusAu;
  final double orbitalVelocityKmPerSec;
  final String? textureAsset;
  final bool hasAtmosphere;
}
