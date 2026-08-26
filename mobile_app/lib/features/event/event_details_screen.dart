import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../core/widgets/tappable.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../profile/widgets/add_address_sheet.dart';

class EventDetailsScreen extends StatefulWidget {
  const EventDetailsScreen({super.key});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _repo = ProfileRepository();
  DateTime? _eventDate;
  String? _deliveryTime;
  final _notesCtrl = TextEditingController();

  late Future<List<Address>> _addressesFuture;
  Address? _selectedAddress;

  final _deliveryTimes = const [
    'Morning (8AM - 11AM)',
    'Afternoon (12PM - 3PM)',
    'Evening (4PM - 7PM)',
  ];

  @override
  void initState() {
    super.initState();
    _addressesFuture = _loadAddresses();
  }

  Future<List<Address>> _loadAddresses() async {
    final userId = context.read<AuthProvider>().profile!.id;
    final addresses = await _repo.fetchAddresses(userId);
    if (addresses.isNotEmpty) {
      setState(() {
        _selectedAddress = addresses.firstWhere(
          (a) => a.isDefault,
          orElse: () => addresses.first,
        );
      });
    }
    return addresses;
  }

  Future<void> _addAddress() async {
    final saved = await showAddAddressSheet(context);
    if (saved == null) return;
    setState(() {
      _selectedAddress = saved;
      _addressesFuture = _loadAddresses();
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  void _continue() {
    if (_eventDate == null || _deliveryTime == null || _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a date, delivery time and address')),
      );
      return;
    }
    final a = _selectedAddress!;
    final fullAddress = a.houseDetails.isNotEmpty ? '${a.houseDetails}, ${a.fullAddress}' : a.fullAddress;

    final cart = context.read<CartProvider>();
    cart.eventDetails
      ..eventDate = _eventDate
      ..deliveryAddress = fullAddress
      ..preferredDeliveryTime = _deliveryTime!
      ..additionalNotes = _notesCtrl.text.trim();
    context.push('/order-summary');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Event Details')),
      body: ScreenBackdrop(
        themed: true,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _label('Event Date'),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  _eventDate == null
                      ? 'Select event date'
                      : '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}',
                  style: TextStyle(
                    color: _eventDate == null ? colors.textMuted : colors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _label('Preferred Delivery Time'),
            Column(
              children: _deliveryTimes
                  .map(
                    (t) => RadioListTile<String>(
                      value: t,
                      groupValue: _deliveryTime,
                      onChanged: (v) => setState(() => _deliveryTime = v),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(t, style: const TextStyle(fontSize: 13.5)),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Delivery Address'),
                GestureDetector(
                  onTap: _addAddress,
                  child: const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      '+ Add New',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            FutureBuilder<List<Address>>(
              future: _addressesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                final addresses = snapshot.data ?? [];
                if (addresses.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'No saved addresses yet.',
                          style: TextStyle(color: colors.textSecondary, fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        PrimaryButton(
                          label: 'Add Delivery Address',
                          height: 44,
                          icon: Icons.add_location_alt_outlined,
                          onPressed: _addAddress,
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: addresses.map((a) {
                    final selected = _selectedAddress?.id == a.id;
                    final displayAddress =
                        a.houseDetails.isNotEmpty ? '${a.houseDetails}, ${a.fullAddress}' : a.fullAddress;
                    return Tappable(
                      onTap: () => setState(() => _selectedAddress = a),
                      pressedScale: 0.98,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.primary.withValues(alpha: colors.isDark ? 0.18 : 0.08)
                              : colors.bg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? AppColors.primary : colors.border,
                            width: selected ? 1.6 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                              color: selected ? AppColors.primary : colors.textMuted,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    a.label,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    displayAddress,
                                    style: TextStyle(fontSize: 12, color: colors.textSecondary),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            _label('Additional Notes'),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 3,
              style: TextStyle(color: colors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Anything else the shop owner should know...',
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              label: 'Continue to Summary',
              icon: Icons.arrow_forward_rounded,
              onPressed: _continue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 14.5,
        color: context.colors.textPrimary,
      ),
    ),
  );
}
