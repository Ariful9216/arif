import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'controller/affiliate_dashboard_controller.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AffiliateDashboardController>();
    
    return RefreshIndicator(
      onRefresh: controller.refreshAnalytics,
      child: Column(
        children: [
          // Time Period Filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey.shade50,
            child: Row(
              children: [
                const Text(
                  'Time Period:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Row(
                    children: [
                      _buildTimePeriodChip('Daily', 'daily', controller),
                      const SizedBox(width: 8),
                      _buildTimePeriodChip('Weekly', 'weekly', controller),
                      const SizedBox(width: 8),
                      _buildTimePeriodChip('Monthly', 'monthly', controller),
                    ],
                  )),
                ),
              ],
            ),
          ),
          
          // Analytics Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingAnalytics.value && controller.analyticsData.value.products.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                );
              }
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Cards - Always show these
                    _buildOverviewCards(controller),
                    
                    const SizedBox(height: 24),
                    
                    // Products Performance - Only show if there are products
                    if (controller.analyticsData.value.products.isNotEmpty)
                      _buildProductsPerformance(controller)
                    else
                      _buildEmptyState(),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePeriodChip(String label, String value, AffiliateDashboardController controller) {
    final isSelected = controller.selectedTimePeriod.value == value;
    
    return GestureDetector(
      onTap: () => controller.filterByTimePeriod(value),
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

  Widget _buildOverviewCards(AffiliateDashboardController controller) {
    final data = controller.analyticsData.value;
    
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total Clicks',
            data.totalClicks.toString(),
            Icons.mouse,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Total Shares',
            data.totalShares.toString(),
            Icons.share,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Total Sales',
            data.totalSales.toString(),
            Icons.shopping_cart,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductsPerformance(AffiliateDashboardController controller) {
    // Filter products - only show products with at least one metric > 0
    final filteredProducts = controller.analyticsData.value.products
        .where((product) => 
          product.shares > 0 || product.clicks > 0 || product.sales > 0
        )
        .toList();
    
    // If all products have zero metrics, show empty state
    if (filteredProducts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Products Performance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.trending_up,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No Product Performance Data',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Products will appear here once you have shares, clicks, or sales',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Products Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        
        ...filteredProducts.map((product) => 
          _buildProductCard(product)
        ).toList(),
        
        // Load more indicator
        if (controller.analyticsData.value.pagination.hasNext)
          Obx(() {
            if (controller.isLoadingMoreAnalytics.value) {
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
                controller.loadMoreAnalytics();
              });
              return const SizedBox.shrink();
            }
          }),
      ],
    );
  }

  Widget _buildProductCard(dynamic product) {
    final productName = product.product ?? 'Unknown Product';
    final shares = product.shares ?? 0;
    final clicks = product.clicks ?? 0;
    final sales = product.sales ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance text with highlighted counts
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.6,
              ),
              children: [
                TextSpan(
                  text: productName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
                const TextSpan(text: ' - '),
                TextSpan(
                  text: 'shared $shares ${shares == 1 ? 'time' : 'times'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'clicked $clicks ${clicks == 1 ? 'time' : 'times'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                if (sales > 0) ...[
                  const TextSpan(text: ' with '),
                  TextSpan(
                    text: '$sales ${sales == 1 ? 'sale' : 'sales'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
                const TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Analytics Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your affiliate analytics will appear here',
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
