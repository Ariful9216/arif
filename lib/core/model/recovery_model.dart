class RecoveryRequest {
  final String phoneNumber;
  final String name;
  final double balance;

  RecoveryRequest({
    required this.phoneNumber,
    required this.name,
    required this.balance,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'name': name,
      'balance': balance,
    };
  }
}

class RecoveryResponse {
  final bool success;
  final String message;
  final RecoveryData? data;

  RecoveryResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RecoveryResponse.fromJson(Map<String, dynamic> json) {
    return RecoveryResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? RecoveryData.fromJson(json['data']) : null,
    );
  }
}

class RecoveryData {
  final bool success;
  final String? token;
  final String? liveToken;
  final bool? recoveryFailed;

  RecoveryData({
    required this.success,
    this.token,
    this.liveToken,
    this.recoveryFailed,
  });

  factory RecoveryData.fromJson(Map<String, dynamic> json) {
    return RecoveryData(
      success: json['success'] as bool? ?? false,
      token: json['token'] as String?,
      liveToken: json['liveToken'] as String?,
      recoveryFailed: json['recoveryFailed'] as bool?,
    );
  }
}

class ResetPasswordRequest {
  final String newPassword;

  ResetPasswordRequest({
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'newPassword': newPassword,
    };
  }
}

class ResetPasswordResponse {
  final bool success;
  final String message;
  final ResetPasswordData? data;

  ResetPasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null ? ResetPasswordData.fromJson(json['data']) : null,
    );
  }
}

class ResetPasswordData {
  final bool success;

  ResetPasswordData({
    required this.success,
  });

  factory ResetPasswordData.fromJson(Map<String, dynamic> json) {
    return ResetPasswordData(
      success: json['success'] as bool,
    );
  }
}
