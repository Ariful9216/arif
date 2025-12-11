import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/chat_model.dart';
import 'package:arif_mart/core/services/chat_service.dart';
import 'package:arif_mart/core/constants/api.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';

class ChatController extends GetxController {
  final ChatService chatService = Get.find<ChatService>();
  
  // Observable variables
  final RxBool isLoading = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxString currentConversationId = ''.obs;
  final RxString adminId = ''.obs; // Will be fetched from backend
  final RxString adminName = ''.obs; // Will be fetched from backend
  
  // Text controllers
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  
  // Timer for typing indicator
  Timer? _typingTimer;
  
  // Store the token for HTTP API calls
  String? _currentToken;
  
  @override
  void onInit() {
    super.onInit();
    setupChatService();
    initializeChat();
  }
  
  void setupChatService() {
    // Set up callbacks
    chatService.onNewMessage = (message) {
      // Only handle NEW real-time messages (not history)
      // Check if this is a new message by comparing timestamp
      final now = DateTime.now();
      final messageTime = message.timestamp;
      final timeDifference = now.difference(messageTime).inSeconds;
      
      // Only add if message is very recent (within last 10 seconds)
      if (timeDifference <= 10) {
        final currentUserId = VarConstants.myProfileModel.value.data?.id;
        if (message.senderId != currentUserId) {
          // Check if message already exists to avoid duplicates
          final exists = chatService.messages.any((msg) => msg.id == message.id);
          if (!exists) {
            chatService.messages.add(message);
            print('Added new real-time message: ${message.message}');
            
            // Auto-scroll to bottom when new message arrives
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
          }
        }
      } else {
        print('Ignoring old message from history: ${message.message}');
      }
    };
    
    chatService.onTypingStatusChanged = (status) {
      // Handle typing status changes
      print('Typing status: $status');
    };
    
    chatService.onAdminStatusChanged = (isOnline) {
      // Handle admin online status changes
      print('Admin online status: $isOnline');
    };
    
    chatService.onConversationsReceived = (conversations) {
      // Handle conversations received
      print('Received ${conversations.length} conversations');
      
      // If we have conversations, get the first one's messages
      if (conversations.isNotEmpty) {
        final firstConversation = conversations.first;
        print('Loading messages for conversation: ${firstConversation.conversationId}');
        getConversationMessages(firstConversation.conversationId);
      } else {
        // If no conversations exist, create a new one or show empty state
        print('No conversations found, starting fresh chat');
        
        // Create a conversation ID for new chat
        final currentUserId = VarConstants.myProfileModel.value.data?.id ?? '';
        final newConversationId = '${currentUserId}_${adminId.value}';
        currentConversationId.value = newConversationId;
      }
    };
    
    chatService.onConversationMessagesReceived = (messages) {
      // Handle conversation messages received (HISTORY ONLY)
      print('Received ${messages.length} conversation messages from history');
      
      // Prevent multiple history loads
      if (chatService.isLoadingHistory) {
        print('Already loading history, skipping...');
        return;
      }
      
      chatService.isLoadingHistory = true;
      
      // Clear existing messages and add history
      chatService.messages.clear();
      chatService.messages.addAll(messages);
      
      // Log each message for debugging
      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        print('History message $i: ${message.senderType} - ${message.message}');
      }
      
      // Auto-scroll to bottom after loading history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
      // Reset flag after a delay
      Timer(const Duration(seconds: 2), () {
        chatService.isLoadingHistory = false;
      });
    };
    
    chatService.onError = (error) {
      Get.snackbar(
        'Chat Error',
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    };
  }
  
