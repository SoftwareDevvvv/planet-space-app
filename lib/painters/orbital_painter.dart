import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/orbital_body.dart';
import '../utils/orbital_constants.dart';

class OrbitalPainter extends CustomPainter {
  OrbitalPainter({
    required this.scale,
    required this.offset,
    required this.textures,
    required this.progress,
  });

  final double scale;
  final Offset offset;
  final Map<String, ui.Image> textures;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final shortestSide = size.shortestSide;
    final orbitSpacing = shortestSide * OrbitalConstants.orbitSpacingFraction;
    final innerRadius = shortestSide * OrbitalConstants.innerOrbitFraction;

    _paintStars(canvas, size, offset);

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.translate(center.dx, center.dy);
    canvas.scale(scale);
    canvas.translate(-center.dx, -center.dy);

    _paintGrid(canvas, size, center, orbitSpacing);
    _paintOrbits(canvas, center, innerRadius, orbitSpacing);
    _paintSun(canvas, center, shortestSide);
    _paintBodies(canvas, center, innerRadius, orbitSpacing, shortestSide);
    canvas.restore();
  }

  void _paintStars(Canvas canvas, Size size, Offset offset) {
    final paint = Paint()..style = PaintingStyle.fill;
    final parallaxOffset = offset * OrbitalConstants.starParallaxFactor;

    for (final star in OrbitalConstants.stars) {
      paint.color = Colors.white.withOpacity(star.opacity);
      final position = Offset(
        star.normalized.dx * size.width + parallaxOffset.dx,
        star.normalized.dy * size.height + parallaxOffset.dy,
      );
      canvas.drawCircle(position, star.radius, paint);
    }
  }

  void _paintGrid(Canvas canvas, Size size, Offset center, double spacing) {
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = OrbitalConstants.gridStroke
      ..color = Colors.white.withOpacity(OrbitalConstants.gridOpacity);

    final extent = math.max(size.width, size.height) * 1.2;
    final left = center.dx - extent;
    final right = center.dx + extent;
    final top = center.dy - extent;
    final bottom = center.dy + extent;

    for (double x = left; x <= right; x += spacing) {
      canvas.drawLine(Offset(x, top), Offset(x, bottom), gridPaint);
    }
    for (double y = top; y <= bottom; y += spacing) {
      canvas.drawLine(Offset(left, y), Offset(right, y), gridPaint);
    }
  }

  void _paintOrbits(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double spacing,
  ) {
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = OrbitalConstants.orbitStroke
      ..color = Colors.white.withOpacity(OrbitalConstants.orbitOpacity);

    for (var i = 0; i < OrbitalConstants.orbitCount; i++) {
      final radius = innerRadius + spacing * i;
      orbitPaint.color = Colors.white.withOpacity(
        i.isEven
            ? OrbitalConstants.orbitOpacity
            : OrbitalConstants.minorOrbitOpacity,
      );
      canvas.drawCircle(center, radius, orbitPaint);
    }
  }

  void _paintSun(Canvas canvas, Offset center, double shortestSide) {
    final haloRadius = shortestSide * OrbitalConstants.sunHaloFraction;
    final coreRadius = shortestSide * OrbitalConstants.sunCoreFraction;
    final haloPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE1A3).withOpacity(0.9),
          const Color(0x00FFB347),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: haloRadius));

    final corePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFFFFF4D1), Color(0xFFFFB347)],
      ).createShader(Rect.fromCircle(center: center, radius: coreRadius));

    canvas.drawCircle(center, haloRadius, haloPaint);
    canvas.drawCircle(center, coreRadius, corePaint);
  }

  void _paintBodies(
    Canvas canvas,
    Offset center,
    double innerRadius,
    double spacing,
    double shortestSide,
  ) {
    final textStyle = TextStyle(
      color: Colors.white.withOpacity(0.85),
      fontSize: OrbitalConstants.labelFontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: 2.2,
    );

    for (final body in OrbitalConstants.bodies) {
      final orbitRadius = innerRadius + spacing * body.orbitIndex;
      final angle = _orbitalAngle(body, progress);
      final position = _orbitalPosition(center, orbitRadius, angle);
      final radius =
          shortestSide *
          OrbitalConstants.planetRadiusFraction *
          body.sizeMultiplier;

      final texture = body.textureAsset == null
          ? null
          : textures[body.textureAsset!];
      final lightDir = center - position;
      final lightDirection = lightDir.distance == 0
          ? const Offset(0, -1)
          : lightDir / lightDir.distance;

      _paintPlanet(
        canvas,
        position,
        radius,
        body.color,
        texture,
        lightDirection,
        body.hasAtmosphere,
      );
      _paintLabel(canvas, position, body.name, textStyle);
    }
  }

  double _orbitalAngle(OrbitalBody body, double progress) {
    // Orbit math: phase + time-based rotation to keep motion subtle but alive.
    return math.pi * 2 * (body.phase + progress * body.speed);
  }

  Offset _orbitalPosition(Offset center, double radius, double angle) {
    // Circular orbit based on center, radius, and angle.
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);
    return Offset(x, y);
  }

  void _paintPlanet(
    Canvas canvas,
    Offset position,
    double radius,
    Color color,
    ui.Image? texture,
    Offset lightDirection,
    bool hasAtmosphere,
  ) {
    final glowPaint = Paint()
      ..color = color.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        OrbitalConstants.planetGlowBlur,
      );
    canvas.drawCircle(
      position,
      radius * OrbitalConstants.planetGlowRadiusMultiplier,
      glowPaint,
    );

    final planetRect = Rect.fromCircle(center: position, radius: radius);
    if (texture != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(planetRect));
      paintImage(
        canvas: canvas,
        rect: planetRect,
        image: texture,
        fit: BoxFit.cover,
      );
      canvas.restore();
      _paintLighting(canvas, planetRect, lightDirection);
    } else {
      final planetPaint = Paint()..color = color;
      canvas.drawCircle(position, radius, planetPaint);
    }

    if (hasAtmosphere) {
      final atmospherePaint = Paint()
        ..color = OrbitalConstants.atmosphereColor.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          OrbitalConstants.atmosphereBlur,
        );
      canvas.drawCircle(
        position,
        radius * OrbitalConstants.atmosphereRadiusMultiplier,
        atmospherePaint,
      );
    }
  }

  void _paintLighting(Canvas canvas, Rect planetRect, Offset lightDirection) {
    final shader = RadialGradient(
      center: Alignment(lightDirection.dx, lightDirection.dy),
      radius: 1.1,
      colors: [Colors.transparent, Colors.black.withOpacity(0.55)],
      stops: const [0.45, 1.0],
    ).createShader(planetRect);

    final paint = Paint()..shader = shader;
    canvas.drawOval(planetRect, paint);
  }

  void _paintLabel(
    Canvas canvas,
    Offset position,
    String label,
    TextStyle style,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = position.translate(
      OrbitalConstants.labelOffset,
      -OrbitalConstants.labelOffset,
    );
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant OrbitalPainter oldDelegate) {
    return oldDelegate.scale != scale ||
        oldDelegate.offset != offset ||
        oldDelegate.textures != textures ||
        oldDelegate.progress != progress;
  }
}
