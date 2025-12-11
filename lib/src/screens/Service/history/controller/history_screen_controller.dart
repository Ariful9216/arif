import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:arif_mart/core/model/history_model.dart';
import 'package:arif_mart/core/services/history_service.dart';
import 'package:arif_mart/core/helper/hive_helper.dart';

class HistoryController extends GetxController {
  final HistoryService _historyService = HistoryService();
  var selectedTab = 0.obs;

  // Recharge History
  var rechargeHistory = <RechargeHistoryItem>[].obs;
  var isLoadingRecharge = false.obs;
  var hasErrorRecharge = false.obs;
  var errorMsgRecharge = ''.obs;
  var rechargePagination = Rx<PaginationMeta>(PaginationMeta(
    total: 0,
    page: 1,
    limit: 10,
    pages: 1,
    hasNextPage: false,
    hasPrevPage: false,
  ));

  // Credit History
  var creditHistory = <CreditHistoryItem>[].obs;
  var isLoadingCredit = false.obs;
  var hasErrorCredit = false.obs;
  var errorMsgCredit = ''.obs;
  var creditPagination = Rx<PaginationMeta>(PaginationMeta(
    total: 0,
    page: 1,
    limit: 10,
    pages: 1,
    hasNextPage: false,
    hasPrevPage: false,
  ));

  // Withdrawal History
  var withdrawalHistory = <WithdrawalHistoryItem>[].obs;
  var isLoadingWithdrawal = false.obs;
  var hasErrorWithdrawal = false.obs;
  var errorMsgWithdrawal = ''.obs;
  var withdrawalPagination = Rx<PaginationMeta>(PaginationMeta(
    total: 0,
    page: 1,
    limit: 10,
    pages: 1,
    hasNextPage: false,
    hasPrevPage: false,
  ));

  // ===== PAGINATION CONTROL VARIABLES =====
  
  // RECHARGE PAGINATION CONTROLS
  final RxInt rechargeCurrentPage = 1.obs;
  final RxInt rechargeTotalPages = 1.obs;
  final RxInt rechargeTotalRecords = 0.obs;
  final RxBool rechargeHasNextPage = false.obs;
  final RxBool rechargeHasPrevPage = false.obs;

  // CREDIT PAGINATION CONTROLS
  final RxInt creditCurrentPage = 1.obs;
  final RxInt creditTotalPages = 1.obs;
  final RxInt creditTotalRecords = 0.obs;
  final RxBool creditHasNextPage = false.obs;
  final RxBool creditHasPrevPage = false.obs;

  // WITHDRAWAL PAGINATION CONTROLS
  final RxInt withdrawalCurrentPage = 1.obs;
  final RxInt withdrawalTotalPages = 1.obs;
  final RxInt withdrawalTotalRecords = 0.obs;
  final RxBool withdrawalHasNextPage = false.obs;
  final RxBool withdrawalHasPrevPage = false.obs;

  // Legacy dummy data (keeping for backward compatibility)
  var transactions =
      [
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
        {"type": "Recharge", "amount": "\$10", "mobile": "038788109090", "status": "Success", "date": "JAN 22, 2025"},
      ].obs;

  @override
  void onInit() {
    super.onInit();
    
    // Log the current token for debugging
    final token = HiveHelper.getToken;
    print('History Controller initialized with token status: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "EXISTS (length: ${token.length})")}');
    
    // Set JWT token from HiveHelper
    if (token != null && token.isNotEmpty) {
      print('Setting token in history service');
      _historyService.setToken(token);
    } else {
      print('WARNING: No token available in HiveHelper');
    }
    
    // Fetch initial data with a delay to ensure UI is ready
    Future.delayed(Duration(milliseconds: 100), () {
      fetchRechargeHistory();
    });
  }
  
  // Helper to check if user is logged in
  bool isUserLoggedIn() {
    final token = HiveHelper.getToken;
    return token != null && token.isNotEmpty;
  }

