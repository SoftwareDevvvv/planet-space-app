import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/orbital_body.dart';

class OrbitalConstants {
  static const double minScale = 0.7;
  static const double maxScale = 4.0;
  static const double defaultScale = 1.0;
  static const double scaleEpsilon = 0.002;
  static const double recenterThreshold = 12.0;
  static const int orbitAnimationSeconds = 140;
  static const int earthOrbitIndex = 2;
  static const double auKm = 149597870.7;
  static const int orbitCount = 8;
  static const double orbitSpacingFraction = 0.085;
  static const double innerOrbitFraction = 0.18;
  static const double sunCoreFraction = 0.075;
  static const double sunHaloFraction = 0.16;
  static const double planetRadiusFraction = 0.012;
  static const double planetGlowRadiusMultiplier = 2.8;
  static const double planetGlowBlur = 12.0;
  static const double orbitStroke = 1.2;
  static const double orbitOpacity = 0.22;
  static const double minorOrbitOpacity = 0.12;
  static const double gridStroke = 0.6;
  static const double gridOpacity = 0.05;
  static const double starParallaxFactor = 0.2;
  static const double labelFontSize = 11;
  static const double labelOffset = 12;
  static const double overlayPadding = 24;
  static const double atmosphereRadiusMultiplier = 1.08;
  static const double atmosphereBlur = 8.0;
  static const Color atmosphereColor = Color(0xFF85C6FF);

  static final List<StarSpec> stars = List.generate(120, (index) {
    final random = math.Random(42 + index);
    return StarSpec(
      normalized: Offset(random.nextDouble(), random.nextDouble()),
      radius: random.nextDouble() * 1.4 + 0.4,
      opacity: random.nextDouble() * 0.5 + 0.2,
    );
  });

  static const List<OrbitalBody> bodies = [
    OrbitalBody(
      name: 'MERCURY',
      orbitIndex: 0,
      color: Color(0xFFB6A99C),
      speed: 1.2,
      phase: 0.15,
      sizeMultiplier: 0.6,
      orbitalRadiusAu: 0.387,
      orbitalVelocityKmPerSec: 47.87,
      textureAsset: 'assets/textures/mercury_1k.jpg',
    ),
    OrbitalBody(
      name: 'VENUS',
      orbitIndex: 1,
      color: Color(0xFFD9B36F),
      speed: 0.95,
      phase: 0.35,
      sizeMultiplier: 0.8,
      orbitalRadiusAu: 0.723,
      orbitalVelocityKmPerSec: 35.02,
      textureAsset: 'assets/textures/venus_1k.jpg',
    ),
    OrbitalBody(
      name: 'EARTH',
      orbitIndex: 2,
      color: Color(0xFF6CB4EE),
      speed: 0.85,
      phase: 0.55,
      sizeMultiplier: 1.0,
      orbitalRadiusAu: 1.0,
      orbitalVelocityKmPerSec: 29.78,
      textureAsset: 'assets/textures/earth_1k.jpg',
      hasAtmosphere: true,
    ),
    OrbitalBody(
      name: 'MARS',
      orbitIndex: 3,
      color: Color(0xFFFF8A65),
      speed: 0.72,
      phase: 0.2,
      sizeMultiplier: 0.85,
      orbitalRadiusAu: 1.524,
      orbitalVelocityKmPerSec: 24.07,
      textureAsset: 'assets/textures/mars_1k.jpg',
    ),
    OrbitalBody(
      name: 'JUPITER',
      orbitIndex: 4,
      color: Color(0xFFD2B48C),
      speed: 0.4,
      phase: 0.75,
      sizeMultiplier: 1.45,
      orbitalRadiusAu: 5.203,
      orbitalVelocityKmPerSec: 13.07,
      textureAsset: 'assets/textures/jupiter_1k.jpg',
    ),
    OrbitalBody(
      name: 'SATURN',
      orbitIndex: 5,
      color: Color(0xFFE3C689),
      speed: 0.32,
      phase: 0.45,
      sizeMultiplier: 1.25,
      orbitalRadiusAu: 9.537,
      orbitalVelocityKmPerSec: 9.68,
      textureAsset: 'assets/textures/saturn_1k.jpg',
    ),
    OrbitalBody(
      name: 'URANUS',
      orbitIndex: 6,
      color: Color(0xFF7DD7E6),
      speed: 0.22,
      phase: 0.05,
      sizeMultiplier: 1.1,
      orbitalRadiusAu: 19.191,
      orbitalVelocityKmPerSec: 6.80,
      textureAsset: 'assets/textures/uranus_1k.jpg',
    ),
    OrbitalBody(
      name: 'NEPTUNE',
      orbitIndex: 7,
      color: Color(0xFF5B7CFF),
      speed: 0.18,
      phase: 0.6,
      sizeMultiplier: 1.1,
      orbitalRadiusAu: 30.07,
      orbitalVelocityKmPerSec: 5.43,
      textureAsset: 'assets/textures/neptune_1k.jpg',
    ),
  ];
}

class StarSpec {
  const StarSpec({
    required this.normalized,
    required this.radius,
    required this.opacity,
  });

  final Offset normalized;
  final double radius;
  final double opacity;
}
