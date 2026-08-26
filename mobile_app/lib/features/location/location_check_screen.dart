import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_ext.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/radar_scanner.dart';
import '../../providers/location_provider.dart';
import '../profile/widgets/map_location_picker.dart';

/// Shown right after login to check whether the customer's area is
/// serviceable. This is a soft gate: whatever the outcome, the user can
/// always continue into the app — an unserviceable/unchecked result only
/// blocks placing a bulk order later (enforced at checkout).
///
/// A definitive result (serviceable/unserviceable) auto-advances a beat
/// after it resolves — no extra tap needed. Inconclusive outcomes
/// (permission denied, location services off, a lookup error) pause here
/// instead, since those are worth letting the user fix before moving on.
class LocationCheckScreen extends StatefulWidget {
  const LocationCheckScreen({super.key});

  @override
  State<LocationCheckScreen> createState() => _LocationCheckScreenState();
}

class _LocationCheckScreenState extends State<LocationCheckScreen> {
  static const _autoContinueStatuses = {
    LocationCheckStatus.serviceable,
    LocationCheckStatus.unserviceable,
  };

  bool _autoContinueScheduled = false;

  @override
  void initState() {
    super.initState();
    context.read<LocationProvider>().addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    context.read<LocationProvider>().removeListener(_onLocationChanged);
    super.dispose();
  }

