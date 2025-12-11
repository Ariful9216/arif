import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:arif_mart/core/helper/export.dart';
import 'package:arif_mart/src/screens/add%20money/show_payment_successfully_dialog.dart';
import 'package:arif_mart/src/screens/home_screen/show_add_money_dialog.dart';
import 'package:arif_mart/src/screens/profile/show_logout_dialog.dart';
import 'package:arif_mart/src/widget/image_slider.dart';
import 'package:arif_mart/src/widget/left_sidebar.dart';
import 'package:arif_mart/src/widget/shopping_banner_widget.dart';
import 'package:arif_mart/src/widget/offers_widget.dart';
import 'package:arif_mart/src/screens/Service/shoping/widgets/wishlist_heart_icon.dart';
import 'package:arif_mart/src/screens/Service/shoping/address/address_list_screen.dart';
import 'package:arif_mart/src/utils/subscription_checker.dart';

import '../../../core/constants/routes/routes.dart';
import 'controller/home_controller.dart';
import '../Service/shoping/controller/shopping_controller.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());
  final ShoppingController shoppingController = Get.put(ShoppingController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const LeftSidebar(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.6),
          currentIndex: 0, // Home is always selected
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                // Home - already on home, do nothing
                break;
              case 1:
                Get.toNamed(Routes.income);
                break;
              case 2:
                Get.toNamed(Routes.withdraw);
                break;
              case 3:
                Get.toNamed(Routes.profileScreen);
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              activeIcon: Icon(Icons.trending_up_rounded, size: 28),
              label: 'Income',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_rounded),
              activeIcon: Icon(Icons.account_balance_wallet_rounded, size: 28),
              label: 'Withdraw',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded, size: 28),
              label: 'Account',
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryColor,
                AppColors.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Image.asset(
          'assets/arifmart.png',
          height: 120,
          width: 360,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            borderRadius: BorderRadius.circular(8),
            child: const Icon(Icons.menu, color: Colors.white, size: 20),
          ),
        ),
        actions: [
          // Notification bell
          Container(
            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () async {
                try {
                  print("=== BELL ICON CLICKED ===");
                  print("Navigating to notifications screen...");
                  
                  // Navigate to notifications and wait for return
                  await Get.toNamed(Routes.notifications);
                  
                  // Immediately refresh unread count when returning
                  print("Returned from notifications, refreshing unread count...");
                  await controller.getUnreadNotificationCount();
                  
                } catch (e) {
                  print("Error navigating to notifications: $e");
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                    const Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
                  // Unread count badge
                  Obx(() => controller.unreadNotificationCount.value > 0
                      ? Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                              padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 12,
                                minHeight: 12,
                            ),
                            child: Text(
                              controller.unreadNotificationCount.value > 99 
                                  ? '99+' 
                                  : '${controller.unreadNotificationCount.value}',
                              style: const TextStyle(
                                color: Colors.white,
                                  fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
                ),
              ),
            ),
          ),
          // Support button
          Container(
            margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              onTap: () {
                Get.toNamed(Routes.chat);
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryColor,
        onRefresh: () async {
          controller.getWallet();
          controller.getSocialMedia();
          controller.getSliders();
          controller.getUnreadNotificationCount();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 12),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 8, bottom: 25),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Balance Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Access balance directly without Obx since we're not displaying it
                              final balance = controller.balance.value;
                              _showBalancePopup(balance);
                            },
                            icon: const Icon(Icons.account_balance_wallet, color: AppColors.primaryColor, size: 20),
                            label: const Text("Balance", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Add Money Button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Get.toNamed(Routes.addMoneyScreen),
                            icon: const Icon(Icons.add, color: AppColors.primaryColor, size: 20),
                            label: const Text("Add Money", style: TextStyle(color: AppColors.primaryColor, fontWeight: FontWeight.bold, fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ).paddingSymmetric(horizontal: 16),

                    const SizedBox(height: 12),

                    // Image Slider - Dynamic Banner
                    Obx(() => controller.isSlidersLoading.value
                      ? AspectRatio(
                          aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        )
                      : ImageSlider(
                          sliders: controller.sliderList,
                          onSliderTap: controller.openSliderUrl,
                        )
                    ).paddingSymmetric(horizontal: 16),
                  ]
                )
              ),

              const SizedBox(height: 20), // Increased from 12 to 20

              // Offers Section with white background and shadow
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                // We add padding but it should not effect to text
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        // border radius should just right side
                        borderRadius: BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)) 
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          "Offers",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                _simpleGridIcon(
                          "assets/icons/internet_offer.png",
                  "Internet\nOffer",
                  onTap: () {
                    SubscriptionChecker.checkInternetOffersFeature(() {
                      Get.toNamed(Routes.internet);
                    });
                  },
                ),
                _simpleGridIcon(
                          "assets/icons/combo_offer.png",
                  "Comb\nOffer",
                  onTap: () {
                    SubscriptionChecker.checkComboOffersFeature(() {
                      Get.toNamed(Routes.combo);
                    });
                  },
                ),
                _simpleGridIcon(
                  "assets/icons/minute_offer.png",
                  "Minute\nOffer",
                  onTap: () {
                    SubscriptionChecker.checkMinuteOffersFeature(() {
                      Get.toNamed(Routes.minuteOffer);
                    });
                  },
                ),
                _simpleGridIcon(
                  "assets/icons/recharge.png",
                  "Recharge",
                  onTap: () {
                    Get.toNamed(Routes.recharge);
                  },
                ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Increased from 12 to 20
              // Services Section - Redesigned for 2 items
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Services",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                     Row(
                       children: [
                         // Affiliate Dashboard Service
                         Expanded(
                           child: _buildServiceCardWithIcon(
                             Icons.dashboard_rounded,
                             "Affiliate Dashboard",
                             "Track Your Earnings",
                             () {
                               SubscriptionChecker.checkAffiliateFeature(() {
                                 Get.toNamed(Routes.affiliateDashboard);
                               });
                             },
                           ),
                         ),
                         const SizedBox(width: 12),
                         // Referral Service
                         Expanded(
                           child: _buildServiceCardWithIcon(
                             Icons.people_alt_rounded,
                             "Referral",
                             "Invite Friends & Earn",
                             () {
                               SubscriptionChecker.checkReferralFeature(() {
                                 Get.toNamed(Routes.referral);
                               });
                             },
                           ),
                         ),
                       ],
                     ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // Increased from 12 to 20
              
              // Shopping Section
              _buildShoppingSection(),
              
              // Add bottom padding for better scrolling experience
              const SizedBox(height: 24), // Increased from 20 to 24
            ],
          ),
        ),
      ),
    );
  }

  Widget section(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.only(topRight: Radius.circular(20), bottomRight: Radius.circular(20))),
            child: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          Center(child: Wrap(spacing: 12, runSpacing: 12, children: items)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _gridIcon(
    dynamic icon, // Can be IconData or String (for custom PNG path)
    String label, 
    {VoidCallback? onTap}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68, // Reduced from 72 to fit 4 items per row
        child: Column(
          children: [
            Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor, 
                borderRadius: BorderRadius.circular(8)
              ),
              child: _buildIconWidget(icon),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // Simple grid icon without background styles
  Widget _simpleGridIcon(
    String imagePath, // Only accepts image path
    String label, 
    {VoidCallback? onTap}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Image.asset(
              imagePath,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback to a default icon if image fails to load
                return const Icon(Icons.error, size: 40, color: Colors.grey);
              },
            ),
            const SizedBox(height: 6),
            Text(
              label, 
              style: const TextStyle(fontSize: 12), 
              textAlign: TextAlign.center
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWidget(dynamic icon) {
    if (icon is IconData) {
      // Use Material Icon
      return Icon(icon, color: Colors.white, size: 20);
    } else if (icon is String) {
      // Use Custom PNG Icon
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Image.asset(
          icon,
          color: Colors.white, // This will tint the PNG to white
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to a default icon if PNG fails to load
            return const Icon(Icons.error, color: Colors.white, size: 20);
          },
        ),
      );
    } else {
      // Fallback for invalid icon type
      return const Icon(Icons.help, color: Colors.white, size: 20);
    }
  }

  // Show balance popup
  void _showBalancePopup(double balance) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.account_balance_wallet, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Text("Your Balance"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "৳${balance.toStringAsFixed(0)}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Available balance in your wallet",
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close", style: TextStyle(color: AppColors.primaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(Routes.addMoneyScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Add Money", style: TextStyle(color: Colors.white)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // New service card for redesigned Services section
  Widget _buildServiceCard(
    String imagePath,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Image.asset(
                  imagePath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.error,
                      size: 24,
                      color: AppColors.primaryColor,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      );
    }

    Widget _buildServiceCardWithIcon(IconData icon, String title, String subtitle, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          // I need to if else condition
          decoration: BoxDecoration(
            color: title == "Referral" ? AppColors.primaryColor : AppColors.redColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: title == "Referral" ? AppColors.primaryColor.withOpacity(0.3) : AppColors.redColor.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    void _showComingSoonDialog(String featureName) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.construction,
                color: AppColors.primaryColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Coming Soon',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Text(
                '$featureName is currently under development.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'re working hard to bring you this feature soon. Stay tuned!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Got it',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  
    // Shopping Section
  Widget _buildShoppingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Shopping Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: const Text(
            "Shopping",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Shopping Banner
        _buildShoppingBanner(),
        const SizedBox(height: 18),
        
        // Search Bar
        _buildSearchBar(),
        const SizedBox(height: 16),
        
        // Categories
        _buildCategories(),
        const SizedBox(height: 16),
        
        // Menu Items
        _buildMenuItems(),
        const SizedBox(height: 24),
        
        // Product Sections
        _buildProductSections(),
      ],
    );
  }

  Widget _buildShoppingBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        if (shoppingController.isBannersLoading.value) {
          return AspectRatio(
            aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }
        
        if (shoppingController.banners.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return ShoppingBannerWidget(
          banners: shoppingController.banners,
          margin: EdgeInsets.zero,
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() => TextField(
        onChanged: shoppingController.updateSearchQuery,
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: shoppingController.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: shoppingController.clearSearch,
                )
              : null,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: AppColors.primaryColor),
          ),
        ),
      )),
    );
  }

  Widget _buildCategories() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        if (shoppingController.isCategoriesLoading.value) {
          return Container(
            height: 40,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (shoppingController.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: shoppingController.categories.length,
            itemBuilder: (context, index) {
              final category = shoppingController.categories[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category.name),
                  selected: false,
                  onSelected: (_) => shoppingController.selectCategory(category.id),
                  backgroundColor: Colors.grey[100],
                  selectedColor: AppColors.primaryColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMenuItems() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(
            icon: Icons.dashboard,
            label: "Dashboard",
            onTap: () => Get.toNamed(Routes.shoppingDashboard),
          ),
          _buildMenuItem(
            icon: Icons.favorite,
            label: "Favorites",
            onTap: shoppingController.navigateToFavorites,
          ),
          Obx(() => _buildMenuItem(
            icon: Icons.shopping_cart,
            label: "Cart",
            onTap: shoppingController.navigateToCart,
            badgeCount: shoppingController.cartItemCount.value > 0 
                ? shoppingController.cartItemCount.value 
                : null,
          )),
          _buildMenuItem(
            icon: Icons.location_on,
            label: "Address",
            onTap: () => Get.to(() => const AddressListScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    int? badgeCount,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildProductSections() {
    return Obx(() => shoppingController.hasSearchResults.value || shoppingController.isLoadingSearch.value
      ? _buildSearchResults()
      : _buildProductSectionsContent());
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Row(
            children: [
              const Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (shoppingController.searchResults.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  '(${shoppingController.searchResults.length})',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          )),
          
          const SizedBox(height: 12),
          
          Obx(() {
            if (shoppingController.isLoadingSearch.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            if (shoppingController.searchResults.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No products found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.62, // Adjusted for 1:1 (square) image aspect ratio
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: shoppingController.searchResults.length,
              itemBuilder: (context, index) {
                final product = shoppingController.searchResults[index];
                return _buildProductCard(product);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductSectionsContent() {
    return Column(
      children: [
        // Flash Sale Section
        _buildProductSection(
          "Flash Sale",
          shoppingController.flashSaleProducts,
          shoppingController.isLoadingFlashSale,
          onViewAll: () => Get.toNamed(Routes.flashSaleProducts),
        ),
        
        const SizedBox(height: 24),
        
        // New Products Section
        _buildProductSection(
          "New Products",
          shoppingController.newProducts,
          shoppingController.isLoadingNewProducts,
          onViewAll: () => Get.toNamed(Routes.newProducts),
        ),
        
        const SizedBox(height: 24),
        
        // Dynamic Offers Section
        _buildOffersSection(),
        
        const SizedBox(height: 24),
        
        // Trending Section
        _buildProductSection(
          "Trending",
          shoppingController.trendingProducts,
          shoppingController.isLoadingTrending,
          onViewAll: () => Get.toNamed(Routes.trendingProducts),
        ),
        
        const SizedBox(height: 24),
        
        // Top Selling Section
        _buildProductSection(
          "Top Selling",
          shoppingController.topSellingProducts,
          shoppingController.isLoadingTopSelling,
          onViewAll: () => Get.toNamed(Routes.topSellingProducts),
        ),
        
        const SizedBox(height: 24),
        
        // Top Rated Section
        _buildProductSection(
          "Top Rated",
          shoppingController.topRatedProducts,
          shoppingController.isLoadingTopRated,
          onViewAll: () => Get.toNamed(Routes.topRatedProducts),
        ),
        
        const SizedBox(height: 16),
        
        // Exclusive Section
        _buildProductSection(
          "Exclusive",
          shoppingController.exclusiveProducts,
          shoppingController.isLoadingExclusive,
          onViewAll: () => Get.toNamed(Routes.exclusiveProducts),
        ),
        
        const SizedBox(height: 24),
        
        // All Products Section
        _buildAllProductsSection(),
      ],
    );
  }

  Widget _buildProductSection(
    String title,
    RxList<ProductData> products,
    RxBool isLoading,
    {VoidCallback? onViewAll}
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    "View All",
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => isLoading.value
            ? _buildLoadingSection()
            : SizedBox(
                height: 280, // Further increased height to eliminate overflow
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product = products[index];
                    return Container(
                      width: 140,
                      // Remove fixed height to allow content to determine height
                      margin: const EdgeInsets.only(right: 8),
                      child: _buildProductCard(product),
                    );
                  },
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductData product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.productDetail,
          arguments: {'productId': product.id},
        );
      },
      child: Container(
        // Let the container size based on content
        constraints: const BoxConstraints(minHeight: 100),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum required space
          children: [
            // Product Image with Flash Sale Badge - Square 1:1 aspect ratio
            AspectRatio(
              aspectRatio: 1.0, // Square 1:1 (6:6) aspect ratio for product images
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: product.primaryThumbnailUrl.isNotEmpty
                        ? Image.network(
                            product.primaryThumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            cacheWidth: 400,
                            cacheHeight: 400, // Square cache dimensions for 1:1 ratio
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                  
                  // Flash Sale Badge
                  if (product.flashSale.isCurrentlyActive)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${_calculateDiscountPercentage(product)}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  // Heart Icon (User-friendly with background)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: WishlistHeartIcon(
                        productId: product.id,
                        iconSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Product Info - Optimized for space with minimal padding
            Padding(
              padding: const EdgeInsets.all(6), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Product Name - Reduced to 1 line to save space
                  Flexible(
                    child: Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Brand (if available)
                  if (product.brand.isNotEmpty) ...[
                    Text(
                      product.brand,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  // Description optional - only show if there's space
                  if (product.description.isNotEmpty && product.brand.isEmpty) ...[
                    const SizedBox(height: 4), // Minimal spacing
                    Text(
                      product.description,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[700],
                        height: 1.0, // Reduced line height
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  
                  const SizedBox(height: 4), // Minimal spacing
                  
                  // Price Section with Flash Sale Support
                  if (product.flashSale.isCurrentlyActive && 
                      product.flashSale.discountPrice != null) ...[
                    // Flash Sale Price
                    Row(
                      children: [
                        Text(
                          '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[600],
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.local_fire_department,
                          size: 11,
                          color: Colors.red[600],
                        ),
                      ],
                    ),
                    // Original Price (crossed out)
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        decoration: TextDecoration.lineThrough,
                        height: 1,
                      ),
                    ),
                  ] else ...[
                    // Regular Price
                    Text(
                      '৳${product.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 2), // Minimal spacing
                  
                  // Reviews (Rating) - Even more compact display
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          size: 10,
                          color: index < product.rating.filledStars 
                              ? Colors.amber 
                              : Colors.grey[300],
                        );
                      }),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          '(${product.rating.count})',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          color: Colors.grey[400],
          size: 40,
        ),
      ),
    );
  }

  // Calculate discount percentage from original price and flash sale price
  int _calculateDiscountPercentage(ProductData product) {
    if (product.flashSale.discountPrice == null || product.price <= 0) {
      return 0;
    }
    final originalPrice = product.price;
    final discountPrice = product.flashSale.discountPrice!;
    final discount = ((originalPrice - discountPrice) / originalPrice * 100).round();
    return discount > 0 ? discount : 0;
  }

  Widget _buildLoadingSection() {
    return SizedBox(
      height: 300, // Increased to match our new SizedBox height
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemBuilder: (_, index) {
          return Container(
            width: 140,
            height: 280, // Adjusted height for loading placeholder
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOffersSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(() {
        if (shoppingController.isOffersLoading.value) {
          return AspectRatio(
            aspectRatio: 16 / 9, // 16:9 aspect ratio (1280x720)
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          );
        }
        
        if (shoppingController.offers.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return OffersWidget(
          offers: shoppingController.offers,
          isLoading: false.obs,
        );
      }),
    );
  }

  Widget _buildAllProductsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      // The Container will expand to fit its content
      constraints: const BoxConstraints(minHeight: 500), // Increased from 400 to 600
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "All Products",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            if (shoppingController.isLoadingAllProducts.value) {
              return _buildAllProductsLoadingGrid();
            }
            
            if (shoppingController.allProducts.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text(
                    'No products available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
            
            return Container(
              constraints: const BoxConstraints(minHeight: 400), // Increased from 300 to 500
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58, // Adjusted for square (1:1) image aspect ratio
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 14, // Increased spacing between rows for better separation
                ),
              itemCount: shoppingController.allProducts.length + 
                         (shoppingController.hasMoreAllProducts.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == shoppingController.allProducts.length) {
                  return _buildLoadMoreIndicator();
                }
                
                final product = shoppingController.allProducts[index];
                return _buildAllProductsGridCard(product);
              },
            ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAllProductsLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.62, // Adjusted for square (1:1) image aspect ratio
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (shoppingController.isLoadingMoreAllProducts.value) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      return Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Center(
          child: TextButton.icon(
            onPressed: () => shoppingController.loadMoreAllProducts(),
            icon: const Icon(Icons.refresh),
            label: const Text('Load More'),
          ),
        ),
      );
    });
  }

  Widget _buildAllProductsGridCard(ProductData product) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routes.productDetail,
          arguments: {'productId': product.id},
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use minimum required space
          children: [
            // Product Image with Heart Icon - Square 1:1 aspect ratio
            AspectRatio(
              aspectRatio: 1.0, // Square 1:1 (6:6) aspect ratio
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: product.primaryThumbnailUrl.isNotEmpty
                        ? Image.network(
                            product.primaryThumbnailUrl,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildPlaceholderImage();
                            },
                          )
                        : _buildPlaceholderImage(),
                  ),
                // Heart Icon
                Positioned(
                  top: 4,
                  right: 4,
                  child: WishlistHeartIcon(
                    productId: product.id,
                    iconSize: 16,
                  ),
                ),
                // Flash Sale Badge
                if (product.flashSale.isCurrentlyActive)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.red, Colors.redAccent],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 8,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '-${product.flashSale.getDiscountPercentage(product.price).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            ),
            
            // Product Info - More compact
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(6), // Reduced padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    // Brand
                    if (product.brand.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.brand,
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Description (1 line max to save space)
                    if (product.description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        product.description,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[700],
                          height: 1.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const Spacer(),
                    
                    // Price Section
                    if (product.flashSale.isCurrentlyActive && 
                        product.flashSale.discountPrice != null) ...[
                      // Flash Sale Price
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '৳${product.flashSale.discountPrice!.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.local_fire_department,
                            size: 8,
                            color: Colors.red[600],
                          ),
                        ],
                      ),
                      // Original Price
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                          height: 1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      // Regular Price
                      Text(
                        '৳${product.price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    const SizedBox(height: 2),
                    
                    // Rating
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 8,
                            color: index < product.rating.filledStars 
                                ? Colors.amber 
                                : Colors.grey[300],
                          );
                        }),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '(${product.rating.count})',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
