import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/widget/custom_loader.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';
import '../../../../core/constants/routes/routes.dart';

class ProfileController extends GetxController {
  onClickLogout() async {
    Loader.showLoader();
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    String? token = await _fcm.getToken();
    HiveHelper.setFcmToken(token);
    final response = await Repository.logout();
    Loader.closeLoader();
    if(response!=null){
      showToast(response['message']);
      if(response['success']==true){
        HiveHelper.clearHive();
        Get.offAllNamed(Routes.login);
      }
    }
  }
}