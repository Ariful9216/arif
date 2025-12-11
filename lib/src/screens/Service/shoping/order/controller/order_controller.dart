import 'package:get/get.dart';
import 'package:arif_mart/core/model/order_model.dart';
import 'package:arif_mart/core/model/address_model.dart';
import 'package:arif_mart/core/model/cart_model.dart';
import 'package:arif_mart/core/services/order_service.dart';
import 'package:arif_mart/core/services/address_service.dart';
import 'package:arif_mart/src/screens/Service/shoping/cart/controller/cart_controller.dart';

class OrderController extends GetxController {
  late OrderService _orderService;
  late AddressService _addressService;

  // Order state
  final RxList<OrderData> orders = <OrderData>[].obs;
  final Rx<OrderData?> currentOrder = Rx<OrderData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxBool hasMoreOrders = true.obs;
  final RxInt totalCount = 0.obs;

  // Order statistics
  final Rx<OrderStatsData?> orderStats = Rx<OrderStatsData?>(null);

  // Checkout state
  final RxList<CartItem> checkoutItems = <CartItem>[].obs;
  final RxDouble checkoutSubtotal = 0.0.obs;
  final RxDouble checkoutDeliveryCost = 0.0.obs;
  final RxDouble checkoutTotal = 0.0.obs;
  final RxBool isInsideCity = true.obs;

