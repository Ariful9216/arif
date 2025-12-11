import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'controller/recharge_screen_controller.dart';

class RechargeScreen extends StatelessWidget {
  RechargeScreen({super.key});

  final RechargeController controller = Get.put(RechargeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text("Mobile Recharge", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => Get.back()
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          await controller.fetchOperators();
          await controller.fetchRechargeHistory();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recharge Form Section
              _buildRechargeForm(),
              
              const SizedBox(height: 24),
              
              // Recharge History Section
              _buildRechargeHistory(),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRechargeForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(Icons.phone_android, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "Recharge Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Operator Selection
          _buildOperatorSelection(),
          
          const SizedBox(height: 20),
          
          // Phone Number Input
          _buildPhoneNumberInput(),
          
          const SizedBox(height: 20),
          
          // Amount Input
          _buildAmountInput(),
          
          const SizedBox(height: 24),
          
          // Submit Button
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildOperatorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Select Operator",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => controller.isLoadingOperators.value
            ? Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : Container(
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedOperator.value.isEmpty 
                        ? null 
                        : controller.selectedOperator.value,
                    hint: Text("Choose operator", style: TextStyle(color: Colors.grey[500])),
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    items: controller.operators.map((operator) {
                      return DropdownMenuItem<String>(
                        value: operator.operatorName,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  operator.operatorCode,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(operator.operatorName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final operator = controller.operators.firstWhere((op) => op.operatorName == value);
                        controller.selectOperator(value, operator.operatorCode);
                      }
                    },
                  ),
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Phone Number",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => TextField(
          controller: controller.phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: controller.selectedOperatorCode.value.isNotEmpty 
                ? "Enter phone number (${controller.selectedOperatorCode.value})"
                : "Enter phone number",
            prefixIcon: const Icon(Icons.phone, color: AppColors.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        )),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Amount (৳)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller.amountController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: "Enter amount",
            prefixIcon: const Icon(Icons.attach_money, color: AppColors.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: controller.isSubmitEnabled.value && !controller.isSubmitting.value
            ? () => controller.submitRecharge()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: controller.isSubmitting.value
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Submit Recharge",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    ));
  }

  Widget _buildRechargeHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            children: [
              Icon(Icons.history, color: AppColors.primaryColor, size: 24),
              const SizedBox(width: 8),
              Text(
                "Recharge History",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // History List
          Obx(() => controller.isLoadingHistory.value
              ? Container(
                  height: 100,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : controller.rechargeHistory.isEmpty
                  ? Container(
                      height: 100,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "No recharge history",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.rechargeHistory.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final recharge = controller.rechargeHistory[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              // Status indicator
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: controller.getStatusColor(recharge.status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Recharge details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      recharge.phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${recharge.operator} • ${recharge.formattedAmount}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Status and date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: controller.getStatusColor(recharge.status).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      recharge.statusDisplayText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: controller.getStatusColor(recharge.status),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.formatDate(recharge.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
          
          // Pagination Controls (Improved UI)
          Obx(() => controller.rechargeHistory.isNotEmpty
              ? Column(
                  children: [
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    
                    // Main Pagination Section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!, width: 1),
                      ),
                      child: Column(
                        children: [
                          // Page Info Row
                          Obx(() => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.primaryColor.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Page ${controller.currentPage.value} of ${controller.totalPages.value}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Obx(() => Text(
                                  '${controller.rechargeHistory.length}/${controller.totalRecharges.value} records',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[700],
                                  ),
                                )),
                              ),
                            ],
                          )),
                          
                          const SizedBox(height: 16),
                          
                          // Navigation Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Previous Button
                              Expanded(
                                child: Obx(() => ElevatedButton.icon(
                                  onPressed: controller.hasPrevPage.value && !controller.isLoadingHistory.value
                                      ? controller.loadPreviousPage
                                      : null,
                                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                                  label: const Text('Previous'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: controller.hasPrevPage.value
                                        ? AppColors.primaryColor
                                        : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[500],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: controller.hasPrevPage.value ? 2 : 0,
                                  ),
                                )),
                              ),
                              
                              const SizedBox(width: 12),
                              
                              // Next Button
                              Expanded(
                                child: Obx(() => ElevatedButton.icon(
                                  onPressed: controller.hasNextPage.value && !controller.isLoadingHistory.value
                                      ? controller.loadNextPage
                                      : null,
                                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                                  label: const Text('Next'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: controller.hasNextPage.value
                                        ? AppColors.primaryColor
                                        : Colors.grey[300],
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: Colors.grey[300],
                                    disabledForegroundColor: Colors.grey[500],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: controller.hasNextPage.value ? 2 : 0,
                                  ),
                                )),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Progress Indicator
                          Obx(() => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: controller.currentPage.value / controller.totalPages.value,
                              minHeight: 6,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryColor,
                              ),
                            ),
                          )),
                          
                          const SizedBox(height: 10),
                          
                          // Progress Text
                          Obx(() => Text(
                            'Progress: ${(controller.currentPage.value / controller.totalPages.value * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
