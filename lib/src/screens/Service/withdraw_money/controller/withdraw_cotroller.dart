import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/helper/repository.dart';
import '../../../../../core/model/income_model.dart';
import '../../../../../core/model/mobile_banking_model.dart';
import '../../../../../core/model/withdrawal_model.dart';
import '../../../../widget/custom_loader.dart';
import '../../../../widget/custom_toast.dart';

class WithdrawController extends GetxController {
  var totalIncome = 0.0.obs;
  var isLoading = false.obs;
  var isMobileBankingLoading = false.obs;
  var isSubmitting = false.obs;
  
  // Withdrawal type
  var selectedWithdrawType = 'mobile_banking'.obs; // 'mobile_banking' or 'bank_transfer'
  
  // Mobile Banking
  var mobileBankingList = <MobileBankingItem>[].obs;
  var selectedMobileBank = Rxn<MobileBankingItem>();
  
  // Form Controllers
  TextEditingController amountController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController bankBranchNameController = TextEditingController();
  TextEditingController bankAccountNumberController = TextEditingController();
  TextEditingController accountHolderNameController = TextEditingController();
  
  // Form Keys
  GlobalKey<FormState> withdrawFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchTotalIncome();
    fetchMobileBanking();
  }

  Future<void> fetchTotalIncome() async {
    try {
      isLoading.value = true;
      
      final incomeModel = await Repository.getIncome();
      
      if (incomeModel != null && incomeModel.success) {
        totalIncome.value = incomeModel.message.totalIncome;
        print("Total income loaded: ${totalIncome.value}");
      } else {
        print("Failed to load income data");
      }
    } catch (e) {
      print("Error fetching income: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMobileBanking() async {
    try {
      isMobileBankingLoading.value = true;
      
      final mobileBankingModel = await Repository.getMobileBanking();
      
      if (mobileBankingModel != null && mobileBankingModel.success) {
        mobileBankingList.value = mobileBankingModel.data.where((bank) => bank.isActive).toList();
        print("Mobile banking loaded: ${mobileBankingList.length} items");
      } else {
        print("Failed to load mobile banking data");
      }
    } catch (e) {
      print("Error fetching mobile banking: $e");
    } finally {
      isMobileBankingLoading.value = false;
    }
  }

  void selectWithdrawType(String type) {
    selectedWithdrawType.value = type;
    clearForm();
  }

  void selectMobileBank(MobileBankingItem bank) {
    selectedMobileBank.value = bank;
  }

  void clearForm() {
    amountController.clear();
    mobileNumberController.clear();
    bankNameController.clear();
    bankBranchNameController.clear();
    bankAccountNumberController.clear();
    accountHolderNameController.clear();
    selectedMobileBank.value = null;
  }

  Future<void> submitWithdrawal() async {
    if (!withdrawFormKey.currentState!.validate()) {
      return;
    }

    if (selectedWithdrawType.value == 'mobile_banking' && selectedMobileBank.value == null) {
      showToast('Please select a mobile banking option');
      return;
    }

    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      showToast('Please enter a valid amount');
      return;
    }

    if (amount > totalIncome.value) {
      showToast('Insufficient balance');
      return;
    }

    try {
      isSubmitting.value = true;
      Loader.showLoader();

      Map<String, dynamic> withdrawalData = {
        'type': selectedWithdrawType.value,
        'amount': amount,
      };

      if (selectedWithdrawType.value == 'mobile_banking') {
        withdrawalData.addAll({
          'mobileOperator': selectedMobileBank.value!.name,
          'mobileNumber': mobileNumberController.text,
        });
      } else {
        withdrawalData.addAll({
          'bankName': bankNameController.text,
          'bankBranchName': bankBranchNameController.text,
          'bankAccountNumber': bankAccountNumberController.text,
          'accountHolderName': accountHolderNameController.text,
        });
      }

      final response = await Repository.createWithdrawal(withdrawalData: withdrawalData);

      if (response != null && (response['success'] ?? false)) {
        showToast('Withdrawal request submitted successfully');
        clearForm();
        fetchTotalIncome(); // Refresh balance
        Get.back(); // Return to previous screen
      } else {
        showToast(response?['message'] ?? 'Failed to submit withdrawal request');
      }
    } catch (e) {
      print("Error submitting withdrawal: $e");
      showToast('Failed to submit withdrawal request');
    } finally {
      isSubmitting.value = false;
      Loader.closeLoader();
    }
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter amount';
    }
    double? amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return 'Please enter a valid amount';
    }
    if (amount > totalIncome.value) {
      return 'Insufficient balance';
    }
    return null;
  }

  String? validateMobileNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter mobile number';
    }
    return null;
  }

  String? validateBankField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  @override
  void onClose() {
    amountController.dispose();
    mobileNumberController.dispose();
    bankNameController.dispose();
    bankBranchNameController.dispose();
    bankAccountNumberController.dispose();
    accountHolderNameController.dispose();
    super.onClose();
  }
}
