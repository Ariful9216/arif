import 'package:flutter/material.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

Widget buildSearchField({
  TextEditingController? controller,
  Color borderColor = AppColors.primaryColor,
  Color cursorColor = AppColors.primaryColor,
  TextStyle? hintStyle,
  TextStyle? textStyle,
  Color iconColor = AppColors.primaryColor,
  void Function(String)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: TextFormField(
      controller: controller,
      cursorColor: cursorColor,
      onChanged: onChanged,
      style: textStyle,
      decoration: InputDecoration(
        hintText: 'Search...',
        hintStyle: hintStyle,
        prefixIcon: Icon(Icons.search, color: iconColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    ),
  );
}
