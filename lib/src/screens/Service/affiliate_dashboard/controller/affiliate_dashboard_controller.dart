import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/affiliate_sales_model.dart';
import 'package:arif_mart/core/services/ecommerce_service.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

class AffiliateDashboardController extends GetxController {
  // Current page state
  final RxInt currentPage = 0.obs; // 0 = Sales, 1 = Analytics
  
  // Sales data
  final RxList<AffiliateSale> sales = <AffiliateSale>[].obs;
  final Rx<SalesSummary> salesSummary = SalesSummary(
    totalSales: 0,
    totalCommission: 0,
    totalCount: 0,
  ).obs;
  final Rx<AffiliatePaginationInfo> salesPagination = AffiliatePaginationInfo(
    currentPage: 1,
    totalPages: 1,
    totalSales: 0,
    hasNext: false,
    hasPrev: false,
  ).obs;
  
  // Analytics data
  final Rx<AffiliateStatisticsData> analyticsData = AffiliateStatisticsData(
    totalClicks: 0,
    totalShares: 0,
    totalSales: 0,
    products: [],
    pagination: AffiliatePaginationInfo(
      currentPage: 1,
      totalPages: 1,
      totalSales: 0,
      hasNext: false,
      hasPrev: false,
    ),
  ).obs;
  
  // Loading states
  final RxBool isLoadingSales = false.obs;
  final RxBool isLoadingAnalytics = false.obs;
  final RxBool isLoadingMoreSales = false.obs;
  final RxBool isLoadingMoreAnalytics = false.obs;
  
  // Current page for pagination
  final RxInt currentSalesPage = 1.obs;
  final RxInt currentAnalyticsPage = 1.obs;
  
