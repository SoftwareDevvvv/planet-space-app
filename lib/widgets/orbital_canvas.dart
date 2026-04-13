import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../painters/orbital_painter.dart';
import '../models/orbital_body.dart';
import '../utils/orbital_constants.dart';

class OrbitalCanvas extends StatefulWidget {
  const OrbitalCanvas({
    super.key,
    required this.scale,
    required this.offset,
    required this.onTransformChanged,
    required this.onPlanetTap,
  });

  final double scale;
  final Offset offset;
  final void Function(double scale, Offset offset) onTransformChanged;
  final void Function(OrbitalBody? body, Offset? worldPosition) onPlanetTap;

  @override
  State<OrbitalCanvas> createState() => _OrbitalCanvasState();
}

class _OrbitalCanvasState extends State<OrbitalCanvas>
    with SingleTickerProviderStateMixin {
  late double _scale;
  late Offset _offset;
  late double _startScale;
  late Offset _startOffset;
  bool _isMousePanning = false;
  Offset _mousePanStart = Offset.zero;
  Offset _mouseStartOffset = Offset.zero;
  bool _didMove = false;
  final Map<String, ui.Image> _textures = {};
  late final AnimationController _orbitController;
  double _orbitCycles = 0;

  @override
  void initState() {
    super.initState();
    _scale = widget.scale;
    _offset = widget.offset;
    _startScale = _scale;
    _startOffset = _offset;
    _loadTextures();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: OrbitalConstants.orbitAnimationSeconds),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _orbitCycles += 1;
          });
        }
      })
      ..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrbitalCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scale != widget.scale || oldWidget.offset != widget.offset) {
      _scale = widget.scale;
      _offset = widget.offset;
    }
  }

  void _onScaleStart(ScaleStartDetails details) {
    _startScale = _scale;
    _startOffset = _offset;
    _didMove = false;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final isScaling =
        (details.scale - 1.0).abs() > OrbitalConstants.scaleEpsilon;
    final nextScale = (_startScale * details.scale).clamp(
      OrbitalConstants.minScale,
      OrbitalConstants.maxScale,
    );

    // Pan with one finger; when scaling, keep the focal point anchored.
    final nextOffset = isScaling
        ? details.focalPoint -
              (details.focalPoint - _startOffset) / _startScale * nextScale
        : _offset + details.focalPointDelta;

    if (isScaling || details.focalPointDelta.distance > 0.5) {
      _didMove = true;
    }

    setState(() {
      _scale = nextScale;
      _offset = nextOffset;
    });
    widget.onTransformChanged(_scale, _offset);
  }

  void _onPointerDown(PointerDownEvent event) {
    if (event.kind != ui.PointerDeviceKind.mouse) {
      return;
    }
    if (event.buttons != kPrimaryMouseButton) {
      return;
    }
    _isMousePanning = true;
    _mousePanStart = event.position;
    _mouseStartOffset = _offset;
    _didMove = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isMousePanning) {
      return;
    }
    final delta = event.position - _mousePanStart;
    if (delta.distance > 0.5) {
      _didMove = true;
    }
    final nextOffset = _mouseStartOffset + delta;
    setState(() {
      _offset = nextOffset;
    });
    widget.onTransformChanged(_scale, _offset);
  }

  void _onPointerUp(PointerUpEvent event) {
    _isMousePanning = false;
  }

  void _onTapUp(TapUpDetails details) {
    if (_didMove) {
      _didMove = false;
      return;
    }
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.size;
    if (size == null) {
      widget.onPlanetTap(null, null);
      return;
    }

    final hit = _hitTestPlanet(details.localPosition, size);
    widget.onPlanetTap(hit?.body, hit?.worldPosition);
  }

  _PlanetHit? _hitTestPlanet(Offset localPosition, Size size) {
    final center = size.center(Offset.zero);
    final shortestSide = size.shortestSide;
    final orbitSpacing = shortestSide * OrbitalConstants.orbitSpacingFraction;
    final innerRadius = shortestSide * OrbitalConstants.innerOrbitFraction;
    final progress = _orbitController.value + _orbitCycles;

    _PlanetHit? best;
    var bestDistance = double.infinity;

    for (final body in OrbitalConstants.bodies) {
      final orbitRadius = innerRadius + orbitSpacing * body.orbitIndex;
      final angle = math.pi * 2 * (body.phase + progress * body.speed);
      final worldPosition = Offset(
        center.dx + orbitRadius * math.cos(angle),
        center.dy + orbitRadius * math.sin(angle),
      );
      final screenPosition =
          (worldPosition - center) * _scale + center + _offset;
      final radius =
          shortestSide * OrbitalConstants.planetRadiusFraction * body.sizeMultiplier;
      final hitRadius = math.max(28.0, radius * _scale * 2.2);
      final distance = (localPosition - screenPosition).distance;
      if (distance <= hitRadius && distance < bestDistance) {
        bestDistance = distance;
        best = _PlanetHit(body: body, worldPosition: worldPosition);
      }
    }

    return best;
  }

  Future<void> _loadTextures() async {
    for (final body in OrbitalConstants.bodies) {
      if (body.textureAsset == null) {
        continue;
      }
      final image = await _loadImage(body.textureAsset!);
      if (!mounted) {
        return;
      }
      setState(() {
        _textures[body.textureAsset!] = image;
      });
    }
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (context, child) {
        return Listener(
          onPointerDown: _onPointerDown,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            onTapUp: _onTapUp,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: OrbitalPainter(
                  scale: _scale,
                  offset: _offset,
                  textures: _textures,
                  progress: _orbitController.value + _orbitCycles,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlanetHit {
  const _PlanetHit({required this.body, required this.worldPosition});

  final OrbitalBody body;
  final Offset worldPosition;
}
