import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import '../data/repositories/location_repository.dart';

enum LocationCheckStatus {
  /// No check has run yet this app session — the router gates on this.
  unknown,
  checking,
  serviceable,
  unserviceable,
  permissionDenied,
  serviceDisabled,
  skipped,
  error,
}

/// Resolves the customer's PIN code (via GPS or a manually picked point)
/// and checks it against the superadmin-managed serviceable_pincodes list.
/// Per product decision this is a soft gate: an unserviceable/unknown
/// result never blocks browsing, only order placement.
class LocationProvider extends ChangeNotifier {
  final LocationRepository _repo = LocationRepository();

  LocationCheckStatus status = LocationCheckStatus.unknown;
  String? pincode;
  String? address;
  String? errorMessage;

  bool get canOrder => status == LocationCheckStatus.serviceable;

  Future<void> checkCurrentLocation() async {
    status = LocationCheckStatus.checking;
    errorMessage = null;
    notifyListeners();
    try {
      final location = loc.Location();

      var serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        // Triggers Android's native "Turn on Location" resolution dialog
        // in-app (Google Play Services), the same prompt Swiggy/Zomato/
        // Blinkit show — unlike Geolocator, which can only deep-link out
        // to the Settings app. On iOS this just re-checks: Apple doesn't
        // let any app toggle Location Services or show that dialog.
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          status = LocationCheckStatus.serviceDisabled;
          notifyListeners();
          return;
        }
      }

      var permission = await location.hasPermission();
      if (permission == loc.PermissionStatus.denied) {
        permission = await location.requestPermission();
      }
      if (permission == loc.PermissionStatus.denied ||
          permission == loc.PermissionStatus.deniedForever) {
        status = LocationCheckStatus.permissionDenied;
        notifyListeners();
        return;
      }

      final locData = await location.getLocation();
      await _resolve(locData.latitude, locData.longitude);
    } catch (e) {
      status = LocationCheckStatus.error;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> checkManualLocation(
    double latitude,
    double longitude, {
    String? resolvedAddress,
  }) async {
    status = LocationCheckStatus.checking;
    errorMessage = null;
    address = resolvedAddress;
    notifyListeners();
    await _resolve(latitude, longitude);
  }

  Future<void> _resolve(double latitude, double longitude) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      final pin = placemarks.isNotEmpty ? placemarks.first.postalCode : null;
      if (pin == null || pin.trim().isEmpty) {
        status = LocationCheckStatus.error;
        errorMessage = 'Could not determine the PIN code for this location.';
        notifyListeners();
        return;
      }
      pincode = pin.trim();
      final serviceable = await _repo.isPincodeServiceable(pincode!);
      status = serviceable
          ? LocationCheckStatus.serviceable
          : LocationCheckStatus.unserviceable;
      notifyListeners();
    } catch (e) {
      status = LocationCheckStatus.error;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// User declined to share/pick a location — browsing continues, but
  /// checkout stays blocked until they check again.
  void skip() {
    status = LocationCheckStatus.skipped;
    notifyListeners();
  }

  /// Clears a resolved result so the screen can present the initial prompt
  /// again (e.g. "Check again" after an unserviceable/error result).
  void retry() {
    status = LocationCheckStatus.unknown;
    pincode = null;
    address = null;
    errorMessage = null;
    notifyListeners();
  }

  /// Opens the device's location-services settings screen (Geolocator has
  /// no cross-platform "enable now" dialog, only this settings deep link).
  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  /// Opens this app's settings screen — needed when permission was denied
  /// permanently, since requesting again silently no-ops in that case.
  Future<void> openAppSettings() => Geolocator.openAppSettings();
}