  Future<void> initializeChat() async {
    try {
      isLoading.value = true;
      
      // Check for liveToken from navigation arguments (recovery flow)
      final arguments = Get.arguments as Map<String, dynamic>?;
      final liveToken = arguments?['liveToken'] as String?;
      final recoveryToken = arguments?['recoveryToken'] as String?;
      
      String? tokenToUse;
      String? userIdToUse;
      
      if (liveToken != null) {
        // Use liveToken from recovery flow
        tokenToUse = liveToken;
        // Extract user ID from liveToken (it's a JWT token)
        try {
          // Parse JWT token to get user ID
          final parts = liveToken.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            // Decode base64
            final normalized = base64.normalize(payload);
            final resp = utf8.decode(base64.decode(normalized));
            final payloadMap = json.decode(resp);
            userIdToUse = payloadMap['id'] as String?;
          }
        } catch (e) {
          print('Error parsing liveToken: $e');
        }
      } else if (recoveryToken != null) {
        // Use recoveryToken
        tokenToUse = recoveryToken;
        // Try to extract user ID from recoveryToken
        try {
          final parts = recoveryToken.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64.normalize(payload);
            final resp = utf8.decode(base64.decode(normalized));
            final payloadMap = json.decode(resp);
            userIdToUse = payloadMap['id'] as String?;
          }
        } catch (e) {
          print('Error parsing recoveryToken: $e');
        }
      } else {
        // Fallback to regular login token
        tokenToUse = HiveHelper.getToken;
        final userData = VarConstants.myProfileModel.value.data;
        userIdToUse = userData?.id;
      }
      
