import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

void showPaymentSuccessfullyDialog({
  required BuildContext context,
  required String description,
  required VoidCallback onClickClose,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Column(
        children: [
          Icon(
            Icons.hourglass_empty,
            color: Colors.orange,
            size: 50,
          ),
          const SizedBox(width: 8),
          Text("Payment Successfully",style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),),
        ],
      ),
      content: Text(
          description
      ),
      actions: [
        TextButton(
          onPressed:onClickClose,
          child: const Text("Close",style: TextStyle(color: AppColors.primaryColor),),
        ),
      ],
    ),
  );
}
