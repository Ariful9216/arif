// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/packages/uddokta_pay/controllers/payment_controller.dart';
import 'package:arif_mart/src/packages/uddokta_pay/core/services/api_services.dart';
import 'package:arif_mart/src/packages/uddokta_pay/models/request_response.dart';
import 'package:arif_mart/src/packages/uddokta_pay/utils/config.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentURL;

  const PaymentScreen({super.key, required this.paymentURL});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _webViewController;
  final PaymentController controller = Get.put(PaymentController());

  @override
  void initState() {
    super.initState();
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onHttpError: (error) {
                print("----------4564564>>>> ${error.response}");
              },
              onNavigationRequest: (NavigationRequest request) async {
                print("---------->>>> ${request.url}");
                if (request.url.contains(AppConfig.redirectURL)) {
                  controller.isPaymentVerifying.value = true;

                  Uri uri = Uri.parse(request.url);
                  String invoiceId = uri.queryParameters['invoice_id'] ?? '';

                  debugPrint('Invoice ID $invoiceId');

                  final response = await Repository.paymentVerify(invoiceId: invoiceId);

                  controller.isPaymentVerifying.value = false;

                  if (context.mounted) {
                    Navigator.pop(context, RequestResponse.fromJson(response?['data']));
                  }

                  return NavigationDecision.prevent;
                }

                if (request.url.startsWith(AppConfig.cancelURL)) {
                  controller.isPaymentVerifying.value = false;

                  if (context.mounted) {
                    Navigator.pop(context);
                  }

                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.paymentURL));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => Stack(
          children: [
            Column(children: [const SizedBox(height: 20), Expanded(child: WebViewWidget(controller: _webViewController))]),
            if (controller.isPaymentVerifying.value) ...[
              Container(decoration: BoxDecoration(color: Colors.white.withOpacity(.90)), child: const Center(child: CircularProgressIndicator())),
            ],
          ],
        ),
      ),
    );
  }
}
