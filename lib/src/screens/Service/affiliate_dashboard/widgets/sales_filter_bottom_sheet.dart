import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import '../controller/affiliate_dashboard_controller.dart';

class SalesFilterBottomSheet extends StatelessWidget {
  const SalesFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateDashboardController>();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          const Text(
            'Filter Sales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Status Filter
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('All', '', controller.selectedStatus.value.isEmpty, controller),
              _buildFilterChip('Pending', 'pending', controller.selectedStatus.value == 'pending', controller),
              _buildFilterChip('Completed', 'completed', controller.selectedStatus.value == 'completed', controller),
              _buildFilterChip('Cancelled', 'cancelled', controller.selectedStatus.value == 'cancelled', controller),
            ],
          )),
          
          const SizedBox(height: 30),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Apply Filter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, bool isSelected, AffiliateDashboardController controller) {
    return GestureDetector(
      onTap: () => controller.filterByStatus(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
