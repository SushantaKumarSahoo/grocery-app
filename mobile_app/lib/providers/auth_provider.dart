import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../data/models/app_user.dart';
import '../data/repositories/profile_repository.dart';

enum AuthStatus {
  unknown,
  onboarding,
  unauthenticated,
  awaitingOtp,
  needsProfile,
  authenticated,
}

class AuthProvider extends ChangeNotifier {
  final ProfileRepository _profileRepo = ProfileRepository();
  StreamSubscription<AuthState>? _authSub;

  AuthStatus status = AuthStatus.unknown;
  Profile? profile;
  String? pendingPhone;
  String? authError;

  User? get supabaseUser => supabase.auth.currentUser;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    _authSub = supabase.auth.onAuthStateChange.listen((data) {
      _handleSession(data.session);
    });

    final session = supabase.auth.currentSession;
    if (session != null) {
      await _handleSession(session, notify: false);
    } else {
      status = onboardingSeen
          ? AuthStatus.unauthenticated
          : AuthStatus.onboarding;
    }
    notifyListeners();
  }

  Future<void> _handleSession(Session? session, {bool notify = true}) async {
    if (session == null) {
      profile = null;
      status = AuthStatus.unauthenticated;
      if (notify) notifyListeners();
      return;
    }
    try {
      final p = await _profileRepo.fetchProfile(session.user.id);
      if (p == null) {
        profile = null;
        status = AuthStatus.needsProfile;
      } else {
        profile = p;
        status = AuthStatus.authenticated;
      }
    } catch (_) {
      status = AuthStatus.needsProfile;
    }
    if (notify) notifyListeners();
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password, {
    required String phone,
  }) async {
    authError = null;
    try {
      final res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );
      if (res.session == null) {
        authError =
            'Account created. Please check your email to confirm before signing in.';
        notifyListeners();
        return false;
      }
      // Create the profile up front using what was already collected on the
      // register form, so the user is never asked for name/phone twice.
      try {
        profile = await _profileRepo.createProfile(
          userId: res.session!.user.id,
          fullName: name,
          email: email,
          phone: phone,
        );
      } catch (_) {
        // Falls back to the complete-profile screen via _handleSession below.
      }
      await _handleSession(res.session);
      return true;
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithEmail(String email, String password) async {
    authError = null;
    try {
      final res = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _handleSession(res.session);
      return true;
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> loginWithGoogle() async {
    authError = null;
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: SupabaseConfig.oauthRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      // Session arrives asynchronously via the deep link + onAuthStateChange.
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
    }
  }

  Future<bool> loginWithPhone(String phone) async {
    authError = null;
    try {
      await supabase.auth.signInWithOtp(phone: phone);
      pendingPhone = phone;
      status = AuthStatus.awaitingOtp;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    authError = null;
    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.sms,
        phone: phone,
        token: otp,
      );
      await _handleSession(res.session);
      return true;
    } on AuthException catch (e) {
      authError = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<void> createProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    profile = await _profileRepo.createProfile(
      userId: user.id,
      fullName: fullName,
      email: user.email ?? '',
      phone: phone.isNotEmpty ? phone : (user.phone ?? ''),
    );
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> updateOwnProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    profile = await _profileRepo.updateProfile(user.id, {
      'full_name': fullName,
      'phone': phone,
    });
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    profile = await _profileRepo.fetchProfile(user.id);
    notifyListeners();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
    profile = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
