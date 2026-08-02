class Profile {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarUrl;

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'avatar_url': avatarUrl,
      };
}

class Address {
  final String id;
  final String userId;
  final String label;
  final String fullAddress;
  final String houseDetails;
  final double? latitude;
  final double? longitude;
  final bool isDefault;

  const Address({
    required this.id,
    required this.userId,
    required this.label,
    required this.fullAddress,
    this.houseDetails = '',
    this.latitude,
    this.longitude,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> map) {
    return Address(
      id: map['id'] as String,
      userId: map['user_id'] as String? ?? '',
      label: map['label'] as String? ?? 'Home',
      fullAddress: map['full_address'] as String? ?? '',
      houseDetails: map['house_details'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isDefault: map['is_default'] as bool? ?? false,
    );
  }
}
