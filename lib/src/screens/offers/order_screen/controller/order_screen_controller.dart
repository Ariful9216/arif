import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/core/model/offers_model.dart';
import 'package:arif_mart/src/screens/home_screen/controller/home_controller.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

import '../../../../../core/constants/routes/routes.dart';
import '../../../../packages/uddokta_pay/uddoktapay.dart';
import '../../../../widget/custom_loader.dart';

class OrderController extends GetxController {
  final phoneNumber = TextEditingController();
  final amount = TextEditingController();
  final operator = TextEditingController();
  late OfferData offerData;
  GlobalKey<FormState> orderKey = GlobalKey<FormState>();
  List<String> stateList = [
    'Dhaka',
    'Chattogram',
    'Rajshahi',
    'Khulna',
    'Barishal',
    'Sylhet',
    'Rangpur',
    'Mymensingh',
  ];
  String? selectedState;

  Future<void> confirmOrder({required BuildContext context}) async {
    if(orderKey.currentState!.validate()){
      try{
        Loader.showLoader();
        final response = await Repository.purchaseOffer(
            offerId: offerData.id,
            phoneNo: phoneNumber.text,
            stateDivision: selectedState!
        );
        if(response!=null){
          if(response['success']==true){
            final controller = Get.find<HomeController>();
            controller.getWallet();
            controller.getMyProfile();
            VarConstants.pendingOrderModel=null;
            Get.back(result: true);
            showToast(response['message']);
          }
        }

      }catch(e){
        Get.log("$e");
      }finally{
        Loader.closeLoader();
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    offerData=Get.arguments;
    amount.text=offerData.actualPrice.toString();
    operator.text=offerData.operator.name;
  }

  @override
  void onClose() {
    phoneNumber.dispose();
    amount.dispose();
    operator.dispose();
    selectedState=null;
    super.onClose();
  }
}
