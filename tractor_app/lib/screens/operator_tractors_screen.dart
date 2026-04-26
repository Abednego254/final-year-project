import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../services/operator_service.dart';

class OperatorTractorsScreen extends StatefulWidget {
  const OperatorTractorsScreen({super.key});

  @override
  State<OperatorTractorsScreen> createState() => _OperatorTractorsScreenState();
}

class _OperatorTractorsScreenState extends State<OperatorTractorsScreen> {
  final OperatorService _operatorService = OperatorService();
  List<dynamic> _tractors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyTractors();
  }

  Future<void> _fetchMyTractors() async {
    setState(() => _isLoading = true);
    try {
      final tractors = await _operatorService.getMyTractors();
      setState(() => _tractors = tractors);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleTractorStatus(int tractorId, bool isAvailable) async {
    final status = isAvailable ? 'available' : 'busy';
    try {
      await _operatorService.updateTractorStatus(tractorId, status);
      _fetchMyTractors();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red));
      }
    }
  }

  // ── Set Location ──────────────────────────────────────────────────────
  /// Opens a full-screen map picker so the operator can pin the tractor's
  /// current or parked location. After confirming, it saves to the backend.
  Future<void> _showSetLocationSheet(int tractorId, String tractorModel) async {
    // 1. Acquire current GPS as a starting point for the map.
    LatLng? pickedPosition;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return _SetLocationSheet(
          tractorId: tractorId,
          tractorModel: tractorModel,
          onSave: (lat, lng) async {
            pickedPosition = LatLng(lat, lng);
          },
        );
      },
    );

    if (pickedPosition == null) return; // user cancelled

    // 2. Persist to backend.
    try {
      await _operatorService.updateTractorLocation(
          tractorId, pickedPosition!.latitude, pickedPosition!.longitude);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location saved! Farmers can now see your tractor.',
              style: GoogleFonts.inter()),
          backgroundColor: Colors.green,
        ));
        _fetchMyTractors(); // refresh to show updated coords
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red));
      }
    }
  }

  // ── Register Tractor ──────────────────────────────────────────────────
  void _showRegisterTractorDialog(BuildContext context) {
    final modelController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Register Tractor',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelController,
              decoration: InputDecoration(
                labelText: 'Tractor Model',
                hintText: 'e.g., John Deere',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: licenseController,
              decoration: InputDecoration(
                labelText: 'License Plate',
                hintText: 'e.g., KCA 123A',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              try {
                await _operatorService.registerTractor(
                    modelController.text, licenseController.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Tractor Registered Successfully',
                          style: GoogleFonts.inter()),
                      backgroundColor: Colors.green));
                  _fetchMyTractors();
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Error: $e', style: GoogleFonts.inter()),
                      backgroundColor: Colors.red));
                }
              }
            },
            child: Text('Register',
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title:
            Text('My Tractors', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _tractors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.agriculture,
                          size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No tractors registered yet.',
                          style: GoogleFonts.inter(
                              fontSize: 18, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: Colors.green,
                  onRefresh: _fetchMyTractors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tractors.length,
                    itemBuilder: (context, index) {
                      final t = _tractors[index];
                      final isAvailable = t['status'] == 'available';
                      final hasLocation =
                          t['latitude'] != null && t['longitude'] != null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Top row: info + status toggle ──
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t['model'],
                                          style: GoogleFonts.outfit(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          t['license_plate'],
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: Colors.grey.shade600),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.green
                                                    .withValues(alpha: 0.1)
                                                : Colors.red
                                                    .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isAvailable ? 'AVAILABLE' : 'BUSY',
                                            style: GoogleFonts.inter(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: isAvailable
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isAvailable,
                                    activeThumbColor: Colors.green,
                                    onChanged: (value) =>
                                        _toggleTractorStatus(t['id'], value),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              // ── Location row ──
                              Row(
                                children: [
                                  Icon(
                                    hasLocation
                                        ? Icons.location_on
                                        : Icons.location_off,
                                    size: 16,
                                    color: hasLocation
                                        ? Colors.teal
                                        : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      hasLocation
                                          ? 'Location: ${double.parse(t['latitude'].toString()).toStringAsFixed(5)}, '
                                              '${double.parse(t['longitude'].toString()).toStringAsFixed(5)}'
                                          : 'No location set — farmers cannot see this tractor on the map',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: hasLocation
                                            ? Colors.teal.shade700
                                            : Colors.grey.shade500,
                                        fontStyle: hasLocation
                                            ? FontStyle.normal
                                            : FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // ── Set / Update Location button ──
                              SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: OutlinedButton.icon(
                                  icon: Icon(
                                    hasLocation
                                        ? Icons.edit_location_alt
                                        : Icons.add_location_alt,
                                    size: 18,
                                    color: Colors.teal.shade700,
                                  ),
                                  label: Text(
                                    hasLocation
                                        ? 'Update Location'
                                        : 'Set Location',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        color: Colors.teal.shade300),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _showSetLocationSheet(
                                      t['id'], t['model']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRegisterTractorDialog(context),
        backgroundColor: Colors.green,
        tooltip: 'Register New Tractor',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet with an interactive Google Map pin picker
// ─────────────────────────────────────────────────────────────────────────────
class _SetLocationSheet extends StatefulWidget {
  final int tractorId;
  final String tractorModel;
  final Future<void> Function(double lat, double lng) onSave;

  const _SetLocationSheet({
    required this.tractorId,
    required this.tractorModel,
    required this.onSave,
  });

  @override
  State<_SetLocationSheet> createState() => _SetLocationSheetState();
}

class _SetLocationSheetState extends State<_SetLocationSheet> {
  final Completer<GoogleMapController> _mapController = Completer();
  LatLng? _pickedLocation;
  bool _acquiring = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _goToCurrentLocation();
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _acquiring = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // Fall back to Nairobi if permission denied
        setState(() {
          _pickedLocation = const LatLng(-1.286389, 36.817223);
          _acquiring = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final myPos = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _pickedLocation = myPos;
        _acquiring = false;
      });

      final controller = await _mapController.future;
      controller.animateCamera(
          CameraUpdate.newCameraPosition(CameraPosition(target: myPos, zoom: 15)));
    } catch (e) {
      setState(() {
        _pickedLocation = const LatLng(-1.286389, 36.817223);
        _acquiring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ── Handle ──
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // ── Header ──
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Set Tractor Location',
                        style: GoogleFonts.outfit(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(widget.tractorModel,
                        style: GoogleFonts.inter(
                            color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          // ── Instruction banner ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app, color: Colors.teal.shade700, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Tap anywhere on the map to drop a pin at the tractor\'s current location.',
                    style: GoogleFonts.inter(
                        fontSize: 13, color: Colors.teal.shade800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Map ──
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: _acquiring
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: Colors.teal))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _pickedLocation!,
                            zoom: 15,
                          ),
                          onMapCreated: (c) => _mapController.complete(c),
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          zoomControlsEnabled: false,
                          onTap: (LatLng tapped) {
                            setState(() => _pickedLocation = tapped);
                          },
                          markers: _pickedLocation == null
                              ? {}
                              : {
                                  Marker(
                                    markerId: const MarkerId('picked'),
                                    position: _pickedLocation!,
                                    icon:
                                        BitmapDescriptor.defaultMarkerWithHue(
                                            BitmapDescriptor.hueGreen),
                                    infoWindow: InfoWindow(
                                        title: widget.tractorModel,
                                        snippet: 'Tractor location'),
                                  ),
                                },
                        ),
                ),
              ],
            ),
          ),
          // ── Coordinates preview ──
          if (_pickedLocation != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  const Icon(Icons.location_pin,
                      color: Colors.teal, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Pin: ${_pickedLocation!.latitude.toStringAsFixed(5)}, '
                    '${_pickedLocation!.longitude.toStringAsFixed(5)}',
                    style: GoogleFonts.inter(
                        fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
          // ── Confirm button ──
          Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  _saving ? 'Saving…' : 'Confirm Location',
                  style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                onPressed: _pickedLocation == null || _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        final nav = Navigator.of(context);
                        await widget.onSave(
                          _pickedLocation!.latitude,
                          _pickedLocation!.longitude,
                        );
                        if (mounted) nav.pop();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
