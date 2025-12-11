import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/affiliate_sales_model.dart';
import 'controller/affiliate_dashboard_controller.dart';
import 'widgets/sales_item_widget.dart';
import 'widgets/sales_summary_cards.dart';
import 'widgets/sales_filter_bottom_sheet.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateDashboardController>();
    
    return RefreshIndicator(
      onRefresh: controller.refreshSales,
      child: Column(
        children: [
          // Summary Cards
          Obx(() => SalesSummaryCards(
            totalCashback: controller.salesSummary.value.totalCommission,
            totalCount: controller.salesSummary.value.totalCount,
            totalSales: controller.salesSummary.value.totalSales,
          )),
          
          // Filter and Sales List
          Expanded(
            child: Column(
              children: [
                // Filter Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey.shade50,
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildFilterChip(
                          'All',
                          controller.selectedStatus.value.isEmpty,
                          () => controller.filterByStatus(''),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => _buildFilterChip(
                          'Pending',
                          controller.selectedStatus.value == 'pending',
                          () => controller.filterByStatus('pending'),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => _buildFilterChip(
                          'Completed',
                          controller.selectedStatus.value == 'completed',
                          () => controller.filterByStatus('completed'),
                        )),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => _buildFilterChip(
                          'Cancelled',
                          controller.selectedStatus.value == 'cancelled',
                          () => controller.filterByStatus('cancelled'),
                        )),
                      ),
                    ],
                  ),
                ),
                
                // Sales List
                Expanded(
                  child: Obx(() {
                    if (controller.isLoadingSales.value && controller.sales.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    
                    if (controller.sales.isEmpty) {
                      return _buildEmptyState();
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: controller.sales.length + (controller.salesPagination.value.hasNext ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == controller.sales.length) {
                          // Load more indicator
                          if (controller.isLoadingMoreSales.value) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            );
                          } else {
                            // Trigger load more
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              controller.loadMoreSales();
                            });
                            return const SizedBox.shrink();
                          }
                        }
                        
                        final sale = controller.sales[index];
                        return SalesItemWidget(sale: sale);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Sales Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your affiliate sales will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
