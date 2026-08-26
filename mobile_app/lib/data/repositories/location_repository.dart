import '../../core/config/supabase_config.dart';

class LocationRepository {
  Future<bool> isPincodeServiceable(String pincode) async {
    final data = await supabase
        .from('serviceable_pincodes')
        .select('id')
        .eq('pincode', pincode)
        .eq('is_active', true)
        .maybeSingle();
    return data != null;
  }
}
