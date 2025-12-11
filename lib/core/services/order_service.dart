import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/model/order_model.dart';

class OrderService {
  // Create new order
  Future<SingleOrderModel?> createOrder({
    required List<Map<String, dynamic>> items,
    required String addressId,
    required double deliveryCost,
  }) async {
    try {
      print('Creating new order with ${items.length} items');
      
      // Debug: Log items with referrerId information
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        print('📦 Order Item ${i + 1}:');
        print('   Product: ${item['product']}');
        print('   Variant: ${item['variant'] ?? 'None'}');
        print('   Quantity: ${item['quantity']}');
        print('   Price: ${item['price']}');
        print('   Referrer ID: ${item['referrerId'] ?? 'None'}');
        print('   Has Referrer: ${item['referrerId'] != null ? '✅ YES' : '❌ NO'}');
      }
      
      Map<String, dynamic> requestBody = {
        'items': items,
        'address': addressId,
        'deliveryCost': deliveryCost,
      };
      
      print('📤 Order Request Body: ${requestBody.toString()}');
      
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .post(url: Apis.orders, body: requestBody);
      
      if (data != null && data['success'] == true) {
        print('Create order API response: ${data.toString()}');
        return SingleOrderModel.fromJson(data);
      } else {
        print('Failed to create order: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error creating order: $e');
      return null;
    }
  }

  // Get user orders
  Future<OrderModel?> getUserOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      String queryParams = '?page=$page&limit=$limit&sortBy=$sortBy&sortOrder=$sortOrder';
      if (status != null && status.isNotEmpty) {
        queryParams += '&status=$status';
      }
      
      print('Fetching user orders: ${Apis.ecommerceBaseUrl}${Apis.userOrders}$queryParams');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '${Apis.userOrders}$queryParams');
      
      if (data != null && data['success'] == true) {
        print('User orders API response: ${data.toString()}');
        return OrderModel.fromJson(data);
      } else {
        print('Failed to fetch user orders: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching user orders: $e');
      return null;
    }
  }

  // Get order by ID
  Future<SingleOrderModel?> getOrderById(String orderId) async {
    try {
      print('Fetching order by ID: $orderId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: '${Apis.orders}/$orderId');
      
      if (data != null && data['success'] == true) {
        print('Order by ID API response: ${data.toString()}');
        return SingleOrderModel.fromJson(data);
      } else {
        print('Failed to fetch order: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching order: $e');
      return null;
    }
  }

  // Cancel order
  Future<bool> cancelOrder(String orderId) async {
    try {
      print('Cancelling order: $orderId');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .patch(url: '${Apis.orders}/$orderId/cancel', body: {});
      
      if (data != null && data['success'] == true) {
        print('Cancel order API response: ${data.toString()}');
        return true;
      } else {
        print('Failed to cancel order: ${data?['message'] ?? "Unknown error"}');
      }
      return false;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }

  // Get user order statistics
  Future<OrderStatsModel?> getUserOrderStats() async {
    try {
      print('Fetching user order statistics');
      Map<String, dynamic>? data = await EcommerceDioHelper(isTokenNeeded: true)
          .get(url: Apis.orderStats);
      
      if (data != null && data['success'] == true) {
        print('Order stats API response: ${data.toString()}');
        return OrderStatsModel.fromJson(data);
      } else {
        print('Failed to fetch order stats: ${data?['message'] ?? "Unknown error"}');
      }
      return null;
    } catch (e) {
      print('Error fetching order stats: $e');
      return null;
    }
  }
}





