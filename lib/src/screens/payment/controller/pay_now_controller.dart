import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/my_profile_model.dart';
import 'package:arif_mart/src/screens/add%20money/show_payment_successfully_dialog.dart';
import 'package:arif_mart/src/screens/home_screen/show_add_money_dialog.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

import '../../../packages/uddokta_pay/uddoktapay.dart';
import '../../../widget/custom_loader.dart';

class PayNowController extends GetxController {

  String tempToken="";
  RxInt subscriptionAmount=0.obs;

  getSubscriptionAmount() async {
    try {
      Loader.showLoader();
      final data = await Repository.getSubscriptionAmount();
      Loader.closeLoader();
      if(data != null && data['success'] == true){
        subscriptionAmount.value = data['data']['subscriptionAmount'];
        showToast("Subscription amount updated successfully");
      } else {
        // If API fails, keep the default amount
        showToast("Using default subscription amount. Please contact support if this persists.");
      }
    } catch (e) {
      Loader.closeLoader();
      // If API fails, keep the default amount (already set in onInit)
      print("Subscription amount API failed: $e");
      showToast("Using default subscription amount.");
    }
  }


  onClickPayNow({required BuildContext context}) async {
    if(HiveHelper.getToken==null){
      HiveHelper.setToken(tempToken);
    }else{
      tempToken=HiveHelper.getToken??'';
    }
    Loader.showLoader();
    final data = await UddoktaPay.createPayment(context: context, type: 'subscription',amount: subscriptionAmount.value);
    Loader.showLoader();
    if(data != null && data.invoiceId!=null) {
      MyProfileModel? myProfileModel = await Repository.getMyProfile();
      Loader.closeLoader();
      if((myProfileModel?.data?.isVerified??false) && (myProfileModel?.data?.isActive??false)){
        Loader.closeLoader();
        HiveHelper.setIsLogin(true);
        Get.offAllNamed(Routes.home);
        showToast("Account verified successfully!");
      }else{
        Loader.closeLoader();
        showPaymentSuccessfullyDialog(
          context: context,
          description: "Payment successful! Your account verification is being processed. You can now access the app. Please login again to continue.",
          onClickClose: () {
            Get.back();
            Get.offNamed(Routes.login);
          },
        );
      }
    }else{
      Loader.closeLoader();
      showToast('Payment failed');
      HiveHelper.clearHive();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await Future.delayed(Duration(milliseconds: 500));

    // Set default amount first to prevent any issues (fallback)
    subscriptionAmount.value = 100; // Default subscription amount

    // Always try to fetch the subscription amount from API. Keep default as fallback.
    try {
      await getSubscriptionAmount();
    } catch (e) {
      print("Failed to fetch subscription amount: $e");
    }

    // Still attempt to fetch profile for messaging / verification state
    try {
      MyProfileModel? profile = await Repository.getMyProfile();
      if (profile?.data?.isVerified != true) {
        showToast("Please complete your subscription to verify your account");
      }
    } catch (e) {
      print("Profile fetch failed: $e");
    }
  }

}