  void changeTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    
    switch (index) {
      case 0:
        if (rechargeHistory.isEmpty) {
          fetchRechargeHistory();
        }
        break;
      case 1:
        if (creditHistory.isEmpty) {
          fetchCreditHistory();
        }
        break;
      case 2:
        if (withdrawalHistory.isEmpty) {
          fetchWithdrawalHistory();
        }
        break;
    }
  }

  // Recharge History Methods
  Future<void> fetchRechargeHistory({int page = 1}) async {
    // Check if user is logged in before making the request
    if (!isUserLoggedIn()) {
      hasErrorRecharge.value = true;
      errorMsgRecharge.value = 'Please log in to view your history';
      print('Attempted to fetch recharge history without being logged in');
      return;
    }
    
    if (page == 1) {
      isLoadingRecharge.value = true;
      hasErrorRecharge.value = false;
      
      // If this is the first page load, clear any existing data
      rechargeHistory.clear();
    }

    try {
      final result = await _historyService.getRechargeHistory(page: page);
      if (page == 1) {
        rechargeHistory.clear();
      }
      
      // Safely handle the response
      if (result.containsKey('recharges')) {
        try {
          final rechargesData = result['recharges'];
          print('Recharges data type: ${rechargesData.runtimeType}');
          
          // Handle empty array case
          if (rechargesData is List && rechargesData.isEmpty) {
            print('Recharge history is empty');
            // We'll let the empty view show since rechargeHistory is already empty
          } else if (rechargesData is List) {
            print('Processing ${rechargesData.length} recharge items');
            
            final items = rechargesData.map((item) {
              try {
                // Ensure item is a Map before parsing
                if (item is Map) {
                  // Convert to Map<String, dynamic> for type safety
                  final Map<String, dynamic> itemMap = {};
                  item.forEach((key, value) {
                    itemMap[key.toString()] = value;
                  });
                  print('Parsing recharge item with id: ${itemMap['_id']}');
                  return RechargeHistoryItem.fromJson(itemMap);
                } else if (item is RechargeHistoryItem) {
                  // If already parsed (shouldn't happen now), just return it
                  print('Item is already a RechargeHistoryItem - unexpected');
                  return item;
                } else {
                  print('Unexpected item type: ${item.runtimeType}');
                  return null;
                }
              } catch (e, stackTrace) {
                print('Error parsing individual recharge item: $e');
                print('Stack trace: $stackTrace');
                print('Problematic item data: $item');
                print('Item type: ${item.runtimeType}');
                return null;
              }
            }).where((item) => item != null).cast<RechargeHistoryItem>().toList();
            
            print('Successfully parsed ${items.length} recharge items');
            // IMPORTANT: Replace list instead of accumulating items
            rechargeHistory.value = items;  // This replaces, not appends
          } else {
            print('Unexpected recharges data type: ${rechargesData.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('Error processing recharge history list: $e');
          print('Stack trace: $stackTrace');
          print('Raw recharges data: ${result['recharges']}');
          hasErrorRecharge.value = true;
          errorMsgRecharge.value = 'Error processing recharge data: $e';
        }
      } else {
        print('No recharges key in result: ${result.keys}');
      }
      
      if (result.containsKey('pagination')) {
        try {
          final paginationData = result['pagination'];
          print('Pagination data type: ${paginationData.runtimeType}');
          
          if (paginationData is PaginationMeta) {
            // Already parsed
            rechargePagination.value = paginationData;
            // Update pagination control variables
            rechargeCurrentPage.value = paginationData.page;
            rechargeTotalPages.value = paginationData.pages;
            rechargeTotalRecords.value = paginationData.total;
            rechargeHasNextPage.value = paginationData.hasNextPage;
            rechargeHasPrevPage.value = paginationData.hasPrevPage;
            print('✅ Recharge pagination updated: page=${rechargeCurrentPage.value}/${rechargeTotalPages.value}');
          } else if (paginationData is Map) {
            // Need to parse
            final Map<String, dynamic> paginationMap = {};
            paginationData.forEach((key, value) {
              paginationMap[key.toString()] = value;
            });
            final parsedPagination = PaginationMeta.fromJson(paginationMap);
            rechargePagination.value = parsedPagination;
            // Update pagination control variables
            rechargeCurrentPage.value = parsedPagination.page;
            rechargeTotalPages.value = parsedPagination.pages;
            rechargeTotalRecords.value = parsedPagination.total;
            rechargeHasNextPage.value = parsedPagination.hasNextPage;
            rechargeHasPrevPage.value = parsedPagination.hasPrevPage;
            print('✅ Recharge pagination updated: page=${rechargeCurrentPage.value}/${rechargeTotalPages.value}');
          }
        } catch (e, stackTrace) {
          print('Error setting pagination data: $e');
          print('Stack trace: $stackTrace');
          print('Raw pagination data: ${result['pagination']}');
        }
      }
      
      hasErrorRecharge.value = false;
    } catch (e) {
      hasErrorRecharge.value = true;
      if (e is DioException) {
        // Better error handling for Dio errors
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          // Handle authentication errors specially
          errorMsgRecharge.value = 'Authentication error. Please log in again.';
          print('401 Unauthorized: Token invalid or expired');
          
          // Check token status
          final token = HiveHelper.getToken;
          print('Current token: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "LENGTH: ${token.length}")}');
          
          // You might want to redirect to login screen here
          // Get.offAllNamed(Routes.loginScreen);
        } else {
          errorMsgRecharge.value = 'API Error (${statusCode ?? "Unknown"}): ${responseData ?? e.message ?? "Unknown error"}';
        }
        print('Recharge History Error: ${errorMsgRecharge.value}');
      } else {
        errorMsgRecharge.value = e.toString();
        print('Recharge History Error: ${e.toString()}');
      }
    } finally {
      isLoadingRecharge.value = false;
    }
  }

  Future<void> refreshRechargeHistory() async {
    rechargePagination.value = PaginationMeta(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
    await fetchRechargeHistory(page: 1);
  }

  Future<void> loadMoreRechargeHistory() async {
    if (!rechargePagination.value.hasNextPage || isLoadingRecharge.value) return;
    
    final nextPage = rechargePagination.value.page + 1;
    await fetchRechargeHistory(page: nextPage);
  }

  // Credit History Methods
  Future<void> fetchCreditHistory({int page = 1}) async {
    // Check if user is logged in before making the request
    if (!isUserLoggedIn()) {
      hasErrorCredit.value = true;
      errorMsgCredit.value = 'Please log in to view your history';
      print('Attempted to fetch credit history without being logged in');
      return;
    }
    
    if (page == 1) {
      isLoadingCredit.value = true;
      hasErrorCredit.value = false;
      
      // If this is the first page load, clear any existing data
      creditHistory.clear();
    }

    try {
      final result = await _historyService.getCreditHistory(page: page);
      if (page == 1) {
        creditHistory.clear();
      }
      
      // Safely handle the response
      if (result.containsKey('credits')) {
        try {
          final creditsData = result['credits'];
          print('Credits data type: ${creditsData.runtimeType}');
          
          // Handle empty array case
          if (creditsData is List && creditsData.isEmpty) {
            print('Credit history is empty');
            // We'll let the empty view show since creditHistory is already empty
          } else if (creditsData is List) {
            print('Processing ${creditsData.length} credit items');
            
            final items = creditsData.map((item) {
              try {
                // Ensure item is a Map before parsing
                if (item is Map) {
                  // Convert to Map<String, dynamic> for type safety
                  final Map<String, dynamic> itemMap = {};
                  item.forEach((key, value) {
                    itemMap[key.toString()] = value;
                  });
                  print('Parsing credit item with id: ${itemMap['_id']}');
                  return CreditHistoryItem.fromJson(itemMap);
                } else if (item is CreditHistoryItem) {
                  // If already parsed (shouldn't happen now), just return it
                  print('Item is already a CreditHistoryItem - unexpected');
                  return item;
                } else {
                  print('Unexpected item type: ${item.runtimeType}');
                  return null;
                }
              } catch (e, stackTrace) {
                print('Error parsing individual credit item: $e');
                print('Stack trace: $stackTrace');
                print('Problematic item data: $item');
                print('Item type: ${item.runtimeType}');
                return null;
              }
            }).where((item) => item != null).cast<CreditHistoryItem>().toList();
            
            print('Successfully parsed ${items.length} credit items');
            // IMPORTANT: Replace list instead of accumulating items
            creditHistory.value = items;  // This replaces, not appends
          } else {
            print('Unexpected credits data type: ${creditsData.runtimeType}');
          }
        } catch (e, stackTrace) {
          print('Error processing credit history list: $e');
          print('Stack trace: $stackTrace');
          print('Raw credits data: ${result['credits']}');
          hasErrorCredit.value = true;
          errorMsgCredit.value = 'Error processing credit data: $e';
        }
      } else {
        print('No credits key in result: ${result.keys}');
      }
      
      if (result.containsKey('pagination')) {
        try {
          final paginationData = result['pagination'];
          print('Pagination data type: ${paginationData.runtimeType}');
          
          if (paginationData is PaginationMeta) {
            // Already parsed
            creditPagination.value = paginationData;
            // Update pagination control variables
            creditCurrentPage.value = paginationData.page;
            creditTotalPages.value = paginationData.pages;
            creditTotalRecords.value = paginationData.total;
            creditHasNextPage.value = paginationData.hasNextPage;
            creditHasPrevPage.value = paginationData.hasPrevPage;
            print('✅ Credit pagination updated: page=${creditCurrentPage.value}/${creditTotalPages.value}');
          } else if (paginationData is Map) {
            // Need to parse
            final Map<String, dynamic> paginationMap = {};
            paginationData.forEach((key, value) {
              paginationMap[key.toString()] = value;
            });
            final parsedPagination = PaginationMeta.fromJson(paginationMap);
            creditPagination.value = parsedPagination;
            // Update pagination control variables
            creditCurrentPage.value = parsedPagination.page;
            creditTotalPages.value = parsedPagination.pages;
            creditTotalRecords.value = parsedPagination.total;
            creditHasNextPage.value = parsedPagination.hasNextPage;
            creditHasPrevPage.value = parsedPagination.hasPrevPage;
            print('✅ Credit pagination updated: page=${creditCurrentPage.value}/${creditTotalPages.value}');
          }
        } catch (e, stackTrace) {
          print('Error setting pagination data: $e');
          print('Stack trace: $stackTrace');
          print('Raw pagination data: ${result['pagination']}');
        }
      }
      
      hasErrorCredit.value = false;
    } catch (e) {
      hasErrorCredit.value = true;
      if (e is DioException) {
        // Better error handling for Dio errors
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          // Handle authentication errors specially
          errorMsgCredit.value = 'Authentication error. Please log in again.';
          print('401 Unauthorized: Token invalid or expired');
          
          // Check token status
          final token = HiveHelper.getToken;
          print('Current token: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "LENGTH: ${token.length}")}');
          
          // You might want to redirect to login screen here
          // Get.offAllNamed(Routes.loginScreen);
        } else {
          errorMsgCredit.value = 'API Error (${statusCode ?? "Unknown"}): ${responseData ?? e.message ?? "Unknown error"}';
        }
        print('Credit History Error: ${errorMsgCredit.value}');
      } else {
        errorMsgCredit.value = e.toString();
        print('Credit History Error: ${e.toString()}');
      }
    } finally {
      isLoadingCredit.value = false;
    }
  }

  Future<void> refreshCreditHistory() async {
    creditPagination.value = PaginationMeta(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
    await fetchCreditHistory(page: 1);
  }

  Future<void> loadMoreCreditHistory() async {
    if (!creditPagination.value.hasNextPage || isLoadingCredit.value) return;
    
    final nextPage = creditPagination.value.page + 1;
    await fetchCreditHistory(page: nextPage);
  }

  // Withdrawal History Methods
  Future<void> fetchWithdrawalHistory({int page = 1}) async {
    // Check if user is logged in before making the request
    if (!isUserLoggedIn()) {
      hasErrorWithdrawal.value = true;
      errorMsgWithdrawal.value = 'Please log in to view your history';
      print('Attempted to fetch withdrawal history without being logged in');
      return;
    }
    
    if (page == 1) {
      isLoadingWithdrawal.value = true;
      hasErrorWithdrawal.value = false;
      
      // If this is the first page load, clear any existing data
      withdrawalHistory.clear();
    }

    try {
      final result = await _historyService.getWithdrawalHistory(page: page);
      if (page == 1) {
        withdrawalHistory.clear();
      }
      
      print('Processing withdrawal result: $result');
      
      // Handle direct data array format from API response
      if (result.containsKey('data') && result['data'] is List) {
        try {
          final List<dynamic> dataArray = result['data'] as List<dynamic>;
          print('Processing direct data array with ${dataArray.length} items');
          
          if (dataArray.isEmpty) {
            print('Withdrawal history data array is empty');
          } else {
            final items = dataArray.map((item) {
              try {
                return WithdrawalHistoryItem.fromJson(item);
              } catch (e) {
                print('Error parsing withdrawal item from data array: $e');
                print('Problematic item: $item');
                return null;
              }
            }).where((item) => item != null).cast<WithdrawalHistoryItem>().toList();
            
            // IMPORTANT: Replace list instead of accumulating items
            withdrawalHistory.value = items;  // This replaces, not appends
          }
        } catch (e) {
          print('Error processing direct data array: $e');
          hasErrorWithdrawal.value = true;
          errorMsgWithdrawal.value = 'Error processing withdrawal data: $e';
        }
      }
      // Handle traditional withdrawals format
      else if (result.containsKey('withdrawals')) {
        try {
          final withdrawalsData = result['withdrawals'];
          
          // Handle empty array case
          if (withdrawalsData is List && withdrawalsData.isEmpty) {
            print('Withdrawal history is empty');
            // We'll let the empty view show since withdrawalHistory is already empty
          } else if (withdrawalsData is List) {
            final items = withdrawalsData.map((item) {
              try {
                return WithdrawalHistoryItem.fromJson(item);
              } catch (e) {
                print('Error parsing individual withdrawal item: $e');
                print('Problematic item data: $item');
                return null;
              }
            }).where((item) => item != null).cast<WithdrawalHistoryItem>().toList();
            
            // IMPORTANT: Replace list instead of accumulating items
            withdrawalHistory.value = items;  // This replaces, not appends
          } else {
            print('Unexpected withdrawals data type: ${withdrawalsData.runtimeType}');
          }
        } catch (e) {
          print('Error processing withdrawal history list: $e');
          print('Raw withdrawals data: ${result['withdrawals']}');
          hasErrorWithdrawal.value = true;
          errorMsgWithdrawal.value = 'Error processing withdrawal data: $e';
        }
      } else {
        print('No withdrawals or data key in result. Available keys: ${result.keys}');
      }
      
      if (result.containsKey('pagination')) {
        try {
          final paginationData = result['pagination'];
          
          if (paginationData is PaginationMeta) {
            withdrawalPagination.value = paginationData;
            // Update pagination control variables
            withdrawalCurrentPage.value = paginationData.page;
            withdrawalTotalPages.value = paginationData.pages;
            withdrawalTotalRecords.value = paginationData.total;
            withdrawalHasNextPage.value = paginationData.hasNextPage;
            withdrawalHasPrevPage.value = paginationData.hasPrevPage;
            print('✅ Withdrawal pagination updated: page=${withdrawalCurrentPage.value}/${withdrawalTotalPages.value}');
          } else if (paginationData is Map) {
            final Map<String, dynamic> paginationMap = {};
            paginationData.forEach((key, value) {
              paginationMap[key.toString()] = value;
            });
            final parsedPagination = PaginationMeta.fromJson(paginationMap);
            withdrawalPagination.value = parsedPagination;
            // Update pagination control variables
            withdrawalCurrentPage.value = parsedPagination.page;
            withdrawalTotalPages.value = parsedPagination.pages;
            withdrawalTotalRecords.value = parsedPagination.total;
            withdrawalHasNextPage.value = parsedPagination.hasNextPage;
            withdrawalHasPrevPage.value = parsedPagination.hasPrevPage;
            print('✅ Withdrawal pagination updated: page=${withdrawalCurrentPage.value}/${withdrawalTotalPages.value}');
          }
        } catch (e) {
          print('Error setting pagination data: $e');
          print('Raw pagination data: ${result['pagination']}');
        }
      }
      
      hasErrorWithdrawal.value = false;
    } catch (e) {
      hasErrorWithdrawal.value = true;
      if (e is DioException) {
        // Better error handling for Dio errors
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        
        if (statusCode == 401) {
          // Handle authentication errors specially
          errorMsgWithdrawal.value = 'Authentication error. Please log in again.';
          print('401 Unauthorized: Token invalid or expired');
          
          // Check token status
          final token = HiveHelper.getToken;
          print('Current token: ${token == null ? "NULL" : (token.isEmpty ? "EMPTY" : "LENGTH: ${token.length}")}');
          
          // You might want to redirect to login screen here
          // Get.offAllNamed(Routes.loginScreen);
        } else {
          errorMsgWithdrawal.value = 'API Error (${statusCode ?? "Unknown"}): ${responseData ?? e.message ?? "Unknown error"}';
        }
        print('Withdrawal History Error: ${errorMsgWithdrawal.value}');
      } else {
        errorMsgWithdrawal.value = e.toString();
        print('Withdrawal History Error: ${e.toString()}');
      }
    } finally {
      isLoadingWithdrawal.value = false;
    }
  }

  Future<void> refreshWithdrawalHistory() async {
    withdrawalPagination.value = PaginationMeta(
      total: 0,
      page: 1,
      limit: 10,
      pages: 1,
      hasNextPage: false,
      hasPrevPage: false,
    );
    await fetchWithdrawalHistory(page: 1);
  }

  Future<void> loadMoreWithdrawalHistory() async {
    if (!withdrawalPagination.value.hasNextPage || isLoadingWithdrawal.value) return;
    
    final nextPage = withdrawalPagination.value.page + 1;
    await fetchWithdrawalHistory(page: nextPage);
  }

  // ============================================
  // PAGINATION NAVIGATION METHODS
  // ============================================
  
  // RECHARGE NAVIGATION
  Future<void> rechargeLoadNextPage() async {
    if (!rechargeHasNextPage.value || isLoadingRecharge.value) return;
    await fetchRechargeHistory(page: rechargeCurrentPage.value + 1);
  }

  Future<void> rechargeLoadPreviousPage() async {
    if (!rechargeHasPrevPage.value || isLoadingRecharge.value) return;
    await fetchRechargeHistory(page: rechargeCurrentPage.value - 1);
  }

  Future<void> rechargeJumpToPage(int page) async {
    if (page < 1 || page > rechargeTotalPages.value || isLoadingRecharge.value) return;
    await fetchRechargeHistory(page: page);
  }

  // CREDIT NAVIGATION
  Future<void> creditLoadNextPage() async {
    if (!creditHasNextPage.value || isLoadingCredit.value) return;
    await fetchCreditHistory(page: creditCurrentPage.value + 1);
  }

  Future<void> creditLoadPreviousPage() async {
    if (!creditHasPrevPage.value || isLoadingCredit.value) return;
    await fetchCreditHistory(page: creditCurrentPage.value - 1);
  }

  Future<void> creditJumpToPage(int page) async {
    if (page < 1 || page > creditTotalPages.value || isLoadingCredit.value) return;
    await fetchCreditHistory(page: page);
  }

  // WITHDRAWAL NAVIGATION
  Future<void> withdrawalLoadNextPage() async {
    if (!withdrawalHasNextPage.value || isLoadingWithdrawal.value) return;
    await fetchWithdrawalHistory(page: withdrawalCurrentPage.value + 1);
  }

  Future<void> withdrawalLoadPreviousPage() async {
    if (!withdrawalHasPrevPage.value || isLoadingWithdrawal.value) return;
    await fetchWithdrawalHistory(page: withdrawalCurrentPage.value - 1);
  }

  Future<void> withdrawalJumpToPage(int page) async {
    if (page < 1 || page > withdrawalTotalPages.value || isLoadingWithdrawal.value) return;
    await fetchWithdrawalHistory(page: page);
  }
}
