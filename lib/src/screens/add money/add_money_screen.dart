import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/validator_constants.dart';
import 'package:arif_mart/src/screens/home_screen/controller/home_controller.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final controller = Get.put(HomeController());
  late final GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    // Create a new key for this instance
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        title: const Text(
          "Add Money",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(onPressed: () {
          controller.amountController.text="";
          Get.back();
        }, icon: Icon(CupertinoIcons.arrow_left)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Material(
                  elevation: 12,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [AppColors.appBarColor1, AppColors.appBarColor1.withAlpha(180)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const Text(
                            "Enter Amount",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            validator: (value) => Validators.validateRequired(controller.amountController.text, "Amount"),
                            controller: controller.amountController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                            decoration: InputDecoration(
                              errorStyle: TextStyle(color: Colors.white),
                              prefixIcon: Text(
                                "৳",
                                style: TextStyle(color: Colors.white70,fontSize: 18),
                              ).paddingOnly(top: 15,left: 15),
                              filled: true,
                              fillColor: Colors.white.withAlpha(40),
                              hintText: "0",
                              hintStyle: const TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          GestureDetector(
                            onTap: () => controller.addMoney(context: context, formKey: _formKey),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  "Add Money",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}