import 'package:intl/intl.dart';

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}

class RechargeHistoryItem {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final double amount;
  final String status;
  final String transactionId;
  final String operator;
  final String mobileNumber;
  final int retryCount;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  RechargeHistoryItem({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.amount,
    required this.status,
    required this.transactionId,
    required this.operator,
    required this.mobileNumber,
    this.retryCount = 0,
    this.description = '',
    required this.createdAt,
    required this.updatedAt,
  });

  // Format the date in a human-readable format
  String get formattedDate {
    final DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(createdAt);
  }

  // Status color helper
  bool get isSuccess => status.toLowerCase() == 'success' || status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isProcessing => status.toLowerCase() == 'processing';
  bool get isFailed => status.toLowerCase() == 'failed' || status.toLowerCase() == 'rejected';

  factory RechargeHistoryItem.fromJson(Map<String, dynamic> json) {
    print('Parsing RechargeHistoryItem from JSON: ${json.keys}');
    
    Map<String, dynamic>? userJson;
    String userId = '';
    String? userName;
    String? userEmail;
    
    // Safely extract user information
    if (json['userId'] != null) {
      if (json['userId'] is Map) {
        userJson = json['userId'] as Map<String, dynamic>;
        userId = userJson['_id']?.toString() ?? '';
        userName = userJson['name']?.toString();
        userEmail = userJson['email']?.toString();
      } else {
        userId = json['userId'].toString();
      }
    }
    
    // Safely convert amount to double
    double amount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        amount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        try {
          amount = double.parse(json['amount']);
        } catch (e) {
          print('Error parsing amount: ${json['amount']}');
        }
      }
    }
    
    // Handle phoneNumber vs mobileNumber
    String mobileNumber = '';
    if (json.containsKey('phoneNumber')) {
      mobileNumber = json['phoneNumber']?.toString() ?? '';
    } else if (json.containsKey('mobileNumber')) {
      mobileNumber = json['mobileNumber']?.toString() ?? '';
    }
    
    // Handle transactionId (might not be present in all responses)
    String transactionId = json['transactionId']?.toString() ?? json['_id']?.toString() ?? '';

    // Handle retry_count
    int retryCount = 0;
    if (json['retry_count'] != null) {
      if (json['retry_count'] is int) {
        retryCount = json['retry_count'];
      } else {
        try {
          retryCount = int.parse(json['retry_count'].toString());
        } catch (e) {
          print('Error parsing retry_count: ${json['retry_count']}');
        }
      }
    }

    return RechargeHistoryItem(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      amount: amount,
      status: json['status']?.toString() ?? 'pending',
      transactionId: transactionId,
      operator: json['operator']?.toString() ?? '',
      mobileNumber: mobileNumber,
      retryCount: retryCount,
      description: json['description']?.toString() ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now(),
    );
  }
}

class CreditHistoryItem {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String description;
  final String status;
  final String reference;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  CreditHistoryItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    required this.status,
    required this.reference,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Format the date in a human-readable format
  String get formattedDate {
    final DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(createdAt);
  }

  // Get payment method from metadata
  String get paymentMethod {
    if (metadata.containsKey('payment_method')) {
      return metadata['payment_method']?.toString() ?? 'N/A';
    } else if (metadata.containsKey('paymentMethod')) {
      return metadata['paymentMethod']?.toString() ?? 'N/A';
    }
    return 'N/A';
  }

  // Helper to get appropriate icon for type
  String get typeIcon {
    switch(type.toLowerCase()) {
      case 'credit':
        return 'credit_icon.png';
      case 'debit':
        return 'debit_icon.png';
      default:
        return 'transaction_icon.png';
    }
  }

  factory CreditHistoryItem.fromJson(Map<String, dynamic> json) {
    print('Parsing CreditHistoryItem from JSON: ${json.keys}');
    
    // Safely extract user ID
    String userId = '';
    if (json['user'] != null) {
      if (json['user'] is String) {
        userId = json['user'];
      } else if (json['user'] is Map && json['user']['_id'] != null) {
        userId = json['user']['_id'].toString();
      } else {
        userId = json['user'].toString();
      }
    } else if (json['userId'] != null) {
      if (json['userId'] is String) {
        userId = json['userId'];
      } else if (json['userId'] is Map && json['userId']['_id'] != null) {
        userId = json['userId']['_id'].toString();
      } else {
        userId = json['userId'].toString();
      }
    }
    
    // Safely convert amount to double
    double amount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        amount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        try {
          amount = double.parse(json['amount']);
        } catch (e) {
          print('Error parsing amount in credit history: ${json['amount']}');
        }
      }
    }
    
    // Safely handle metadata
    Map<String, dynamic> safeMetadata = {};
    if (json['metadata'] != null) {
      if (json['metadata'] is Map) {
        (json['metadata'] as Map).forEach((key, value) {
          safeMetadata[key.toString()] = value;
        });
      }
    }
    
    return CreditHistoryItem(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      amount: amount,
      type: json['type']?.toString() ?? 'credit',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      reference: json['reference']?.toString() ?? '',
      metadata: safeMetadata,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'].toString()) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'].toString()) 
          : DateTime.now(),
    );
  }
}