  // Address selection for checkout
  final RxList<AddressData> availableAddresses = <AddressData>[].obs;
  final Rx<AddressData?> selectedAddress = Rx<AddressData?>(null);
  final RxBool isLoadingAddresses = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      _orderService = Get.find<OrderService>();
      _addressService = Get.find<AddressService>();
      print('✅ OrderController: Services found successfully');
    } catch (e) {
      print('❌ OrderController: Error finding services: $e');
      // Try to find services with a delay
      Future.delayed(const Duration(milliseconds: 100), () {
        try {
          _orderService = Get.find<OrderService>();
          _addressService = Get.find<AddressService>();
          print('✅ OrderController: Services found on retry');
        } catch (retryError) {
          print('❌ OrderController: Services still not found: $retryError');
          errorMessage.value = 'Services not available. Please restart the app.';
        }
      });
    }
  }

  // Load user orders
  Future<void> loadUserOrders({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        hasMoreOrders.value = true;
        errorMessage.value = '';
      }

      if (currentPage.value == 1) {
        isLoading.value = true;
        orders.clear();
      } else {
        isLoadingMore.value = true;
      }

      final response = await _orderService.getUserOrders(
        page: currentPage.value,
        limit: 20,
        sortBy: 'createdAt',
        sortOrder: 'desc',
      );

      if (response != null && response.success) {
        final newOrders = response.data ?? [];
        
        if (refresh) {
          orders.value = newOrders;
        } else {
          orders.addAll(newOrders);
        }

        if (newOrders.isNotEmpty) {
          currentPage.value++;
        } else {
          hasMoreOrders.value = false;
        }

        print('Loaded ${orders.length} orders for page ${currentPage.value}');
      } else {
        errorMessage.value = response?.message ?? 'Failed to load orders';
        print('Failed to load orders: ${errorMessage.value}');
      }
    } catch (e) {
      print('Error loading orders: $e');
      errorMessage.value = 'Error loading orders: $e';
      
      if (currentPage.value == 1) {
        orders.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  // Load order statistics
  Future<void> loadOrderStats() async {
    try {
      final response = await _orderService.getUserOrderStats();
      
      if (response != null && response.success && response.data != null) {
        orderStats.value = response.data;
        print('Order stats loaded: ${response.data!.totalOrders} total orders');
      } else {
        print('Failed to load order stats: ${response?.message}');
      }
    } catch (e) {
      print('Error loading order stats: $e');
    }
  }

  // Initialize checkout with cart items
  void initializeCheckout(List<CartItem> cartItems, double subtotal, double deliveryCost, bool isInsideCity) {
    checkoutItems.value = List.from(cartItems);
    checkoutSubtotal.value = subtotal;
    checkoutDeliveryCost.value = deliveryCost;
    checkoutTotal.value = subtotal + deliveryCost;
    this.isInsideCity.value = isInsideCity;
    
    // Load available addresses for checkout
    loadAvailableAddresses();
  }

  // Load available addresses for checkout
  Future<void> loadAvailableAddresses() async {
    try {
      isLoadingAddresses.value = true;
      
      final response = await _addressService.getAddressesForOrder();
      
      if (response != null && response.success) {
        availableAddresses.value = response.data ?? [];
        
        // Set default address as selected if available
        final defaultAddress = availableAddresses.firstWhereOrNull((addr) => addr.isDefault);
        selectedAddress.value = defaultAddress ?? (availableAddresses.isNotEmpty ? availableAddresses.first : null);
        
        print('Loaded ${availableAddresses.length} addresses for checkout');
      } else {
        availableAddresses.clear();
        selectedAddress.value = null;
        print('Failed to load addresses: ${response?.message}');
      }
    } catch (e) {
      print('Error loading addresses: $e');
      availableAddresses.clear();
      selectedAddress.value = null;
    } finally {
      isLoadingAddresses.value = false;
    }
  }

  // Select address for checkout
  void selectAddress(AddressData address) {
    selectedAddress.value = address;
  }

  // Refresh addresses (useful after returning from address management)
  Future<void> refreshAddresses() async {
    await loadAvailableAddresses();
  }

  // Create order from checkout
  Future<bool> createOrderFromCheckout() async {
    if (selectedAddress.value == null) {
      errorMessage.value = 'Please select a delivery address';
      return false;
    }

    if (checkoutItems.isEmpty) {
      errorMessage.value = 'No items to order';
      return false;
    }

    // Check if services are available
    try {
      
    } catch (e) {
      errorMessage.value = 'Order service not available. Please restart the app.';
      print('❌ OrderService not found in createOrderFromCheckout: $e');
      return false;
    }

    try {
      // Prepare order items
      List<Map<String, dynamic>> orderItems = [];
      for (var item in checkoutItems) {
        Map<String, dynamic> orderItem = {
          'product': item.product.id,
          'variant': item.variant?.id,
          'quantity': item.quantity,
          'price': item.calculatedEffectivePrice,
        };
        
        // Add referrerId if present (for affiliate tracking)
        if (item.referrerId != null && item.referrerId!.isNotEmpty) {
          orderItem['referrerId'] = item.referrerId;
          print('🛒 Adding referrerId to order item: ${item.referrerId}');
        } else {
          print('🛒 No referrerId for order item - Direct order');
        }
        
        orderItems.add(orderItem);
      }

      final response = await _orderService.createOrder(
        items: orderItems,
        addressId: selectedAddress.value!.id,
        deliveryCost: checkoutDeliveryCost.value,
      );

      if (response != null && response.success && response.data != null) {
        currentOrder.value = response.data;
        print('Order created successfully: ${response.data!.invoice}');
        
        // Clear the cart after successful order creation
        try {
          if (Get.isRegistered<CartController>()) {
            final cartController = Get.find<CartController>();
            await cartController.clearCart();
            print('Cart cleared after successful order');
          }
        } catch (e) {
          print('Error clearing cart after order: $e');
          // Don't fail the order if cart clearing fails
        }
        
        return true;
      } else {
        errorMessage.value = response?.message ?? 'Failed to create order';
        return false;
      }
    } catch (e) {
      print('Error creating order: $e');
      errorMessage.value = 'Error creating order: $e';
      return false;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      final success = await _orderService.cancelOrder(orderId);
      
      if (success) {
        // Update local order status
        final orderIndex = orders.indexWhere((order) => order.id == orderId);
        if (orderIndex != -1) {
          orders[orderIndex] = orders[orderIndex].copyWith(status: 'cancelled');
        }
        
        print('Order cancelled successfully');
        return true;
      } else {
        errorMessage.value = 'Failed to cancel order';
        return false;
      }
    } catch (e) {
      print('Error cancelling order: $e');
      errorMessage.value = 'Error cancelling order: $e';
      return false;
    }
  }

  // Get order by ID
  Future<void> loadOrderById(String orderId) async {
    try {
      final response = await _orderService.getOrderById(orderId);
      
      if (response != null && response.success && response.data != null) {
        currentOrder.value = response.data;
        print('Order loaded: ${response.data!.invoice}');
      } else {
        errorMessage.value = response?.message ?? 'Failed to load order';
      }
    } catch (e) {
      print('Error loading order: $e');
      errorMessage.value = 'Error loading order: $e';
    }
  }

  // Clear checkout data
  void clearCheckout() {
    checkoutItems.clear();
    checkoutSubtotal.value = 0.0;
    checkoutDeliveryCost.value = 0.0;
    checkoutTotal.value = 0.0;
    isInsideCity.value = true;
    availableAddresses.clear();
    selectedAddress.value = null;
  }

  // Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  // Refresh orders
  Future<void> refreshOrders() async {
    await loadUserOrders(refresh: true);
  }

  // Helper getters
  bool get hasOrders => orders.isNotEmpty;
  bool get hasCurrentOrder => currentOrder.value != null;
  bool get hasSelectedAddress => selectedAddress.value != null;
  bool get canCreateOrder => hasSelectedAddress && checkoutItems.isNotEmpty;
  
  // Get orders by status
  List<OrderData> getOrdersByStatus(String status) {
    return orders.where((order) => order.status.toLowerCase() == status.toLowerCase()).toList();
  }
  
  // Get pending orders
  List<OrderData> get pendingOrders => getOrdersByStatus('pending');
  
  // Get confirmed orders
  List<OrderData> get confirmedOrders => getOrdersByStatus('confirmed');
  
  // Get cancelled orders
  List<OrderData> get cancelledOrders => getOrdersByStatus('cancelled');
}

// Extension to add copyWith method to OrderData
extension OrderDataCopyWith on OrderData {
  OrderData copyWith({
    String? id,
    String? user,
    String? invoice,
    List<OrderItem>? items,
    OrderAddress? address,
    double? deliveryCost,
    String? status,
    bool? deliveryCostRefunded,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderData(
      id: id ?? this.id,
      user: user ?? this.user,
      invoice: invoice ?? this.invoice,
      items: items ?? this.items,
      address: address ?? this.address,
      deliveryCost: deliveryCost ?? this.deliveryCost,
      status: status ?? this.status,
      deliveryCostRefunded: deliveryCostRefunded ?? this.deliveryCostRefunded,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
