import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/src/screens/profile/controller/profile_controller.dart';
import 'package:arif_mart/src/widget/custom_toast.dart';

import 'show_logout_dialog.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.black,
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(Routes.editProfile);
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () {
              showLogoutDialog(controller: controller);
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar + Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(radius: 45, backgroundColor: AppColors.primaryColor, child: const Icon(Icons.person, size: 45, color: Colors.white)),
                  const SizedBox(height: 12),
                  Obx(() => Text(VarConstants.myProfileModel.value.data?.name ?? '',textAlign: TextAlign.center , style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Obx(() => profileCard("Phone", VarConstants.myProfileModel.value.data?.phoneNo ?? '', Icons.phone)),
            Obx(
              () => profileCard(
                "Referral Code",
                VarConstants.myProfileModel.value.data?.referralCode ?? '',
                Icons.code,
                trailingIcon: Icon(Icons.copy, color: AppColors.primaryColor),
                onClickTrailingIcon: () {
                  Clipboard.setData(
                    ClipboardData(text: VarConstants.myProfileModel.value.data?.referralCode ?? ''),
                  );
                  showToast('Copied ${VarConstants.myProfileModel.value.data?.referralCode ?? ''}');
                },
              ),
            ),
            Obx(() => profileCard("Wallet Balance", VarConstants.myProfileModel.value.data?.wallet.balance.toString() ?? '', Icons.account_balance_wallet)),
            Obx(() => profileCard("Subscription Date", VarConstants.myProfileModel.value.data?.subscriptionDate.split("T")[0] ?? '', Icons.calendar_month)),
            Obx(() => profileCard("Subscription Transaction ID", VarConstants.myProfileModel.value.data?.subscriptionTransactionId ?? '', Icons.receipt_long)),
            if (VarConstants.myProfileModel.value.data?.referredBy != null) ...[
              Obx(() => profileCard("Referred By", VarConstants.myProfileModel.value.data?.referredBy ?? '', Icons.group_add)),
            ],
          ],
        ),
      ),
    );
  }

  Widget profileCard(String title, String value, IconData icon, {Color? color, Icon? trailingIcon, VoidCallback? onClickTrailingIcon}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color ?? AppColors.primaryColor, child: Icon(icon, color: color ?? Colors.white)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
        trailing: trailingIcon!=null?InkWell(onTap: onClickTrailingIcon, child: trailingIcon):null,
      ),
    );
  }
}
