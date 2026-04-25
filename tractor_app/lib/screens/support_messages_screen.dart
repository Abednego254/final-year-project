import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/support_service.dart';
import 'package:intl/intl.dart';

class SupportMessagesScreen extends StatefulWidget {
  const SupportMessagesScreen({super.key});

  @override
  State<SupportMessagesScreen> createState() => _SupportMessagesScreenState();
}

class _SupportMessagesScreenState extends State<SupportMessagesScreen> {
  final SupportService _supportService = SupportService();
  List<dynamic> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final messages = await _supportService.getMessages();
      if (mounted) setState(() => _messages = messages);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Support History', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _messages.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.message_outlined, size: 80, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text('No messages sent yet.', style: GoogleFonts.inter(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final bool isReply = msg['admin_id'] != null;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isReply ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isReply ? Colors.blue.shade200 : Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isReply ? 'Support Reply' : 'Your Message',
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                  color: isReply ? Colors.blue.shade800 : Colors.black87,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, HH:mm').format(DateTime.parse(msg['created_at'])),
                                style: GoogleFonts.inter(fontSize: 12, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            msg['subject'] ?? 'No Subject',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['content'],
                            style: GoogleFonts.inter(color: Colors.grey.shade800),
                          ),
                          if (isReply) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _showReplyDialog(msg['subject'], msg['id']),
                                icon: const Icon(Icons.reply, size: 18),
                                label: const Text('Reply'),
                                style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  void _showReplyDialog(String? originalSubject, int originalId) {
    final contentController = TextEditingController();
    String subject = originalSubject ?? 'Follow-up';
    if (!subject.startsWith('Re:')) subject = 'Re: $subject';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reply to Admin', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Subject: $subject', style: GoogleFonts.inter(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Type your response...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (contentController.text.isEmpty) return;
              Navigator.pop(ctx);
              _sendReply(subject, contentController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade800, foregroundColor: Colors.white),
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply(String subject, String content) async {
    showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      await _supportService.sendMessage(subject, content);
      if (mounted) Navigator.pop(context);
      _fetchMessages(); // Refresh list
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply sent successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
