import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/model/chat_model.dart';
import 'chat_controller.dart';

class ChatScreen extends StatelessWidget {
  ChatScreen({super.key});

  final ChatController controller = Get.put(ChatController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.support_agent, color: AppColors.primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.adminName.value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )),
                  Obx(() => Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: controller.chatService.isAdminOnline.value 
                              ? Colors.green 
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        controller.chatService.isAdminOnline.value 
                            ? 'Online' 
                            : 'Offline',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => controller.chatService.isConnected.value
              ? const Icon(Icons.wifi, color: Colors.green, size: 20)
              : const Icon(Icons.wifi_off, color: Colors.red, size: 20)),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  ),
                );
              }
              
              if (controller.chatService.messages.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Start a conversation with support',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We\'re here to help you!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                controller: controller.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: controller.chatService.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.chatService.messages[index];
                  final isFromUser = controller.isMessageFromUser(message);
                  
                  return _MessageBubble(
                    message: message,
                    isFromUser: isFromUser,
                    formatTime: controller.formatTime,
                  );
                },
              );
            }),
          ),
          
          // Typing indicator
          Obx(() => controller.chatService.isTyping.value
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Admin is typing',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    onChanged: controller.onMessageChanged,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                Obx(() => GestureDetector(
                  onTap: controller.isSendingMessage.value ? null : controller.sendMessage,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: controller.isSendingMessage.value 
                          ? Colors.grey[300]
                          : AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: controller.isSendingMessage.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 20,
                          ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isFromUser;
  final String Function(DateTime) formatTime;

  const _MessageBubble({
    required this.message,
    required this.isFromUser,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isFromUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryColor,
              child: const Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isFromUser 
                    ? AppColors.primaryColor 
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: isFromUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isFromUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: TextStyle(
                      color: isFromUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        formatTime(message.timestamp),
                        style: TextStyle(
                          color: isFromUser 
                              ? Colors.white70 
                              : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                      if (isFromUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == 'seen' 
                              ? Icons.done_all 
                              : Icons.done,
                          color: message.status == 'seen' 
                              ? Colors.blue[200] 
                              : Colors.white70,
                          size: 14,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isFromUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: const Icon(
                Icons.person,
                color: Colors.grey,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 