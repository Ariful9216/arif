
class BannerModel {
  final bool success;
  final String message;
  final List<BannerData> data;

  BannerModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => BannerData.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((banner) => banner.toJson()).toList(),
    };
  }
}

class BannerData {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String linkUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;

  BannerData({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.linkUrl,
    required this.isActive,
    required this.displayOrder,
    this.startDate,
    this.endDate,
    required this.createdAt,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['url'] ?? json['imageUrl'] ?? '', // API uses 'url' field
      linkUrl: json['redirect_url'] ?? json['linkUrl'] ?? '', // API uses 'redirect_url' field
      isActive: json['isActive'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Get full image URL
  String get fullImageUrl {
    print('Processing imageUrl: "$imageUrl"');
    
    if (imageUrl.isEmpty) {
      print('Image URL is empty');
      return '';
    }
    
    if (imageUrl.startsWith('http')) {
      print('Image URL already has protocol: $imageUrl');
      return imageUrl;
    }
    
    // Remove leading slash if present and add domain
    String cleanPath = imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl;
    String fullUrl = 'https://ecommerce.arifmart.app/$cleanPath';
    print('Generated full URL: $fullUrl');
    return fullUrl;
  }

  // Check if banner is currently active based on date range
  bool get isCurrentlyActive {
    if (!isActive) return false;
    
    final now = DateTime.now();
    
    if (startDate != null && now.isBefore(startDate!)) {
      return false;
    }
    
    if (endDate != null && now.isAfter(endDate!)) {
      return false;
    }
    
    return true;
  }
}
