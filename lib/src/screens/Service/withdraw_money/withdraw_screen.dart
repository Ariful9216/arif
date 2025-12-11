import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/repository.dart';
import 'package:arif_mart/core/model/withdrawal_model.dart';

import 'controller/withdraw_cotroller.dart';

class WithdrawScreen extends StatelessWidget {
  WithdrawScreen({super.key});

  final WithdrawController controller = Get.put(WithdrawController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdraw Money", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: InkWell(
              onTap: () {
                // Navigate to withdrawal history
                Get.to(() => WithdrawalHistoryScreen());
              },
              child: const Icon(
                Icons.history,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        return Form(
          key: controller.withdrawFormKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Available Balance Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                  color: AppColors.primaryColor,
                  child: const Text("Available\nBalance", style: TextStyle(color: Colors.white)),
                ).paddingOnly(top: 20, bottom: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(
                      () => Column(
                        children: [
                          Text(
                            "৳${controller.totalIncome.value.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 22,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text("Earnings"),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Withdraw Option Section
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
                  color: AppColors.primaryColor,
                  child: const Text("Withdraw\nOption", style: TextStyle(color: Colors.white)),
                ),

                const SizedBox(height: 20),

                // Withdrawal Type Selection
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select Withdrawal Method",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: Obx(() => RadioListTile<String>(
                              title: const Text("Mobile Banking"),
                              value: "mobile_banking",
                              groupValue: controller.selectedWithdrawType.value,
                              onChanged: (value) => controller.selectWithdrawType(value!),
                              activeColor: AppColors.primaryColor,
                            )),
                          ),
                          Expanded(
                            child: Obx(() => RadioListTile<String>(
                              title: const Text("Bank Transfer"),
                              value: "bank_transfer",
                              groupValue: controller.selectedWithdrawType.value,
                              onChanged: (value) => controller.selectWithdrawType(value!),
                              activeColor: AppColors.primaryColor,
                            )),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Amount Field (Common for both types)
                      _buildTextField(
                        controller: controller.amountController,
                        hint: "Enter withdrawal amount",
                        label: "Amount (৳)",
                        keyboardType: TextInputType.number,
                        validator: controller.validateAmount,
                      ),

                      const SizedBox(height: 16),

                      // Mobile Banking Section
                      Obx(() {
                        if (controller.selectedWithdrawType.value == 'mobile_banking') {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Select Mobile Banking",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              
                              Obx(() {
                                if (controller.isMobileBankingLoading.value) {
                                  return const Center(
                                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                                  );
                                }

                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    childAspectRatio: 1.2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: controller.mobileBankingList.length,
                                  itemBuilder: (context, index) {
                                    final bank = controller.mobileBankingList[index];
                                    final isSelected = controller.selectedMobileBank.value?.id == bank.id;
                                    
                                    return InkWell(
                                      onTap: () => controller.selectMobileBank(bank),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected ? AppColors.primaryColor : Colors.grey[300]!,
                                            width: isSelected ? 3 : 1,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          color: isSelected ? AppColors.primaryColor.withOpacity(0.15) : Colors.white,
                                          boxShadow: isSelected 
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.primaryColor.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [
                                                BoxShadow(
                                                  color: Colors.grey.withOpacity(0.1),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
                                        ),
                                        child: Stack(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  // Center the logo
                                                  Center(
                                                    child: Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius: BorderRadius.circular(25),
                                                        border: Border.all(
                                                          color: isSelected 
                                                            ? AppColors.primaryColor
                                                            : Colors.grey[300]!,
                                                          width: isSelected ? 2 : 1,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black.withOpacity(0.1),
                                                            blurRadius: 4,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius: BorderRadius.circular(23),
                                                        child: bank.logo.isNotEmpty 
                                                          ? Image.network(
                                                              "${Apis.mobileBankingBaseUrl}${bank.logo}",
                                                              height: 46,
                                                              width: 46,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (context, child, loadingProgress) {
                                                                if (loadingProgress == null) return child;
                                                                return Container(
                                                                  height: 46,
                                                                  width: 46,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.grey[200],
                                                                    borderRadius: BorderRadius.circular(23),
                                                                  ),
                                                                  child: const Center(
                                                                    child: SizedBox(
                                                                      height: 20,
                                                                      width: 20,
                                                                      child: CircularProgressIndicator(
                                                                        strokeWidth: 2,
                                                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (context, error, stackTrace) {
                                                                return Container(
                                                                  height: 46,
                                                                  width: 46,
                                                                  decoration: BoxDecoration(
                                                                    color: AppColors.primaryColor.withOpacity(0.1),
                                                                    borderRadius: BorderRadius.circular(23),
                                                                  ),
                                                                  child: const Icon(
                                                                    Icons.account_balance_wallet,
                                                                    color: AppColors.primaryColor,
                                                                    size: 20,
                                                                  ),
                                                                );
                                                              },
                                                            )
                                                          : Container(
                                                              height: 46,
                                                              width: 46,
                                                              decoration: BoxDecoration(
                                                                color: AppColors.primaryColor.withOpacity(0.1),
                                                                borderRadius: BorderRadius.circular(23),
                                                              ),
                                                              child: const Icon(
                                                                Icons.account_balance_wallet,
                                                                color: AppColors.primaryColor,
                                                                size: 20,
                                                              ),
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Center the text
                                                  Expanded(
                                                    child: Center(
                                                      child: Text(
                                                        bank.name,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                                          color: isSelected ? AppColors.primaryColor : Colors.black87,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Checkmark icon for selected state
                                            if (isSelected)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryColor,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Colors.white, width: 2),
                                                  ),
                                                  child: const Icon(
                                                    Icons.check,
                                                    color: Colors.white,
                                                    size: 12,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),

                              const SizedBox(height: 12),

                              // Selected mobile bank indicator
                              Obx(() {
                                if (controller.selectedMobileBank.value != null) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.primaryColor.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: AppColors.primaryColor,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Selected: ${controller.selectedMobileBank.value!.name}",
                                          style: TextStyle(
                                            color: AppColors.primaryColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange[700],
                                          size: 16,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Please select a mobile banking option",
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }),

                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: controller.mobileNumberController,
                                hint: "Enter mobile number",
                                label: "Mobile Number",
                                keyboardType: TextInputType.phone,
                                validator: controller.validateMobileNumber,
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      // Bank Transfer Section
                      Obx(() {
                        if (controller.selectedWithdrawType.value == 'bank_transfer') {
                          return Column(
                            children: [
                              _buildTextField(
                                controller: controller.bankNameController,
                                hint: "Enter bank name",
                                label: "Bank Name",
                                validator: (value) => controller.validateBankField(value, "bank name"),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: controller.bankBranchNameController,
                                hint: "Enter branch name",
                                label: "Branch Name",
                                validator: (value) => controller.validateBankField(value, "branch name"),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: controller.bankAccountNumberController,
                                hint: "Enter account number",
                                label: "Account Number",
                                keyboardType: TextInputType.number,
                                validator: (value) => controller.validateBankField(value, "account number"),
                              ),
                              const SizedBox(height: 16),
                              
                              _buildTextField(
                                controller: controller.accountHolderNameController,
                                hint: "Enter account holder name",
                                label: "Account Holder Name",
                                validator: (value) => controller.validateBankField(value, "account holder name"),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      const SizedBox(height: 30),

                      // Submit Button
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value ? null : controller.submitWithdrawal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            controller.isSubmitting.value ? "Submitting..." : "Submit Withdrawal",
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      )),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
        ),
      ),
    );
  }
}

// Withdrawal History Screen
class WithdrawalHistoryScreen extends StatelessWidget {
  WithdrawalHistoryScreen({super.key});

  final WithdrawalHistoryController controller = Get.put(WithdrawalHistoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Withdrawal History", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryColor),
          );
        }

        if (controller.withdrawalList.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "No withdrawal history",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: controller.fetchWithdrawals,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.withdrawalList.length,
            itemBuilder: (context, index) {
              final withdrawal = controller.withdrawalList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "৳${withdrawal.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(withdrawal.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            withdrawal.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(withdrawal.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Show type with icon
                    Row(
                      children: [
                        Icon(
                          withdrawal.type == 'mobile_banking' 
                            ? Icons.phone_android 
                            : Icons.account_balance,
                          size: 16,
                          color: Colors.grey[700],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          withdrawal.type == 'mobile_banking' 
                            ? "Mobile Banking" 
                            : "Bank Transfer",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Show details based on type
                    if (withdrawal.type == 'mobile_banking') ...[
                      _buildDetailRow("Operator", withdrawal.mobileOperator ?? 'N/A'),
                      _buildDetailRow("Mobile Number", withdrawal.mobileNumber ?? 'N/A'),
                    ] else if (withdrawal.type == 'bank_transfer') ...[
                      _buildDetailRow("Bank Name", withdrawal.bankName ?? 'N/A'),
                      _buildDetailRow("Branch", withdrawal.bankBranchName ?? 'N/A'),
                      _buildDetailRow("Account Number", withdrawal.bankAccountNumber ?? 'N/A'),
                      _buildDetailRow("Account Holder", withdrawal.accountHolderName ?? 'N/A'),
                    ],
                    
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          controller.formatDate(withdrawal.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Withdrawal History Controller
class WithdrawalHistoryController extends GetxController {
  var withdrawalList = <WithdrawalItem>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWithdrawals();
  }

  Future<void> fetchWithdrawals() async {
    try {
      isLoading.value = true;
      
      final withdrawalModel = await Repository.getWithdrawals();
      
      if (withdrawalModel != null && withdrawalModel.success) {
        withdrawalList.value = withdrawalModel.data;
        print("Withdrawal history loaded: ${withdrawalList.length} items");
      } else {
        print("Failed to load withdrawal history");
      }
    } catch (e) {
      print("Error fetching withdrawal history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateString;
    }
  }
}
