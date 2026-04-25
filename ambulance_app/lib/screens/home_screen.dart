import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as app_auth;
import '../providers/ambulance_provider.dart';
import '../providers/hospital_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final authProvider =
          Provider.of<app_auth.AuthProvider>(context, listen: false);
      final ambProvider =
          Provider.of<AmbulanceProvider>(context, listen: false);
      final hospProvider =
          Provider.of<HospitalProvider>(context, listen: false);

      // Use user UID as ambulance ID
      if (authProvider.user != null) {
        ambProvider.setAmbulanceId(authProvider.user!.uid);
      }
      ambProvider.listenToAmbulance();
      hospProvider.listenToHospitals();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<app_auth.AuthProvider>(context);
    final ambulance = Provider.of<AmbulanceProvider>(context);
    final hospital = Provider.of<HospitalProvider>(context);
    final isActive = ambulance.isTracking;
    final selectedHospital = hospital.selectedHospital;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🚑 Ambulance Control'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFF6B7280)),
            onPressed: () async {
              if (ambulance.isTracking) {
                await ambulance.endRoute();
              }
              await auth.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E1A), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),

                // ─── Status Card ───────────────────────────
                _buildStatusCard(isActive),
                const SizedBox(height: 20),

                // ─── Hospital Card ─────────────────────────
                _buildHospitalCard(selectedHospital, ambulance),
                const SizedBox(height: 20),

                // ─── ETA & Distance ────────────────────────
                if (isActive && selectedHospital != null)
                  _buildInfoRow(ambulance),
                if (isActive && selectedHospital != null)
                  const SizedBox(height: 20),

                // ─── Error Display ─────────────────────────
                if (ambulance.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ambulance.error!,
                            style: const TextStyle(
                                color: Color(0xFFEF4444), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                const Spacer(),

                // ─── Action Button ─────────────────────────
                _buildActionButton(isActive, selectedHospital, ambulance),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isActive) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? const Color(0xFFEF4444).withOpacity(0.5)
              : const Color(0xFF22C55E).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          if (isActive)
            BoxShadow(
              color: const Color(0xFFEF4444).withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        children: [
          // Animated status indicator
          ScaleTransition(
            scale: isActive ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? const Color(0xFFEF4444).withOpacity(0.2)
                    : const Color(0xFF22C55E).withOpacity(0.2),
              ),
              child: Icon(
                isActive
                    ? Icons.emergency_rounded
                    : Icons.check_circle_outline_rounded,
                color: isActive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF22C55E),
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AMBULANCE STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'ACTIVE — EN ROUTE' : 'INACTIVE — STANDBY',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: isActive
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF22C55E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHospitalCard(
      dynamic selectedHospital, AmbulanceProvider ambulance) {
    return GestureDetector(
      onTap: ambulance.isTracking
          ? null
          : () => Navigator.pushNamed(context, '/hospitals'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: const Color(0xFF3B82F6).withOpacity(0.15),
              ),
              child: const Icon(
                Icons.local_hospital_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DESTINATION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedHospital != null
                        ? selectedHospital.name
                        : 'Tap to select hospital',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: selectedHospital != null
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                  if (selectedHospital != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.bed_rounded,
                          size: 14,
                          color: selectedHospital.availableBeds > 0
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${selectedHospital.availableBeds} beds',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Icon(
                          Icons.monitor_heart_rounded,
                          size: 14,
                          color: selectedHospital.icuAvailable
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          selectedHospital.icuAvailable
                              ? 'ICU Ready'
                              : 'ICU Full',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (!ambulance.isTracking)
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF6B7280)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(AmbulanceProvider ambulance) {
    return Row(
      children: [
        Expanded(
          child: _infoTile(
            icon: Icons.route_rounded,
            label: 'DISTANCE',
            value: '${ambulance.distance.toStringAsFixed(1)} km',
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _infoTile(
            icon: Icons.timer_rounded,
            label: 'ETA',
            value: '${ambulance.eta.toStringAsFixed(0)} min',
            color: const Color(0xFFF59E0B),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _infoTile(
            icon: Icons.speed_rounded,
            label: 'SPEED',
            value:
                '${(ambulance.currentPosition?.speed ?? 0 * 3.6).toStringAsFixed(0)} km/h',
            color: const Color(0xFF22C55E),
          ),
        ),
      ],
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      bool isActive, dynamic selectedHospital, AmbulanceProvider ambulance) {
    if (isActive) {
      // END ROUTE button
      return SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: () => ambulance.endRoute(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: const Color(0xFFEF4444).withOpacity(0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.stop_circle_rounded, size: 24),
              SizedBox(width: 10),
              Text(
                'END ROUTE',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // START ROUTE button
    final canStart = selectedHospital != null;
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: canStart
            ? () => ambulance.startRoute(selectedHospital)
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              canStart ? const Color(0xFF22C55E) : const Color(0xFF374151),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF374151),
          disabledForegroundColor: const Color(0xFF6B7280),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: canStart ? 8 : 0,
          shadowColor: const Color(0xFF22C55E).withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              canStart
                  ? Icons.play_circle_filled_rounded
                  : Icons.block_rounded,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              canStart ? 'START ROUTE' : 'SELECT HOSPITAL FIRST',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
