class WithdrawalModel {
  final bool success;
  final String message;
  final List<WithdrawalItem> data;

  WithdrawalModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory WithdrawalModel.fromJson(Map<String, dynamic> json) {
    return WithdrawalModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => WithdrawalItem.fromJson(item))
              .toList()
          : [],
    );
  }
}

class WithdrawalItem {
  final String id;
  final String userId;
  final String type;
  final double amount;
  final String status;
  final String? mobileOperator;
  final String? mobileNumber;
  final String? bankName;
  final String? bankBranchName;
  final String? bankAccountNumber;
  final String? accountHolderName;
  final String createdAt;
  final String updatedAt;

  WithdrawalItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    this.mobileOperator,
    this.mobileNumber,
    this.bankName,
    this.bankBranchName,
    this.bankAccountNumber,
    this.accountHolderName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WithdrawalItem.fromJson(Map<String, dynamic> json) {
    return WithdrawalItem(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      mobileOperator: json['mobileOperator'],
      mobileNumber: json['mobileNumber'],
      bankName: json['bankName'],
      bankBranchName: json['bankBranchName'],
      bankAccountNumber: json['bankAccountNumber'],
      accountHolderName: json['accountHolderName'],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
} 