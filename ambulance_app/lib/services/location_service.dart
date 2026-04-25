import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Service for GPS location tracking with permission handling.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;

  /// Check and request location permissions.
  /// Returns true if permissions are granted and location services enabled.
  Future<bool> checkAndRequestPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get the current device position.
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Start continuous location tracking.
  /// [onUpdate] is called every time a new position is available.
  /// Uses a minimum distance filter of 5 meters to conserve battery.
  void startLocationUpdates(void Function(Position) onUpdate) {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters of movement
      ),
    ).listen(
      onUpdate,
      onError: (error) {
        // Silently handle stream errors
        print('Location stream error: $error');
      },
    );
  }

  /// Stop all location tracking.
  void stopLocationUpdates() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  /// Calculate distance between two coordinates in kilometers.
  double calculateDistanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000.0;
  }

  /// Check if location tracking is currently active.
  bool get isTracking => _positionSubscription != null;
}
