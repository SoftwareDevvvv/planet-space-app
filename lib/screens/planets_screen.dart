import 'package:flutter/material.dart';

import '../models/orbital_body.dart';
import '../utils/orbital_constants.dart';
import '../utils/planet_facts.dart';
import 'planet_detail_screen.dart';

class PlanetsScreen extends StatelessWidget {
  const PlanetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final planets = _planets();
    return Container(
      color: const Color(0xFF05070E),
      child: Stack(
        children: [
          const _GridBackdrop(),
          const _StarField(),
          SafeArea(
            child: Column(
              children: [
                const _HeaderTitle(),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final crossAxisCount = width >= 900
                          ? 4
                          : width >= 700
                              ? 3
                              : 2;
                      final childAspectRatio = width >= 900 ? 0.78 : 0.7;
                      final horizontalPadding = width >= 900 ? 32.0 : 20.0;
                      return GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: 16,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: planets.length,
                        itemBuilder: (context, index) {
                          return _PlanetGridCard(body: planets[index]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<OrbitalBody> _planets() {
    final bodies = OrbitalConstants.bodies
        .where((body) => body.textureAsset != null)
        .toList();
    bodies.sort((a, b) => a.orbitIndex.compareTo(b.orbitIndex));
    return bodies;
  }
}

class _HeaderTitle extends StatelessWidget {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'ALL PLANETS',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.2,
              ),
        ),
      ),
    );
  }
}

class _PlanetGridCard extends StatelessWidget {
  const _PlanetGridCard({required this.body});

  final OrbitalBody body;

  @override
  Widget build(BuildContext context) {
    final facts = PlanetFactsData.forBody(body);
    return ClipPath(
      clipper: const _CutCornerClipper(cut: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PlanetDetailScreen(body: body),
              ),
            );
          },
          splashColor: body.color.withOpacity(0.2),
          highlightColor: body.color.withOpacity(0.08),
          child: CustomPaint(
            foregroundPainter: _CornerAccentPainter(color: body.color),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0D1628), Color(0xFF070A12)],
                ),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: CustomPaint(painter: _ScanlinePainter()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _TypeBadge(label: facts.type),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(child: _PlanetThumb(body: body)),
                        const Spacer(),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            body.name,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanetThumb extends StatelessWidget {
  const _PlanetThumb({required this.body});

  final OrbitalBody body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 118,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: body.color.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipOval(
        child: body.textureAsset == null
            ? Container(color: body.color)
            : Image.asset(body.textureAsset!, fit: BoxFit.cover),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _StarPainter()));
  }
}

class _GridBackdrop extends StatelessWidget {
  const _GridBackdrop();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _GridGlowPainter(),
        child: Container(),
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final stars = <Offset>[
      const Offset(0.12, 0.14),
      const Offset(0.32, 0.1),
      const Offset(0.56, 0.16),
      const Offset(0.8, 0.12),
      const Offset(0.18, 0.3),
      const Offset(0.42, 0.28),
      const Offset(0.7, 0.26),
      const Offset(0.88, 0.32),
      const Offset(0.2, 0.5),
      const Offset(0.45, 0.48),
      const Offset(0.78, 0.46),
      const Offset(0.1, 0.7),
      const Offset(0.3, 0.78),
      const Offset(0.6, 0.72),
      const Offset(0.85, 0.74),
    ];

    for (final star in stars) {
      final position = Offset(star.dx * size.width, star.dy * size.height);
      final radius = star.dx * 1.6 + 1.2;
      paint.color = Colors.white.withOpacity(0.6);
      canvas.drawCircle(position, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CutCornerClipper extends CustomClipper<Path> {
  const _CutCornerClipper({required this.cut});

  final double cut;

  @override
  Path getClip(Size size) {
    final c = cut.clamp(0.0, size.shortestSide * 0.2).toDouble();
    return Path()
      ..moveTo(c, 0)
      ..lineTo(size.width - c, 0)
      ..lineTo(size.width, c)
      ..lineTo(size.width, size.height - c)
      ..lineTo(size.width - c, size.height)
      ..lineTo(c, size.height)
      ..lineTo(0, size.height - c)
      ..lineTo(0, c)
      ..close();
  }

  @override
  bool shouldReclip(covariant _CutCornerClipper oldClipper) {
    return oldClipper.cut != cut;
  }
}

class _ScanlinePainter extends CustomPainter {
  const _ScanlinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1.0;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerAccentPainter extends CustomPainter {
  _CornerAccentPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withOpacity(0.6);
    const inset = 8.0;
    const length = 18.0;

    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset + length, inset),
      paint,
    );
    canvas.drawLine(
      const Offset(inset, inset),
      const Offset(inset, inset + length),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - inset - length, inset),
      Offset(size.width - inset, inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, inset),
      Offset(size.width - inset, inset + length),
      paint,
    );

    canvas.drawLine(
      Offset(inset, size.height - inset),
      Offset(inset + length, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(inset, size.height - inset - length),
      Offset(inset, size.height - inset),
      paint,
    );

    canvas.drawLine(
      Offset(size.width - inset - length, size.height - inset),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - inset, size.height - inset - length),
      Offset(size.width - inset, size.height - inset),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerAccentPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _GridGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    const step = 38.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white.withOpacity(0.12), Colors.transparent],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.8, size.height * 0.2),
          radius: size.width * 0.6,
        ),
      );
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
