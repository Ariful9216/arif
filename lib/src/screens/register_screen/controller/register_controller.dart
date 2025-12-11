import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';

import '../../../../core/constants/routes/routes.dart';
import '../../../packages/uddokta_pay/uddoktapay.dart';
import '../../../widget/custom_toast.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final referralController = TextEditingController();
  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final maleAndFemaleBottomPadding=0.obs;

  // Form key moved to the widget to avoid GlobalKey duplication across routes

  Future<void> onTapRegister(GlobalKey<FormState> formKey) async {
    try {
      if(nameController.text==""){
        maleAndFemaleBottomPadding.value=18;
      }else{
        maleAndFemaleBottomPadding.value=0;
      }
  if (formKey.currentState != null && formKey.currentState!.validate()) {
        Loader.showLoader();
        final response = await Repository.register(
            refferalCode: referralController.text,
            username: nameController.text,
            phone: phoneController.text,
            password: passwordController.text
        );
        if(response!=null){
          if (response['success'] == true) {
            showToast(response['message'] ?? 'Registration failed');
            if (response['data'] != null) {
              await HiveHelper.setToken(response['data']['token']);
              // Allow all users to access the app freely
              HiveHelper.setIsLogin(true);
              nameController.text="";
              phoneController.text="";
              passwordController.text="";
              confirmPasswordController.text="";
              referralController.text="";
              Get.offAllNamed(Routes.home);
              showToast("Registration successful");
            }
          } else {
            showToast(response['message'] ?? 'Registration failed');
          }
        }
        Loader.closeLoader();
      }
    } catch (e) {
      Loader.closeLoader();
      showToast("Registration failed: ${e.toString()}");
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    referralController.dispose();
    obscurePassword.value=true;
    obscureConfirmPassword.value=true;
    maleAndFemaleBottomPadding.value=0;
  }

}
