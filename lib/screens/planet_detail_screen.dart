import 'package:flutter/material.dart';

import '../models/orbital_body.dart';
import '../utils/planet_facts.dart';

class PlanetDetailScreen extends StatefulWidget {
  const PlanetDetailScreen({super.key, required this.body});

  final OrbitalBody body;

  @override
  State<PlanetDetailScreen> createState() => _PlanetDetailScreenState();
}

class _PlanetDetailScreenState extends State<PlanetDetailScreen> {
  static const double _appBarExpandedHeight = 150;
  late final ScrollController _controller;
  bool _showScrollHint = true;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_handleScrollHint);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScrollHint);
    _controller.dispose();
    super.dispose();
  }

  void _handleScrollHint() {
    if (!_showScrollHint) {
      return;
    }
    if (_controller.offset > 24) {
      setState(() {
        _showScrollHint = false;
      });
    }
  }

  double get _collapseProgress {
    final maxOffset = _appBarExpandedHeight - kToolbarHeight;
    if (!_controller.hasClients || maxOffset <= 0) {
      return 0.0;
    }
    return (_controller.offset / maxOffset).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final facts = PlanetFactsData.forBody(widget.body);
    return Scaffold(
      backgroundColor: const Color(0xFF05070E),
      body: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _HudGridPainter())),
          Positioned(
            top: 0,
            right: 10,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: _ScrollIndicator(controller: _controller),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: _showScrollHint ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: _ScrollHint(),
                  ),
                ),
              ),
            ),
          ),
          CustomScrollView(
            controller: _controller,
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: const Color(0xFF05070E),
                elevation: 0,
                scrolledUnderElevation: 0,
                surfaceTintColor: Colors.transparent,
                pinned: true,
                expandedHeight: _appBarExpandedHeight,
                titleSpacing: 24,
                title: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    final t = _collapseProgress;
                    return Opacity(
                      opacity: t,
                      child: Text(
                        widget.body.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                      ),
                    );
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          final t = _collapseProgress;
                          final opacity = 1 - t;
                          final translateY = (1 - opacity) * -18;
                          final scale = 1 - (t * 0.08);
                          return Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(0, translateY),
                              child: Transform.scale(
                                scale: scale,
                                alignment: Alignment.bottomLeft,
                                child: _HudHeader(
                                  name: widget.body.name,
                                  type: facts.type,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  80 + MediaQuery.of(context).padding.bottom,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isWide)
                      _DetailSplitLayout(
                        body: widget.body,
                        facts: facts,
                        subtitle: _subtitleFor(widget.body),
                        controller: _controller,
                      )
                    else
                      ..._detailStackChildren(widget.body, facts),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _subtitleFor(OrbitalBody body) {
    switch (body.name) {
      case 'MERCURY':
        return 'Swift Core';
      case 'VENUS':
        return 'Veiled Glow';
      case 'EARTH':
        return 'Home';
      case 'MARS':
        return 'Neighbor';
      case 'JUPITER':
        return 'Gas Giant';
      case 'SATURN':
        return 'Rings';
      case 'URANUS':
        return 'Ice Giant';
      case 'NEPTUNE':
        return 'Deep Blue';
      default:
        return 'Orbit';
    }
  }

  List<Widget> _detailStackChildren(OrbitalBody body, PlanetFacts facts) {
    return [
      _HeroParallax(controller: _controller, body: body),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 40,
        end: 180,
        alwaysVisible: true,
        child: Center(
          child: Text(
            _subtitleFor(body),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 1.2,
                ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      _ScrollReveal(
        controller: _controller,
        start: 80,
        end: 260,
        child: _DataSection(
          title: 'SYSTEM SNAPSHOT',
          child: Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _DataPill(
                label: 'DISTANCE',
                value: '${body.orbitalRadiusAu.toStringAsFixed(2)} AU',
              ),
              _DataPill(
                label: 'GRAVITY',
                value: '${(facts.gravity / 9.81).toStringAsFixed(2)} g',
              ),
              _DataPill(
                label: 'DAY LENGTH',
                value: '${(facts.dayHours / 24).toStringAsFixed(2)} d',
              ),
              _DataPill(
                label: 'YEAR LENGTH',
                value: '${(facts.yearDays / 365.25).toStringAsFixed(2)} yr',
              ),
              _DataPill(
                label: 'MOONS',
                value: '${facts.moons}',
              ),
              _DataPill(
                label: 'ESCAPE V',
                value: '${facts.escapeVelocityKmPerSec.toStringAsFixed(1)} km/s',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 24),
      _ScrollReveal(
        controller: _controller,
        start: 120,
        end: 320,
        child: _DataSection(
          title: 'MISSION BRIEF',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                facts.summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.78),
                      height: 1.6,
                    ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _DataPill(
                    label: 'ATMOSPHERE',
                    value: facts.atmosphere,
                  ),
                  _DataPill(
                    label: 'AVG TEMP',
                    value: '${facts.avgTempC.toStringAsFixed(0)} C',
                  ),
                  _DataPill(
                    label: 'AXIAL TILT',
                    value: '${facts.tiltDeg.toStringAsFixed(1)} deg',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 220,
        end: 420,
        child: _DataSection(
          title: 'ORBITAL DATA',
          child: Column(
            children: [
              _HudRow(
                label: 'ORBIT SPEED',
                value: body.orbitalVelocityKmPerSec.toStringAsFixed(2),
                unit: 'KM/S',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'YEAR LENGTH',
                value: facts.yearDays.toStringAsFixed(0),
                unit: 'DAYS',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'DAY LENGTH',
                value: facts.dayHours.toStringAsFixed(2),
                unit: 'HOURS',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 320,
        end: 520,
        child: _DataSection(
          title: 'PHYSICAL DATA',
          child: Column(
            children: [
              _HudRow(
                label: 'RADIUS',
                value: facts.radiusKm.toStringAsFixed(0),
                unit: 'KM',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'MASS',
                value: facts.massEarths.toStringAsFixed(3),
                unit: 'EARTHS',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'GRAVITY',
                value: facts.gravity.toStringAsFixed(2),
                unit: 'M/S^2',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 420,
        end: 660,
        child: _DataSection(
          title: 'SURFACE DATA',
          child: Column(
            children: [
              _HudRow(
                label: 'ALBEDO',
                value: '${(facts.albedo * 100).toStringAsFixed(0)}',
                unit: '%',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'MOONS',
                value: '${facts.moons}',
                unit: 'COUNT',
              ),
              const _HudDivider(),
              _HudRow(
                label: 'ESCAPE V',
                value: facts.escapeVelocityKmPerSec.toStringAsFixed(2),
                unit: 'KM/S',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 520,
        end: 780,
        child: _DataSection(
          title: 'COMPARATIVE METRICS',
          child: Column(
            children: [
              _StatBar(
                label: 'RADIUS SCALE',
                value: _normalized(facts.radiusKm, 69911),
              ),
              const SizedBox(height: 12),
              _StatBar(
                label: 'MASS SCALE',
                value: _normalized(facts.massEarths, 317.8),
              ),
              const SizedBox(height: 12),
              _StatBar(
                label: 'GRAVITY SCALE',
                value: _normalized(facts.gravity, 24.79),
              ),
              const SizedBox(height: 12),
              _StatBar(
                label: 'YEAR LENGTH',
                value: _normalized(facts.yearDays, 60182),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 640,
        end: 940,
        child: _DataSection(
          title: 'SIGNAL LOG',
          child: Column(
            children: const [
              _SignalRow(
                time: 'T+00:12',
                message: 'Telemetry lock confirmed.',
              ),
              _HudDivider(),
              _SignalRow(
                time: 'T+01:03',
                message: 'Atmospheric profile resolved.',
              ),
              _HudDivider(),
              _SignalRow(
                time: 'T+02:44',
                message: 'Surface scan complete.',
              ),
              _HudDivider(),
              _SignalRow(
                time: 'T+03:12',
                message: 'Orbital corridor stable.',
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _ScrollReveal(
        controller: _controller,
        start: 760,
        end: 1120,
        child: _DataSection(
          title: 'MISSION TIMELINE',
          child: const _Timeline(),
        ),
      ),
    ];
  }
}

double _normalized(num value, num max) {
  if (max == 0) {
    return 0;
  }
  return (value / max).clamp(0.0, 1.0).toDouble();
}

class _DetailSplitLayout extends StatelessWidget {
  const _DetailSplitLayout({
    required this.body,
    required this.facts,
    required this.subtitle,
    required this.controller,
  });

  final OrbitalBody body;
  final PlanetFacts facts;
  final String subtitle;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: Column(
            children: [
              _HeroParallax(controller: controller, body: body),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 40,
                end: 180,
                alwaysVisible: true,
                child: Center(
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          letterSpacing: 1.2,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _ScrollReveal(
                controller: controller,
                start: 80,
                end: 260,
                child: _DataSection(
                  title: 'SYSTEM SNAPSHOT',
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 8,
                    children: [
                      _DataPill(
                        label: 'DISTANCE',
                        value: '${body.orbitalRadiusAu.toStringAsFixed(2)} AU',
                      ),
                      _DataPill(
                        label: 'GRAVITY',
                        value: '${(facts.gravity / 9.81).toStringAsFixed(2)} g',
                      ),
                      _DataPill(
                        label: 'DAY LENGTH',
                        value: '${(facts.dayHours / 24).toStringAsFixed(2)} d',
                      ),
                      _DataPill(
                        label: 'YEAR LENGTH',
                        value: '${(facts.yearDays / 365.25).toStringAsFixed(2)} yr',
                      ),
                      _DataPill(
                        label: 'MOONS',
                        value: '${facts.moons}',
                      ),
                      _DataPill(
                        label: 'ESCAPE V',
                        value: '${facts.escapeVelocityKmPerSec.toStringAsFixed(1)} km/s',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _ScrollReveal(
                controller: controller,
                start: 120,
                end: 320,
                child: _DataSection(
                  title: 'MISSION BRIEF',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        facts.summary,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.78),
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          _DataPill(
                            label: 'ATMOSPHERE',
                            value: facts.atmosphere,
                          ),
                          _DataPill(
                            label: 'AVG TEMP',
                            value: '${facts.avgTempC.toStringAsFixed(0)} C',
                          ),
                          _DataPill(
                            label: 'AXIAL TILT',
                            value: '${facts.tiltDeg.toStringAsFixed(1)} deg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _ScrollReveal(
                controller: controller,
                start: 220,
                end: 420,
                child: _DataSection(
                  title: 'ORBITAL DATA',
                  child: Column(
                    children: [
                      _HudRow(
                        label: 'ORBIT SPEED',
                        value: body.orbitalVelocityKmPerSec.toStringAsFixed(2),
                        unit: 'KM/S',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'YEAR LENGTH',
                        value: facts.yearDays.toStringAsFixed(0),
                        unit: 'DAYS',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'DAY LENGTH',
                        value: facts.dayHours.toStringAsFixed(2),
                        unit: 'HOURS',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 320,
                end: 520,
                child: _DataSection(
                  title: 'PHYSICAL DATA',
                  child: Column(
                    children: [
                      _HudRow(
                        label: 'RADIUS',
                        value: facts.radiusKm.toStringAsFixed(0),
                        unit: 'KM',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'MASS',
                        value: facts.massEarths.toStringAsFixed(3),
                        unit: 'EARTHS',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'GRAVITY',
                        value: facts.gravity.toStringAsFixed(2),
                        unit: 'M/S^2',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 420,
                end: 660,
                child: _DataSection(
                  title: 'SURFACE DATA',
                  child: Column(
                    children: [
                      _HudRow(
                        label: 'ALBEDO',
                        value: '${(facts.albedo * 100).toStringAsFixed(0)}',
                        unit: '%',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'MOONS',
                        value: '${facts.moons}',
                        unit: 'COUNT',
                      ),
                      const _HudDivider(),
                      _HudRow(
                        label: 'ESCAPE V',
                        value: facts.escapeVelocityKmPerSec.toStringAsFixed(2),
                        unit: 'KM/S',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 520,
                end: 780,
                child: _DataSection(
                  title: 'COMPARATIVE METRICS',
                  child: Column(
                    children: [
                      _StatBar(
                        label: 'RADIUS SCALE',
                        value: _normalized(facts.radiusKm, 69911),
                      ),
                      const SizedBox(height: 12),
                      _StatBar(
                        label: 'MASS SCALE',
                        value: _normalized(facts.massEarths, 317.8),
                      ),
                      const SizedBox(height: 12),
                      _StatBar(
                        label: 'GRAVITY SCALE',
                        value: _normalized(facts.gravity, 24.79),
                      ),
                      const SizedBox(height: 12),
                      _StatBar(
                        label: 'YEAR LENGTH',
                        value: _normalized(facts.yearDays, 60182),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 640,
                end: 940,
                child: _DataSection(
                  title: 'SIGNAL LOG',
                  child: Column(
                    children: const [
                      _SignalRow(
                        time: 'T+00:12',
                        message: 'Telemetry lock confirmed.',
                      ),
                      _HudDivider(),
                      _SignalRow(
                        time: 'T+01:03',
                        message: 'Atmospheric profile resolved.',
                      ),
                      _HudDivider(),
                      _SignalRow(
                        time: 'T+02:44',
                        message: 'Surface scan complete.',
                      ),
                      _HudDivider(),
                      _SignalRow(
                        time: 'T+03:12',
                        message: 'Orbital corridor stable.',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _ScrollReveal(
                controller: controller,
                start: 760,
                end: 1120,
                child: _DataSection(
                  title: 'MISSION TIMELINE',
                  child: const _Timeline(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScrollReveal extends StatefulWidget {
  const _ScrollReveal({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.alwaysVisible = false,
  });

  final ScrollController controller;
  final double start;
  final double end;
  final Widget child;
  final bool alwaysVisible;

  @override
  State<_ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<_ScrollReveal>
    with AutomaticKeepAliveClientMixin {
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant _ScrollReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleScroll);
      widget.controller.addListener(_handleScroll);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleScroll);
    super.dispose();
  }

  void _handleScroll() {
    if (_revealed) {
      return;
    }
    final offset = widget.controller.hasClients ? widget.controller.offset : 0.0;
    final t = ((offset - widget.start) / (widget.end - widget.start))
        .clamp(0.0, 1.0);
    if (t >= 1.0) {
      setState(() {
        _revealed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final offset =
            widget.controller.hasClients ? widget.controller.offset : 0.0;
        final t = widget.alwaysVisible
            ? 1.0
            : _revealed
                ? 1.0
                : ((offset - widget.start) / (widget.end - widget.start))
                    .clamp(0.0, 1.0);
        final eased = Curves.easeOutCubic.transform(t);
        final translateY = (1 - eased) * 18;
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: widget.child,
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ScrollIndicator extends StatelessWidget {
  const _ScrollIndicator({required this.controller});

  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final position = controller.hasClients ? controller.position : null;
        final maxExtent = position?.maxScrollExtent ?? 0.0;
        final offset = controller.hasClients ? controller.offset : 0.0;
        final t = maxExtent == 0 ? 0.0 : (offset / maxExtent).clamp(0.0, 1.0);
        return LayoutBuilder(
          builder: (context, constraints) {
            final trackHeight = constraints.maxHeight;
            final indicatorHeight = (trackHeight * 0.22).clamp(40.0, 90.0);
            final travel = trackHeight - indicatorHeight;
            final top = travel * t;

            return Stack(
              children: [
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                Positioned(
                  top: top,
                  child: Container(
                    width: 3,
                    height: indicatorHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF9AD2FF), Color(0xFF3C7DFF)],
                      ),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5EA1FF).withOpacity(0.45),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _HeroParallax extends StatelessWidget {
  const _HeroParallax({required this.controller, required this.body});

  final ScrollController controller;
  final OrbitalBody body;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final offset = controller.hasClients ? controller.offset : 0.0;
        final translateY = (offset * -0.08).clamp(-18.0, 18.0).toDouble();
        final scale = (1.0 - offset * 0.0004).clamp(0.94, 1.0).toDouble();
        final scanProgress = ((offset * 0.002) % 1.0).toDouble();
        return Transform.translate(
          offset: Offset(0, translateY),
          child: Transform.scale(
            scale: scale,
            child: Center(
              child: _PlanetHero(
                body: body,
                scanProgress: scanProgress,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanetHero extends StatelessWidget {
  const _PlanetHero({required this.body, required this.scanProgress});

  final OrbitalBody body;
  final double scanProgress;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = (screenWidth * 0.62).clamp(220.0, 320.0);
    final scanHeight = size * 1.4;
    final scanOffset = (scanProgress * scanHeight) - (scanHeight * 0.5);
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: body.color.withOpacity(0.35),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipOval(
                child: body.textureAsset == null
                    ? Container(color: body.color)
                    : Image.asset(
                        body.textureAsset!,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.12),
                    width: 1.2,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: ClipOval(
                  child: Transform.translate(
                    offset: Offset(0, scanOffset),
                    child: SizedBox(
                      width: size,
                      height: scanHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white.withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.35, 0.5, 0.65],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudHeader extends StatelessWidget {
  const _HudHeader({required this.name, required this.type});

  final String name;
  final String type;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
          ),
        ),
        _TypeChip(label: type),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withOpacity(0.75),
              letterSpacing: 1.0,
            ),
      ),
    );
  }
}

class _HudFrame extends StatelessWidget {
  const _HudFrame({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: const _HudCutClipper(cut: 14),
      child: CustomPaint(
        foregroundPainter: _HudCornerPainter(),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0D1628), Color(0xFF070A12)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.6,
                    ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _HudRow extends StatelessWidget {
  const _HudRow({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
        ),
        Text(
          '$value $unit',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DataSection extends StatelessWidget {
  const _DataSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 18,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1.6,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DataPill extends StatelessWidget {
  const _DataPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white.withOpacity(0.6),
                  letterSpacing: 1.0,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}


class _StatBar extends StatelessWidget {
  const _StatBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.6),
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF76B6FF), Color(0xFF6EE7FF)],
                  ),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SignalRow extends StatelessWidget {
  const _SignalRow({required this.time, required this.message});

  final String time;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _TimelineStep(
          title: 'Approach vector aligned',
          detail: 'Auto-correct for drift and radiation pressure.',
        ),
        _TimelineStep(
          title: 'Orbital insertion',
          detail: 'Stabilize path for continuous mapping window.',
        ),
        _TimelineStep(
          title: 'Surface scan',
          detail: 'Capture multi-spectrum tiles and thermal sweep.',
        ),
        _TimelineStep(
          title: 'Data relay',
          detail: 'Transmit compressed stack to the relay network.',
        ),
      ],
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 38,
                color: Colors.white.withOpacity(0.2),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withOpacity(0.65),
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HudDivider extends StatelessWidget {
  const _HudDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Divider(
        height: 1,
        color: Colors.white.withOpacity(0.08),
      ),
    );
  }
}

class _ScrollHint extends StatefulWidget {
  const _ScrollHint();

  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}

class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _offset = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SCROLL',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.75),
                    letterSpacing: 2.0,
                  ),
            ),
            const SizedBox(width: 10),
            AnimatedBuilder(
              animation: _offset,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _offset.value),
                  child: child,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.7)),
                  Icon(Icons.keyboard_arrow_down,
                      color: Colors.white.withOpacity(0.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HudGridPainter extends CustomPainter {
  const _HudGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0;
    const step = 36.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HudCutClipper extends CustomClipper<Path> {
  const _HudCutClipper({required this.cut});

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
  bool shouldReclip(covariant _HudCutClipper oldClipper) {
    return oldClipper.cut != cut;
  }
}

class _HudCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = Colors.white.withOpacity(0.45);
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
