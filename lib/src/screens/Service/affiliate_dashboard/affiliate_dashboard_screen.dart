import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'controller/affiliate_dashboard_controller.dart';
import 'sales_page.dart';
import 'analytics_page.dart';

class AffiliateDashboardScreen extends StatelessWidget {
  const AffiliateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AffiliateDashboardController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Affiliate Dashboard", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              if (controller.currentPage.value == 0) {
                controller.refreshSales();
              } else {
                controller.refreshAnalytics();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Tabs
          Container(
            color: Colors.white,
            child: Obx(() => Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Sales',
                    0,
                    controller.currentPage.value == 0,
                    () => controller.switchToSales(),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Analytics',
                    1,
                    controller.currentPage.value == 1,
                    () => controller.switchToAnalytics(),
                  ),
                ),
              ],
            )),
          ),
          
          // Content based on selected tab
          Expanded(
            child: Obx(() {
              if (controller.currentPage.value == 0) {
                return const SalesPage();
              } else {
                return const AnalyticsPage();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
