import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/services/recovery_service.dart';
import 'package:arif_mart/core/model/recovery_model.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';

class RecoveryController extends GetxController {
  // Form controllers
  final phoneNumberController = TextEditingController();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();

  // State variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final recoveryToken = ''.obs;
  final liveToken = ''.obs;
  final isRecoveryFailed = false.obs;

  // Form validation
  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    _loadRecoveryToken();
  }

  @override
  void onClose() {
    phoneNumberController.dispose();
    nameController.dispose();
    balanceController.dispose();
    super.onClose();
  }

  /// Load recovery token from storage if exists
  void _loadRecoveryToken() {
    final token = VarConstants.recoveryToken.value;
    if (token.isNotEmpty) {
      recoveryToken.value = token;
      isRecoveryFailed.value = true;
      // Set a default message for recovery failed state
      errorMessage.value = 'Too many recovery attempts. Please contact support via live chat.';
    }
  }

  /// Save recovery token to storage
  void _saveRecoveryToken(String token) {
    VarConstants.recoveryToken.value = token;
    recoveryToken.value = token;
  }

  /// Save live token to storage
  void _saveLiveToken(String token) {
    VarConstants.recoveryToken.value = token; // Use same storage for live token
    liveToken.value = token;
  }

  /// Clear recovery token from storage
  void clearRecoveryToken() {
    VarConstants.recoveryToken.value = '';
    recoveryToken.value = '';
    isRecoveryFailed.value = false;
  }

  /// Send recovery request
  Future<void> sendRecoveryRequest() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final request = RecoveryRequest(
        phoneNumber: phoneNumberController.text.trim(),
        name: nameController.text.trim(),
        balance: double.tryParse(balanceController.text.trim()) ?? 0.0,
      );

      final response = await RecoveryService.sendRecoveryRequest(request);

      if (response.success && response.data != null) {
        if (response.data!.recoveryFailed == true) {
          // Too many attempts - save live token and redirect to existing chat
          if (response.data!.liveToken != null) {
            _saveLiveToken(response.data!.liveToken!);
          }
          isRecoveryFailed.value = true;
          // Auto-redirect to existing chat system
          Get.toNamed(Routes.chat, arguments: {'liveToken': response.data!.liveToken});
        } else if (response.data!.success && response.data!.token != null) {
          // Success - save token and navigate to reset password
          _saveRecoveryToken(response.data!.token!);
          Get.toNamed(Routes.resetPassword);
        } else {
          // Show API error message in UI
          errorMessage.value = response.message;
        }
      } else {
        // Show API error message in UI
        errorMessage.value = response.message;
      }
    } catch (e) {
      // Show network/connection error in UI
      errorMessage.value = 'Failed to send recovery request. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Reset password
  Future<void> resetPassword(String newPassword) async {
    if (recoveryToken.value.isEmpty) {
      errorMessage.value = 'No recovery token found';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await RecoveryService.resetPassword(
        token: recoveryToken.value,
        newPassword: newPassword,
      );

      if (response.success && response.data?.success == true) {
        // Clear all tokens and redirect to login
        clearRecoveryToken();
        VarConstants.token.value = '';
        Get.offAllNamed(Routes.login);
      } else {
        // Show API error message in UI
        errorMessage.value = response.message;
      }
    } catch (e) {
      // Show network/connection error in UI
      errorMessage.value = 'Failed to reset password. Please check your connection.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate to live chat
  void navigateToLiveChat() {
    if (recoveryToken.value.isNotEmpty) {
      // Navigate to existing chat with recovery token
      Get.toNamed(Routes.chat, arguments: {'recoveryToken': recoveryToken.value});
    } else {
      // Navigate to existing chat without recovery token
      Get.toNamed(Routes.chat);
    }
  }

  /// Check if user has recovery token (for live chat icon)
  bool get hasRecoveryToken => recoveryToken.value.isNotEmpty;
}
