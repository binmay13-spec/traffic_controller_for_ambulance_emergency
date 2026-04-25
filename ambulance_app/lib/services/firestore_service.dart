import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ambulance_model.dart';
import '../models/hospital_model.dart';

/// Service for all Firestore read/write operations.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Ambulance Operations ────────────────────────────────────────

  /// Update ambulance GPS coordinates and speed in real-time.
  Future<void> updateAmbulanceLocation({
    required String ambulanceId,
    required double latitude,
    required double longitude,
    required double speed,
  }) async {
    await _db.collection('ambulance').doc(ambulanceId).set({
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Set ambulance status to ACTIVE or INACTIVE.
  Future<void> setAmbulanceStatus({
    required String ambulanceId,
    required String status,
    String? destinationHospital,
  }) async {
    final data = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (destinationHospital != null) {
      data['destinationHospital'] = destinationHospital;
    }
    if (status == 'INACTIVE') {
      data['speed'] = 0.0;
    }
    await _db
        .collection('ambulance')
        .doc(ambulanceId)
        .set(data, SetOptions(merge: true));
  }

  /// Stream real-time ambulance data for a specific ambulance.
  Stream<AmbulanceModel> getAmbulanceStream(String ambulanceId) {
    return _db
        .collection('ambulance')
        .doc(ambulanceId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        return AmbulanceModel.empty(ambulanceId);
      }
      return AmbulanceModel.fromFirestore(doc.data() ?? {}, doc.id);
    });
  }

  /// Stream all ambulances (for dashboard use).
  Stream<List<AmbulanceModel>> getAllAmbulancesStream() {
    return _db.collection('ambulance').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return AmbulanceModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  // ─── Hospital Operations ─────────────────────────────────────────

  /// Stream real-time hospital list.
  Stream<List<HospitalModel>> getHospitalsStream() {
    return _db.collection('hospital').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return HospitalModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Update hospital details (used by admin dashboard).
  Future<void> updateHospital({
    required String hospitalId,
    int? availableBeds,
    bool? icuAvailable,
    String? status,
  }) async {
    final data = <String, dynamic>{};
    if (availableBeds != null) data['availableBeds'] = availableBeds;
    if (icuAvailable != null) data['ICUAvailable'] = icuAvailable;
    if (status != null) data['status'] = status;
    await _db.collection('hospital').doc(hospitalId).update(data);
  }
}
