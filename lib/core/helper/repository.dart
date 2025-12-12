import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/helper/export.dart';

import '../constants/api.dart';
import '../model/referral_model.dart';
import '../model/income_model.dart';
import '../model/mobile_banking_model.dart';
import '../model/withdrawal_model.dart';
import 'dio_helper.dart';

class Repository {
  static Future<Map<String, dynamic>?> register({required String refferalCode, required String username, required String phone, required String password}) async {
    Map<String, dynamic>? data = await DioApiHelper(
      isTokeNeeded: false,
    ).post(url: Apis.register, body: {"phoneNo": phone, "name": username, "password": password, "referralCode": refferalCode, "fcmToken":HiveHelper.getFcmToken});
    return data;
  }

  static Future<Map<String, dynamic>?> login({required String phone, required String password}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: false).post(url: Apis.login, body: {"phoneNo": phone, "password": password, "fcmToken":HiveHelper.getFcmToken});
    return data;
  }

  static Future<MyProfileModel?> getMyProfile() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.myProfile);
    if (data != null) {
      MyProfileModel myProfileModel = MyProfileModel.fromJson(data);
      VarConstants.myProfileModel.value = myProfileModel;
      return myProfileModel;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getWallet() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.wallet);
    return data;
  }

  static Future<Map<String, dynamic>?> paymentInitiate({required String type, int? amount}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(
      url: Apis.initiatePayment,
      body: {
        "type": type, //topup,subscription
        if (amount != null) "amount": amount, // this for topup only
      },
    );
    return data;
  }

  static Future<Map<String, dynamic>?> paymentVerify({required String invoiceId}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(url: Apis.verifyPayment, body: {"invoice_id": invoiceId});
    return data;
  }

  static Future<Map<String, dynamic>?> addMoney({required int amount}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(url: Apis.walletAdd, body: {"amount": amount});
    return data;
  }

  static Future<Map<String, dynamic>?> getOperators() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.operators);
    return data;
  }

  static Future<Map<String, dynamic>?> getOffers({required String operator, required String type}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: "${Apis.offers}?operator=$operator&offerType=$type");
    return data;
  }

  static Future<Map<String, dynamic>?> purchaseOffer({required String offerId, required String phoneNo, required String stateDivision}) async {
    Map<String, dynamic>? data = await DioApiHelper(
      isTokeNeeded: true,
    ).post(url: Apis.purchaseOffer, body: {"offerId": offerId, "phoneNo": phoneNo, "stateDivision": stateDivision});
    return data;
  }

  static Future<OfferOrderModel> getOrder({required String type}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: "${Apis.order}?status=$type");
    if(data!=null){
      OfferOrderModel getFirstStepModel = OfferOrderModel.fromJson(data);
      return getFirstStepModel;
    }else{
      return OfferOrderModel(success: false, message: '', data: []);
    }
  }

  static Future<Map<String, dynamic>?> getSubscriptionAmount() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.subscriptionAmount);
    return data;
  }

  static Future<Map<String, dynamic>?> editProfile({required String name,required String phoneNo}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).patch(
        url: Apis.editProfile,
        body: {
          "name": name,
          "phoneNo": phoneNo,
          "fcmToken":HiveHelper.getFcmToken
        }
    );
    return data;
  }

  static Future<Map<String, dynamic>?> logout() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(
      url: Apis.logout,
      body: {
        "fcmToken":HiveHelper.getFcmToken
      }
    );
    return data;
  }

  static Future<ReferralModel?> getReferrals() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.referrals);
    if (data != null) {
      ReferralModel referralModel = ReferralModel.fromJson(data);
      return referralModel;
    }
    return null;
  }

  static Future<SocialMediaModel?> getSocialMedia() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: false).get(url: Apis.socialMedia);
    if (data != null) {
      SocialMediaModel socialMediaModel = SocialMediaModel.fromJson(data);
      return socialMediaModel;
    }
    return null;
  }

  static Future<SliderModel?> getSliders({String type = 'home'}) async {
    String url = "${Apis.sliders}?type=$type";
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: false).get(url: url);
    if (data != null) {
      SliderModel sliderModel = SliderModel.fromJson(data);
      return sliderModel;
    }
    return null;
  }

  static Future<NotificationListModel?> getNotifications({int page = 1}) async {
    String url = "${Apis.notifications}?page=$page";
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: url);
    if (data != null) {
      NotificationListModel notificationModel = NotificationListModel.fromJson(data);
      return notificationModel;
    }
    return null;
  }

  static Future<UnreadCountModel?> getUnreadNotificationCount() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.notificationsUnreadCount);
    if (data != null) {
      UnreadCountModel unreadCountModel = UnreadCountModel.fromJson(data);
      return unreadCountModel;
    }
    return null;
  }

  static Future<SingleNotificationModel?> getNotificationById({required String notificationId}) async {
    String url = "${Apis.notifications}/$notificationId";
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: url);
    if (data != null) {
      SingleNotificationModel notificationModel = SingleNotificationModel.fromJson(data);
      return notificationModel;
    }
    return null;
  }

  static Future<bool> markNotificationAsRead({required String notificationId}) async {
    String url = "${Apis.notifications}/$notificationId/read";
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(url: url, body: {});
    return data != null && (data['success'] ?? false);
  }

  static Future<bool> markAllNotificationsAsRead() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(url: Apis.notificationsReadAll, body: {});
    return data != null && (data['success'] ?? false);
  }

  static Future<IncomeModel?> getIncome() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.income);
    if (data != null) {
      IncomeModel incomeModel = IncomeModel.fromJson(data);
      return incomeModel;
    }
    return null;
  }

  static Future<MobileBankingModel?> getMobileBanking() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.mobileBanking);
    if (data != null) {
      MobileBankingModel mobileBankingModel = MobileBankingModel.fromJson(data);
      return mobileBankingModel;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> createWithdrawal({required Map<String, dynamic> withdrawalData}) async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).post(
      url: Apis.manualWithdrawals,
      body: withdrawalData,
    );
    return data;
  }

  static Future<WithdrawalModel?> getWithdrawals() async {
    Map<String, dynamic>? data = await DioApiHelper(isTokeNeeded: true).get(url: Apis.manualWithdrawals);
    if (data != null) {
      WithdrawalModel withdrawalModel = WithdrawalModel.fromJson(data);
      return withdrawalModel;
    }
    return null;
  }

}
