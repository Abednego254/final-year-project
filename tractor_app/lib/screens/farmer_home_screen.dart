import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/tractor_provider.dart';
import '../services/booking_service.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final BookingService _bookingService = BookingService();

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

  void _showBookingSheet(BuildContext context, dynamic tractor) {
    _selectedTractorId = tractor['id'];
    _acres = 1.0;
    _scheduledDate = DateTime.now().add(const Duration(days: 1));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double estimatedPrice = _acres * 3000.0; // 3000 KES per acre

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 24, right: 24, top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Book Tractor', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.agriculture, color: Colors.green, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tractor #${tractor['id']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Model: ${tractor['model']}', style: GoogleFonts.inter(color: Colors.grey.shade700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Farm Size:', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text('${_acres.toStringAsFixed(1)} Acres', style: GoogleFonts.inter(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.green,
                      thumbColor: Colors.green.shade700,
                      overlayColor: Colors.green.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _acres,
                      min: 0.5,
                      max: 20.0,
                      divisions: 39,
                      label: _acres.toStringAsFixed(1),
                      onChanged: (val) => setModalState(() => _acres = val),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                       title: Text('Scheduled Date', style: GoogleFonts.inter(fontSize: 14, color: Colors.grey.shade600)),
                       subtitle: Text('${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                       trailing: const Icon(Icons.calendar_month, color: Colors.green),
                       onTap: () async {
                         final dt = await showDatePicker(
                           context: context,
                           initialDate: _scheduledDate,
                           firstDate: DateTime.now(),
                           lastDate: DateTime.now().add(const Duration(days: 30)),
                           builder: (context, child) {
                             return Theme(
                               data: Theme.of(context).copyWith(
                                 colorScheme: const ColorScheme.light(primary: Colors.green),
                               ),
                               child: child!,
                             );
                           }
                         );
                         if (dt != null) {
                           setModalState(() => _scheduledDate = dt);
                         }
                       },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Estimated Total', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                      Text('KES ${estimatedPrice.toStringAsFixed(0)}', style: GoogleFonts.outfit(fontSize: 24, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _isBooking
                      ? const Center(child: CircularProgressIndicator(color: Colors.green))
                      : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
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
                                    SnackBar(content: Text('Booking created! Proceed to Pay in the Bookings tab.', style: GoogleFonts.inter()), backgroundColor: Colors.green),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red),
                                  );
                                }
                              } finally {
                                setModalState(() => _isBooking = false);
                              }
                            },
                            child: Text('Confirm Booking', style: GoogleFonts.inter(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                  const SizedBox(height: 32),
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
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        color: Colors.green,
        onRefresh: () async {
          await Provider.of<TractorProvider>(context, listen: false).fetchAvailableTractors();
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.green.shade700,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Text(
                  'Ready to farm, ${user?.name?.split(' ').first ?? "Farmer"}?',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.green.shade600, Colors.green.shade800],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(Icons.agriculture, size: 150, color: Colors.white.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Available Tractors',
                  style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
            ),
            Consumer<TractorProvider>(
              builder: (context, tractorProvider, child) {
                if (tractorProvider.tractors.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40.0),
                        child: Column(
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No tractors available right now.',
                              style: GoogleFonts.inter(color: Colors.grey.shade600, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tractor = tractorProvider.tractors[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _showBookingSheet(context, tractor),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(Icons.agriculture, size: 40, color: Colors.green.shade600),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            tractor['model'] ?? 'Standard Tractor',
                                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.star, size: 16, color: Colors.orange.shade400),
                                              Text(' 4.8 (120 reviews)', style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade600)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text('KES 3,000 / Acre', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)),
                                      child: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: tractorProvider.tractors.length,
                    ),
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)), // padding for bottom nav
          ],
        ),
      ),
    );
  }
}
