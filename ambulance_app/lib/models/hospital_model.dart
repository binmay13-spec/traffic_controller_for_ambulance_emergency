import 'dart:math';

class HospitalModel {
  final String id;
  final String name;
  final int availableBeds;
  final bool icuAvailable;
  final String status;
  final double latitude;
  final double longitude;

  HospitalModel({
    required this.id,
    required this.name,
    required this.availableBeds,
    required this.icuAvailable,
    required this.status,
    required this.latitude,
    required this.longitude,
  });

  bool get isReady => status == 'READY';

  factory HospitalModel.fromFirestore(Map<String, dynamic> data, String id) {
    final location = data['location'] as Map<String, dynamic>? ?? {};
    return HospitalModel(
      id: id,
      name: data['name'] ?? 'Unknown Hospital',
      availableBeds: data['availableBeds'] ?? 0,
      icuAvailable: data['ICUAvailable'] ?? false,
      status: data['status'] ?? 'BUSY',
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lon'] ?? 0.0).toDouble(),
    );
  }

  /// Calculate distance from given coordinates using the Haversine formula.
  /// Returns distance in kilometers.
  double distanceFrom(double lat, double lon) {
    const double earthRadius = 6371.0; // km
    final double dLat = _degToRad(latitude - lat);
    final double dLon = _degToRad(longitude - lon);
    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat)) *
            cos(_degToRad(latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degToRad(double deg) => deg * pi / 180.0;
}
