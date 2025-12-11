import 'package:get/get.dart';
import 'package:arif_mart/src/screens/Service/history/history_screen.dart';
import 'package:arif_mart/src/screens/Service/income_screen/income_screen.dart';
import 'package:arif_mart/src/screens/Service/refferral_dashboard/refferral_screen.dart';
import 'package:arif_mart/src/screens/Service/affiliate_dashboard/affiliate_dashboard_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/shopping_dashboard_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/shopping_screen.dart';
import 'package:arif_mart/src/screens/Service/withdraw_money/withdraw_screen.dart';
import 'package:arif_mart/src/screens/add%20money/add_money_screen.dart';
import 'package:arif_mart/src/screens/home_screen/home_screen.dart';
import 'package:arif_mart/src/screens/login_screen/login_screen.dart';
import 'package:arif_mart/src/screens/offers/combo_offer/combo_offer_screen.dart';
import 'package:arif_mart/src/screens/offers/internet_offer/internet_offer_screen.dart';
import 'package:arif_mart/src/screens/offers/Minute_offer/minute_offer_screen.dart';
import 'package:arif_mart/src/screens/offers/order_screen/order_screen.dart';
import 'package:arif_mart/src/screens/offers/recharge_screen/recharge_screen.dart';
import 'package:arif_mart/src/screens/payment/pay_now_screen.dart';
import 'package:arif_mart/src/screens/profile/edit_profile_screen.dart';
import 'package:arif_mart/src/screens/profile/profile_screen.dart';
import 'package:arif_mart/src/screens/register_screen/register_screen.dart';
import 'package:arif_mart/src/screens/notifications/notifications_screen.dart';
import 'package:arif_mart/src/screens/blog/blog_screen.dart';
import 'package:arif_mart/src/screens/chat/chat_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/product_category/product_category_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/product_detail/product_detail_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/wishlist/favourites_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/cart/cart_screen.dart';
import 'package:arif_mart/src/screens/Service/shoping/category_products/category_products_screen.dart';
import 'package:arif_mart/src/screens/auth/recovery/forgot_password_screen.dart';
import 'package:arif_mart/src/screens/auth/recovery/reset_password_screen.dart';
import 'package:arif_mart/src/screens/auth/recovery/live_chat_screen.dart';
import 'routes.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(name: Routes.register, page: () => RegisterScreen()),
    GetPage(name: Routes.home, page: () => HomeScreen()),
    GetPage(name: Routes.profileScreen, page: () => ProfileScreen()),
    GetPage(name: Routes.editProfile, page: () => EditProfileScreen()),
    GetPage(name: Routes.addMoneyScreen, page: () => AddMoneyScreen()),
    GetPage(name: Routes.payNowScreen, page: () => PayNowScreen()),
    GetPage(name: Routes.internet, page: () => InternetOfferScreen()),
    GetPage(name: Routes.combo, page: () => ComboOfferScreen()),
    GetPage(name: Routes.minuteOffer, page: () => MinuteOfferScreen()),
    GetPage(name: Routes.recharge, page: () => RechargeScreen()),
    GetPage(name: Routes.order, page: () => OrderScreen()),
    GetPage(name: Routes.shopping, page: () => ShoppingScreen()),
    GetPage(name: Routes.shoppingDashboard, page: () => ShoppingDashboardScreen()),
    GetPage(name: Routes.income, page: () => IncomeScreen()),
    GetPage(name: Routes.referral, page: () => ReferralScreen()),
    GetPage(name: Routes.affiliateDashboard, page: () => const AffiliateDashboardScreen()),
    GetPage(name: Routes.withdraw, page: () => WithdrawScreen()),
    GetPage(name: Routes.history, page: () => HistoryScreen()),
    GetPage(name: Routes.notifications, page: () => NotificationsScreen()),
    GetPage(name: Routes.blog, page: () => const BlogScreen()),
    GetPage(name: Routes.chat, page: () => ChatScreen()),
    
    // Product Category Pages
    GetPage(name: Routes.freshSellProducts, page: () => const FreshSellProductsScreen()),
    GetPage(name: Routes.newProducts, page: () => const NewProductsScreen()),
    GetPage(name: Routes.trendingProducts, page: () => const TrendingProductsScreen()),
    GetPage(name: Routes.topSellingProducts, page: () => const TopSellingProductsScreen()),
    GetPage(name: Routes.flashSaleProducts, page: () => const FlashSaleProductsScreen()),
    GetPage(name: Routes.topRatedProducts, page: () => const TopRatedProductsScreen()),
    GetPage(name: Routes.exclusiveProducts, page: () => const ExclusiveProductsScreen()),
    GetPage(name: Routes.categoryProducts, page: () => const CategoryProductsScreen()),
    
    // Product Detail
    GetPage(name: Routes.productDetail, page: () => const ProductDetailScreen()),
    
    // Favourites/Wishlist
    GetPage(name: Routes.favourites, page: () => const FavouritesScreen()),
    GetPage(name: Routes.cart, page: () => CartScreen()),
    
    // Recovery/Password Reset
    GetPage(name: Routes.forgotPassword, page: () => const ForgotPasswordScreen()),
    GetPage(name: Routes.resetPassword, page: () => const ResetPasswordScreen()),
    GetPage(name: Routes.liveChat, page: () => const LiveChatScreen()),
  ];
}
