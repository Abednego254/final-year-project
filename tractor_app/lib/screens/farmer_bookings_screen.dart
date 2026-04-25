import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import '../services/socket_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/translations.dart';

class FarmerBookingsScreen extends StatefulWidget {
  const FarmerBookingsScreen({super.key});

  @override
  State<FarmerBookingsScreen> createState() => _FarmerBookingsScreenState();
}

class _FarmerBookingsScreenState extends State<FarmerBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
  final SocketService _socketService = SocketService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        _socketService.listenToNotifications(user.id!, 'farmer', (data) {
          if (!mounted) return;
          _fetchBookings(); // Refresh list to show new paid/cancelled status
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(data['title'] ?? 'Notice', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.blue)),
              content: Text(data['message'] ?? 'Booking updated.', style: GoogleFonts.inter()),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
              ],
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _socketService.stopListeningToNotifications(user.id!, 'farmer');
    }
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bookings = await _bookingService.getMyBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(int bookingId, String newStatus) async {
    try {
      showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
      await _bookingService.updateBookingStatus(bookingId, newStatus);
      if (mounted) Navigator.pop(context); // close loading
      _fetchBookings();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red));
      }
    }
  }

  void _payForBooking(int bookingId) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    
    final phoneController = TextEditingController(text: ''); 
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('M-Pesa Payment', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Enter your M-Pesa number to pay for this booking.', style: GoogleFonts.inter(color: Colors.grey.shade700)),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                hintText: '2547XXXXXXXX',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.phone, color: Colors.green),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
               Navigator.pop(ctx);
               if (phoneController.text.isEmpty) return;
               
               try {
                 showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
                 final res = await _paymentService.initiateStkPush(bookingId, phoneController.text);
                 if (!mounted) return;
                 Navigator.pop(context); // close loading
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'], style: GoogleFonts.inter()), backgroundColor: Colors.green));
                 _fetchBookings(); 
               } catch (e) {
                 if (!mounted) return;
                 Navigator.pop(context); // close loading
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: GoogleFonts.inter()), backgroundColor: Colors.red));
               }
            },
            child: Text('Pay Now', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  void _verifyPayment(int bookingId) async {
    try {
      showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.purple)), barrierDismissible: false);
      final res = await _paymentService.verifyPayment(bookingId);
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message'] ?? 'Verified.', style: GoogleFonts.inter()), 
        backgroundColor: (res['message'] ?? '').toString().toLowerCase().contains('success') ? Colors.green : Colors.blue
      ));
      _fetchBookings();
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // close loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString(), style: GoogleFonts.inter()), backgroundColor: Colors.red));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'accepted': return Colors.blue;
      case 'paid': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<AuthProvider>(context).user?.language ?? 'en';
    final isDark = Provider.of<AuthProvider>(context).user?.darkMode ?? false;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(Translations.get('bookings', lang), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        elevation: 0,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.green))
        : _bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No bookings found.', style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600)),
                ],
              )
            )
          : RefreshIndicator(
              color: Colors.green,
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final b = _bookings[index];
                  final statusColor = _getStatusColor(b['status']);
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Booking #${b['id']}', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  b['status'].toString().toUpperCase(),
                                  style: GoogleFonts.inter(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.person, size: 20, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text('Operator: ${b['operator_name'] ?? 'Unassigned'}', style: GoogleFonts.inter(color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today, size: 20, color: Colors.grey.shade600),
                              const SizedBox(width: 8),
                              Text('Date: ${DateTime.tryParse(b['scheduled_date'].toString())?.toLocal().toString().split(' ')[0] ?? ''}', style: GoogleFonts.inter(color: Colors.black87)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(Translations.get('payment', lang), style: GoogleFonts.inter(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                              Text('KES ${b['price']}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                            ],
                          ),
                          if (b['estimated_start_time'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 20, color: Colors.purple),
                                const SizedBox(width: 8),
                                Text('${Translations.get('estimated_start', lang)}: ${b['estimated_start_time']}', style: GoogleFonts.inter(color: Colors.purple, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                          if (b['completed_at'] != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
                                const SizedBox(width: 8),
                                Text(
                                  '${Translations.get('completed', lang)}: ${DateTime.tryParse(b['completed_at'].toString())?.toLocal().toString().split('.')[0] ?? ''}',
                                  style: GoogleFonts.inter(color: Colors.green.shade800, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                           if (b['status'] == 'pending') ...[
                             const SizedBox(height: 16),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.orange.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.orange.shade200)
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.hourglass_empty, color: Colors.orange.shade600),
                                   const SizedBox(width: 8),
                                   Expanded(child: Text('Waiting for the operator to accept this booking.', style: GoogleFonts.inter(color: Colors.orange.shade800))),
                                 ]
                               )
                             )
                           ],
                           if (b['status'] == 'accepted') ...[
                            const SizedBox(height: 16),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.blue.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.blue.shade200)
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.payment, color: Colors.blue.shade600),
                                   const SizedBox(width: 8),
                                   Expanded(child: Text('Operator accepted! Please pay to secure the booking.', style: GoogleFonts.inter(color: Colors.blue.shade800))),
                                 ]
                               )
                             ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () => _payForBooking(b['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 0,
                                ),
                                child: Text('Pay via M-Pesa (Priority)', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => _verifyPayment(b['id']),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.purple,
                                  side: const BorderSide(color: Colors.purple),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Verify Pending Payment', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                          if (b['status'] == 'pending' || b['status'] == 'accepted') ...[
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                onPressed: () => _updateStatus(b['id'], 'cancelled'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text('Cancel Booking', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                          if (b['status'] == 'paid' && b['estimated_start_time'] == null) ...[
                             const SizedBox(height: 16),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.green.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.green.shade200)
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.check_circle, color: Colors.green.shade600),
                                   const SizedBox(width: 8),
                                   Expanded(child: Text('Payment Successful! The operator will set an estimated start time shortly.', style: GoogleFonts.inter(color: Colors.green.shade800))),
                                 ]
                               )
                             )
                          ],
                          if (b['status'] == 'ongoing' && !(b['farmer_completed'] == true)) ...[
                             const SizedBox(height: 16),
                             if (b['operator_completed'] != true)
                               Container(
                                 padding: const EdgeInsets.all(12),
                                 decoration: BoxDecoration(
                                   color: Colors.orange.shade50,
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: Colors.orange.shade200)
                                 ),
                                 child: Row(
                                   children: [
                                     Icon(Icons.directions_run, color: Colors.orange.shade600),
                                     const SizedBox(width: 8),
                                     Expanded(child: Text('Tractor is currently working on your farm!', style: GoogleFonts.inter(color: Colors.orange.shade800, fontWeight: FontWeight.bold))),
                                   ]
                                 )
                               )
                             else ...[
                               Padding(
                                 padding: const EdgeInsets.only(bottom: 8.0),
                                 child: Text('The operator has finished! Please confirm to release their final payment.', style: GoogleFonts.inter(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                               ),
                               SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () => _updateStatus(b['id'], 'completed'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text('Confirm Job Completion', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                             ],
                          ],
                          if (b['status'] == 'paid' && b['estimated_start_time'] != null && !(b['farmer_completed'] == true)) ...[
                             const SizedBox(height: 16),
                             Container(
                               padding: const EdgeInsets.all(12),
                               decoration: BoxDecoration(
                                 color: Colors.blue.shade50,
                                 borderRadius: BorderRadius.circular(8),
                                 border: Border.all(color: Colors.blue.shade200)
                               ),
                               child: Row(
                                 children: [
                                   Icon(Icons.access_time, color: Colors.blue.shade600),
                                   const SizedBox(width: 8),
                                   Expanded(child: Text('Payment confirmed. Waiting for the operator to start the job.', style: GoogleFonts.inter(color: Colors.blue.shade800))),
                                 ]
                               )
                             )
                          ]
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
