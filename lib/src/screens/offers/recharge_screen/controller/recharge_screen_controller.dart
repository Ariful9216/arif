import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/services/recharge_service.dart';
import 'package:arif_mart/core/model/recharge_model.dart';
import 'package:arif_mart/core/model/recharge_operator_model.dart';

class RechargeController extends GetxController {
  // Form controllers
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  
  // Observable variables
  final RxList<RechargeOperatorData> operators = <RechargeOperatorData>[].obs;
  final RxList<RechargeData> rechargeHistory = <RechargeData>[].obs;
  final RxString selectedOperator = ''.obs;
  final RxString selectedOperatorCode = ''.obs;
  final RxBool isLoadingOperators = false.obs;
  final RxBool isLoadingHistory = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isSubmitEnabled = false.obs;
  
  // Pagination variables
  final RxInt currentPage = 1.obs;
  final RxInt pageLimit = 10.obs;
  final RxInt totalRecharges = 0.obs;
  final RxInt totalPages = 1.obs;
  final RxBool hasNextPage = false.obs;
  final RxBool hasPrevPage = false.obs;
  
  // Service
  late final RechargeService _rechargeService;
  
  @override
  void onInit() {
    super.onInit();
    _rechargeService = Get.find<RechargeService>();
    
    // Add listeners to text controllers for reactive button state
    phoneController.addListener(_updateSubmitEnabled);
    amountController.addListener(_updateSubmitEnabled);
    
    fetchOperators();
    fetchRechargeHistory();
    
    // Initialize submit button state
    _updateSubmitEnabled();
  }

  @override
  void onClose() {
    phoneController.dispose();
    amountController.dispose();
    super.onClose();
  }

  // Update submit button enabled state
  void _updateSubmitEnabled() {
    final enabled = selectedOperator.value.isNotEmpty && 
                   phoneController.text.isNotEmpty && 
                   amountController.text.isNotEmpty;
    isSubmitEnabled.value = enabled;
    print('Submit button state updated: $enabled');
    print('  - Operator: ${selectedOperator.value.isNotEmpty}');
    print('  - Phone: ${phoneController.text.isNotEmpty}');
    print('  - Amount: ${amountController.text.isNotEmpty}');
  }

  // Check if submit button should be enabled (for backward compatibility)
  bool get isSubmitEnabledValue {
    return selectedOperator.value.isNotEmpty && 
           phoneController.text.isNotEmpty && 
           amountController.text.isNotEmpty;
  }

  // Force update submit button state (useful for debugging)
  void forceUpdateSubmitState() {
    _updateSubmitEnabled();
  }

