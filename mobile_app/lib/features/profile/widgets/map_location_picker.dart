import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart' as loc;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_ext.dart';
import '../../../core/widgets/primary_button.dart';

class PickedLocation {
  final LatLng point;
  final String address;
  const PickedLocation({required this.point, required this.address});
}

enum _LocationErrorKind { none, serviceDisabled, permissionDenied, other }

/// Full-screen map picker: drag the map to move a fixed center pin, or jump
/// to the device's current location, then confirm to reverse-geocode the
/// pin into a readable address.
class MapLocationPicker extends StatefulWidget {
  const MapLocationPicker({super.key});

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  static const _fallback = LatLng(20.5937, 78.9629); // India, default view

  final MapController _mapController = MapController();
  LatLng _center = _fallback;
  bool _locating = false;
  bool _resolving = false;
  String? _error;
  _LocationErrorKind _errorKind = _LocationErrorKind.none;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _useCurrentLocation(silent: true));
  }

  void _fail(_LocationErrorKind kind, String message, bool silent) {
    if (silent || !mounted) return;
    setState(() {
      _errorKind = kind;
      _error = message;
    });
  }

  Future<void> _useCurrentLocation({bool silent = false}) async {
    setState(() {
      _locating = true;
      _error = null;
      _errorKind = _LocationErrorKind.none;
    });
    try {
      final location = loc.Location();

      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        // Shows Android's native "Turn on Location" resolution dialog
        // in-app instead of just failing silently.
        serviceEnabled = silent ? false : await location.requestService();
        if (!serviceEnabled) {
          _fail(_LocationErrorKind.serviceDisabled, 'Location services are turned off', silent);
          return;
        }
      }
      var permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
      if (permission == loc.PermissionStatus.denied ||
          permission == loc.PermissionStatus.deniedForever) {
        _fail(_LocationErrorKind.permissionDenied, 'Location permission denied', silent);
        return;
      }
      final locData = await location.getLocation();
      final point = LatLng(locData.latitude, locData.longitude);
      _mapController.move(point, 16);
      setState(() => _center = point);
    } catch (e) {
      _fail(_LocationErrorKind.other, e.toString(), silent);
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _confirm() async {
    setState(() {
      _resolving = true;
      _error = null;
    });
    String address = '';
    try {
      final placemarks = await placemarkFromCoordinates(_center.latitude, _center.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = [p.street, p.subLocality, p.locality, p.administrativeArea, p.postalCode]
            .where((s) => s != null && s.trim().isNotEmpty)
            .join(', ');
      }
    } catch (_) {
      // Reverse geocoding can fail (no network / no provider) — the user
      // can still type the address manually on the next screen.
    }
    if (!mounted) return;
    setState(() => _resolving = false);
    Navigator.pop(context, PickedLocation(point: _center, address: address));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const Text('Pin Delivery Location')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 5,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() => _center = position.center);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'io.bulkmart.app',
              ),
            ],
          ),
          // Fixed center pin — the map moves underneath it.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 44,
                  color: AppColors.primary,
                  shadows: [Shadow(color: colors.shadow, blurRadius: 6)],
                ),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 140,
            child: FloatingActionButton(
              heroTag: 'use_current_location',
              backgroundColor: colors.card,
              foregroundColor: AppColors.primary,
              onPressed: _locating ? null : () => _useCurrentLocation(),
              child: _locating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
                    )
                  : const Icon(Icons.my_location_rounded),
            ),
          ),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              child: Material(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5),
                        ),
                      ),
                      if (_errorKind == _LocationErrorKind.serviceDisabled)
                        TextButton(
                          onPressed: () => Geolocator.openLocationSettings(),
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          child: const Text('Turn On'),
                        )
                      else if (_errorKind == _LocationErrorKind.permissionDenied)
                        TextButton(
                          onPressed: () => Geolocator.openAppSettings(),
                          style: TextButton.styleFrom(foregroundColor: Colors.white),
                          child: const Text('Settings'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: SafeArea(
              top: false,
              child: PrimaryButton(
                label: 'Confirm Location',
                icon: Icons.check_rounded,
                loading: _resolving,
                onPressed: _confirm,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