      if (tokenToUse != null && userIdToUse != null) {
        // Store the token for HTTP API calls
        _currentToken = tokenToUse;
        
        // Fetch support admin ID from backend FIRST
        await fetchSupportAdmin();
        
        // Connect to chat service with available token
        await chatService.connect(tokenToUse, userIdToUse);
        
        // Wait a bit for connection to establish
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Get conversations
        await getConversations();
        
        // Check admin online status
        chatService.checkAdminOnlineStatus();
        
        // Get unread count
        await getUnreadCount();
      } else {
        // No valid token available - show helpful message
        Get.dialog(
          AlertDialog(
            title: const Text('Chat Support'),
            content: const Text(
              'To access chat support, you need to be logged in. Would you like to login now?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.back(); // Go back to previous screen
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back(); // Close dialog
                  Get.offAllNamed(Routes.login);
                },
                child: const Text('Login'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error initializing chat: $e');
      Get.snackbar(
        'Error',
        'Failed to initialize chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> getConversations() async {
    try {
      print('Requesting conversations from server');
      chatService.getConversations();
      
      // Set a timeout to retry if no conversations received
      Timer(const Duration(seconds: 5), () {
        if (chatService.conversations.isEmpty) {
          print('No conversations received, retrying...');
          chatService.getConversations();
        }
      });
    } catch (e) {
      print('Error getting conversations: $e');
    }
  }
  
  Future<void> fetchSupportAdmin() async {
    try {
      print('Fetching support admin from server...');
      final response = await _getDioHelper().get(
        url: Apis.chatSupportAdmin,
      );
      
      if (response != null && response['success'] == true) {
        final adminData = response['data'];
        adminId.value = adminData['adminId'] ?? '';
        adminName.value = adminData['name'] ?? 'Support Admin';
        print('✅ Support admin fetched: ${adminName.value} (ID: ${adminId.value})');
      } else {
        print('⚠️ Failed to fetch support admin, using fallback');
        // Fallback: set a default if not found
        adminId.value = '';
        adminName.value = 'Support Team';
      }
    } catch (e) {
      print('Error fetching support admin: $e');
      // Fallback on error
      adminName.value = 'Support Team';
    }
  }
  
  Future<void> getConversationMessages(String conversationId, {int page = 1, int limit = 50}) async {
    try {
      currentConversationId.value = conversationId;
      chatService.clearMessages();
      
      print('Requesting messages for conversation: $conversationId');
      
      // Get messages from socket (this will populate the messages list via onConversationMessagesReceived)
      chatService.getConversationMessages(conversationId, limit: limit, skip: (page - 1) * limit);
      
      // Mark conversation as seen
      await markConversationAsSeen(conversationId);
    } catch (e) {
      print('Error getting conversation messages: $e');
    }
  }
  
  Future<void> loadMessagesViaRestApi(String conversationId, {int page = 1, int limit = 50}) async {
    try {
      print('Loading messages via REST API fallback for conversation: $conversationId');
      
      final response = await _getDioHelper().get(
        url: '${Apis.chatConversations}/$conversationId/messages?page=$page&limit=$limit',
      );
      
      if (response != null && response['success'] == true) {
        final messagesData = response['data']['messages'] as List;
        final List<Message> messages = messagesData
            .map((msg) => Message.fromJson(msg))
            .toList();
        
        print('Loaded ${messages.length} messages via REST API fallback');
        
        // Clear and add messages (this is history loading)
        chatService.messages.clear();
        chatService.messages.addAll(messages);
        
        // Auto-scroll to bottom after loading history
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      print('Error loading messages via REST API: $e');
    }
  }
  
  Future<void> markConversationAsSeen(String conversationId) async {
    try {
      final response = await _getDioHelper().post(
        url: '${Apis.chatConversations}/$conversationId/seen',
        body: {},
      );
      
      if (response != null && response['success'] == true) {
        print('Conversation marked as seen');
      }
    } catch (e) {
      print('Error marking conversation as seen: $e');
    }
  }
  
  Future<void> getUnreadCount() async {
    try {
      final response = await _getDioHelper().get(
        url: Apis.chatUnreadCount,
      );
      
      if (response != null && response['success'] == true) {
        final unreadCountModel = ChatUnreadCountModel.fromJson(response);
        chatService.updateUnreadCount(unreadCountModel.data.unreadCount);
      }
    } catch (e) {
      print('Error getting unread count: $e');
    }
  }
  
  void sendMessage() {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    
    try {
      isSendingMessage.value = true;
      
      // Debug logging
      print('ChatController: Admin ID: ${adminId.value}');
      print('ChatController: Message: $message');
      
      // Create a temporary message for immediate display
      final currentUserId = VarConstants.myProfileModel.value.data?.id ?? '';
      final tempMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        senderId: currentUserId,
        receiverId: adminId.value,
        message: message,
        timestamp: DateTime.now(),
        status: 'sent',
        conversationId: currentConversationId.value,
        senderType: 'user',
        receiverType: 'admin',
      );
      
      // Add user's message to the list immediately
      chatService.messages.add(tempMessage);
      
      // Send message via socket
      chatService.sendMessage(adminId.value, message, 'admin');
      
      // Clear input
      messageController.clear();
      
      // Stop typing indicator
      stopTyping();
      
      // Auto-scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      print('Error sending message: $e');
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSendingMessage.value = false;
    }
  }
  
  void onMessageChanged(String value) {
    // Start typing indicator
    if (value.isNotEmpty) {
      startTyping();
    } else {
      stopTyping();
    }
  }
  
  void startTyping() {
    // Cancel existing timer
    _typingTimer?.cancel();
    
    // Debug logging
    print('ChatController: Starting typing with admin ID: ${adminId.value}');
    
    // Start typing indicator
    chatService.startTyping(adminId.value, 'admin');
    
    // Set timer to stop typing after 2 seconds of inactivity
    _typingTimer = Timer(const Duration(seconds: 2), () {
      stopTyping();
    });
  }
  
  void stopTyping() {
    _typingTimer?.cancel();
    print('ChatController: Stopping typing with admin ID: ${adminId.value}');
    chatService.stopTyping(adminId.value, 'admin');
  }
  
  String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  bool isMessageFromUser(Message message) {
    return message.senderType == 'user';
  }
  
  /// Create DioApiHelper with current token
  DioApiHelper _getDioHelper() {
    final dioHelper = DioApiHelper(isTokeNeeded: false);
    if (_currentToken != null) {
      dioHelper.header['Authorization'] = 'Bearer $_currentToken';
    }
    return dioHelper;
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    _typingTimer?.cancel();
    super.onClose();
  }
} 