import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/support.dart';
import '../../data/repositories/support_repository.dart';
import '../../providers/auth_provider.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _repo = SupportRepository();
  late Future<List<SupportTicket>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.fetchMyTickets();
  }

  void _reload() => setState(() => _future = _repo.fetchMyTickets());

  Future<void> _openNewTicket() async {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    bool sending = false;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: BoxDecoration(
              color: context.colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('New Support Request',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        color: context.colors.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: subjectCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    prefixIcon: Icon(Icons.topic_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'How can we help?',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.chat_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  label: 'Submit Request',
                  loading: sending,
                  onPressed: () async {
                    if (messageCtrl.text.trim().isEmpty) return;
                    setSheetState(() => sending = true);
                    final profile = context.read<AuthProvider>().profile!;
                    await _repo.createTicket(
                      subject: subjectCtrl.text.trim().isEmpty
                          ? 'General Support'
                          : subjectCtrl.text.trim(),
                      firstMessage: messageCtrl.text.trim(),
                      customerName: profile.fullName,
                      customerEmail: profile.email,
                      customerPhone: profile.phone,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Support')),
      body: ScreenBackdrop(
        child: FutureBuilder<List<SupportTicket>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) {
              return EmptyState(
                icon: Icons.support_agent_rounded,
                title: 'No support requests yet',
                message: 'Have a question about an order or product? We usually reply within a few hours.',
                action: PrimaryButton(
                  label: 'New Support Request',
                  height: 46,
                  onPressed: _openNewTicket,
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => _reload(),
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                itemCount: tickets.length,
                itemBuilder: (context, i) {
                  final t = tickets[i];
                  return _TicketCard(ticket: t, index: i);
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewTicket,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('New Request', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportTicket ticket;
  final int index;
  const _TicketCard({required this.ticket, required this.index});

  Color _statusColor() {
    switch (ticket.status) {
      case TicketStatus.open:
        return AppColors.secondary;
      case TicketStatus.inProgress:
        return AppColors.accent;
      case TicketStatus.resolved:
        return AppColors.success;
      case TicketStatus.closed:
        return AppColors.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = _statusColor();
    return GestureDetector(
      onTap: () => context.push('/support/${ticket.id}', extra: ticket.subject),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.support_agent_rounded, color: statusColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket.subject,
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13.5, color: colors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(
                    'Updated ${ticket.updatedAt.day}/${ticket.updatedAt.month}/${ticket.updatedAt.year}',
                    style: TextStyle(fontSize: 11.5, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                ticket.status.label,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: (50 * index).ms, duration: 280.ms)
        .slideX(begin: 0.06, end: 0, delay: (50 * index).ms, duration: 280.ms);
  }
}
