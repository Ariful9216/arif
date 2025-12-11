import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';

import 'custom_loader.dart';


TextStyle b16400 = GoogleFonts.poppins(
    color: AppColors.primaryColor,
    fontSize: 16,
    fontWeight: FontWeight.w400);

void showToast(String msg, [Color? color]) {
  Loader.closeLoader();
  Get.showSnackbar(GetSnackBar(
    animationDuration: const Duration(seconds: 1),
    borderRadius: 8,
    padding: const EdgeInsets.all(15),
    margin: const EdgeInsets.all(15),
    duration: const Duration(milliseconds: 2000),
    messageText:
        Text(msg, style: b16400.copyWith(color: Colors.white)),
    backgroundColor: color ?? AppColors.primaryColor,
  ));
}
