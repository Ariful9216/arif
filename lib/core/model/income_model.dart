class IncomeModel {
  final bool success;
  final IncomeData message;
  final String data;

  IncomeModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      success: json['success'] ?? false,
      message: IncomeData.fromJson(json['message'] ?? {}),
      data: json['data'] ?? '',
    );
  }
}

class IncomeData {
  final String id;
  final String user;
  final double fromReferral;
  final double fromShopping;
  final double fromRecharge;
  final double totalIncome;
  final String createdAt;
  final String updatedAt;
  final int version;
  final LastTransaction? lastTransaction;

  IncomeData({
    required this.id,
    required this.user,
    required this.fromReferral,
    required this.fromShopping,
    required this.fromRecharge,
    required this.totalIncome,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    this.lastTransaction,
  });

  factory IncomeData.fromJson(Map<String, dynamic> json) {
    return IncomeData(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      fromReferral: (json['fromReferral'] ?? 0).toDouble(),
      fromShopping: (json['fromShopping'] ?? 0).toDouble(),
      fromRecharge: (json['fromRecharge'] ?? 0).toDouble(),
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      version: json['__v'] ?? 0,
      lastTransaction: json['lastTransaction'] != null
          ? LastTransaction.fromJson(json['lastTransaction'])
          : null,
    );
  }
}

class LastTransaction {
  final String id;
  final double amount;
  final String type;
  final String description;
  final String createdAt;

  LastTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory LastTransaction.fromJson(Map<String, dynamic> json) {
    return LastTransaction(
      id: json['_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
} 