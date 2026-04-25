import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/hospital_model.dart';
import '../providers/hospital_provider.dart';
import '../providers/ambulance_provider.dart';

class HospitalSelectionScreen extends StatelessWidget {
  const HospitalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hospitalProvider = Provider.of<HospitalProvider>(context);
    final ambulanceProvider =
        Provider.of<AmbulanceProvider>(context, listen: false);

    // Sort by distance if we have current position
    List<HospitalModel> hospitals;
    final pos = ambulanceProvider.currentPosition;
    if (pos != null) {
      hospitals =
          hospitalProvider.sortedByDistance(pos.latitude, pos.longitude);
    } else {
      hospitals = hospitalProvider.hospitals;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Hospital'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
          ),
        ),
        child: hospitalProvider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
              )
            : hospitals.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: hospitals.length,
                    itemBuilder: (context, index) {
                      final hospital = hospitals[index];
                      return _HospitalCard(
                        hospital: hospital,
                        currentLat: pos?.latitude,
                        currentLon: pos?.longitude,
                        isSelected:
                            hospitalProvider.selectedHospital?.id == hospital.id,
                        onTap: () {
                          hospitalProvider.selectHospital(hospital);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.local_hospital_rounded,
            size: 64,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'No hospitals found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please add hospitals in Firestore',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final HospitalModel hospital;
  final double? currentLat;
  final double? currentLon;
  final bool isSelected;
  final VoidCallback onTap;

  const _HospitalCard({
    required this.hospital,
    this.currentLat,
    this.currentLon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isReady = hospital.isReady;
    final statusColor =
        isReady ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final distance = (currentLat != null && currentLon != null)
        ? hospital.distanceFrom(currentLat!, currentLon!)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withOpacity(0.12)
              : const Color(0xFF1F2937).withOpacity(0.7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6).withOpacity(0.5)
                : statusColor.withOpacity(0.25),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF3B82F6).withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Row ──────────────────────────
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: statusColor.withOpacity(0.15),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: statusColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          hospital.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (distance != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${distance.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                      const Text(
                        'km',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // ─── Info Row ────────────────────────────
            Row(
              children: [
                _infoChip(
                  icon: Icons.bed_rounded,
                  label: '${hospital.availableBeds} Beds',
                  color: hospital.availableBeds > 0
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
                const SizedBox(width: 12),
                _infoChip(
                  icon: Icons.monitor_heart_rounded,
                  label: hospital.icuAvailable ? 'ICU Ready' : 'ICU Full',
                  color: hospital.icuAvailable
                      ? const Color(0xFF22C55E)
                      : const Color(0xFFEF4444),
                ),
                const Spacer(),
                if (isSelected)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: Color(0xFF3B82F6), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'SELECTED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3B82F6),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
