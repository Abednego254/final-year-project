import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/socket_service.dart';

/// Shown when a farmer taps "View Location" on a tractor card while browsing.
///
/// It shows the tractor's last known position (loaded from the DB via the
/// parent screen) and simultaneously subscribes to live socket updates so the
/// marker moves in real-time if the operator is currently broadcasting.
class TractorPreviewMapScreen extends StatefulWidget {
  final int tractorId;
  final String tractorModel;
  final String? operatorName;
  final double? initialLat;
  final double? initialLng;
  final VoidCallback? onBookNow;

  const TractorPreviewMapScreen({
    super.key,
    required this.tractorId,
    required this.tractorModel,
    this.operatorName,
    this.initialLat,
    this.initialLng,
    this.onBookNow,
  });

  @override
  State<TractorPreviewMapScreen> createState() =>
      _TractorPreviewMapScreenState();
}

class _TractorPreviewMapScreenState extends State<TractorPreviewMapScreen> {
  final SocketService _socketService = SocketService();
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _tractorPosition;
  bool _isLive = false;
  DateTime? _lastUpdate;

  @override
  void initState() {
    super.initState();

    // Seed with the last-known position from the DB (already fetched by the list)
    if (widget.initialLat != null && widget.initialLng != null) {
      _tractorPosition = LatLng(widget.initialLat!, widget.initialLng!);
    }

    // Also subscribe to live updates — if the operator is actively broadcasting
    // those will start arriving and override the static DB position.
    _socketService.listenToLocation(widget.tractorId, (lat, lng) async {
      final newPos = LatLng(lat, lng);
      if (!mounted) return;
      setState(() {
        _tractorPosition = newPos;
        _isLive = true;
        _lastUpdate = DateTime.now();
      });
      final controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLng(newPos));
    });
  }

  @override
  void dispose() {
    _socketService.stopListening(widget.tractorId);
    super.dispose();
  }

  String _lastUpdateText() {
    if (_lastUpdate == null) return 'Last known location (static)';
    final diff = DateTime.now().difference(_lastUpdate!).inSeconds;
    if (diff < 5) return 'Updated just now';
    return 'Updated ${diff}s ago';
  }

  @override
  Widget build(BuildContext context) {
    // Fallback centre — Nairobi if no position at all
    const LatLng nairobiDefault = LatLng(-1.286389, 36.817223);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.tractorModel,
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            if (widget.operatorName != null)
              Text('Operator: ${widget.operatorName}',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Chip(
              avatar: Icon(
                _isLive ? Icons.wifi_tethering : Icons.location_on,
                size: 14,
                color: Colors.white,
              ),
              label: Text(
                _isLive ? 'LIVE' : 'STATIC',
                style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
              backgroundColor: _isLive ? Colors.green : Colors.blueGrey,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── MAP ──────────────────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _tractorPosition ?? nairobiDefault,
              zoom: _tractorPosition != null ? 14 : 10,
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
                        title: widget.tractorModel,
                        snippet: _isLive ? '🟢 Broadcasting live' : '📍 Last known position',
                      ),
                    ),
                  },
          ),

          // ── NO POSITION FALLBACK ─────────────────────────────────────────
          if (_tractorPosition == null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 16)
                    ]),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.location_off, color: Colors.grey, size: 40),
                    const SizedBox(height: 8),
                    Text('Location not yet available.',
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade700, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('The operator has not broadcast a position yet.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
            ),

          // ── BOTTOM INFO + BOOK BUTTON ────────────────────────────────────
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
                  // Status row
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
                              widget.tractorModel,
                              style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(
                                  _isLive
                                      ? Icons.wifi_tethering
                                      : Icons.location_on,
                                  size: 13,
                                  color: _isLive
                                      ? Colors.green
                                      : Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _lastUpdateText(),
                                    style: GoogleFonts.inter(
                                        color: Colors.grey.shade600,
                                        fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_tractorPosition != null) ...[
                    const Divider(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_pin,
                            color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${_tractorPosition!.latitude.toStringAsFixed(5)}, '
                          '${_tractorPosition!.longitude.toStringAsFixed(5)}',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                  // Rate badge
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rate',
                          style: GoogleFonts.inter(
                              color: Colors.grey.shade600, fontSize: 13)),
                      Text('KES 3,000 / Acre',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Book Now button
                  if (widget.onBookNow != null)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_outline,
                            color: Colors.white),
                        label: Text('Book This Tractor',
                            style: GoogleFonts.inter(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        onPressed: () {
                          Navigator.pop(context); // close map
                          widget.onBookNow!(); // open booking sheet
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
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
