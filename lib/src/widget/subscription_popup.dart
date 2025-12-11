import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';

class SubscriptionPopup extends StatelessWidget {
  final String featureName;
  final String description;
  final IconData icon;

  const SubscriptionPopup({
    super.key,
    required this.featureName,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Premium Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryColor,
                    AppColors.primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Feature Name
            Text(
              featureName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Benefits List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _buildBenefitItem(
                    Icons.check_circle,
                    // 'Unlock all premium features',
                    'প্রিমিয়াম ফিচার আনলক – সব সুবিধা ব্যবহার করুন।',
                    Colors.green[600]!,
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    Icons.monetization_on,
                    // 'Earn commissions from affiliate links',
                    'অ্যাফিলিয়েট লিঙ্ক থেকে কমিশন অর্জন করুন',
                    Colors.green[600]!,
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    Icons.people,
                    // 'Access referral system',
                    'রেফারেল সুবিধা – বন্ধুদের আমন্ত্রণ করে টাকা উপার্জন করুন ।',
                    Colors.green[600]!,
                  ),
                  const SizedBox(height: 8),
                  _buildBenefitItem(
                    Icons.local_offer,
                    // 'Special offers and discounts',
                    'বিশেষ অফার এবং ছাড়',
                    Colors.green[600]!,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 1, // 1/3 of the width
                  child: TextButton(
                    onPressed: () {
                      Get.back(); // Close popup
                      Get.back(); // Go back to previous page
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      // 'Maybe Later',
                      'সম্ভবত পরে',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2, // 2/3 of the width
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.toNamed(Routes.payNowScreen);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      // 'Subscribe Now',
                      'সাবস্ক্রাইব করুন এখনই',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  // Static method to show the popup
  static void show({
    required String featureName,
    required String description,
    required IconData icon,
  }) {
    Get.dialog(
      SubscriptionPopup(
        featureName: featureName,
        description: description,
        icon: icon,
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }
}