class WithdrawalHistoryItem {
  final String id;
  final String userId;
  final double amount;
  final String status;
  final String? type;
  final String? mobileOperator;
  final String? mobileNumber;
  final String? bankName;
  final String? bankBranchName;
  final String? bankAccountNumber;
  final String? accountHolderName;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  WithdrawalHistoryItem({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    this.type,
    this.mobileOperator,
    this.mobileNumber,
    this.bankName,
    this.bankBranchName,
    this.bankAccountNumber,
    this.accountHolderName,
    required this.createdAt,
    required this.updatedAt,
  });

  // Format the date in a human-readable format
  String get formattedDate {
    final DateFormat formatter = DateFormat('MMM dd, yyyy hh:mm a');
    return formatter.format(createdAt);
  }

  // Status helpers
  bool get isSuccess => status.toLowerCase() == 'success' || status.toLowerCase() == 'completed';
  bool get isPending => status.toLowerCase() == 'pending' || status.toLowerCase() == 'processing';
  bool get isFailed => status.toLowerCase() == 'failed' || status.toLowerCase() == 'rejected';

  // Get type display name
  String get typeDisplayName {
    if (type == null || type!.isEmpty) {
      // Try to infer type from available fields
      if (mobileOperator != null || mobileNumber != null) {
        return 'Mobile Banking';
      } else if (bankName != null || bankAccountNumber != null) {
        return 'Bank Transfer';
      }
      return 'Withdrawal';
    }
    return type == 'mobile_banking' ? 'Mobile Banking' : 'Bank Transfer';
  }

  // Get account display text based on type
  String get accountDisplayText {
    try {
      final withdrawalType = type ?? '';
      
      if (withdrawalType == 'mobile_banking' || (mobileOperator != null || mobileNumber != null)) {
        final operator = mobileOperator ?? 'N/A';
        final number = mobileNumber ?? 'N/A';
        return '$operator - $number';
      } else if (withdrawalType == 'bank_transfer' || (bankName != null || bankAccountNumber != null)) {
        final bank = bankName ?? 'N/A';
        final branch = bankBranchName ?? 'N/A';
        return '$bank - $branch';
      }
    } catch (e) {
      print('Error getting accountDisplayText: $e');
      return 'Account info unavailable';
    }
    return 'Not specified';
  }

  factory WithdrawalHistoryItem.fromJson(Map<String, dynamic> json) {
    print('Processing withdrawal item: $json');
    
    // Safely convert amount to double
    double amount = 0.0;
    if (json['amount'] != null) {
      if (json['amount'] is num) {
        amount = (json['amount'] as num).toDouble();
      } else if (json['amount'] is String) {
        try {
          amount = double.parse(json['amount']);
        } catch (e) {
          print('Error parsing amount: ${json['amount']} (type: ${json['amount'].runtimeType}): $e');
        }
      } else {
        print('Unexpected amount type: ${json['amount'].runtimeType}');
      }
    }
    
    // Safely extract user ID
    String userId = '';
    if (json['userId'] != null) {
      if (json['userId'] is String) {
        userId = json['userId'];
      } else if (json['userId'] is Map) {
        userId = json['userId']['_id']?.toString() ?? '';
      } else {
        userId = json['userId'].toString();
      }
    }
    
    // Safely handle dates
    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } catch (e) {
        print('Error parsing createdAt: ${json['createdAt']}: $e');
      }
    }
    
    DateTime updatedAt = DateTime.now();
    if (json['updatedAt'] != null) {
      try {
        updatedAt = DateTime.parse(json['updatedAt'].toString());
      } catch (e) {
        print('Error parsing updatedAt: ${json['updatedAt']}: $e');
      }
    }
    
    // Determine type from JSON or infer from available fields
    String? withdrawalType = json['type']?.toString();
    if (withdrawalType == null || withdrawalType.isEmpty) {
      // Try to infer type from available fields
      if (json['mobileOperator'] != null || json['mobileNumber'] != null) {
        withdrawalType = 'mobile_banking';
      } else if (json['bankName'] != null || json['bankAccountNumber'] != null) {
        withdrawalType = 'bank_transfer';
      }
      print('Inferred withdrawal type: $withdrawalType');
    }
    
    return WithdrawalHistoryItem(
      id: json['_id']?.toString() ?? '',
      userId: userId,
      amount: amount,
      status: json['status']?.toString() ?? 'pending',
      type: withdrawalType,
      mobileOperator: json['mobileOperator']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      bankName: json['bankName']?.toString(),
      bankBranchName: json['bankBranchName']?.toString(),
      bankAccountNumber: json['bankAccountNumber']?.toString(),
      accountHolderName: json['accountHolderName']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}