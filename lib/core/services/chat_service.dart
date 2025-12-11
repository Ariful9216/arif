import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:arif_mart/core/model/chat_model.dart';
import 'package:arif_mart/core/constants/api.dart';

class ChatService extends GetxService {
  IO.Socket? socket;
  String? currentUserId;
  String? jwtToken;
  bool _isConnecting = false;
  bool isLoadingHistory = false;
  
  // Observable variables
  final RxBool isConnected = false.obs;
  final RxBool isAdminOnline = false.obs;
  final RxBool isTyping = false.obs;
  final RxInt unreadCount = 0.obs;
  
  // Message streams
  final RxList<Message> messages = <Message>[].obs;
  final RxList<Conversation> conversations = <Conversation>[].obs;
  
  // Callbacks
  Function(Message)? onNewMessage;
  Function(String)? onTypingStatusChanged;
  Function(bool)? onAdminStatusChanged;
  Function(List<Conversation>)? onConversationsReceived;
  Function(List<Message>)? onConversationMessagesReceived;
  Function(String)? onError;
  
  // Connection methods
  Future<void> connect(String token, String userId) async {
    // Prevent multiple simultaneous connections
    if (_isConnecting) {
      print('ChatService: Already connecting, skipping...');
      return;
    }
    
    // Check if already connected with same credentials
    if (socket?.connected == true && 
        jwtToken == token && 
        currentUserId == userId) {
      print('ChatService: Already connected with same credentials, skipping...');
      return;
    }
    
    try {
      _isConnecting = true;
      
      // Disconnect existing connection if any
      if (socket != null) {
        await disconnect();
      }
      
      jwtToken = token;
      currentUserId = userId;
      
      // Use configurable chat socket host from API constants
      socket = IO.io(Apis.chatSocketHost, 
        IO.OptionBuilder()
          .setAuth({'token': token})
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(1000)
          .build()
      );
      
      setupEventListeners();
      
      socket!.connect();
      
      print('ChatService: Attempting to connect to chat server...');
    } catch (e) {
      print('ChatService: Connection error: $e');
      onError?.call('Failed to connect to chat server');
    } finally {
      _isConnecting = false;
    }
  }
  
  Future<void> disconnect() async {
    try {
      // Clear all event listeners before disconnecting
      if (socket != null) {
        socket!.clearListeners();
      }
      
      socket?.disconnect();
      socket?.dispose();
      socket = null;
      isConnected.value = false;
      print('ChatService: Disconnected from chat server');
    } catch (e) {
      print('ChatService: Disconnect error: $e');
    }
  }
  
  // Message methods
  void sendMessage(String receiverId, String message, String receiverType) {
    // Validate inputs
    if (receiverId.isEmpty) {
      onError?.call('Receiver ID is required');
      return;
    }
    
    if (message.isEmpty) {
      onError?.call('Message is required');
      return;
    }
    
    if (socket?.connected == true) {
      socket!.emit('send_message', {
        'receiverId': receiverId,
        'message': message,
        'receiverType': receiverType
      });
      print('ChatService: ✅ Message emitted to server');
      print('ChatService: - Receiver ID: $receiverId');
      print('ChatService: - Receiver Type: $receiverType');
      print('ChatService: - Message: $message');
    } else {
      print('ChatService: ❌ Socket not connected');
      onError?.call('Not connected to chat server');
    }
  }
  
  void markMessageAsSeen(String messageId) {
    if (socket?.connected == true) {
      socket!.emit('message_seen', {
        'messageId': messageId
      });
    }
  }
  
  void markConversationAsSeen(String conversationId) {
    if (socket?.connected == true) {
      socket!.emit('message_seen', {
        'conversationId': conversationId
      });
    }
  }
  
  // Typing indicators
  void startTyping(String receiverId, String receiverType) {
    if (receiverId.isEmpty) {
      return;
    }
    
    if (socket?.connected == true) {
      socket!.emit('typing_start', {
        'receiverId': receiverId,
        'receiverType': receiverType
      });
    }
  }
  
  void stopTyping(String receiverId, String receiverType) {
    if (receiverId.isEmpty) {
      return;
    }
    
    if (socket?.connected == true) {
      socket!.emit('typing_stop', {
        'receiverId': receiverId,
        'receiverType': receiverType
      });
    }
  }
  
  // Get conversations and messages
  void getConversations() {
    if (socket?.connected == true) {
      socket!.emit('get_conversations');
    }
  }
  
