import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/validator_constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

import '../../../core/constants/colors/app_colors.dart';
import '../../../core/constants/routes/routes.dart';
import 'controller/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller = Get.put(RegisterController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Center(child: Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black))),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.nameController,
                            decoration: InputDecoration(
                              hintText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            validator: (value) => Validators.validateName(controller.nameController.text, "Name"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        prefixIcon: const Icon(Icons.phone),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (value) => Validators.validateMobile(controller.phoneController.text),
                    ),
                    const SizedBox(height: 16),

                    Obx(
                      () =>  TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              controller.obscurePassword.value = !controller.obscurePassword.value;
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) {
                          if(Validators.validatePassword(controller.passwordController.text)==null){
                            return Validators.validateConfirmPassword(controller.passwordController.text, controller.confirmPasswordController.text);
                          }else{
                            return Validators.validatePassword(controller.passwordController.text);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    Obx(
                          () =>  TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.obscureConfirmPassword.value,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(controller.obscureConfirmPassword.value ? Icons.visibility_off : Icons.visibility),
                            onPressed: () {
                              controller.obscureConfirmPassword.value = !controller.obscureConfirmPassword.value;
                            },
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        validator: (value) {
                          if(Validators.validatePassword(controller.confirmPasswordController.text)==null){
                            return Validators.validateConfirmPassword(controller.passwordController.text, controller.confirmPasswordController.text);
                          }else{
                            return Validators.validatePassword(controller.confirmPasswordController.text);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: controller.referralController,
                      decoration: InputDecoration(
                        hintText: 'Referral Code(Optional)',
                        prefixIcon: const Icon(Icons.card_giftcard),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () => controller.onTapRegister(_formKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Register', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),

                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Get.offAndToNamed(Routes.login);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: const TextStyle(color: Colors.black),
                            children: [TextSpan(text: "Login", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold))],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Privacy policy inline text
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'By signing up you agree to our ',
                          style: const TextStyle(color: Colors.black87),
                          children: [
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: AppColors.primaryColor, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final uri = Uri.parse('https://privacy.arifmart.app');
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    // ignore: avoid_print
                                    print('Could not launch $uri');
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
