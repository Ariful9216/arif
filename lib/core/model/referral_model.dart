class ReferralModel {
  final bool success;
  final String message;
  final ReferralData? data;

  ReferralModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ReferralModel.fromJson(Map<String, dynamic> json) {
    return ReferralModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ReferralData.fromJson(json['data']) : null,
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

class ReferralData {
  final double reward;
  final String referralCode;
  final int totalReferralCount;
  final List<RecentReferral> recentReferrals;

  ReferralData({
    required this.reward,
    required this.referralCode,
    required this.totalReferralCount,
    required this.recentReferrals,
  });

  factory ReferralData.fromJson(Map<String, dynamic> json) {
    return ReferralData(
      reward: (json['reward'] ?? 0).toDouble(),
      referralCode: json['referralCode'] ?? '',
      totalReferralCount: json['total_referral_count'] ?? 0,
      recentReferrals: (json['recent_referrals'] as List<dynamic>?)
          ?.map((e) => RecentReferral.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reward': reward,
      'referralCode': referralCode,
      'total_referral_count': totalReferralCount,
      'recent_referrals': recentReferrals.map((e) => e.toJson()).toList(),
    };
  }
}

class RecentReferral {
  final String id;
  final String name;
  final String phoneNo;
  final String createdAt;
  final bool isActive;
  final bool isVerified;

  RecentReferral({
    required this.id,
    required this.name,
    required this.phoneNo,
    required this.createdAt,
    required this.isActive,
    required this.isVerified,
  });

  factory RecentReferral.fromJson(Map<String, dynamic> json) {
    return RecentReferral(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      createdAt: json['createdAt'] ?? '',
      isActive: json['isActive'] ?? false,
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phoneNo': phoneNo,
      'createdAt': createdAt,
      'isActive': isActive,
      'isVerified': isVerified,
    };
  }
} 