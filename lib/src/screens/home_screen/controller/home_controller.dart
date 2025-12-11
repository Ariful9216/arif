import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/social_media_model.dart';
import 'package:arif_mart/core/model/slider_model.dart';
import 'package:arif_mart/core/model/notification_model.dart';
import 'package:arif_mart/src/packages/uddokta_pay/uddoktapay.dart';
import 'package:arif_mart/src/screens/add%20money/show_payment_successfully_dialog.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeController extends GetxController {
  RxDouble balance = 0.0.obs;
  TextEditingController amountController = TextEditingController();
  GlobalKey<FormState> addMoneyKey = GlobalKey<FormState>();
  
  // Social Media
  var socialMediaList = <SocialMediaItem>[].obs;
  var isSocialMediaLoading = false.obs;
  
  // Sliders
  var sliderList = <SliderItem>[].obs;
  var isSlidersLoading = false.obs;

  // Notifications
  var unreadNotificationCount = 0.obs;

  Future<void> getMyProfile() async {
    await Repository.getMyProfile();
  }

  Future<void> getWallet() async {
    final response = await Repository.getWallet();
    if(response!=null){
      Get.log("data in balance $response");
      balance.value=double.parse(response['data']['balance'].toString());
    }
  }

  Future<void> getSocialMedia() async {
    try {
      isSocialMediaLoading.value = true;
      final response = await Repository.getSocialMedia();
      
      if (response != null && response.success) {
        socialMediaList.value = response.data;
        print("Social media loaded: ${socialMediaList.length} items");
        // Debug: Print each social media item
        for (var item in socialMediaList) {
          print("Social Media: ${item.name} - Logo: ${item.logo} - Full URL: ${item.logoUrl}");
        }
      } else {
        print("Failed to load social media: ${response?.message}");
      }
    } catch (e) {
      print("Error loading social media: $e");
    } finally {
      isSocialMediaLoading.value = false;
    }
  }

  Future<void> getSliders() async {
    try {
      isSlidersLoading.value = true;
      
      // Fetch both home and all type sliders
      final homeResponse = await Repository.getSliders(type: 'home');
      final allResponse = await Repository.getSliders(type: 'all');
      
      List<SliderItem> combinedSliders = [];
      
      if (homeResponse != null && homeResponse.success) {
        combinedSliders.addAll(homeResponse.data.where((slider) => slider.isActive));
      }
      
      if (allResponse != null && allResponse.success) {
        combinedSliders.addAll(allResponse.data.where((slider) => slider.isActive));
      }
      
      sliderList.value = combinedSliders;
      print("Home sliders loaded: ${sliderList.length} items (home + all types)");
      // Debug: Print each slider item
      for (var slider in sliderList) {
        print("Slider: ${slider.title} - Image: ${slider.image} - Full URL: ${slider.imageUrl}");
      }
    } catch (e) {
      print("Error loading home sliders: $e");
    } finally {
      isSlidersLoading.value = false;
    }
  }

  Future<void> getUnreadNotificationCount() async {
    try {
      final response = await Repository.getUnreadNotificationCount();
      
      if (response != null && response.success && response.data != null) {
        unreadNotificationCount.value = response.data!.unreadCount;
        print("Unread notification count: ${unreadNotificationCount.value}");
      }
    } catch (e) {
      print("Error fetching unread notification count: $e");
    }
  }

  Future<void> openSocialMediaUrl(String url) async {
    try {
      print("Attempting to open URL: $url");
      
      // First try with url_launcher
      final uri = Uri.parse(url);
      bool canLaunch = await canLaunchUrl(uri);
      
      if (canLaunch) {
        bool launched = await launchUrl(
          uri, 
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          print("Successfully launched URL: $url");
          return;
        }
      }
      
      // Fallback: Copy URL to clipboard
      await Clipboard.setData(ClipboardData(text: url));
      showToast('Link copied to clipboard: ${_extractDomainName(url)}');
      print("URL copied to clipboard as fallback");
      
    } catch (e) {
      print("Error with URL launcher: $e");
      
      // Final fallback: Copy to clipboard
      try {
        await Clipboard.setData(ClipboardData(text: url));
        showToast('Link copied to clipboard: ${_extractDomainName(url)}');
      } catch (clipboardError) {
        print("Clipboard error: $clipboardError");
        showToast('Unable to open link');
      }
    }
  }

  Future<void> openSliderUrl(String url) async {
    if (url.isNotEmpty) {
      await openSocialMediaUrl(url); // Reuse the same URL opening logic
    }
  }

  String _extractDomainName(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return url;
    }
  }

  void addMoney({required BuildContext context, GlobalKey<FormState>? formKey}) async{
    // Use the provided formKey or fall back to controller's key
    final key = formKey ?? addMoneyKey;
    
    if(key.currentState?.validate() ?? false){
      try{
        Loader.showLoader();
        final response = await UddoktaPay.createPayment(context: context, type: 'topup',amount: int.parse(amountController.text));
        if(response != null && response.invoiceId!=null) {
          Get.log("response = $response");
          getWallet();
          getMyProfile();
          amountController.text="";
          Loader.closeLoader();
          showPaymentSuccessfullyDialog(context: context,description: "Your payment is pending. Please check after some time.",onClickClose: () {
            Get.back();
            Get.back();
          },);
        }else{
          showToast('Payment failed');
        }
      }catch(e){
        Loader.closeLoader();
        showToast("Something Went Wrong");
      }finally{
        Loader.closeLoader();
      }
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print("📱 HomeController initializing...");
    
    // Run all initialization calls with timeout protection
    // Don't wait for them to complete - let them run in the background
    Future.microtask(() async {
      print("🔄 Starting getMyProfile...");
      await getMyProfile().timeout(
        const Duration(seconds: 8),
        onTimeout: () => print("⏱️ getMyProfile timeout")
      ).catchError((e) => print("❌ getMyProfile error: $e"));
    });
    
    Future.microtask(() async {
      print("💰 Starting getWallet...");
      await getWallet().timeout(
        const Duration(seconds: 8),
        onTimeout: () => print("⏱️ getWallet timeout")
      ).catchError((e) => print("❌ getWallet error: $e"));
    });
    
    Future.microtask(() async {
      print("📱 Starting getSocialMedia...");
      await getSocialMedia().timeout(
        const Duration(seconds: 8),
        onTimeout: () => print("⏱️ getSocialMedia timeout")
      ).catchError((e) => print("❌ getSocialMedia error: $e"));
    });
    
    Future.microtask(() async {
      print("🎨 Starting getSliders...");
      await getSliders().timeout(
        const Duration(seconds: 8),
        onTimeout: () => print("⏱️ getSliders timeout")
      ).catchError((e) => print("❌ getSliders error: $e"));
    });
    
    Future.microtask(() async {
      print("🔔 Starting getUnreadNotificationCount...");
      await getUnreadNotificationCount().timeout(
        const Duration(seconds: 8),
        onTimeout: () => print("⏱️ getUnreadNotificationCount timeout")
      ).catchError((e) => print("❌ getUnreadNotificationCount error: $e"));
    });
  }

  @override
  void onClose() {
    amountController.dispose();
    super.onClose();
  }
}
