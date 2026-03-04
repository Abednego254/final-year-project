import 'package:flutter/material.dart';
import '../services/booking_service.dart';
import '../services/payment_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class FarmerBookingsScreen extends StatefulWidget {
  const FarmerBookingsScreen({super.key});

  @override
  State<FarmerBookingsScreen> createState() => _FarmerBookingsScreenState();
}

class _FarmerBookingsScreenState extends State<FarmerBookingsScreen> {
  final BookingService _bookingService = BookingService();
  final PaymentService _paymentService = PaymentService();
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
      final bookings = await _bookingService.getMyBookings();
      setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _payForBooking(int bookingId) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;
    
    // Simple popup to confirm phone number
    final phoneController = TextEditingController(text: ''); // User model lacks phone in app side rn, prompt or fallback
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('M-Pesa Payment'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(labelText: 'M-Pesa Phone Number', hintText: '2547XXXXXXXX'),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
               Navigator.pop(ctx);
               if (phoneController.text.isEmpty) return;
               
               try {
                 showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                 final res = await _paymentService.initiateStkPush(bookingId, phoneController.text);
                 Navigator.pop(context); // close loading
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(res['message'])));
                 _fetchBookings(); // refresh statuses
               } catch (e) {
                 Navigator.pop(context); // close loading
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
               }
            },
            child: const Text('Initiate STK Push'),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty
          ? const Center(child: Text('No bookings found.'))
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final b = _bookings[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Booking #${b['id']} - KES ${b['price']}'),
                      subtitle: Text('Status: ${b['status']}\nOperator: ${b['operator_name']}'),
                      trailing: b['status'] == 'accepted' 
                        ? ElevatedButton(
                            onPressed: () => _payForBooking(b['id']),
                            child: const Text('Pay')
                          )
                        : null,
                    ),
                  );
                },
              ),
            ),
    );
  }
}
