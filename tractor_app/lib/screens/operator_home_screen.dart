import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/operator_service.dart';
import '../services/socket_service.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final OperatorService _operatorService = OperatorService();
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
        _socketService.listenToNotifications(user.id!, 'operator', (data) {
          if (mounted) {
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
          }
        });
      }
    });
  }

  @override
  void dispose() {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _socketService.stopListeningToNotifications(user.id!, 'operator');
    }
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    setState(() => _isLoading = true);
    try {
      final bookings = await _operatorService.getOperatorBookings();
      setState(() => _bookings = bookings);
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
      await _operatorService.updateBookingStatus(bookingId, newStatus);
      if (mounted) Navigator.pop(context); // close loading
      _fetchBookings();
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close loading
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red));
      }
    }
  }

  void _showStartTimeDialog(int bookingId) {
    final timeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Set Start Time', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: timeController,
          decoration: const InputDecoration(hintText: 'e.g., In 2 hours or At 14:00'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (timeController.text.isNotEmpty) {
                try {
                  showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
                  await _operatorService.updateBookingStartTime(bookingId, timeController.text);
                  Navigator.pop(context);
                  _fetchBookings();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      )
    );
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
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Op: ${user?.name?.split(' ').first ?? "User"}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No booking requests yet.', style: GoogleFonts.inter(fontSize: 18, color: Colors.grey.shade600)),
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
                                  Text(
                                    'Booking #${b['id']}', 
                                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)
                                  ),
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
                                  Icon(Icons.person_outline, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text('Farmer: ${b['farmer_name']}', style: GoogleFonts.inter(color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone_outlined, size: 20, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Text('${b['farmer_phone'] ?? 'N/A'}', style: GoogleFonts.inter(color: Colors.black87)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.calendar_month_outlined, size: 20, color: Colors.grey.shade600),
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
                                  Text('Total Price', style: GoogleFonts.inter(color: Colors.grey.shade600)),
                                  Text('KES ${b['price']}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                                ],
                              ),
                              if (b['status'] == 'paid' || b['status'] == 'completed')
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Your Earnings (90%)', style: GoogleFonts.inter(color: Colors.purple.shade600, fontWeight: FontWeight.w500)),
                                      Text('KES ${(double.parse(b['price'].toString()) * 0.9).toStringAsFixed(2)}', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.purple.shade700)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 16),
                              if (b['status'] == 'pending')
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => _updateStatus(b['id'], 'cancelled'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(color: Colors.red),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        child: Text('Reject', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () => _updateStatus(b['id'], 'accepted'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: Text('Accept', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: Colors.white)),
                                      ),
                                    ),
                                  ],
                                ),
                              if (b['status'] == 'accepted')
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.shade200)
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.payment, color: Colors.orange.shade600),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('Waiting for payment from farmer.', style: GoogleFonts.inter(color: Colors.orange.shade800))),
                                      ]
                                    )
                                  )
                                ),
                              if (b['status'] == 'paid' && b['estimated_start_time'] == null)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => _showStartTimeDialog(b['id']),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: Text('Funds Received. Set Start Time', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (b['status'] == 'paid' && b['estimated_start_time'] != null && !(b['operator_completed'] == true))
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
                                    child: Text('Mark as Completed', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (b['operator_completed'] == true && b['farmer_completed'] != true && b['status'] != 'completed')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Center(
                                    child: Text('Waiting for Farmer to mark as complete', style: GoogleFonts.inter(color: Colors.grey.shade600, fontStyle: FontStyle.italic, fontSize: 13)),
                                  ),
                                ),
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
