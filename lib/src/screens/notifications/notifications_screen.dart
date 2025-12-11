import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/notification_model.dart';
import 'package:arif_mart/src/screens/notifications/controller/notification_controller.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    print("=== NOTIFICATIONS SCREEN BUILD ===");
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text(
          "Notifications",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text(
                    'Mark All Read',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              : const SizedBox.shrink()),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          print("Building notifications body - loading: ${controller.isLoading.value}, count: ${controller.notifications.length}");
          
          if (controller.isLoading.value && controller.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryColor),
                  SizedBox(height: 16),
                  Text('Loading notifications...'),
                ],
              ),
            );
          }

          if (controller.notifications.isEmpty && !controller.isLoading.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You\'ll see your notifications here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryColor,
            onRefresh: controller.refreshNotifications,
            child: ListView.builder(
              controller: controller.scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: controller.notifications.length + 
                         (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.notifications.length) {
                  // Loading more indicator
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primaryColor),
                    ),
                  );
                }

                try {
                  final notification = controller.notifications[index];
                  return _buildNotificationCard(notification);
                } catch (e) {
                  print("Error building notification card at index $index: $e");
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading notification'),
                  );
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    try {
      return Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () {
            try {
              controller.showNotificationDetail(notification);
            } catch (e) {
              print("Error opening notification detail: $e");
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notification.isRead ? Colors.white : Colors.blue.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unread indicator
                    if (!notification.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(top: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    if (!notification.isRead) const SizedBox(width: 8),
                    
                    // Title and content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            notification.title.isNotEmpty ? notification.title : 'Notification',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead 
                                  ? FontWeight.w600 
                                  : FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 6),
                          
                          // Short message
                          Text(
                            notification.getTruncatedMessage(maxLength: 100),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Time and read more indicator
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                notification.getFormattedTime(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              
                              // Read more indicator if message is truncated
                              if (notification.message.length > 100) ...[
                                const Spacer(),
                                Text(
                                  'Tap to read more',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print("Error in _buildNotificationCard: $e");
      return Container(
        padding: const EdgeInsets.all(16),
        child: Text('Error displaying notification'),
      );
    }
  }
} 