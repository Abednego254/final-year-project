import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/tractor_provider.dart';
import '../services/booking_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  late GoogleMapController mapController;
  final BookingService _bookingService = BookingService();

  final LatLng _center = const LatLng(-1.2921, 36.8219); // Default to Nairobi
  int? _selectedTractorId;
  double _acres = 1.0;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TractorProvider>(context, listen: false).fetchAvailableTractors();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _showBookingSheet(BuildContext context) {
    if (_selectedTractorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap a tractor marker first to select it.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double estimatedPrice = _acres * 3000.0; // 3000 KES per acre

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16, right: 16, top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Book Tractor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text('Selected Tractor ID: $_selectedTractorId'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Farm Size (Acres):'),
                      Slider(
                        value: _acres,
                        min: 0.5,
                        max: 20.0,
                        divisions: 39,
                        label: _acres.toStringAsFixed(1),
                        onChanged: (val) => setModalState(() => _acres = val),
                      ),
                      Text('${_acres.toStringAsFixed(1)} ac'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                     title: const Text('Date'),
                     subtitle: Text('${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}'),
                     trailing: const Icon(Icons.calendar_today),
                     onTap: () async {
                       final dt = await showDatePicker(
                         context: context,
                         initialDate: _scheduledDate,
                         firstDate: DateTime.now(),
                         lastDate: DateTime.now().add(const Duration(days: 30)),
                       );
                       if (dt != null) {
                         setModalState(() => _scheduledDate = dt);
                       }
                     },
                  ),
                  const SizedBox(height: 16),
                  Text('Estimated Price: KES ${estimatedPrice.toStringAsFixed(0)}', 
                    style: const TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 24),
                  _isBooking
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              setModalState(() => _isBooking = true);
                              try {
                                await _bookingService.createBooking(
                                  _selectedTractorId!,
                                  _scheduledDate.toIso8601String(),
                                  estimatedPrice,
                                );
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Booking created! Please proceed to payment.'), backgroundColor: Colors.green),
                                  );
                                  // TODO: Navigate or trigger M-Pesa STK push
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                                  );
                                }
                              } finally {
                                setModalState(() => _isBooking = false);
                              }
                            },
                            child: const Text('Confirm Booking'),
                          ),
                        ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${user?.name ?? "Farmer"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Consumer<TractorProvider>(
        builder: (context, tractorProvider, child) {
          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 11.0,
            ),
            markers: tractorProvider.markers.map((m) {
              return m.copyWith(
                onTapParam: () {
                  setState(() {
                    _selectedTractorId = int.tryParse(m.markerId.value);
                  });
                },
              );
            }).toSet(),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookingSheet(context),
        label: const Text('Request Tractor'),
        icon: const Icon(Icons.agriculture),
      ),
    );
  }
}
