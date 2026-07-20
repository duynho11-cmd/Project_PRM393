import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String id;
  final String label;       // "Nhà riêng", "Công ty", v.v.
  final String fullName;
  final String phone;
  final String street;      // Số nhà, tên đường
  final String ward;        // Phường/Xã
  final String district;    // Quận/Huyện
  final String province;    // Tỉnh/Thành phố
  final bool isDefault;
  final DateTime createdAt;

  AddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.ward,
    required this.district,
    required this.province,
    required this.isDefault,
    required this.createdAt,
  });

  /// Full address string dùng cho checkout / hiển thị
  String get fullAddress =>
      '$street, $ward, $district, $province';

  factory AddressModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AddressModel(
      id: id,
      label: data['label'] ?? 'Nhà riêng',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      street: data['street'] ?? '',
      ward: data['ward'] ?? '',
      district: data['district'] ?? '',
      province: data['province'] ?? '',
      isDefault: data['isDefault'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'street': street,
    'ward': ward,
    'district': district,
    'province': province,
    'isDefault': isDefault,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  AddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? street,
    String? ward,
    String? district,
    String? province,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return AddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      street: street ?? this.street,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      province: province ?? this.province,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
