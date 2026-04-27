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
  /// Fetches the operator's current GPS location and sets it as the tractor's location.
  Future<void> _updateLocationToCurrent(int tractorId) async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _operatorService.updateTractorLocation(
          tractorId, pos.latitude, pos.longitude);
          
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Location updated to your current position!',
              style: GoogleFonts.inter()),
          backgroundColor: Colors.green,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e', style: GoogleFonts.inter()),
            backgroundColor: Colors.red));
      }
    } finally {
      _fetchMyTractors();
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
                                  onPressed: () => _updateLocationToCurrent(
                                      t['id']),
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

