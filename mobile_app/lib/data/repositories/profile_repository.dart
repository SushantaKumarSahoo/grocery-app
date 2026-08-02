import '../../core/config/supabase_config.dart';
import '../models/app_user.dart';

class ProfileRepository {
  Future<Profile?> fetchProfile(String userId) async {
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return Profile.fromMap(data);
  }

  Future<Profile> createProfile({
    required String userId,
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final data = await supabase
        .from('profiles')
        .insert({
          'id': userId,
          'full_name': fullName,
          'email': email,
          'phone': phone,
        })
        .select()
        .single();
    return Profile.fromMap(data);
  }

  Future<Profile> updateProfile(String userId, Map<String, dynamic> updates) async {
    final data = await supabase
        .from('profiles')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
    return Profile.fromMap(data);
  }

  Future<List<Address>> fetchAddresses(String userId) async {
    final data = await supabase
        .from('addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => Address.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<Address> addAddress({
    required String userId,
    required String label,
    required String fullAddress,
    String houseDetails = '',
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    if (isDefault) {
      await supabase.from('addresses').update({'is_default': false}).eq('user_id', userId);
    }
    final data = await supabase
        .from('addresses')
        .insert({
          'user_id': userId,
          'label': label,
          'full_address': fullAddress,
          'house_details': houseDetails,
          'latitude': latitude,
          'longitude': longitude,
          'is_default': isDefault,
        })
        .select()
        .single();
    return Address.fromMap(data);
  }

  Future<void> deleteAddress(String id) async {
    await supabase.from('addresses').delete().eq('id', id);
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    await supabase.from('addresses').update({'is_default': false}).eq('user_id', userId);
    await supabase.from('addresses').update({'is_default': true}).eq('id', addressId);
  }
}
