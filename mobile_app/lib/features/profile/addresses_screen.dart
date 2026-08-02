import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/screen_backdrop.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/profile_repository.dart';
import '../../providers/auth_provider.dart';
import 'widgets/add_address_sheet.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _repo = ProfileRepository();
  late Future<List<Address>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Address>> _load() {
    final userId = context.read<AuthProvider>().profile!.id;
    return _repo.fetchAddresses(userId);
  }

  void _reload() => setState(() => _future = _load());

  Future<void> _addAddress() async {
    final saved = await showAddAddressSheet(context);
    if (saved != null) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Addresses')),
      body: ScreenBackdrop(
        child: FutureBuilder<List<Address>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            final addresses = snapshot.data ?? [];
            if (addresses.isEmpty) {
              return EmptyState(
                icon: Icons.location_on_outlined,
                title: 'No saved addresses',
                message: 'Add a delivery address to speed up your next order.',
                action: PrimaryButton(
                  label: 'Add Address',
                  height: 46,
                  onPressed: _addAddress,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: addresses.length,
              itemBuilder: (context, i) {
                final a = addresses[i];
                final displayAddress = a.houseDetails.isNotEmpty
                    ? '${a.houseDetails}, ${a.fullAddress}'
                    : a.fullAddress;
                return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: a.isDefault
                            ? Border.all(color: AppColors.primary)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow,
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colors.isDark
                                  ? AppColors.primary.withValues(alpha: 0.18)
                                  : AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              a.latitude != null
                                  ? Icons.pin_drop_rounded
                                  : Icons.location_on_rounded,
                              color: AppColors.primaryDark,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      a.label,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                        color: colors.textPrimary,
                                      ),
                                    ),
                                    if (a.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: colors.isDark
                                              ? AppColors.primary.withValues(
                                                  alpha: 0.18,
                                                )
                                              : AppColors.primaryLight,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: const Text(
                                          'Default',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primaryDark,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  displayAddress,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.error,
                              size: 20,
                            ),
                            onPressed: () async {
                              await _repo.deleteAddress(a.id);
                              _reload();
                            },
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: (50 * i).ms, duration: 280.ms)
                    .slideX(
                      begin: 0.06,
                      end: 0,
                      delay: (50 * i).ms,
                      duration: 280.ms,
                    );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAddress,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Add Address', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
