import '../utils/orbital_constants.dart';

String sectorForDistance(double distanceAu) {
  if (distanceAu < 0.8) {
    return 'CORE';
  }
  if (distanceAu < 1.7) {
    return 'INNER RIM';
  }
  return 'OUTER RIM';
}

String formatDistance(double distanceAu) {
  final km = distanceAu * OrbitalConstants.auKm;
  if (km >= 1e9) {
    return '${(km / 1e9).toStringAsFixed(2)}B KM';
  }
  if (km >= 1e6) {
    return '${(km / 1e6).toStringAsFixed(1)}M KM';
  }
  return '${km.toStringAsFixed(0)} KM';
}

