import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ambulance_model.dart';
import '../models/hospital_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

/// Provider managing ambulance tracking state,
/// GPS location updates, and route lifecycle.
class AmbulanceProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  String _ambulanceId = 'ambulance_01';
  AmbulanceModel? _ambulance;
  bool _isTracking = false;
  Position? _currentPosition;
  double _distance = 0.0;
  double _eta = 0.0;
  String? _error;
  StreamSubscription? _ambulanceSubscription;

  // ─── Getters ─────────────────────────────────────────────────────
  AmbulanceModel? get ambulance => _ambulance;
  bool get isTracking => _isTracking;
  Position? get currentPosition => _currentPosition;
  double get distance => _distance;
  double get eta => _eta;
  String? get error => _error;
  String get ambulanceId => _ambulanceId;

  /// Set the ambulance document ID (e.g., based on user UID).
  void setAmbulanceId(String id) {
    _ambulanceId = id;
    notifyListeners();
  }

  /// Begin listening to Firestore for this ambulance's data.
  void listenToAmbulance() {
    _ambulanceSubscription?.cancel();
    _ambulanceSubscription =
        _firestoreService.getAmbulanceStream(_ambulanceId).listen(
      (ambulance) {
        _ambulance = ambulance;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to listen to ambulance data: $e';
        notifyListeners();
      },
    );
  }

  /// Start an emergency route toward the given hospital.
  Future<void> startRoute(HospitalModel hospital) async {
    _error = null;

    // Check GPS permissions
    bool hasPermission = await _locationService.checkAndRequestPermissions();
    if (!hasPermission) {
      _error = 'Location permission denied. Please enable GPS.';
      notifyListeners();
      return;
    }

    _isTracking = true;

    // Set ambulance status to ACTIVE in Firestore
    await _firestoreService.setAmbulanceStatus(
      ambulanceId: _ambulanceId,
      status: 'ACTIVE',
      destinationHospital: hospital.id,
    );

    // Start continuous GPS tracking
    _locationService.startLocationUpdates((Position position) {
      _currentPosition = position;

      // Calculate distance to destination hospital
      _distance = _locationService.calculateDistanceKm(
        position.latitude,
        position.longitude,
        hospital.latitude,
        hospital.longitude,
      );

      // Calculate ETA in minutes (speed in m/s converted to km/h)
      final speedKmH = position.speed * 3.6;
      if (speedKmH > 2.0) {
        _eta = (_distance / speedKmH) * 60.0; // minutes
      } else {
        _eta = _distance > 0 ? (_distance / 40.0) * 60.0 : 0.0; // Assume 40 km/h
      }

      // Push location to Firestore
      _firestoreService.updateAmbulanceLocation(
        ambulanceId: _ambulanceId,
        latitude: position.latitude,
        longitude: position.longitude,
        speed: speedKmH,
      );

      notifyListeners();
    });

    notifyListeners();
  }

  /// End the current emergency route.
  Future<void> endRoute() async {
    _isTracking = false;
    _locationService.stopLocationUpdates();

    await _firestoreService.setAmbulanceStatus(
      ambulanceId: _ambulanceId,
      status: 'INACTIVE',
    );

    _distance = 0.0;
    _eta = 0.0;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    _ambulanceSubscription?.cancel();
    super.dispose();
  }
}
