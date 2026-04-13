import 'package:flutter/material.dart';

import '../models/orbital_readout.dart';
import '../models/orbital_body.dart';
import '../utils/orbital_constants.dart';
import '../utils/orbital_metrics.dart';
import '../utils/planet_facts.dart';
import '../widgets/orbital_canvas.dart';
import '../widgets/controls_sheet.dart';
import '../widgets/recenter_button.dart';
import '../widgets/ui_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'planet_detail_screen.dart';
import 'settings_screen.dart';

class OrbitalScreen extends StatefulWidget {
  const OrbitalScreen({super.key});

  @override
  State<OrbitalScreen> createState() => _OrbitalScreenState();
}

class _OrbitalScreenState extends State<OrbitalScreen>
    with SingleTickerProviderStateMixin {
  double _scale = OrbitalConstants.defaultScale;
  Offset _offset = Offset.zero;
  OrbitalBody? _selectedBody;
  late final AnimationController _focusController;
  bool _tutorialScheduled = false;
  Animation<double>? _scaleAnimation;
  Animation<Offset>? _offsetAnimation;
  double _animationStartScale = OrbitalConstants.defaultScale;
  Offset _animationStartOffset = Offset.zero;

  void _handleTransformChanged(double scale, Offset offset) {
    setState(() {
      _scale = scale;
      _offset = offset;
    });
  }

  void _recenter() {
    setState(() {
      _scale = OrbitalConstants.defaultScale;
      _offset = Offset.zero;
      _selectedBody = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _maybeShowTutorial();
    _focusController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(() {
        setState(() {
          _scale = _scaleAnimation?.value ?? _scale;
          _offset = _offsetAnimation?.value ?? _offset;
        });
      });
  }

  Future<void> _maybeShowTutorial() async {
    if (_tutorialScheduled) return;
    _tutorialScheduled = true;
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool('controls_tutorial_seen') ?? false;
    if (hasSeen || !mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showControlsSheet(context).whenComplete(() {
        prefs.setBool('controls_tutorial_seen', true);
      });
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  void _animateTo(double targetScale, Offset targetOffset) {
    _focusController.stop();
    _animationStartScale = _scale;
    _animationStartOffset = _offset;
    _scaleAnimation = Tween<double>(
      begin: _animationStartScale,
      end: targetScale,
    ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOut));
    _offsetAnimation = Tween<Offset>(
      begin: _animationStartOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOut));
    _focusController.forward(from: 0);
  }

  void _handlePlanetTap(OrbitalBody? body, Offset? worldPosition) {
    if (body == null || worldPosition == null) {
      setState(() {
        _selectedBody = null;
      });
      return;
    }

    final targetScale = (_scale < 1.6 ? 1.8 : _scale).clamp(
      OrbitalConstants.minScale,
      OrbitalConstants.maxScale,
    );
    final size = MediaQuery.sizeOf(context);
    final center = size.center(Offset.zero);
    final targetOffset = -(worldPosition - center) * targetScale;

    setState(() {
      _selectedBody = body;
    });
    _animateTo(targetScale, targetOffset);
  }

  OrbitalReadout _buildReadout(Size size, double scale, Offset offset) {
    final shortestSide = size.shortestSide;
    final orbitSpacing = shortestSide * OrbitalConstants.orbitSpacingFraction;
    final innerRadius = shortestSide * OrbitalConstants.innerOrbitFraction;
    final earthOrbitPx =
        innerRadius + orbitSpacing * OrbitalConstants.earthOrbitIndex;
    final cameraWorldOffset = -offset / scale;
    final cameraDistanceAu = earthOrbitPx == 0
        ? 0.0
        : cameraWorldOffset.distance / earthOrbitPx;

    final sectorLabel = sectorForDistance(cameraDistanceAu);
    final distanceText = formatDistance(cameraDistanceAu);

    return OrbitalReadout(
      sectorLabel: sectorLabel,
      distanceText: distanceText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isWide = screenSize.width >= 900;
    final readout = _buildReadout(screenSize, _scale, _offset);
    final shouldShowRecenter =
        _offset.distance > OrbitalConstants.recenterThreshold ||
        (_scale - OrbitalConstants.defaultScale).abs() >
            OrbitalConstants.scaleEpsilon;
    final showRecenter = shouldShowRecenter && _selectedBody == null;

    return Container(
      color: const Color(0xFF05070E),
      child: Stack(
        children: [
          Positioned.fill(
            child: OrbitalCanvas(
              scale: _scale,
              offset: _offset,
              onTransformChanged: _handleTransformChanged,
              onPlanetTap: _handlePlanetTap,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(child: UIOverlay(readout: readout)),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 6, right: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TopActionButton(
                      icon: Icons.help_outline,
                      onPressed: () => showControlsSheet(context),
                    ),
                    const SizedBox(width: 8),
                    _TopActionButton(
                      icon: Icons.settings,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_selectedBody != null)
            Positioned.fill(
              child: SafeArea(
                child: Align(
                  alignment: isWide ? Alignment.centerRight : Alignment.bottomCenter,
                  child: isWide
                      ? Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: _PlanetQuickPanel(
                            body: _selectedBody!,
                            onClose: () => _handlePlanetTap(null, null),
                            onView: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PlanetDetailScreen(
                                    body: _selectedBody!,
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      : _PlanetQuickSheet(
                          body: _selectedBody!,
                          onClose: () => _handlePlanetTap(null, null),
                          onView: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => PlanetDetailScreen(
                                  body: _selectedBody!,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ),
          Positioned.fill(
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: AnimatedOpacity(
                  opacity: showRecenter ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 20, bottom: 20),
                    child: RecenterButton(
                      onPressed: _recenter,
                      isVisible: showRecenter,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  const _TopActionButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70),
        onPressed: onPressed,
      ),
    );
  }
}

class _PlanetQuickSheet extends StatelessWidget {
  const _PlanetQuickSheet({
    required this.body,
    required this.onClose,
    required this.onView,
  });

  final OrbitalBody body;
  final VoidCallback onClose;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final facts = PlanetFactsData.forBody(body);
    return AnimatedSlide(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    body.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                ),
              ],
            ),
            Text(
              facts.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _QuickChip(label: 'TYPE', value: facts.type),
                _QuickChip(
                  label: 'RADIUS',
                  value: '${facts.radiusKm.toStringAsFixed(0)} KM',
                ),
                _QuickChip(
                  label: 'GRAVITY',
                  value: '${facts.gravity.toStringAsFixed(2)} M/S^2',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('DESELECT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('VIEW DETAILS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetQuickPanel extends StatelessWidget {
  const _PlanetQuickPanel({
    required this.body,
    required this.onClose,
    required this.onView,
  });

  final OrbitalBody body;
  final VoidCallback onClose;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final facts = PlanetFactsData.forBody(body);
    return SizedBox(
      width: 320,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFF0B0F1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    body.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: onClose,
                ),
              ],
            ),
            Text(
              facts.summary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _QuickChip(label: 'TYPE', value: facts.type),
                _QuickChip(
                  label: 'RADIUS',
                  value: '${facts.radiusKm.toStringAsFixed(0)} KM',
                ),
                _QuickChip(
                  label: 'GRAVITY',
                  value: '${facts.gravity.toStringAsFixed(2)} M/S^2',
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('DESELECT'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D6BFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('VIEW DETAILS'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
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
