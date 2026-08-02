import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  SupabaseConfig._();

  // Same project the web admin panel (admin-panels/.env.local) uses.
  static const String url = 'https://kmbbnwtywdtvkfdauqie.supabase.co';
  static const String anonKey =
      'sb_publishable_ludCggDchrkDxUCYGRDFww_rDwqzREx';

  // Deep link used to return to the app after Google OAuth in the browser.
  static const String oauthRedirect = 'io.bulkmart.app://login-callback';

  static Future<void> init() async {
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }
}

SupabaseClient get supabase => Supabase.instance.client;
