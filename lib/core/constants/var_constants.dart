import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:arif_mart/core/model/my_profile_model.dart';
import 'package:arif_mart/core/model/offer_order_model.dart';

class VarConstants {
  static double height = 0.0;
  static double width = 0.0;
  static String? appName;
  static String? packageName;
  static String? version;
  static String? buildNumber;
  static Rx<MyProfileModel> myProfileModel=MyProfileModel(success: false, message: '').obs;
  static OfferOrderModel? pendingOrderModel;
  static OfferOrderModel? historyOrderModel;
  static RxString recoveryToken = ''.obs;
  static RxString token = ''.obs;
}