  // Fetch operators from API
  Future<void> fetchOperators() async {
    try {
      isLoadingOperators.value = true;
      final response = await _rechargeService.getActiveRechargeOperators();
      
      if (response != null && response.success) {
        operators.value = response.data ?? [];
      } else {
        Get.snackbar('Error', response?.message ?? 'Failed to load operators');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error loading operators: $e');
    } finally {
      isLoadingOperators.value = false;
    }
  }

  // Fetch recharge history from API with pagination support
  Future<void> fetchRechargeHistory({int? page}) async {
    try {
      isLoadingHistory.value = true;
      int pageToFetch = page ?? currentPage.value;
      
      print('\n🔵 ===== FETCH RECHARGE HISTORY START =====');
      print('📍 Page requested: $pageToFetch');
      print('📍 Limit: ${pageLimit.value}');
      print('📊 BEFORE API CALL:');
      print('   - rechargeHistory.length: ${rechargeHistory.length}');
      print('   - rechargeHistory items: ${rechargeHistory.map((r) => r.id).toList()}');
      
      final response = await _rechargeService.getRechargeHistory(
        page: pageToFetch,
        limit: pageLimit.value,
      );
      
      print('📥 AFTER API CALL:');
      print('   - Response success: ${response?.success}');
      print('   - Response data length: ${response?.data?.length ?? 0}');
      print('   - API returned items: ${response?.data?.map((r) => r.id).toList()}');
      
      if (response != null && response.success) {
        print('🔄 UPDATING LIST:');
        final previousLength = rechargeHistory.length;
        
        // Update recharge history list - REPLACE not ACCUMULATE
        rechargeHistory.value = response.data ?? [];
        
        final afterLength = rechargeHistory.length;
        print('   - Previous length: $previousLength');
        print('   - New length: $afterLength');
        print('   - Change: ${afterLength - previousLength} (should NOT be positive if changing page!)');
        
        if (afterLength > (response.pagination?.limit ?? 10)) {
          print('⚠️  WARNING: List length (${afterLength}) > API limit (${response.pagination?.limit ?? 10})');
          print('   This indicates ACCUMULATION is happening!');
        }
        
        // Update pagination metadata
        if (response.pagination != null) {
          print('📊 PAGINATION METADATA:');
          print('   - API total: ${response.pagination!.total}');
          print('   - API page: ${response.pagination!.page}');
          print('   - API limit: ${response.pagination!.limit}');
          print('   - API pages: ${response.pagination!.pages}');
          print('   - API hasNextPage: ${response.pagination!.hasNextPage}');
          print('   - API hasPrevPage: ${response.pagination!.hasPrevPage}');
          
          currentPage.value = response.pagination!.page;
          totalRecharges.value = response.pagination!.total;
          totalPages.value = response.pagination!.pages;
          hasNextPage.value = response.pagination!.hasNextPage;
          hasPrevPage.value = response.pagination!.hasPrevPage;
          
          print('✅ STATE UPDATED:');
          print('   - currentPage: ${currentPage.value}');
          print('   - totalRecharges: ${totalRecharges.value}');
          print('   - totalPages: ${totalPages.value}');
          print('   - hasNextPage: ${hasNextPage.value}');
          print('   - hasPrevPage: ${hasPrevPage.value}');
        } else {
          print('⚠️ No pagination metadata in response');
        }
        
        print('✅ FINAL STATE:');
        print('   - rechargeHistory.length: ${rechargeHistory.length}');
        print('   - Expected: ${response.pagination?.limit ?? 10}');
        
      } else {
        print('❌ Failed to load recharge history: ${response?.message}');
        Get.snackbar('Error', response?.message ?? 'Failed to load recharge history');
      }
      print('🔵 ===== FETCH RECHARGE HISTORY END =====\n');
    } catch (e) {
      print('❌ Error loading recharge history: $e');
      print('Stack trace: ${StackTrace.current}');
      Get.snackbar('Error', 'Error loading recharge history: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // Load next page of recharge history
  Future<void> loadNextPage() async {
    if (hasNextPage.value && !isLoadingHistory.value) {
      await fetchRechargeHistory(page: currentPage.value + 1);
    }
  }

  // Load previous page of recharge history
  Future<void> loadPreviousPage() async {
    if (hasPrevPage.value && !isLoadingHistory.value) {
      await fetchRechargeHistory(page: currentPage.value - 1);
    }
  }

  // Jump to specific page
  Future<void> jumpToPage(int page) async {
    if (page >= 1 && page <= totalPages.value && !isLoadingHistory.value) {
      await fetchRechargeHistory(page: page);
    }
  }

  // Select operator
  void selectOperator(String operatorName, String operatorCode) {
    selectedOperator.value = operatorName;
    selectedOperatorCode.value = operatorCode; // Store without plus sign for placeholder
    
    // Update submit button state
    _updateSubmitEnabled();
  }

  // Submit recharge request
  Future<void> submitRecharge() async {
    print('Submit recharge called');
    print('isSubmitEnabled: ${isSubmitEnabled.value}');
    print('selectedOperator: ${selectedOperator.value}');
    print('phoneNumber: ${phoneController.text}');
    print('amount: ${amountController.text}');
    
    if (!isSubmitEnabled.value) {
      print('Submit not enabled, returning');
      return;
    }

    try {
      isSubmitting.value = true;
      print('Starting recharge submission...');
      
      final response = await _rechargeService.submitRecharge(
        operator: selectedOperator.value,
        phoneNumber: phoneController.text,
        amount: double.parse(amountController.text),
      );

      if (response != null && response['success'] == true) {
        Get.snackbar(
          'Success', 
          'Recharge request submitted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Clear form
        phoneController.clear();
        amountController.clear();
        selectedOperator.value = '';
        selectedOperatorCode.value = '';
        
        // Update submit button state
        _updateSubmitEnabled();
        
        // Refresh history
        await fetchRechargeHistory();
      } else {
        Get.snackbar(
          'Error', 
          response?['message'] ?? 'Failed to submit recharge request',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Error submitting recharge: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  // Get status color for recharge history
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Format date for display
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Get operator by code
  RechargeOperatorData? getOperatorByCode(String code) {
    try {
      return operators.firstWhere((op) => op.operatorCode == code);
    } catch (e) {
      return null;
    }
  }

  // Get operator by name
  RechargeOperatorData? getOperatorByName(String name) {
    try {
      return operators.firstWhere((op) => op.operatorName == name);
    } catch (e) {
      return null;
    }
  }

  // Validate phone number format
  bool isValidPhoneNumber(String phone) {
    // Remove any non-digit characters except +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if it starts with + and has 11-15 digits total
    if (cleaned.startsWith('+')) {
      String digits = cleaned.substring(1);
      return digits.length >= 10 && digits.length <= 14;
    }
    
    // Check if it's just digits (10-14 digits)
    return cleaned.length >= 10 && cleaned.length <= 14;
  }

  // Validate amount
  bool isValidAmount(String amount) {
    try {
      double value = double.parse(amount);
      return value > 0 && value <= 10000; // Assuming max recharge is 10,000
    } catch (e) {
      return false;
    }
  }

  // Get validation error message
  String? getValidationError() {
    if (phoneController.text.isEmpty) {
      return 'Phone number is required';
    }
    if (!isValidPhoneNumber(phoneController.text)) {
      return 'Please enter a valid phone number';
    }
    if (amountController.text.isEmpty) {
      return 'Amount is required';
    }
    if (!isValidAmount(amountController.text)) {
      return 'Please enter a valid amount (1-10,000)';
    }
    if (selectedOperator.value.isEmpty) {
      return 'Please select an operator';
    }
    return null;
  }
}
