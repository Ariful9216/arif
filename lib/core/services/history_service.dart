import 'package:dio/dio.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/model/history_model.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';
import 'package:get/get.dart';

class HistoryService {
  final Dio _dio;

  HistoryService() : _dio = Dio() {
    _dio.options.baseUrl = Apis.baseUrl;

    // Configure Dio timeouts
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // Set default headers
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Automatically set token from HiveHelper
    setTokenFromHive();

    // Add request interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
  
  // Set token from HiveHelper
  void setTokenFromHive() {
    final token = HiveHelper.getToken;
    if (token != null && token.isNotEmpty) {
      // Format the token correctly
      _dio.options.headers['Authorization'] = token.startsWith('Bearer ') 
          ? token 
          : 'Bearer $token';
    }
  }

  // Set JWT token for authenticated requests
  void setToken(String token) {
    if (token.isEmpty) {
      return;
    }
    
    _dio.options.headers['Authorization'] = token.startsWith('Bearer ') 
        ? token 
        : 'Bearer $token';
  }
  
  // Helper to mask token for logging
  String maskToken(String token) {
    if (token.length <= 10) return '*' * token.length;
    return '${token.substring(0, 5)}...${token.substring(token.length - 5)}';
  }

  // Fetch recharge history
  Future<Map<String, dynamic>> getRechargeHistory({int page = 1, int limit = 10}) async {
    try {
      // Ensure token is set before making the request
      setTokenFromHive();
      
      print('Making request to: ${Apis.baseUrl}history/recharge-history');
      print('Query params: page=$page, limit=$limit');
      
      final response = await _dio.get(
        'history/recharge-history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        print('Recharge response received');
        print('Response type: ${response.data.runtimeType}');
        print('Response keys: ${response.data is Map ? response.data.keys.toList() : "Not a map"}');
        
        // Return raw data for controller to parse
        List<dynamic> rechargesRaw = [];
        Map<String, dynamic>? paginationRaw;
        
        // Check if data exists and what type it is
        if (response.data.containsKey('data')) {
          var data = response.data['data'];
          print('Data field exists, type: ${data.runtimeType}');
          
          if (data is List) {
            // Direct list of recharges
            print('Direct list format detected with ${data.length} items');
            rechargesRaw = data;
          } else if (data is Map && data.containsKey('recharges')) {
            // Nested structure with recharges field
            print('Nested structure with recharges field');
            if (data['recharges'] is List) {
              print('Found recharges list with ${data['recharges'].length} items');
              rechargesRaw = data['recharges'];
              
              // Check for pagination in nested data
              if (data.containsKey('pagination')) {
                paginationRaw = data['pagination'] as Map<String, dynamic>?;
              }
            }
          } else {
            print('Data is neither a list nor has recharges field');
          }
        } else {
          print('No data field in response');
        }
        
        // Get pagination from response root if not found in nested data
        if (paginationRaw == null && response.data.containsKey('pagination')) {
          paginationRaw = response.data['pagination'] as Map<String, dynamic>?;
        }
        
        // Create default pagination if not available
        if (paginationRaw == null) {
          paginationRaw = {
            'total': rechargesRaw.length,
            'page': page,
            'limit': limit,
            'pages': 1,
            'hasNextPage': false,
            'hasPrevPage': page > 1,
          };
        }
        
        print('Returning ${rechargesRaw.length} raw recharge items');
        
        return {
          'recharges': rechargesRaw,
          'pagination': paginationRaw,
        };
      }
      
      throw Exception('Failed to load recharge history');
    } on DioException catch (e) {
      print('DioException caught in getRechargeHistory:');
      print('- Status code: ${e.response?.statusCode}');
      print('- Response data: ${e.response?.data}');
      print('- Request URI: ${e.requestOptions.uri}');
      
      // Handle 401 Unauthorized error silently
      if (e.response?.statusCode == 401) {
        print('Authentication error - attempting to refresh token');
        setTokenFromHive();  // Try to refresh the token
      }
      
      throw Exception('Error fetching recharge history: ${e.response?.statusCode} - ${e.response?.statusMessage}');
    }
  }

  // Fetch credit history
  Future<Map<String, dynamic>> getCreditHistory({int page = 1, int limit = 10}) async {
    try {
      // Ensure token is set before making the request
      setTokenFromHive();
      
      print('Making request to: ${Apis.baseUrl}history/credit-history');
      print('Query params: page=$page, limit=$limit');
      
      final response = await _dio.get(
        'history/credit-history',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        print('Credit response received');
        print('Response type: ${response.data.runtimeType}');
        print('Response keys: ${response.data is Map ? response.data.keys.toList() : "Not a map"}');
        
        // Return raw data for controller to parse
        List<dynamic> creditsRaw = [];
        Map<String, dynamic>? paginationRaw;
        
        // Check if data exists and what type it is
        if (response.data.containsKey('data')) {
          var data = response.data['data'];
          print('Data field exists, type: ${data.runtimeType}');
          
          if (data is List) {
            // Direct list of credits (old format)
            print('Direct list format detected with ${data.length} items');
            creditsRaw = data;
          } else if (data is Map) {
            // Nested structure - check for 'transactions', 'credits', or other keys
            if (data.containsKey('transactions')) {
              print('Found transactions field with ${data['transactions'] is List ? data['transactions'].length : 0} items');
              if (data['transactions'] is List) {
                creditsRaw = data['transactions'];
              }
            } else if (data.containsKey('credits')) {
              print('Found credits field with ${data['credits'] is List ? data['credits'].length : 0} items');
              if (data['credits'] is List) {
                creditsRaw = data['credits'];
              }
            }
            
            // Check for pagination in nested data
            if (data.containsKey('pagination')) {
              paginationRaw = data['pagination'] as Map<String, dynamic>?;
            }
          }
        } else {
          print('No data field in response');
        }
        
        // Get pagination from response root if not found in nested data
        if (paginationRaw == null && response.data.containsKey('pagination')) {
          paginationRaw = response.data['pagination'] as Map<String, dynamic>?;
        }
        
        // Create default pagination if not available
        if (paginationRaw == null) {
          paginationRaw = {
            'total': creditsRaw.length,
            'page': page,
            'limit': limit,
            'pages': 1,
            'hasNextPage': false,
            'hasPrevPage': page > 1,
          };
        }
        
        print('Returning ${creditsRaw.length} raw credit items');
        
        return {
          'credits': creditsRaw,
          'pagination': paginationRaw,
        };
      }
      
      throw Exception('Failed to load credit history');
    } on DioException catch (e) {
      print('DioException caught in getCreditHistory:');
      print('- Status code: ${e.response?.statusCode}');
      print('- Response data: ${e.response?.data}');
      print('- Request URI: ${e.requestOptions.uri}');
      
      if (e.response?.statusCode == 401) {
        // Handle 401 Unauthorized error
        print('Authentication error detected. Token might be invalid or expired.');
        final token = HiveHelper.getToken;
        print('Current token status: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "EXISTS (${maskToken(token)})")}');
      }
      
      throw Exception('Error fetching credit history: ${e.response?.statusCode} - ${e.response?.statusMessage} - ${e.response?.data ?? e.message}');
    }
  }

  // Fetch withdrawal history
  Future<Map<String, dynamic>> getWithdrawalHistory({int page = 1, int limit = 10}) async {
    try {
      // Ensure token is set before making the request
      setTokenFromHive();
      
      print('Making request to: ${Apis.baseUrl}history/withdraws-history');
      print('Headers: ${_dio.options.headers}');
      
      final response = await _dio.get(
        'history/withdraws-history',  // Updated endpoint to match the actual API endpoint
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        // Print the entire response for debugging
        print('Withdrawal response type: ${response.data.runtimeType}');
        print('Withdrawal response: ${response.data}');
        
        final Map<String, dynamic> result = {};
        final List<WithdrawalHistoryItem> withdrawals = [];
        
        // Handle all possible response formats
        
        // Case 1: {success: true, message: Success, data: []}
        if (response.data is Map && 
            response.data.containsKey('success') &&
            response.data.containsKey('data')) {
          
          print('Format detected: {success, message, data}');
          var data = response.data['data'];
          
          if (data is List) {
            print('Processing direct list of withdrawals from data field');
            for (var item in data) {
              try {
                withdrawals.add(WithdrawalHistoryItem.fromJson(item));
              } catch (e) {
                print('Error parsing withdrawal item: $e');
                print('Problematic withdrawal data: $item');
              }
            }
            
            // Add data to result
            result['withdrawals'] = withdrawals;
            result['data'] = data;  // Also include raw data for controller
          }
        } 
        // Case 2: {data: {withdrawals: [], pagination: {}}}
        else if (response.data is Map && 
                response.data.containsKey('data') &&
                response.data['data'] is Map) {
          
          print('Format detected: {data: {withdrawals, pagination}}');
          var nestedData = response.data['data'] as Map;
          
          if (nestedData.containsKey('withdrawals') && nestedData['withdrawals'] is List) {
            print('Processing withdrawals from nested data structure');
            for (var item in nestedData['withdrawals']) {
              try {
                withdrawals.add(WithdrawalHistoryItem.fromJson(item));
              } catch (e) {
                print('Error parsing withdrawal item from nested structure: $e');
                print('Problematic withdrawal data: $item');
              }
            }
            
            // Add data to result
            result['withdrawals'] = withdrawals;
            
            // Include pagination if available
            if (nestedData.containsKey('pagination')) {
              try {
                result['pagination'] = PaginationMeta.fromJson(nestedData['pagination']);
              } catch (e) {
                print('Error parsing nested pagination: $e');
              }
            }
          }
        } 
        // Case 3: Other formats
        else {
          print('Unexpected response format - trying to handle generically');
          
          // Try to find any list in the response
          if (response.data is Map) {
            response.data.forEach((key, value) {
              if (value is List) {
                print('Found list at key: $key with ${value.length} items');
                for (var item in value) {
                  try {
                    if (item is Map) {
                      // Convert dynamic Map to Map<String, dynamic>
                      Map<String, dynamic> stringKeyMap = {};
                      item.forEach((key, value) {
                        stringKeyMap[key.toString()] = value;
                      });
                      withdrawals.add(WithdrawalHistoryItem.fromJson(stringKeyMap));
                    }
                  } catch (e) {
                    print('Error parsing item from $key: $e');
                  }
                }
                
                if (withdrawals.isNotEmpty) {
                  result['withdrawals'] = withdrawals;
                }
              }
            });
          }
        }
        
        // If we didn't find any data in the expected formats, return empty lists
        if (!result.containsKey('withdrawals')) {
          result['withdrawals'] = [];
        }
        
        // Create default pagination if not available
        if (!result.containsKey('pagination')) {
          result['pagination'] = PaginationMeta(
            total: withdrawals.length,
            page: page,
            limit: limit,
            pages: 1,
            hasNextPage: false,
            hasPrevPage: page > 1,
          );
        }
        
        // Include the raw response data for debugging
        result['rawResponse'] = response.data;
        
        return result;
      }
      
      throw Exception('Failed to load withdrawal history');
    } on DioException catch (e) {
      print('DioException caught in getWithdrawalHistory:');
      print('- Status code: ${e.response?.statusCode}');
      print('- Response data: ${e.response?.data}');
      print('- Request URI: ${e.requestOptions.uri}');
      print('- Request headers: ${e.requestOptions.headers}');
      
      if (e.response?.statusCode == 401) {
        // Handle 401 Unauthorized error
        print('Authentication error detected. Token might be invalid or expired.');
        final token = HiveHelper.getToken;
        print('Current token status: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "EXISTS (${maskToken(token)})")}');
      }
      
      throw Exception('Error fetching withdrawal history: ${e.response?.statusCode} - ${e.response?.statusMessage} - ${e.response?.data ?? e.message}');
    }
  }
}