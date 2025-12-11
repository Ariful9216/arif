import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:intl/intl.dart';

import 'controller/income_screen_controller.dart';

class IncomeScreen extends StatelessWidget {
  IncomeScreen({super.key});

  final IncomeController controller = Get.put(IncomeController());

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date.toLocal());
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildIncomeCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "৳${amount.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 20,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Income Balance", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: () async {
            await controller.fetchEarnings();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Total Income Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryColor, AppColors.primaryColor.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        "Total Income",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(
                        () => Text(
                          "৳${controller.totalIncome.value.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Income Sources Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: const Text(
                    "Income Sources",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Income Sources Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // From Referral
                      Obx(
                        () => _buildIncomeCard(
                          title: "From Referral",
                          amount: controller.referralEarnings.value,
                          icon: Icons.people_alt_outlined,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // From Shopping
                      Obx(
                        () => _buildIncomeCard(
                          title: "From Shopping",
                          amount: controller.shoppingEarnings.value,
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // From Recharge
                      Obx(
                        () => _buildIncomeCard(
                          title: "From Recharge",
                          amount: controller.rechargeEarnings.value,
                          icon: Icons.phone_android_outlined,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  child: const Text(
                    "Recent Transaction",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Obx(() {
                  if (controller.lastTransaction.value != null) {
                    final transaction = controller.lastTransaction.value!;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  transaction.description,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: transaction.type == 'credit' ? Colors.green[100] : Colors.red[100],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  transaction.type.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: transaction.type == 'credit' ? Colors.green[700] : Colors.red[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "৳${transaction.amount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: transaction.type == 'credit' ? Colors.green[600] : Colors.red[600],
                                ),
                              ),
                              Text(
                                formatDate(transaction.createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "No recent transactions",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }
}
