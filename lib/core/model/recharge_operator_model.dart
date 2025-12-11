class RechargeOperatorModel {
  final bool success;
  final String message;
  final List<RechargeOperatorData>? data;

  RechargeOperatorModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory RechargeOperatorModel.fromJson(Map<String, dynamic> json) {
    return RechargeOperatorModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null 
          ? List<RechargeOperatorData>.from(
              json['data'].map((item) => RechargeOperatorData.fromJson(item))
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class RechargeOperatorData {
  final String id;
  final String operatorName;
  final String operatorCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  RechargeOperatorData({
    required this.id,
    required this.operatorName,
    required this.operatorCode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RechargeOperatorData.fromJson(Map<String, dynamic> json) {
    return RechargeOperatorData(
      id: json['_id'] ?? '',
      operatorName: json['operatorName'] ?? '',
      operatorCode: json['operatorCode'] ?? '',
      isActive: json['isActive'] ?? false,
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
      'operatorName': operatorName,
      'operatorCode': operatorCode,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Get operator display name
  String get displayName => operatorName;

  // Get operator code for API calls
  String get code => operatorCode;

  // Check if operator is available for recharge
  bool get isAvailable => isActive;
}

