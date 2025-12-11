import 'package:arif_mart/core/constants/api.dart';

class SocialMediaModel {
  final bool success;
  final String message;
  final List<SocialMediaItem> data;

  SocialMediaModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SocialMediaModel.fromJson(Map<String, dynamic> json) {
    return SocialMediaModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SocialMediaItem.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SocialMediaItem {
  final String id;
  final String name;
  final String url;
  final String logo;

  SocialMediaItem({
    required this.id,
    required this.name,
    required this.url,
    required this.logo,
  });

  factory SocialMediaItem.fromJson(Map<String, dynamic> json) {
    return SocialMediaItem(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      url: json['url'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'url': url,
      'logo': logo,
    };
  }

  // Get full logo URL
  String get logoUrl => '${Apis.socialMediaBaseUrl}$logo';
} 