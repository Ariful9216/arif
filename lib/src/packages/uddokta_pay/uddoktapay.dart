// ignore_for_file: use_build_context_synchronously

library uddoktapay;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/dio_helper.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/packages/uddokta_pay/models/request_response.dart';
import 'package:arif_mart/src/packages/uddokta_pay/views/payment_screen.dart';
import 'package:arif_mart/src/packages/uddokta_pay/controllers/payment_controller.dart';

class UddoktaPay {
  static Future<RequestResponse?> createPayment({required BuildContext context, required String type, int? amount}) async {
   try{
     final controller = Get.put(PaymentController());

     final request = await Repository.paymentInitiate(type: type, amount: amount);
     if (request != null) {
       final paymentURL = request['data']['paymentUrl'];
       String paymentId = Uri.parse(paymentURL).pathSegments.last;
       controller.paymentID.value = paymentId;

       debugPrint(controller.paymentID.value);

       final body = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentScreen(paymentURL: paymentURL)));

       if (body != null) {
         final response = body as RequestResponse;
         return response;
       }

       return RequestResponse(status: ResponseStatus.canceled);
     } else {
       return RequestResponse(status: ResponseStatus.canceled);
     }
   }catch (e){
     rethrow;
   }
  }
}
