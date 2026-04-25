import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hospital_model.dart';
import '../services/firestore_service.dart';

/// Provider managing hospital list and selection state.
class HospitalProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<HospitalModel> _hospitals = [];
  HospitalModel? _selectedHospital;
  bool _isLoading = true;
  StreamSubscription? _hospitalSubscription;

  List<HospitalModel> get hospitals => _hospitals;
  HospitalModel? get selectedHospital => _selectedHospital;
  bool get isLoading => _isLoading;

  /// Begin listening to Firestore for real-time hospital updates.
  void listenToHospitals() {
    _hospitalSubscription?.cancel();
    _hospitalSubscription =
        _firestoreService.getHospitalsStream().listen((hospitals) {
      _hospitals = hospitals;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// Select a hospital as the emergency destination.
  void selectHospital(HospitalModel hospital) {
    _selectedHospital = hospital;
    notifyListeners();
  }

  /// Clear the selected hospital.
  void clearSelection() {
    _selectedHospital = null;
    notifyListeners();
  }

  /// Sort hospitals by distance from a given position.
  List<HospitalModel> sortedByDistance(double lat, double lon) {
    final sorted = List<HospitalModel>.from(_hospitals);
    sorted.sort((a, b) =>
        a.distanceFrom(lat, lon).compareTo(b.distanceFrom(lat, lon)));
    return sorted;
  }

  @override
  void dispose() {
    _hospitalSubscription?.cancel();
    super.dispose();
  }
}
