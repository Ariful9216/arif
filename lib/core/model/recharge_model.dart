class RechargeModel {
  final bool success;
  final String message;
  final List<RechargeData>? data;
  final PaginationMetadata? pagination;

  RechargeModel({
    required this.success,
    required this.message,
    this.data,
    this.pagination,
  });

  factory RechargeModel.fromJson(Map<String, dynamic> json) {
    List<RechargeData>? rechargeList;
    PaginationMetadata? paginationData;
    
    print('🔍 RechargeModel.fromJson parsing...');
    print('   Input keys: ${json.keys.toList()}');
    
    // The API response has data as an object with recharges and pagination
    if (json['data'] != null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      print('   Data is Map with keys: ${dataMap.keys.toList()}');
      
      // Extract recharges list
      if (dataMap['recharges'] != null && dataMap['recharges'] is List) {
        try {
          final rechargesList = dataMap['recharges'] as List;
          print('   Found recharges list with ${rechargesList.length} items');
          rechargeList = rechargesList
              .map((item) {
                if (item is Map<String, dynamic>) {
                  return RechargeData.fromJson(item);
                }
                return null;
              })
              .whereType<RechargeData>()
              .toList();
          print('   ✅ Parsed ${rechargeList.length} recharges');
        } catch (e) {
          print('   ❌ Error parsing recharges list: $e');
          rechargeList = null;
        }
      }
      
      // Extract pagination metadata
      if (dataMap['pagination'] != null && dataMap['pagination'] is Map<String, dynamic>) {
        try {
          paginationData = PaginationMetadata.fromJson(
            dataMap['pagination'] as Map<String, dynamic>
          );
          print('   ✅ Pagination parsed: total=${paginationData.total}, page=${paginationData.page}, pages=${paginationData.pages}');
        } catch (e) {
          print('   ❌ Error parsing pagination: $e');
          paginationData = null;
        }
      } else {
        print('   ⚠️ No pagination found in data object');
      }
    } else if (json['data'] != null && json['data'] is List) {
      // Fallback: if data is directly a list
      try {
        final dataValue = json['data'] as List;
        print('   Data is List with ${dataValue.length} items');
        rechargeList = dataValue
            .map((item) {
              if (item is Map<String, dynamic>) {
                return RechargeData.fromJson(item);
              }
              return null;
            })
            .whereType<RechargeData>()
            .toList();
        print('   ✅ Parsed ${rechargeList.length} recharges from list');
      } catch (e) {
        print('   ❌ Error parsing data list: $e');
        rechargeList = null;
      }
    }
    
    // Extract pagination from top level if not found in data
    if (paginationData == null && json['pagination'] != null) {
      try {
        print('   Checking top-level pagination...');
        paginationData = PaginationMetadata.fromJson(
          json['pagination'] as Map<String, dynamic>
        );
        print('   ✅ Top-level pagination parsed');
      } catch (e) {
        print('   ❌ Error parsing top-level pagination: $e');
      }
    }
    
    print('📊 Final Result:');
    print('   - success: ${json['success']}');
    print('   - recharges: ${rechargeList?.length ?? 0}');
    print('   - pagination.total: ${paginationData?.total ?? 'NULL'}');
    print('   - pagination.page: ${paginationData?.page ?? 'NULL'}');
    print('   - pagination.pages: ${paginationData?.pages ?? 'NULL'}');
    
    return RechargeModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: rechargeList,
      pagination: paginationData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
      'pagination': pagination?.toJson(),
    };
  }
}

class PaginationMetadata {
  final int total;
  final int page;
  final int limit;
  final int pages;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationMetadata({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMetadata.fromJson(Map<String, dynamic> json) {
    return PaginationMetadata(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'pages': pages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}

class RechargeData {
  final String id;
  final RechargeUser? userId;
  final String phoneNumber;
  final num amount;
  final String operator;
  final String status;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? retryCount;
  final int? version;

  RechargeData({
    required this.id,
    this.userId,
    required this.phoneNumber,
    required this.amount,
    required this.operator,
    required this.status,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.retryCount,
    this.version,
  });

  factory RechargeData.fromJson(Map<String, dynamic> json) {
    return RechargeData(
      id: json['_id'] ?? '',
      userId: json['userId'] != null 
          ? RechargeUser.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      phoneNumber: json['phoneNumber'] ?? '',
      amount: _parseAmount(json['amount']),
      operator: json['operator'] ?? '',
      status: json['status'] ?? '',
      description: json['description'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
      retryCount: json['retry_count'],
      version: json['__v'],
    );
  }

  // Helper method to parse amount (can be string or number)
  static num _parseAmount(dynamic amount) {
    if (amount == null) return 0;
    if (amount is num) return amount;
    if (amount is String) {
      try {
        return num.parse(amount);
      } catch (e) {
        return 0;
      }
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId?.toJson(),
      'phoneNumber': phoneNumber,
      'amount': amount,
      'operator': operator,
      'status': status,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'retry_count': retryCount,
      '__v': version,
    };
  }

  // Get formatted amount
  String get formattedAmount => '৳${amount.toStringAsFixed(0)}';

  // Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'completed':
        return '#4CAF50'; // Green
      case 'pending':
        return '#FF9800'; // Orange
      case 'processing':
        return '#2196F3'; // Blue
      case 'failed':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get status display text
  String get statusDisplayText {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      default:
        return 'Unknown';
    }
  }
}

class RechargeUser {
  final String id;
  final String name;
  final String email;

  RechargeUser({
    required this.id,
    required this.name,
    required this.email,
  });

  factory RechargeUser.fromJson(Map<String, dynamic> json) {
    return RechargeUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
    };
  }
}
