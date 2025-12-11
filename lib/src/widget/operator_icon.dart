import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

Widget operatorIcon(String asset, bool isSelected) {
  return Column(
    children: [
      Container(
        height: 50,
        width: 50,
        margin: EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: ClipOval(child: Image.network(asset, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))),
      ),
      if (isSelected) ...[Container(height: 2, width: 50, margin: EdgeInsets.symmetric(vertical: 4), color: AppColors.appBarColor1)],
    ],
  );
}