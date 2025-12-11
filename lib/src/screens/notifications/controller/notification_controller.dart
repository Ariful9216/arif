import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/notification_model.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';
import 'package:arif_mart/src/screens/home_screen/controller/home_controller.dart';

class NotificationController extends GetxController {
  var notifications = <NotificationItem>[].obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var unreadCount = 0.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    print("=== NOTIFICATION CONTROLLER INIT ===");
    setupScrollListener();
    // Add a small delay to ensure everything is initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      fetchNotifications();
      fetchUnreadCount();
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    // Update home controller one final time when closing
    _updateHomeControllerUnreadCount(unreadCount.value);
    super.onClose();
  }

  void setupScrollListener() {
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        if (hasMoreData.value && !isLoadingMore.value) {
          loadMoreNotifications();
        }
      }
    });
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      print("=== FETCHING NOTIFICATIONS ===");
      
      if (refresh) {
        currentPage.value = 1;
        hasMoreData.value = true;
      }
      
      isLoading.value = true;
      
      // Check if user has authentication token
      final token = HiveHelper.getToken;
      print("Auth token available: ${token != null && token.isNotEmpty}");
      
      if (token == null || token.isEmpty) {
        print("No authentication token available");
        showToast('Please login to view notifications');
        isLoading.value = false;
        return;
      }
      
      print("Making API call for notifications (page: ${currentPage.value})");
      final response = await Repository.getNotifications(page: currentPage.value);
      print("API response received: ${response != null}");
      
      if (response != null && response.success) {
        print("Response success: true");
        if (response.data != null) {
          print("Response data available: ${response.data!.notifications.length} notifications");
          
          if (refresh) {
            notifications.clear();
          }
          
          notifications.addAll(response.data!.notifications);
          totalPages.value = response.data!.pagination.totalPages;
          hasMoreData.value = currentPage.value < totalPages.value;
          
          print("Notifications loaded: ${notifications.length} items (Page ${currentPage.value}/${totalPages.value})");
        } else {
          print("Response data is null");
        }
      } else {
        print("API request failed: ${response?.message ?? 'Unknown error'}");
        showToast(response?.message ?? 'Failed to fetch notifications');
      }
    } catch (e, stackTrace) {
      print("=== NOTIFICATION FETCH ERROR ===");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      showToast('Something went wrong while loading notifications');
    } finally {
      isLoading.value = false;
      print("=== NOTIFICATION FETCH COMPLETE ===");
    }
  }

  Future<void> loadMoreNotifications() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    
    try {
      isLoadingMore.value = true;
      currentPage.value++;
      
      final response = await Repository.getNotifications(page: currentPage.value);
      
      if (response != null && response.success && response.data != null) {
        notifications.addAll(response.data!.notifications);
        hasMoreData.value = currentPage.value < response.data!.pagination.totalPages;
        print("More notifications loaded: ${response.data!.notifications.length} items");
      }
    } catch (e) {
      print("Error loading more notifications: $e");
      currentPage.value--; // Revert page increment
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      print("=== FETCHING UNREAD COUNT ===");
      
      // Check if user has authentication token
      final token = HiveHelper.getToken;
      if (token == null || token.isEmpty) {
        print("No authentication token for unread count");
        return;
      }
      
      final response = await Repository.getUnreadNotificationCount();
      
      if (response != null && response.success && response.data != null) {
        unreadCount.value = response.data!.unreadCount;
        print("Unread notification count: ${unreadCount.value}");
        
        // Update home controller's unread count as well
        _updateHomeControllerUnreadCount(unreadCount.value);
      } else {
        print("Failed to fetch unread count: ${response?.message}");
      }
    } catch (e) {
      print("Error fetching unread count: $e");
    }
  }

  void _updateHomeControllerUnreadCount(int count) {
    try {
      // Try to find the home controller if it exists
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.unreadNotificationCount.value = count;
        print("Updated home controller unread count: $count");
      }
    } catch (e) {
      print("Error updating home controller unread count: $e");
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      print("Marking notification as read: $notificationId");
      final success = await Repository.markNotificationAsRead(notificationId: notificationId);
      
      if (success) {
        // Update local notification status
        final index = notifications.indexWhere((n) => n.notificationId == notificationId);
        if (index != -1 && !notifications[index].isRead) {
          // Create a new instance instead of modifying existing one
          final oldNotification = notifications[index];
          final newNotification = NotificationItem(
            id: oldNotification.id,
            notificationId: oldNotification.notificationId,
            title: oldNotification.title,
            message: oldNotification.message,
            recipientType: oldNotification.recipientType,
            isRead: true,
            readAt: DateTime.now().toIso8601String(),
            receivedAt: oldNotification.receivedAt,
            createdAt: oldNotification.createdAt,
            createdBy: oldNotification.createdBy,
          );
          
          notifications[index] = newNotification;
          notifications.refresh();
          
          // Update unread count
          if (unreadCount.value > 0) {
            unreadCount.value--;
            // Update home controller immediately
            _updateHomeControllerUnreadCount(unreadCount.value);
            print("Unread count updated to: ${unreadCount.value}");
          }
        }
      }
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  Future<void> markAllAsRead() async {
    try {
      Loader.showLoader();
      final success = await Repository.markAllNotificationsAsRead();
      
      if (success) {
        // Count how many were unread before marking all as read
        int unreadCountBefore = notifications.where((n) => !n.isRead).length;
        
        // Update all notifications to read status
        for (int i = 0; i < notifications.length; i++) {
          if (!notifications[i].isRead) {
            final oldNotification = notifications[i];
            notifications[i] = NotificationItem(
              id: oldNotification.id,
              notificationId: oldNotification.notificationId,
              title: oldNotification.title,
              message: oldNotification.message,
              recipientType: oldNotification.recipientType,
              isRead: true,
              readAt: DateTime.now().toIso8601String(),
              receivedAt: oldNotification.receivedAt,
              createdAt: oldNotification.createdAt,
              createdBy: oldNotification.createdBy,
            );
          }
        }
        notifications.refresh();
        unreadCount.value = 0;
        
        // Update home controller immediately
        _updateHomeControllerUnreadCount(0);
        
        showToast('All notifications marked as read');
        print("All notifications marked as read. Updated unread count to 0");
      } else {
        showToast('Failed to mark all as read');
      }
    } catch (e) {
      print("Error marking all as read: $e");
      showToast('Something went wrong');
    } finally {
      Loader.closeLoader();
    }
  }

  Future<void> showNotificationDetail(NotificationItem notification) async {
    try {
      // Mark as read when opening detail
      if (!notification.isRead) {
        await markAsRead(notification.notificationId);
      }
      
      // Show detail modal
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  notification.message,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Received: ${notification.getFormattedTime()}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      if (notification.createdBy != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.person, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'From: ${notification.createdBy}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print("Error showing notification detail: $e");
      showToast('Error opening notification');
    }
  }

  Future<void> refreshNotifications() async {
    await fetchNotifications(refresh: true);
    await fetchUnreadCount();
  }


} 