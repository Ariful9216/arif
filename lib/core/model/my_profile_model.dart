class MyProfileModel {
  final bool success;
  final String message;
  final ProfileData? data;

  MyProfileModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory MyProfileModel.fromJson(Map<String, dynamic> json) {
    return MyProfileModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
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

class ProfileData {
  final String id;
  final String phoneNo;
  final String name;
  final String? referredBy;
  final bool isActive;
  final bool isVerified;
  final bool isDeleted;
  final String referralCode;
  final String createdAt;
  final String updatedAt;
  final String subscriptionDate;
  final String subscriptionTransactionId;
  final num v;
  final Wallet wallet;

  ProfileData({
    required this.id,
    required this.phoneNo,
    required this.name,
    this.referredBy,
    required this.isActive,
    required this.isVerified,
    required this.isDeleted,
    required this.referralCode,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.wallet,
    required this.subscriptionDate,
    required this.subscriptionTransactionId
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['_id'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      name: json['name'] ?? '',
      referredBy: json['referredBy'],
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      referralCode: json['referralCode'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      subscriptionDate: json['subscriptionDate'] ?? '',
      subscriptionTransactionId: json['subscriptionTransactionId'] ?? '',
      v: json['__v'] ?? 0,
      wallet: Wallet.fromJson(json['wallet'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'phoneNo': phoneNo,
      'name': name,
      'referredBy': referredBy,
      'isActive': isActive,
      'isVerified': isVerified,
      'isDeleted': isDeleted,
      'referralCode': referralCode,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'subscriptionDate': subscriptionDate,
      'subscriptionTransactionId': subscriptionTransactionId,
      '__v': v,
      'wallet': wallet.toJson(),
    };
  }
}

class Wallet {
  final String id;
  final num balance;

  Wallet({
    required this.id,
    required this.balance,
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      id: json['_id'] ?? '',
      balance: json['balance'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'balance': balance,
    };
  }
}
