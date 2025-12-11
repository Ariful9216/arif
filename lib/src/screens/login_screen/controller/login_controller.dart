import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/routes/routes.dart';
import '../../../../core/constants/var_constants.dart';
import '../../../../core/helper/hive_helper.dart';
import '../../../../core/helper/repository.dart';
import '../../../widget/custom_loader.dart';
import '../../../widget/custom_toast.dart';
import '../../auth/recovery/controller/recovery_controller.dart';

class LoginController extends GetxController {
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  var obscurePassword = true.obs;

  // Form key moved to the widget to avoid GlobalKey duplication across routes

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login(GlobalKey<FormState> formKey) async {
    if (formKey.currentState != null && formKey.currentState!.validate()) {
      Loader.showLoader();
      final response = await Repository.login(
          phone: phoneController.text,
          password: passwordController.text
      );
      if(response!=null){
        if (response['success'] == true) {
          if (response['data'] != null) {
            await HiveHelper.setToken(response['data']['token']);
            // Allow all users to access the app freely
            HiveHelper.setIsLogin(true);
            // Clear recovery token on successful login
            VarConstants.recoveryToken.value = '';
            phoneController.text="";
            passwordController.text="";
            Get.offAllNamed(Routes.home);
            showToast("Login successful");
          }
        }else{
          showToast(response['message'] ?? 'Login failed');
        }
      }
    }
  }

  void navigateToRegister() {
    Get.offAndToNamed(Routes.register);
  }

  void forgotPassword() {
    Get.toNamed(Routes.forgotPassword);
  }

  void navigateToLiveChat() {
    final recoveryController = Get.put(RecoveryController());
    recoveryController.navigateToLiveChat();
  }

  bool get hasRecoveryToken => VarConstants.recoveryToken.value.isNotEmpty;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    phoneController.dispose();
    passwordController.dispose();
    obscurePassword.value =true;
  }

}
