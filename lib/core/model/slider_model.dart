import 'package:arif_mart/core/constants/api.dart';

class SliderModel {
  final bool success;
  final String message;
  final List<SliderItem> data;

  SliderModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => SliderItem.fromJson(e))
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

class SliderItem {
  final String id;
  final String title;
  final String description;
  final String image;
  final String link;
  final bool isActive;
  final String type;
  final String createdAt;
  final String updatedAt;

  SliderItem({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.link,
    required this.isActive,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SliderItem.fromJson(Map<String, dynamic> json) {
    return SliderItem(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      link: json['link'] ?? '',
      isActive: json['isActive'] ?? false,
      type: json['type'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'link': link,
      'isActive': isActive,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Get full image URL
  String get imageUrl => '${Apis.sliderBaseUrl}$image';
} 