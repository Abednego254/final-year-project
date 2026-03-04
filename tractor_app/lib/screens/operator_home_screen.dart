import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/operator_service.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> {
  final OperatorService _operatorService = OperatorService();
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
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
      await _operatorService.updateBookingStatus(bookingId, newStatus);
      _fetchBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showRegisterTractorDialog() {
    final modelController = TextEditingController();
    final licenseController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Register Tractor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: modelController,
              decoration: const InputDecoration(labelText: 'Tractor Model (e.g., John Deere)'),
            ),
            TextField(
              controller: licenseController,
              decoration: const InputDecoration(labelText: 'License Plate (e.g., KCA 123A)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _operatorService.registerTractor(modelController.text, licenseController.text);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tractor Registered Successfully')));
                }
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Op: ${user?.name ?? "Tractor"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Register Tractor',
            onPressed: _showRegisterTractorDialog,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const Center(child: Text('No bookings requests yet.'))
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: ListView.builder(
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Booking #${b['id']} - KES ${b['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              Text('Farmer: ${b['farmer_name']} (${b['farmer_phone']})'),
                              Text('Date: ${DateTime.parse(b['scheduled_date']).toLocal().toString().split(' ')[0]}'),
                              Text('Status: ${b['status']}', style: TextStyle(color: b['status'] == 'pending' ? Colors.orange : Colors.green)),
                              const SizedBox(height: 12),
                              if (b['status'] == 'pending')
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => _updateStatus(b['id'], 'cancelled'),
                                      child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () => _updateStatus(b['id'], 'accepted'),
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                ),
                              if (b['status'] == 'accepted')
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => _updateStatus(b['id'], 'completed'),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                    child: const Text('Mark Completed', style: TextStyle(color: Colors.white)),
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