  void getConversationMessages(String conversationId, {int limit = 50, int skip = 0}) {
    if (socket?.connected == true) {
      socket!.emit('get_conversation_messages', {
        'conversationId': conversationId,
        'limit': limit,
        'skip': skip
      });
    }
  }
  
  void checkAdminOnlineStatus() {
    if (socket?.connected == true) {
      socket!.emit('check_admin_online');
    }
  }
  
  // Event listeners
  void setupEventListeners() {
    if (socket == null) return;
    
    // Connection events
    socket!.on('connect', (data) {
      print('ChatService: ✅ Connected to server');
      print('ChatService: - Socket ID: ${socket!.id}');
      isConnected.value = true;
      
      // Join chat after connection
      socket!.emit('join', {
        'userId': currentUserId,
        'userType': 'user'
      });
      print('ChatService: - Emitted join event as user: $currentUserId');
    });
    
    socket!.on('disconnect', (reason) {
      print('ChatService: Disconnected: $reason');
      isConnected.value = false;
    });
    
    socket!.on('connect_error', (error) {
      print('ChatService: Connection error: $error');
      isConnected.value = false;
      onError?.call('Connection failed: $error');
    });
    
    // User joined confirmation
    socket!.on('user_joined', (data) {
      print('ChatService: Joined as ${data['userType']}: ${data['userId']}');
    });
    
    // Message events
    socket!.on('new_message', (messageData) {
      print('ChatService: New message received: ${messageData['message']}');
      final message = Message.fromJson(messageData);
      messages.add(message);
      onNewMessage?.call(message);
    });
    
    socket!.on('message_sent', (message) {
      print('ChatService: ✅ Message sent confirmation received');
      print('ChatService: - Message ID: ${message['_id']}');
      print('ChatService: - Conversation ID: ${message['conversationId']}');
    });
    
    socket!.on('message_seen', (data) {
      print('ChatService: Message seen by ${data['seenBy']}');
      // Update message status in the list
      final messageId = data['messageId'];
      final index = messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final updatedMessage = Message(
          id: messages[index].id,
          senderId: messages[index].senderId,
          receiverId: messages[index].receiverId,
          message: messages[index].message,
          timestamp: messages[index].timestamp,
          status: 'seen',
          conversationId: messages[index].conversationId,
          senderType: messages[index].senderType,
          receiverType: messages[index].receiverType,
        );
        messages[index] = updatedMessage;
      }
    });
    
    // Typing indicators
    socket!.on('user_typing', (data) {
      final typingStatus = data['isTyping'] ?? false;
      isTyping.value = typingStatus;
      onTypingStatusChanged?.call(typingStatus ? 'typing' : 'stopped');
    });
    
    // Online status events
    socket!.on('user_online', (data) {
      print('ChatService: ${data['userId']} came online');
    });
    
    socket!.on('user_offline', (data) {
      print('ChatService: ${data['userId']} went offline');
    });
    
    socket!.on('admin_online_status', (data) {
      final isOnline = data['isOnline'] ?? false;
      isAdminOnline.value = isOnline;
      onAdminStatusChanged?.call(isOnline);
      print('ChatService: Admin online: $isOnline');
    });
    
    // Conversation events
    socket!.on('conversations', (conversationsData) {
      print('ChatService: Received ${conversationsData.length} conversations');
      final List<Conversation> convList = (conversationsData as List)
          .map((conv) => Conversation.fromJson(conv))
          .toList();
      conversations.value = convList;
      onConversationsReceived?.call(convList);
    });
    
    socket!.on('conversation_messages', (data) {
      print('ChatService: Received ${data['messages'].length} messages');
      final List<Message> msgList = (data['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList();
      
      // Clear existing messages and add new ones
      messages.clear();
      messages.addAll(msgList);
      
      // Notify controller
      onConversationMessagesReceived?.call(msgList);
    });
    
    // Error handling
    socket!.on('error', (error) {
      print('ChatService: ❌ Socket error: ${error['message']}');
      onError?.call(error['message'] ?? 'Unknown error occurred');
    });
  }
  
  // Clear messages for a specific conversation
  void clearMessages() {
    messages.clear();
  }
  
  // Update unread count
  void updateUnreadCount(int count) {
    unreadCount.value = count;
  }
  
  @override
  void onClose() {
    disconnect();
    super.onClose();
  }
} 