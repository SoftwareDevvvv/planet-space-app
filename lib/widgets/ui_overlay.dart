import 'package:flutter/material.dart';

import '../models/orbital_readout.dart';
import '../utils/orbital_constants.dart';

class UIOverlay extends StatelessWidget {
  const UIOverlay({super.key, required this.readout});

  final OrbitalReadout readout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OrbitalConstants.overlayPadding,
          OrbitalConstants.overlayPadding + 48,
          OrbitalConstants.overlayPadding,
          OrbitalConstants.overlayPadding,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _OverlayHeader(sector: readout.sectorLabel),
            _OverlayMetrics(readout: readout),
          ],
        ),
      ),
    );
  }
}

class _OverlayHeader extends StatelessWidget {
  const _OverlayHeader({required this.sector});

  final String sector;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT SECTOR',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.65),
                letterSpacing: 2.4,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          sector,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 1.8,
              ),
        ),
      ],
    );
  }
}

class _OverlayMetrics extends StatelessWidget {
  const _OverlayMetrics({required this.readout});

  final OrbitalReadout readout;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white.withOpacity(0.6),
          letterSpacing: 1.6,
        );
    final valueStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('HELIOCENTRIC COORD', style: labelStyle),
        const SizedBox(height: 6),
        Text(readout.distanceText, style: valueStyle),
      ],
    );
  }
}
