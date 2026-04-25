import 'package:cloud_firestore/cloud_firestore.dart';

class AmbulanceModel {
  final String id;
  final String status;
  final double latitude;
  final double longitude;
  final double speed;
  final String destinationHospital;
  final DateTime? updatedAt;

  AmbulanceModel({
    required this.id,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.destinationHospital,
    this.updatedAt,
  });

  bool get isActive => status == 'ACTIVE';

  factory AmbulanceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AmbulanceModel(
      id: id,
      status: data['status'] ?? 'INACTIVE',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      speed: (data['speed'] ?? 0.0).toDouble(),
      destinationHospital: data['destinationHospital'] ?? '',
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'speed': speed,
      'destinationHospital': destinationHospital,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory AmbulanceModel.empty(String id) {
    return AmbulanceModel(
      id: id,
      status: 'INACTIVE',
      latitude: 0.0,
      longitude: 0.0,
      speed: 0.0,
      destinationHospital: '',
    );
  }
}
