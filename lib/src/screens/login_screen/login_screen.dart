import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/validator_constants.dart';
import 'controller/login_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
              child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 50,),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(16)),
                      child: Image.asset('assets/logo.png',width: 120,height: 120),
                    ),
                    SizedBox(height: 24),
                    Center(child: Text('Welcome back!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: controller.phoneController,
                      keyboardType: TextInputType.phone,
                      validator: (value) => Validators.validateRequired(controller.phoneController.text, "Phone Number"),
                      decoration: InputDecoration(hintText: 'Phone', prefixIcon: const Icon(Icons.phone), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    const SizedBox(height: 16),

                    Obx(
                      () => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscurePassword.value,
                        validator: (value) => Validators.validateRequired(controller.passwordController.text, "Password"),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(controller.obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: controller.forgotPassword, 
                          child: Text('Forgot Password?', style: TextStyle(color: AppColors.primaryColor))
                        ),
                        Obx(() => controller.hasRecoveryToken
                          ? IconButton(
                              onPressed: controller.navigateToLiveChat,
                              icon: Icon(
                                Icons.chat,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                              tooltip: 'Contact Support - Recovery Failed',
                            )
                          : const SizedBox.shrink()
                        ),
                      ],
                    ),
                    
                    // Show recovery failed message if token exists
                    Obx(() => controller.hasRecoveryToken
                      ? Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Recovery attempts exceeded. Contact support for assistance.',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink()
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.login(_formKey),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Login', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                    const SizedBox(height: 12),

                    OutlinedButton(
                      onPressed: controller.navigateToRegister,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                        side: BorderSide(color: AppColors.primaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Create an Account', style: TextStyle(fontSize: 16)),
                    ),
                    const SizedBox(height: 18),

                    // Privacy policy inline text
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'By signing in you agree to our ',
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
