import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/model/order_model.dart';
import 'package:arif_mart/core/services/order_service.dart';

class ShoppingDashboardController extends GetxController {
  late OrderService _orderService;

  // Order data
  final RxList<OrderData> allOrders = <OrderData>[].obs;
  final RxList<OrderData> inProcessOrders = <OrderData>[].obs;
  final RxList<OrderData> completedOrders = <OrderData>[].obs;
  
  // Loading states
  final RxBool isLoadingOrders = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Tab selection
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _orderService = Get.find<OrderService>();
    loadUserOrders();
  }

  // Load user orders
  Future<void> loadUserOrders() async {
    try {
      isLoadingOrders.value = true;
      errorMessage.value = '';
      
      final response = await _orderService.getUserOrders();
      
      if (response != null && response.success) {
        allOrders.value = response.data ?? [];
        _filterOrders();
        print('Loaded ${allOrders.length} orders');
      } else {
        allOrders.clear();
        inProcessOrders.clear();
        completedOrders.clear();
        errorMessage.value = response?.message ?? 'Failed to load orders';
      }
    } catch (e) {
      print('Error loading orders: $e');
      allOrders.clear();
      inProcessOrders.clear();
      completedOrders.clear();
      errorMessage.value = 'Error loading orders: $e';
    } finally {
      isLoadingOrders.value = false;
    }
  }

  // Filter orders based on status
  void _filterOrders() {
    // In Process: All statuses except delivered, cancelled, unknown, rejected
    inProcessOrders.value = allOrders.where((order) {
      final status = order.status.toLowerCase();
      return !['delivered', 'cancelled', 'unknown', 'rejected'].contains(status);
    }).toList();

    // All (Completed): delivered, cancelled, rejected, unknown
    completedOrders.value = allOrders.where((order) {
      final status = order.status.toLowerCase();
      return ['delivered', 'cancelled', 'rejected', 'unknown'].contains(status);
    }).toList();

    print('In Process orders: ${inProcessOrders.length}');
    print('Completed orders: ${completedOrders.length}');
  }

  // Switch tab
  void switchTab(int index) {
    selectedTabIndex.value = index;
  }

  // Get current orders based on selected tab
  List<OrderData> get currentOrders {
    switch (selectedTabIndex.value) {
      case 0:
        return inProcessOrders;
      case 1:
        return completedOrders;
      default:
        return [];
    }
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadUserOrders();
  }

  // Get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.cyan;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'rejected':
        return Colors.red;
      case 'unknown':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Get status display text
  String getStatusDisplayText(String status) {
    return status.capitalizeFirst ?? status;
  }
}