import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../services/socket_service.dart';

/// Shown when a farmer taps "Track Tractor" on an ongoing booking.
/// Listens to Socket.io for real-time tractor position updates and
/// animates a map marker as the tractor moves.
class FarmerLiveTrackingScreen extends StatefulWidget {
  final int tractorId;
  final int bookingId;
  final String? operatorName;

  const FarmerLiveTrackingScreen({
    super.key,
    required this.tractorId,
    required this.bookingId,
    this.operatorName,
  });

  @override
  State<FarmerLiveTrackingScreen> createState() =>
      _FarmerLiveTrackingScreenState();
}

class _FarmerLiveTrackingScreenState extends State<FarmerLiveTrackingScreen> {
  final SocketService _socketService = SocketService();
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _tractorPosition;
  bool _isConnected = false;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _socketService.stopListening(widget.tractorId);
    super.dispose();
  }

  void _startListening() {
    setState(() => _isConnected = true);

    _socketService.listenToLocation(widget.tractorId, (lat, lng) async {
      final newPos = LatLng(lat, lng);
      if (!mounted) return;

      setState(() {
        _tractorPosition = newPos;
        _lastUpdate = DateTime.now();
      });

      // Smoothly pan the camera to the new position.
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(newPos));
    });
  }

  String _timeSinceUpdate() {
    if (_lastUpdate == null) return 'Waiting for first update…';
    final diff = DateTime.now().difference(_lastUpdate!).inSeconds;
    if (diff < 5) return 'Just now';
    return '$diff seconds ago';
  }

  @override
  Widget build(BuildContext context) {
    // Default camera – Nairobi, Kenya (fallback until first update arrives)
    const LatLng defaultCenter = LatLng(-1.286389, 36.817223);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tracking: ${widget.operatorName ?? "Tractor #${widget.tractorId}"}',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Chip(
              avatar: const Icon(Icons.wifi_tethering, size: 16, color: Colors.white),
              label: Text(
                _isConnected ? 'LIVE' : 'CONNECTING',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              backgroundColor: _isConnected ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _tractorPosition ?? defaultCenter,
              zoom: 15,
            ),
            onMapCreated: (c) => _mapController.complete(c),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            markers: _tractorPosition == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId('tractor'),
                      position: _tractorPosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(
                        title: 'Tractor #${widget.tractorId}',
                        snippet: widget.operatorName != null
                            ? 'Operator: ${widget.operatorName}'
                            : 'Live position',
                      ),
                    ),
                  },
          ),
          // Status card at the bottom
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4))
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.agriculture,
                            color: Colors.green, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.operatorName != null
                                  ? 'Operator: ${widget.operatorName}'
                                  : 'Tractor #${widget.tractorId}',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _tractorPosition == null
                                  ? 'Waiting for tractor to broadcast…'
                                  : 'Last update: ${_timeSinceUpdate()}',
                              style: GoogleFonts.inter(
                                  color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_tractorPosition != null) ...[
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.green, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Lat: ${_tractorPosition!.latitude.toStringAsFixed(5)}, '
                          'Lng: ${_tractorPosition!.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Show a centred shimmer if waiting for very first update
          if (_tractorPosition == null)
            Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 16)
                    ]),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.green),
                    const SizedBox(width: 16),
                    Text('Waiting for tractor signal…',
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
