import 'package:arif_mart/core/constants/api.dart';

class MobileBankingModel {
  final bool success;
  final String message;
  final List<MobileBankingItem> data;

  MobileBankingModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory MobileBankingModel.fromJson(Map<String, dynamic> json) {
    return MobileBankingModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => MobileBankingItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class MobileBankingItem {
  final String id;
  final String name;
  final String logo;
  final bool isActive;

  MobileBankingItem({
    required this.id,
    required this.name,
    required this.logo,
    required this.isActive,
  });

  factory MobileBankingItem.fromJson(Map<String, dynamic> json) {
    return MobileBankingItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? false,
    );
  }

  // Get full logo URL
  String get logoUrl => '${Apis.mobileBankingBaseUrl}$logo';
} 