  // Filter options
  final RxString selectedStatus = ''.obs; // 'pending', 'completed', 'cancelled', or '' for all
  final RxString selectedTimePeriod = 'daily'.obs; // 'daily', 'weekly', 'monthly'

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    loadSalesData();
  }

  // Navigation methods
  void switchToSales() {
    currentPage.value = 0;
    if (sales.isEmpty) {
      loadSalesData();
    }
  }

  void switchToAnalytics() {
    currentPage.value = 1;
    if (analyticsData.value.products.isEmpty) {
      loadAnalyticsData();
    }
  }

  // Sales data methods
  Future<void> loadSalesData({bool refresh = false}) async {
    try {
      if (refresh) {
        currentSalesPage.value = 1;
        sales.clear();
      }
      
      isLoadingSales.value = true;
      
      print('Loading affiliate sales - Page: ${currentSalesPage.value}, Status: ${selectedStatus.value}');
      
      final response = await EcommerceService.to.getMyAffiliateSales(
        page: currentSalesPage.value,
        limit: 10,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      
      if (response != null && response['success'] == true) {
        final salesModel = AffiliateSalesModel.fromJson(response);
        
        if (refresh) {
          sales.value = salesModel.data.sales;
        } else {
          sales.addAll(salesModel.data.sales);
        }
        
        salesSummary.value = salesModel.data.summary;
        salesPagination.value = salesModel.data.pagination;
        
        print('Sales loaded: ${sales.length} items, Total: ${salesPagination.value.totalSales}');
        print('Summary - Total Sales: ${salesSummary.value.totalSales}, Commission: ${salesSummary.value.totalCommission}');
      } else {
        showToast(response?['message'] ?? 'Failed to load sales data');
      }
    } catch (e) {
      print('Error loading sales data: $e');
      showToast('Error loading sales data');
    } finally {
      isLoadingSales.value = false;
    }
  }

  Future<void> loadMoreSales() async {
    if (isLoadingMoreSales.value || !salesPagination.value.hasNext) return;
    
    try {
      isLoadingMoreSales.value = true;
      currentSalesPage.value++;
      
      final response = await EcommerceService.to.getMyAffiliateSales(
        page: currentSalesPage.value,
        limit: 10,
        status: selectedStatus.value.isEmpty ? null : selectedStatus.value,
      );
      
      if (response != null && response['success'] == true) {
        final salesModel = AffiliateSalesModel.fromJson(response);
        sales.addAll(salesModel.data.sales);
        salesPagination.value = salesModel.data.pagination;
        
        print('Loaded more sales: ${salesModel.data.sales.length} items');
      }
    } catch (e) {
      print('Error loading more sales: $e');
      currentSalesPage.value--; // Revert page increment on error
    } finally {
      isLoadingMoreSales.value = false;
    }
  }

  // Analytics data methods
  Future<void> loadAnalyticsData({bool refresh = false}) async {
    try {
      if (refresh) {
        currentAnalyticsPage.value = 1;
      }
      
      isLoadingAnalytics.value = true;
      
      print('Loading affiliate analytics - Page: ${currentAnalyticsPage.value}, Period: ${selectedTimePeriod.value}');
      
      final response = await EcommerceService.to.getAffiliateStatistics(
        page: currentAnalyticsPage.value,
        limit: 10,
        type: selectedTimePeriod.value,
      );
      
      if (response != null && response['success'] == true) {
        final analyticsModel = AffiliateStatisticsModel.fromJson(response);
        
        print('📊 Analytics API Response: $response');
        print('📊 Parsed Analytics Data: ${analyticsModel.data}');
        
        if (refresh) {
          analyticsData.value = analyticsModel.data;
        } else {
          // Merge new data with existing
          final existingProducts = analyticsData.value.products;
          final newProducts = analyticsModel.data.products;
          analyticsData.value = analyticsModel.data.copyWith(
            products: [...existingProducts, ...newProducts],
          );
        }
        
        print('📊 Analytics loaded: ${analyticsData.value.products.length} products');
        print('📊 Total Clicks: ${analyticsData.value.totalClicks}, Shares: ${analyticsData.value.totalShares}, Sales: ${analyticsData.value.totalSales}');
      } else {
        print('📊 Analytics API failed: ${response?['message']}');
        showToast(response?['message'] ?? 'Failed to load analytics data');
      }
    } catch (e) {
      print('Error loading analytics data: $e');
      showToast('Error loading analytics data');
    } finally {
      isLoadingAnalytics.value = false;
    }
  }

  Future<void> loadMoreAnalytics() async {
    if (isLoadingMoreAnalytics.value || !analyticsData.value.pagination.hasNext) return;
    
    try {
      isLoadingMoreAnalytics.value = true;
      currentAnalyticsPage.value++;
      
      final response = await EcommerceService.to.getAffiliateStatistics(
        page: currentAnalyticsPage.value,
        limit: 10,
        type: selectedTimePeriod.value,
      );
      
      if (response != null && response['success'] == true) {
        final analyticsModel = AffiliateStatisticsModel.fromJson(response);
        final existingProducts = analyticsData.value.products;
        analyticsData.value = analyticsModel.data.copyWith(
          products: [...existingProducts, ...analyticsModel.data.products],
        );
        
        print('Loaded more analytics: ${analyticsModel.data.products.length} products');
      }
    } catch (e) {
      print('Error loading more analytics: $e');
      currentAnalyticsPage.value--; // Revert page increment on error
    } finally {
      isLoadingMoreAnalytics.value = false;
    }
  }

  // Filter methods
  void filterByStatus(String status) {
    selectedStatus.value = status;
    currentSalesPage.value = 1;
    sales.clear();
    loadSalesData();
  }

  void filterByTimePeriod(String period) {
    selectedTimePeriod.value = period;
    currentAnalyticsPage.value = 1;
    analyticsData.value = analyticsData.value.copyWith(products: []);
    loadAnalyticsData();
  }

  // Refresh methods
  Future<void> refreshSales() async {
    await loadSalesData(refresh: true);
  }

  Future<void> refreshAnalytics() async {
    await loadAnalyticsData(refresh: true);
  }

  // Utility methods
  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  String getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'orange';
      case 'completed':
        return 'green';
      case 'cancelled':
        return 'red';
      default:
        return 'grey';
    }
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// Extension to add copyWith method to AffiliateStatisticsData
extension AffiliateStatisticsDataExtension on AffiliateStatisticsData {
  AffiliateStatisticsData copyWith({
    int? totalClicks,
    int? totalShares,
    int? totalSales,
    List<ProductStatistics>? products,
    AffiliatePaginationInfo? pagination,
  }) {
    return AffiliateStatisticsData(
      totalClicks: totalClicks ?? this.totalClicks,
      totalShares: totalShares ?? this.totalShares,
      totalSales: totalSales ?? this.totalSales,
      products: products ?? this.products,
      pagination: pagination ?? this.pagination,
    );
  }
}
