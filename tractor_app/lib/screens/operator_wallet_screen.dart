import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/socket_service.dart';
import '../services/wallet_service.dart';

class OperatorWalletScreen extends StatefulWidget {
  const OperatorWalletScreen({super.key});

  @override
  State<OperatorWalletScreen> createState() => _OperatorWalletScreenState();
}

class _OperatorWalletScreenState extends State<OperatorWalletScreen> {
  final WalletService _walletService = WalletService();
  final SocketService _socketService = SocketService();
  Map<String, dynamic>? _walletData;
  bool _isLoading = true;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadData();
    _initSocket();
  }

  void _initSocket() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      if (user != null) {
        _currentUserId = user.id;
        _socketService.listenToNotifications(user.id, 'operator', (data) {
          if (mounted) {
            _loadData(); 
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _walletService.getWalletData();
      setState(() => _walletData = data);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    final phoneController = TextEditingController(text: Provider.of<AuthProvider>(context, listen: false).user?.phone ?? '');
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Withdraw Funds', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Maintain a minimum balance of KES 200.00', style: GoogleFonts.inter(fontSize: 12, color: Colors.red)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'KES ',
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'M-Pesa Number',
                  hintText: '2547XXXXXXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.phone, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'System Password',
                  hintText: 'Required for authorization',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_outline, size: 20),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid amount')));
                return;
              }
              if (phoneController.text.isEmpty || passwordController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone and Password are required')));
                return;
              }
              Navigator.pop(ctx);
              _processWithdrawal(amount, phoneController.text, passwordController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  Future<void> _processWithdrawal(double amount, String phone, String password) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.green)), barrierDismissible: false);
    try {
      final res = await _walletService.withdraw(amount, phone, password);
      if (mounted) Navigator.pop(context); // close loader
      _loadData(); // refresh
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 50),
            content: Text(res['message'] ?? 'Withdrawal successful', textAlign: TextAlign.center),
            actions: [
              Center(child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('DONE'))),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('My Wallet', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: Colors.green,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 32),
                    Text('Recent Transactions', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildTransactionList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    final balance = double.tryParse(_walletData?['wallet']?['balance']?.toString() ?? '0') ?? 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade700, Colors.green.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Available Balance', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'KES ${balance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: balance > 0 ? _showWithdrawDialog : null,
              icon: const Icon(Icons.account_balance_wallet_outlined),
              label: const Text('Withdraw Funds'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.green.shade800,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    final List<dynamic> txs = _walletData?['transactions'] ?? [];
    if (txs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('No transactions yet.', style: GoogleFonts.inter(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: txs.length,
      itemBuilder: (context, index) {
        final tx = txs[index];
        final isCredit = tx['type'] == 'credit';
        final amount = double.tryParse(tx['amount']?.toString() ?? '0') ?? 0.0;
        final date = DateTime.tryParse(tx['created_at'].toString())?.toLocal();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: isCredit ? Colors.green : Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx['description'] ?? 'Transaction', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(
                      '${date?.day}/${date?.month}/${date?.year} ${date?.hour}:${date?.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                '${isCredit ? "+" : "-"} KES ${amount.toStringAsFixed(0)}',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
