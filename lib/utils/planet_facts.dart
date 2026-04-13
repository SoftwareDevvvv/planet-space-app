import '../models/orbital_body.dart';

class PlanetFacts {
  const PlanetFacts({
    required this.type,
    required this.radiusKm,
    required this.massEarths,
    required this.gravity,
    required this.dayHours,
    required this.yearDays,
    required this.moons,
    required this.escapeVelocityKmPerSec,
    required this.albedo,
    required this.summary,
    required this.atmosphere,
    required this.avgTempC,
    required this.tiltDeg,
  });

  final String type;
  final double radiusKm;
  final double massEarths;
  final double gravity;
  final double dayHours;
  final double yearDays;
  final int moons;
  final double escapeVelocityKmPerSec;
  final double albedo;
  final String summary;
  final String atmosphere;
  final double avgTempC;
  final double tiltDeg;
}

class PlanetFactsData {
  static final Map<String, PlanetFacts> byName = {
    'MERCURY': const PlanetFacts(
      type: 'Rocky',
      radiusKm: 2439.7,
      massEarths: 0.055,
      gravity: 3.7,
      dayHours: 1407.6,
      yearDays: 88.0,
      moons: 0,
      escapeVelocityKmPerSec: 4.25,
      albedo: 0.12,
      summary:
          'A scorched, cratered world with extreme day-night swings and only a whisper-thin exosphere.',
      atmosphere: 'Trace exosphere',
      avgTempC: 167,
      tiltDeg: 0.03,
    ),
    'VENUS': const PlanetFacts(
      type: 'Rocky',
      radiusKm: 6051.8,
      massEarths: 0.815,
      gravity: 8.87,
      dayHours: 5832.5,
      yearDays: 224.7,
      moons: 0,
      escapeVelocityKmPerSec: 10.36,
      albedo: 0.75,
      summary:
          'A veiled furnace with a runaway greenhouse effect, crushing pressures, and sulfuric clouds.',
      atmosphere: 'CO2, N2 (dense)',
      avgTempC: 464,
      tiltDeg: 177.4,
    ),
    'EARTH': const PlanetFacts(
      type: 'Rocky',
      radiusKm: 6371.0,
      massEarths: 1.0,
      gravity: 9.81,
      dayHours: 23.93,
      yearDays: 365.25,
      moons: 1,
      escapeVelocityKmPerSec: 11.19,
      albedo: 0.30,
      summary:
          'A blue world with liquid oceans, a protective atmosphere, and the only known life-bearing biosphere.',
      atmosphere: 'N2, O2',
      avgTempC: 15,
      tiltDeg: 23.4,
    ),
    'MARS': const PlanetFacts(
      type: 'Rocky',
      radiusKm: 3389.5,
      massEarths: 0.107,
      gravity: 3.71,
      dayHours: 24.62,
      yearDays: 687.0,
      moons: 2,
      escapeVelocityKmPerSec: 5.03,
      albedo: 0.25,
      summary:
          'A cold desert planet with towering volcanoes, vast canyons, and a thin, dusty atmosphere.',
      atmosphere: 'CO2 (thin)',
      avgTempC: -63,
      tiltDeg: 25.2,
    ),
    'JUPITER': const PlanetFacts(
      type: 'Gas Giant',
      radiusKm: 69911,
      massEarths: 317.8,
      gravity: 24.79,
      dayHours: 9.93,
      yearDays: 4332.6,
      moons: 95,
      escapeVelocityKmPerSec: 59.5,
      albedo: 0.50,
      summary:
          'The solar system’s giant, wrapped in turbulent bands and storms, with a powerful magnetic field.',
      atmosphere: 'H2, He',
      avgTempC: -110,
      tiltDeg: 3.1,
    ),
    'SATURN': const PlanetFacts(
      type: 'Gas Giant',
      radiusKm: 58232,
      massEarths: 95.2,
      gravity: 10.44,
      dayHours: 10.7,
      yearDays: 10759,
      moons: 146,
      escapeVelocityKmPerSec: 35.5,
      albedo: 0.34,
      summary:
          'A golden giant with spectacular rings, fast winds, and an extended family of icy moons.',
      atmosphere: 'H2, He',
      avgTempC: -140,
      tiltDeg: 26.7,
    ),
    'URANUS': const PlanetFacts(
      type: 'Ice Giant',
      radiusKm: 25362,
      massEarths: 14.5,
      gravity: 8.69,
      dayHours: 17.24,
      yearDays: 30688,
      moons: 27,
      escapeVelocityKmPerSec: 21.3,
      albedo: 0.30,
      summary:
          'A pale, tilted ice giant with methane haze and a faint ring system.',
      atmosphere: 'H2, He, CH4',
      avgTempC: -195,
      tiltDeg: 97.8,
    ),
    'NEPTUNE': const PlanetFacts(
      type: 'Ice Giant',
      radiusKm: 24622,
      massEarths: 17.1,
      gravity: 11.15,
      dayHours: 16.11,
      yearDays: 60182,
      moons: 14,
      escapeVelocityKmPerSec: 23.5,
      albedo: 0.29,
      summary:
          'A deep-blue world with fierce winds and dynamic storms at the edge of the system.',
      atmosphere: 'H2, He, CH4',
      avgTempC: -200,
      tiltDeg: 28.3,
    ),
  };

  static PlanetFacts forBody(OrbitalBody body) {
    return byName[body.name] ??
        const PlanetFacts(
          type: 'Planet',
          radiusKm: 0,
          massEarths: 0,
          gravity: 0,
          dayHours: 0,
          yearDays: 0,
          moons: 0,
          escapeVelocityKmPerSec: 0,
          albedo: 0,
          summary: 'No data available.',
          atmosphere: 'Unknown',
          avgTempC: 0,
          tiltDeg: 0,
        );
  }
}
