class AddressModel {
  final bool success;
  final String message;
  final List<AddressData>? data;

  AddressModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data']['addresses'] != null
          ? List<AddressData>.from(
              json['data']['addresses'].map((x) => AddressData.fromJson(x))
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((x) => x.toJson()).toList(),
    };
  }
}

class AddressData {
  final String id;
  final String user;
  final String name;
  final String phone;
  final String district;
  final String thana;
  final String village;
  final String fullAddress;
  final String landmark;
  final String postalCode;
  final String addressType;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AddressData({
    required this.id,
    required this.user,
    required this.name,
    required this.phone,
    required this.district,
    required this.thana,
    required this.village,
    required this.fullAddress,
    required this.landmark,
    required this.postalCode,
    required this.addressType,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      district: json['district'] ?? '',
      thana: json['thana'] ?? '',
      village: json['village'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      landmark: json['landmark'] ?? '',
      postalCode: json['postalCode'] ?? '',
      addressType: json['addressType'] ?? 'home',
      isDefault: json['isDefault'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'name': name,
      'phone': phone,
      'district': district,
      'thana': thana,
      'village': village,
      'fullAddress': fullAddress,
      'landmark': landmark,
      'postalCode': postalCode,
      'addressType': addressType,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get displayAddress {
    return '$fullAddress, $village, $thana, $district';
  }

  String get shortAddress {
    return '$village, $thana, $district';
  }

  String get addressTypeIcon {
    switch (addressType.toLowerCase()) {
      case 'home':
        return '🏠';
      case 'work':
        return '🏢';
      default:
        return '📍';
    }
  }

  String get addressTypeDisplay {
    switch (addressType.toLowerCase()) {
      case 'home':
        return 'Home';
      case 'work':
        return 'Work';
      default:
        return 'Other';
    }
  }

  // Create a copy with updated fields
  AddressData copyWith({
    String? id,
    String? user,
    String? name,
    String? phone,
    String? district,
    String? thana,
    String? village,
    String? fullAddress,
    String? landmark,
    String? postalCode,
    String? addressType,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AddressData(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      district: district ?? this.district,
      thana: thana ?? this.thana,
      village: village ?? this.village,
      fullAddress: fullAddress ?? this.fullAddress,
      landmark: landmark ?? this.landmark,
      postalCode: postalCode ?? this.postalCode,
      addressType: addressType ?? this.addressType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Single address response model
class SingleAddressModel {
  final bool success;
  final String message;
  final AddressData? data;

  SingleAddressModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory SingleAddressModel.fromJson(Map<String, dynamic> json) {
    return SingleAddressModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AddressData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

