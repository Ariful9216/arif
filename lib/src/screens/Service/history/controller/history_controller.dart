import 'package:get/get.dart';
import 'package:arif_mart/core/services/history_service.dart';
import 'package:arif_mart/core/model/history_model.dart';

class HistoryController extends GetxController {
  final HistoryService _historyService = HistoryService();
  
  // Recharge history
  final RxBool isLoadingRecharge = false.obs;
  final RxBool hasErrorRecharge = false.obs;
  final RxString errorMsgRecharge = ''.obs;
  final RxList<RechargeHistoryItem> rechargeHistory = <RechargeHistoryItem>[].obs;
  final Rx<PaginationMeta> rechargePagination = PaginationMeta(
    total: 0, page: 1, limit: 10, pages: 0, hasNextPage: false, hasPrevPage: false
  ).obs;
  
  // Credit history
  final RxBool isLoadingCredit = false.obs;
  final RxBool hasErrorCredit = false.obs;
  final RxString errorMsgCredit = ''.obs;
  final RxList<CreditHistoryItem> creditHistory = <CreditHistoryItem>[].obs;
  final Rx<PaginationMeta> creditPagination = PaginationMeta(
    total: 0, page: 1, limit: 10, pages: 0, hasNextPage: false, hasPrevPage: false
  ).obs;
  
  // Withdrawal history
  final RxBool isLoadingWithdrawal = false.obs;
  final RxBool hasErrorWithdrawal = false.obs;
  final RxString errorMsgWithdrawal = ''.obs;
  final RxList<WithdrawalHistoryItem> withdrawalHistory = <WithdrawalHistoryItem>[].obs;
  final Rx<PaginationMeta> withdrawalPagination = PaginationMeta(
    total: 0, page: 1, limit: 10, pages: 0, hasNextPage: false, hasPrevPage: false
  ).obs;

  @override
  void onInit() {
    super.onInit();
    // Set JWT token from storage
    _historyService.setToken(getJwtToken());
    // Initially load data for all tabs
    fetchRechargeHistory();
    fetchCreditHistory();
    fetchWithdrawalHistory();
  }

  // Helper to get JWT token from storage
  String getJwtToken() {
    // Replace with your actual token storage mechanism
    // return Get.find<AuthController>().token;
    return ''; // Placeholder, replace with actual implementation
  }

  // Fetch recharge history
  Future<void> fetchRechargeHistory({int page = 1, bool refresh = false}) async {
    try {
      isLoadingRecharge.value = true;
      hasErrorRecharge.value = false;
      errorMsgRecharge.value = '';

      if (refresh) {
        rechargeHistory.clear();
      }

      final result = await _historyService.getRechargeHistory(page: page);
      
      final List<RechargeHistoryItem> fetchedRecharges = result['recharges'];
      final PaginationMeta pagination = result['pagination'];
      
      if (page == 1 || refresh) {
        rechargeHistory.assignAll(fetchedRecharges);
      } else {
        rechargeHistory.addAll(fetchedRecharges);
      }
      
      rechargePagination.value = pagination;
    } catch (e) {
      hasErrorRecharge.value = true;
      errorMsgRecharge.value = e.toString();
    } finally {
      isLoadingRecharge.value = false;
      update();
    }
  }

  // Load more recharge history
  Future<void> loadMoreRechargeHistory() async {
    if (!isLoadingRecharge.value && 
        rechargePagination.value.hasNextPage) {
      await fetchRechargeHistory(page: rechargePagination.value.page + 1);
    }
  }

  // Refresh recharge history
  Future<void> refreshRechargeHistory() async {
    await fetchRechargeHistory(page: 1, refresh: true);
  }

  // Fetch credit history
  Future<void> fetchCreditHistory({int page = 1, bool refresh = false}) async {
    try {
      isLoadingCredit.value = true;
      hasErrorCredit.value = false;
      errorMsgCredit.value = '';

      if (refresh) {
        creditHistory.clear();
      }

      final result = await _historyService.getCreditHistory(page: page);
      
      final List<CreditHistoryItem> fetchedCredits = result['credits'];
      final PaginationMeta pagination = result['pagination'];
      
      if (page == 1 || refresh) {
        creditHistory.assignAll(fetchedCredits);
      } else {
        creditHistory.addAll(fetchedCredits);
      }
      
      creditPagination.value = pagination;
    } catch (e) {
      hasErrorCredit.value = true;
      errorMsgCredit.value = e.toString();
    } finally {
      isLoadingCredit.value = false;
      update();
    }
  }

  // Load more credit history
  Future<void> loadMoreCreditHistory() async {
    if (!isLoadingCredit.value && 
        creditPagination.value.hasNextPage) {
      await fetchCreditHistory(page: creditPagination.value.page + 1);
    }
  }

  // Refresh credit history
  Future<void> refreshCreditHistory() async {
    await fetchCreditHistory(page: 1, refresh: true);
  }

  // Fetch withdrawal history
  Future<void> fetchWithdrawalHistory({int page = 1, bool refresh = false}) async {
    try {
      isLoadingWithdrawal.value = true;
      hasErrorWithdrawal.value = false;
      errorMsgWithdrawal.value = '';

      if (refresh) {
        withdrawalHistory.clear();
      }

      final result = await _historyService.getWithdrawalHistory(page: page);
      
      final List<WithdrawalHistoryItem> fetchedWithdrawals = result['withdrawals'];
      final PaginationMeta pagination = result['pagination'];
      
      if (page == 1 || refresh) {
        withdrawalHistory.assignAll(fetchedWithdrawals);
      } else {
        withdrawalHistory.addAll(fetchedWithdrawals);
      }
      
      withdrawalPagination.value = pagination;
    } catch (e) {
      hasErrorWithdrawal.value = true;
      errorMsgWithdrawal.value = e.toString();
    } finally {
      isLoadingWithdrawal.value = false;
      update();
    }
  }

  // Load more withdrawal history
  Future<void> loadMoreWithdrawalHistory() async {
    if (!isLoadingWithdrawal.value && 
        withdrawalPagination.value.hasNextPage) {
      await fetchWithdrawalHistory(page: withdrawalPagination.value.page + 1);
    }
  }

  // Refresh withdrawal history
  Future<void> refreshWithdrawalHistory() async {
    await fetchWithdrawalHistory(page: 1, refresh: true);
  }
}