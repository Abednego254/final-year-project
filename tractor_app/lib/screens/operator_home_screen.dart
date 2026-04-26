import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../services/operator_service.dart';
import '../services/socket_service.dart';
import 'operator_live_tracking_screen.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final OperatorService _operatorService = OperatorService();
  final SocketService _socketService = SocketService();
  List<dynamic> _bookings = [];
  int? _currentUserId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        _currentUserId = user.id;
        _socketService.listenToNotifications(user.id!, 'operator', (data) {
          if (!mounted) return;
          _fetchBookings(); // Refresh list
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(
                    data['type'] == 'payment_received' ? Icons.account_balance_wallet : Icons.info_outline,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Text(data['title'] ?? 'Notice', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ],
              ),
              content: Text(data['message'] ?? 'Booking updated.', style: GoogleFonts.inter()),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('UNDERSTOOD', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                ),
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
    if (_currentUserId != null) {
      _socketService.stopListeningToNotifications(_currentUserId!, 'operator');
    }
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final bookings = await _operatorService.getOperatorBookings();
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
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
    
    try {
      await _operatorService.updateBookingStatus(bookingId, newStatus).timeout(const Duration(seconds: 20));
      _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e', style: GoogleFonts.inter()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Always close loading
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
              if (timeController.text.isEmpty) return;
              Navigator.pop(ctx);
              
              showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
              try {
                await _operatorService.updateBookingStartTime(bookingId, timeController.text).timeout(const Duration(seconds: 20));
                _fetchBookings();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) Navigator.of(context, rootNavigator: true).pop();
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
                      
                      final bool hasStartTime = b['estimated_start_time'] != null && 
                                                b['estimated_start_time'].toString().trim().isNotEmpty && 
                                                b['estimated_start_time'].toString() != 'null';
                      
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
                              if (hasStartTime)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 20, color: Colors.purple),
                                      const SizedBox(width: 8),
                                      Text('Starts: ${b['estimated_start_time']}', style: GoogleFonts.inter(color: Colors.purple, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              if (b['status'] == 'paid' || b['status'] == 'completed' || b['status'] == 'ongoing')
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Payment Breakdown:', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple.shade800)),
                                      const SizedBox(height: 4),
                                      _buildPayoutRow('Total Price', 'KES ${b['price']}', isBold: true),
                                      _buildPayoutRow('System Fee (10%)', '- KES ${(double.parse(b['price'].toString()) * 0.1).toStringAsFixed(2)}', color: Colors.red.shade400),
                                      _buildPayoutRow('Operator Net', 'KES ${(double.parse(b['price'].toString()) * 0.9).toStringAsFixed(2)}', color: Colors.green.shade700),
                                      const Divider(height: 12),
                                      Text(
                                        'Note: You get 50% (KES ${(double.parse(b['price'].toString()) * 0.45).toStringAsFixed(2)}) upfront on receipt, and the remaining 50% after job completion.',
                                        style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                                      ),
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
                              if (b['status'] == 'paid' && !hasStartTime)
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
                              if (b['status'] == 'paid' && hasStartTime)
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(b['id'], 'ongoing'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                    child: Text('Start Job', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              if (b['status'] == 'ongoing' && !(b['operator_completed'] == true)) ...[
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.location_on, color: Colors.white),
                                    label: Text('Track Live', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OperatorLiveTrackingScreen(
                                            tractorId: b['tractor_id'] is int
                                                ? b['tractor_id']
                                                : int.tryParse(b['tractor_id'].toString()) ?? 0,
                                            bookingId: b['id'] is int
                                                ? b['id']
                                                : int.tryParse(b['id'].toString()) ?? 0,
                                          ),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                              ],
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

  Widget _buildPayoutRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade600)),
          Text(value, style: GoogleFonts.outfit(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, color: color ?? Colors.black87)),
        ],
      ),
    );
  }
}
