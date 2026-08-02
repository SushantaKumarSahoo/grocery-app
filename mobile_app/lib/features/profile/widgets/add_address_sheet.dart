import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../../providers/auth_provider.dart';
import 'map_location_picker.dart';

/// Opens the "Add Address" bottom sheet (pin on map + house details) and
/// returns the newly saved [Address], or null if the user cancelled.
/// Shared by the Addresses screen and anywhere else that needs to collect
/// a delivery address (e.g. Event Details), so there's only one add-address
/// flow in the app.
Future<Address?> showAddAddressSheet(BuildContext context) async {
  final repo = ProfileRepository();
  final labelCtrl = TextEditingController();
  final houseCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  bool isDefault = false;
  LatLng? pickedPoint;

  return showModalBottomSheet<Address>(
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Address',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<PickedLocation>(
                      context,
                      MaterialPageRoute(builder: (_) => const MapLocationPicker()),
                    );
                    if (result != null) {
                      pickedPoint = result.point;
                      if (result.address.isNotEmpty) {
                        addressCtrl.text = result.address;
                      }
                      setSheetState(() {});
                    }
                  },
                  icon: Icon(
                    pickedPoint == null ? Icons.map_outlined : Icons.check_circle_rounded,
                    color: pickedPoint == null ? null : AppColors.primary,
                  ),
                  label: Text(
                    pickedPoint == null ? 'Pin location on map' : 'Location pinned — tap to change',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: houseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'House / Flat / Floor',
                    hintText: 'e.g. Flat 302, Sunrise Apartments',
                    prefixIcon: Icon(Icons.home_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: labelCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Label (e.g. Home, Venue)',
                    prefixIcon: Icon(Icons.label_outline_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Area / Full address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                ),
                CheckboxListTile(
                  value: isDefault,
                  onChanged: (v) => setSheetState(() => isDefault = v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: const Text('Set as default address', style: TextStyle(fontSize: 13.5)),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Save Address',
                  onPressed: () async {
                    if (addressCtrl.text.trim().isEmpty) return;
                    final userId = context.read<AuthProvider>().profile!.id;
                    final saved = await repo.addAddress(
                      userId: userId,
                      label: labelCtrl.text.trim().isEmpty ? 'Address' : labelCtrl.text.trim(),
                      fullAddress: addressCtrl.text.trim(),
                      houseDetails: houseCtrl.text.trim(),
                      latitude: pickedPoint?.latitude,
                      longitude: pickedPoint?.longitude,
                      isDefault: isDefault,
                    );
                    if (context.mounted) Navigator.pop(context, saved);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
