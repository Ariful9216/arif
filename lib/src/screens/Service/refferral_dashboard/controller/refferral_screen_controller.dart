import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/referral_model.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

class ReferralController extends GetxController {
  var referralCode = "".obs;
  var totalReferrals = 0.obs;
  var reward = 0.0.obs;
  var recentReferrals = <RecentReferral>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    print("=== CONTROLLER ONINT CALLED ===");
    // Add delay like other controllers in the app
    Future.delayed(Duration(milliseconds: 100), () {
      print("=== DELAYED INIT STARTING ===");
      fetchReferralData();
    });
  }

  @override
  void onReady() {
    super.onReady();
    print("=== CONTROLLER ONREADY CALLED ===");
    // Fallback: if onInit didn't work, try again when widget is fully ready
    if (referralCode.value.isEmpty && !isLoading.value) {
      print("=== ONREADY FALLBACK TRIGGERED ===");
      fetchReferralData();
    }
  }

  Future<void> fetchReferralData() async {
    try {
      isLoading.value = true;
      Loader.showLoader();
      
      // Check if we have authentication token
      final token = HiveHelper.getToken;
      print("=== REFERRAL DEBUG START ===");
      print("Auth token available: ${token != null && token.isNotEmpty}");
      print("Token preview: ${token?.substring(0, 10)}...");
      
      print("Making API call to fetch referral data...");
      final response = await Repository.getReferrals();
      
      print("=== API RESPONSE ANALYSIS ===");
      print("Response is null: ${response == null}");
      if (response != null) {
        print("Response success: ${response.success}");
        print("Response message: ${response.message}");
        print("Response data is null: ${response.data == null}");
        
        if (response.data != null) {
          print("Raw referral code from API: '${response.data!.referralCode}'");
          print("Referral code length: ${response.data!.referralCode.length}");
          print("Referral code isEmpty: ${response.data!.referralCode.isEmpty}");
          print("Total referrals: ${response.data!.totalReferralCount}");
          print("Reward: ${response.data!.reward}");
          print("Recent referrals count: ${response.data!.recentReferrals.length}");
        }
      }
      
      if (response != null && response.success) {
        if (response.data != null) {
          // Update values step by step with logging
          final apiReferralCode = response.data!.referralCode;
          print("=== UPDATING CONTROLLER VALUES ===");
          print("Setting referralCode from '$apiReferralCode'");
          
          referralCode.value = apiReferralCode;
          totalReferrals.value = response.data!.totalReferralCount;
          reward.value = response.data!.reward;
          recentReferrals.value = response.data!.recentReferrals;
          
          print("Controller updated values:");
          print("- Referral Code: '${referralCode.value}'");
          print("- Referral Code length: ${referralCode.value.length}");
          print("- Referral Code isEmpty: ${referralCode.value.isEmpty}");
          print("- Total Referrals: ${totalReferrals.value}");
          print("- Reward: ${reward.value}");
          print("- Recent Referrals: ${recentReferrals.length}");
          
          // Force UI update
          update();
          
        } else {
          print("=== API RESPONSE ERROR ===");
          print("Response data is null even though success is true");
          showToast('No referral data available in response');
        }
      } else {
        print("=== API REQUEST FAILED ===");
        print("Success: ${response?.success}");
        print("Message: ${response?.message}");
        showToast(response?.message ?? 'Failed to fetch referral data');
      }
    } catch (e, stackTrace) {
      print("=== EXCEPTION OCCURRED ===");
      print("Error: $e");
      print("Stack trace: $stackTrace");
      Get.log("Error fetching referral data: $e");
      showToast('Something went wrong while fetching referral data');
    } finally {
      isLoading.value = false;
      Loader.closeLoader();
      print("=== REFERRAL DEBUG END ===");
    }
  }

  void shareReferralCode() {
    if (referralCode.value.isNotEmpty) {
      Get.log("Share referral code: ${referralCode.value}");
      // You can implement sharing functionality here
      // For example, using share_plus package
      showToast('Referral code: ${referralCode.value}');
    } else {
      showToast('No referral code to share');
    }
  }

  void refreshData() {
    print("=== MANUAL REFRESH TRIGGERED ===");
    fetchReferralData();
  }

  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateString;
    }
  }
}
