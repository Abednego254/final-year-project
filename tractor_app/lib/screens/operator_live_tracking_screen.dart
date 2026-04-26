import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';

/// Shown when an operator presses "Start Job".
/// Opens a Google Map centred on the operator's current GPS position,
/// broadcasts the position in real-time via Socket.io, and updates the
/// on-screen map as the device moves.
class OperatorLiveTrackingScreen extends StatefulWidget {
  final int tractorId;
  final int bookingId;

  const OperatorLiveTrackingScreen({
    super.key,
    required this.tractorId,
    required this.bookingId,
  });

  @override
  State<OperatorLiveTrackingScreen> createState() =>
      _OperatorLiveTrackingScreenState();
}

class _OperatorLiveTrackingScreenState
    extends State<OperatorLiveTrackingScreen> {
  final SocketService _socketService = SocketService();
  final Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription<Position>? _positionStream;

  LatLng? _currentPosition;
  bool _isBroadcasting = false;

  // -----------------------------------------------------------------
  // Lifecycle
  // -----------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _stopTracking();
    super.dispose();
  }

  // -----------------------------------------------------------------
  // GPS helpers
  // -----------------------------------------------------------------

  Future<void> _initLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Location permission is required to broadcast your position.'),
          backgroundColor: Colors.red,
        ));
      }
      return;
    }

    setState(() => _isBroadcasting = false);

    // Get initial position quickly.
    const LocationSettings initSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
    );
    final pos = await Geolocator.getCurrentPosition(
        locationSettings: initSettings);
    if (mounted) {
      setState(() => _currentPosition = LatLng(pos.latitude, pos.longitude));
    }

    // Start broadcasting immediately.
    _startTracking();
  }

  void _startTracking() {
    setState(() => _isBroadcasting = true);

    const LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _positionStream =
        Geolocator.getPositionStream(locationSettings: settings).listen(
      (Position pos) async {
        final latLng = LatLng(pos.latitude, pos.longitude);

        // Emit to backend.
        _socketService.emitLocation(
            widget.tractorId, pos.latitude, pos.longitude);

        if (!mounted) return;
        setState(() => _currentPosition = latLng);

        // Move camera.
        final controller = await _mapController.future;
        controller.animateCamera(CameraUpdate.newLatLng(latLng));
      },
    );
  }

  Future<void> _stopTracking() async {
    await _positionStream?.cancel();
    _positionStream = null;
    await _socketService.stopBroadcastingLocation();
    if (mounted) setState(() => _isBroadcasting = false);
  }

  // -----------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Tracking – Booking #${widget.bookingId}',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Chip(
              avatar: Icon(
                _isBroadcasting ? Icons.wifi_tethering : Icons.wifi_off,
                size: 16,
                color: Colors.white,
              ),
              label: Text(
                _isBroadcasting ? 'LIVE' : 'PAUSED',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              backgroundColor: _isBroadcasting ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      body: _currentPosition == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.green),
                  const SizedBox(height: 16),
                  Text('Acquiring GPS signal…',
                      style: GoogleFonts.inter(color: Colors.grey.shade600)),
                ],
              ),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 16,
                  ),
                  onMapCreated: (controller) =>
                      _mapController.complete(controller),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('tractor'),
                      position: _currentPosition!,
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueGreen),
                      infoWindow: InfoWindow(
                          title: 'Tractor #${widget.tractorId}',
                          snippet: 'Your current position'),
                    ),
                  },
                ),
                // Bottom action card
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
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}\n'
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: Icon(
                              _isBroadcasting
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_fill,
                            ),
                            label: Text(
                              _isBroadcasting
                                  ? 'Pause Broadcasting'
                                  : 'Resume Broadcasting',
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isBroadcasting
                                  ? Colors.orange
                                  : Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            onPressed: () {
                              if (_isBroadcasting) {
                                _stopTracking();
                              } else {
                                _startTracking();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
