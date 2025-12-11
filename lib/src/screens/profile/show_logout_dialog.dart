import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/src/screens/profile/controller/profile_controller.dart';

void showLogoutDialog({required ProfileController controller}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
      content: const Text('Are you sure you want to logout?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(), // Dismiss dialog
          child: const Text('Cancel',style: TextStyle(color: AppColors.primaryColor),),
        ),
        ElevatedButton(
          onPressed: controller.onClickLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
          ),
          child: const Text('Logout',style: TextStyle(color: Colors.white),),
        ),
      ],
    ),
    barrierDismissible: false, // Prevent tap outside to dismiss
  );
}
