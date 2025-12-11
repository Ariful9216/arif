import 'package:arif_mart/core/constants/api.dart';

class OperatorModel {
  final bool success;
  final String message;
  final List<OperatorData> data;

  OperatorModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OperatorModel.fromJson(Map<String, dynamic> json) {
    return OperatorModel(
      success: json['success'],
      message: json['message'],
      data: List<OperatorData>.from(
        json['data'].map((item) => OperatorData.fromJson(item)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}


class OperatorData {
  final String id;
  final String name;
  final String image;
  final String themeColor;
  final bool isActive;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int operatorId;
  final num v;

  OperatorData({
    required this.id,
    required this.name,
    required this.image,
    required this.themeColor,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.operatorId,
    required this.v,
  });

  factory OperatorData.fromJson(Map<String, dynamic> json) {
    return OperatorData(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      themeColor: json['themeColor'],
      isActive: json['isActive'],
      isDeleted: json['isDeleted'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      operatorId: json['operatorId'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'image': image,
      'themeColor': themeColor,
      'isActive': isActive,
      'isDeleted': isDeleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'operatorId': operatorId,
      '__v': v,
    };
  }

  // Get full image URL
  String get imageUrl => '${Apis.operatorBaseUrl}$image';
}
