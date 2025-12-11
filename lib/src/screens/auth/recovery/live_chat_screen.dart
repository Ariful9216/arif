import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';

class LiveChatScreen extends StatelessWidget {
  const LiveChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get live token from arguments if available
    final arguments = Get.arguments as Map<String, dynamic>?;
    final liveToken = arguments?['liveToken'] as String?;
    final recoveryToken = arguments?['recoveryToken'] as String?;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Live Chat Support',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // Chat Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chat,
                  size: 50,
                  color: AppColors.primaryColor,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Title
              const Text(
                'Live Chat Support',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Description
              const Text(
                'Our support team is here to help you with any issues.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Live Chat Option
              _buildContactOption(
                icon: Icons.chat_bubble,
                title: 'Start Live Chat',
                subtitle: 'Chat with our support team',
                onTap: () {
                  // Navigate to existing chat screen
                  // Pass any recovery token information if available
                  if (liveToken != null || recoveryToken != null) {
                    Get.toNamed(Routes.chat, arguments: {
                      'liveToken': liveToken,
                      'recoveryToken': recoveryToken,
                    });
                  } else {
                    Get.toNamed(Routes.chat);
                  }
                },
              ),
              
              const SizedBox(height: 40),
              
              // Help Text
              const Text(
                'Our support team is available 24/7 to help you',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