  void _onLocationChanged() {
    if (_autoContinueScheduled) return;
    if (!_autoContinueStatuses.contains(context.read<LocationProvider>().status)) return;
    _autoContinueScheduled = true;
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) _continue(context);
    });
  }

  Future<void> _pickManually(BuildContext context) async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(builder: (_) => const MapLocationPicker()),
    );
    if (result == null || !context.mounted) return;
    context.read<LocationProvider>().checkManualLocation(
          result.point.latitude,
          result.point.longitude,
          resolvedAddress: result.address,
        );
  }

  void _skip(BuildContext context) {
    context.read<LocationProvider>().skip();
    _continue(context);
  }

  void _continue(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final location = context.watch<LocationProvider>();

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              _StatusPanel(location: location),
              const Spacer(),
              _Actions(
                location: location,
                onUseCurrent: () => context.read<LocationProvider>().checkCurrentLocation(),
                onManual: () => _pickManually(context),
                onSkip: () => _skip(context),
                onRetry: () => context.read<LocationProvider>().checkCurrentLocation(),
                onContinue: () => _continue(context),
                onOpenLocationSettings: () =>
                    context.read<LocationProvider>().openLocationSettings(),
                onOpenAppSettings: () => context.read<LocationProvider>().openAppSettings(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  final LocationProvider location;
  const _StatusPanel({required this.location});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    late final IconData icon;
    late final Color iconColor;
    late final String title;
    late final String message;

    switch (location.status) {
      case LocationCheckStatus.unknown:
      case LocationCheckStatus.skipped:
        icon = Icons.location_on_rounded;
        iconColor = AppColors.primary;
        title = 'Is BulkMart available in your area?';
        message =
            'Share your location so we can check bulk order delivery availability nearby.';
        break;
      case LocationCheckStatus.checking:
        icon = Icons.location_searching_rounded;
        iconColor = AppColors.primary;
        title = 'Checking your area...';
        message = 'Hang tight while we confirm delivery availability.';
        break;
      case LocationCheckStatus.serviceable:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        title = 'Great, we deliver here!';
        message = location.pincode == null
            ? 'Bulk orders are available in your area.'
            : 'Bulk orders are available for PIN code ${location.pincode}.';
        break;
      case LocationCheckStatus.unserviceable:
        icon = Icons.location_off_rounded;
        iconColor = AppColors.warning;
        title = 'Not available in your area yet';
        message = location.pincode == null
            ? 'We don\'t deliver here yet, but you can still browse the catalog.'
            : 'We don\'t deliver to PIN code ${location.pincode} yet. You can still browse the catalog.';
        break;
      case LocationCheckStatus.permissionDenied:
        icon = Icons.location_disabled_rounded;
        iconColor = AppColors.warning;
        title = 'Location permission needed';
        message =
            'Allow location access to check delivery availability, or enter your location manually.';
        break;
      case LocationCheckStatus.serviceDisabled:
        icon = Icons.location_disabled_rounded;
        iconColor = AppColors.warning;
        title = 'Location services are off';
        message = 'Turn on location services, or enter your location manually.';
        break;
      case LocationCheckStatus.error:
        icon = Icons.error_outline_rounded;
        iconColor = AppColors.error;
        title = 'Could not check your area';
        message = 'Something went wrong. Please try again.';
        break;
    }

    const scanningStatuses = {
      LocationCheckStatus.unknown,
      LocationCheckStatus.skipped,
      LocationCheckStatus.checking,
    };
    final scanning = scanningStatuses.contains(location.status);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RadarScanner(
          color: iconColor,
          scanning: scanning,
          child: Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: colors.isDark ? 0.18 : 0.12),
              shape: BoxShape.circle,
            ),
            child: location.status == LocationCheckStatus.checking
                ? const Center(
                    child: SizedBox(
                      width: 34,
                      height: 34,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : Center(child: Icon(icon, size: 46, color: iconColor)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.display(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: colors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        if (location.status == LocationCheckStatus.error &&
            location.errorMessage != null) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: Text(
              location.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: colors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final LocationProvider location;
  final VoidCallback onUseCurrent;
  final VoidCallback onManual;
  final VoidCallback onSkip;
  final VoidCallback onRetry;
  final VoidCallback onContinue;
  final VoidCallback onOpenLocationSettings;
  final VoidCallback onOpenAppSettings;

  const _Actions({
    required this.location,
    required this.onUseCurrent,
    required this.onManual,
    required this.onSkip,
    required this.onRetry,
    required this.onContinue,
    required this.onOpenLocationSettings,
    required this.onOpenAppSettings,
  });

  Widget _outlined(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      child: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (location.status) {
      case LocationCheckStatus.unknown:
      case LocationCheckStatus.skipped:
        return Column(
          children: [
            PrimaryButton(
              label: 'Use Current Location',
              icon: Icons.my_location_rounded,
              onPressed: onUseCurrent,
            ),
            const SizedBox(height: 12),
            _outlined('Enter Location Manually', onManual),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onSkip,
              child: const Text('Skip for now'),
            ),
          ],
        );
      case LocationCheckStatus.checking:
        return const SizedBox(height: 54);
      case LocationCheckStatus.serviceable:
        return PrimaryButton(
          label: 'Continue',
          icon: Icons.arrow_forward_rounded,
          onPressed: onContinue,
        );
      case LocationCheckStatus.serviceDisabled:
        // Geolocator has no in-app "enable location" dialog — the device
        // settings screen is the only cross-platform way to turn it on.
        return Column(
          children: [
            PrimaryButton(
              label: 'Turn On Location',
              icon: Icons.location_on_rounded,
              onPressed: onOpenLocationSettings,
            ),
            const SizedBox(height: 12),
            _outlined('Enter Location Manually', onManual),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('I\'ve turned it on — retry'),
            ),
            TextButton(
              onPressed: onContinue,
              child: const Text('Continue Browsing'),
            ),
          ],
        );
      case LocationCheckStatus.permissionDenied:
        return Column(
          children: [
            PrimaryButton(
              label: 'Grant Location Permission',
              icon: Icons.lock_open_rounded,
              onPressed: onOpenAppSettings,
            ),
            const SizedBox(height: 12),
            _outlined('Enter Location Manually', onManual),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
            TextButton(
              onPressed: onContinue,
              child: const Text('Continue Browsing'),
            ),
          ],
        );
      case LocationCheckStatus.unserviceable:
      case LocationCheckStatus.error:
        return Column(
          children: [
            PrimaryButton(
              label: 'Try Again',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onContinue,
              child: const Text('Continue Browsing'),
            ),
          ],
        );
    }
  }
}
