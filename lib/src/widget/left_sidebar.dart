import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:arif_mart/core/constants/colors/app_colors.dart';
import 'package:arif_mart/core/constants/routes/routes.dart';
import 'package:arif_mart/core/constants/var_constants.dart';
import 'package:arif_mart/core/model/social_media_model.dart';
import 'package:arif_mart/src/screens/home_screen/controller/home_controller.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    
    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Profile Card
          _buildProfileCard(),
          
          // History Button
          _buildHistoryButton(),
          
          // Divider Line
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 10),
          // Social Media Section
          _buildSocialMediaSection(controller),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Profile Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // User Name
          Obx(() {
            final userProfile = VarConstants.myProfileModel?.value;
            final userName = userProfile?.data?.name ?? 'User';
            return Text(
              userName.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            );
          }),
          
          // Phone Number
          Obx(() {
            final userProfile = VarConstants.myProfileModel?.value;
            final phoneNumber = userProfile?.data?.phoneNo ?? '';
            return Text(
              phoneNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHistoryButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.back(); // Close drawer
            Get.toNamed(Routes.history);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.history,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(HomeController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        if (controller.isSocialMediaLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        }
        
        if (controller.socialMediaList.isEmpty) {
          return const Center(
            child: Text(
              'No social media links available',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          );
        }
        
        return Column(
          children: controller.socialMediaList.map((socialMedia) {
            return _buildSocialMediaItem(socialMedia, controller);
          }).toList(),
        );
      }),
    );
  }

  Widget _buildSocialMediaItem(SocialMediaItem socialMedia, HomeController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.back(); // Close drawer
            controller.openSocialMediaUrl(socialMedia.url);
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Social Media Icon/Logo
                SizedBox(
                  width: 20,
                  height: 20,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      socialMedia.logoUrl,
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.public,
                            color: Colors.white,
                            size: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Social Media Name
                Expanded(
                  child: Text(
                    socialMedia.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
