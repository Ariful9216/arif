class Apis {
  /// Environment configuration - Change these for development/testing
  /// 
  /// **Production**: Use https://api.arifmart.app
  /// **Development (Local Machine)**: Use http://localhost:3001
  /// **Development (Emulator - Android)**: Use http://10.0.2.2:3001
  /// **Development (Emulator - iOS)**: Use http://127.0.0.1:3001
  
  // ============ CONFIGURE HERE FOR YOUR ENVIRONMENT ============
  static const String apiHost = "https://api.arifmart.app";
  static const String ecommerceHost = "https://ecommerce.arifmart.app";
  static const String rechargeHost = "https://recharge.arifmart.app";
  static const String chatSocketHost = "https://api.arifmart.app"; // Remove /api/v1/ for socket
  
  // For development, uncomment and use one of these:
  // static const String apiHost = "http://10.0.2.2:3001"; // Android Emulator
  // static const String ecommerceHost = "http://10.0.2.2:5000"; // Android Emulator
  // static const String rechargeHost = "http://10.0.2.2:3002"; // Android Emulator
  // static const String chatSocketHost = "http://10.0.2.2:3001"; // Android Emulator
  
  // static const String apiHost = "http://127.0.0.1:3001"; // iOS Simulator
  // static const String ecommerceHost = "http://127.0.0.1:5000"; // iOS Simulator
  // static const String rechargeHost = "http://127.0.0.1:3002"; // iOS Simulator
  // static const String chatSocketHost = "http://127.0.0.1:3001"; // iOS Simulator
  
  // static const String apiHost = "http://localhost:3001"; // Local Machine
  // static const String ecommerceHost = "http://localhost:5000"; // Local Machine
  // static const String rechargeHost = "http://localhost:3002"; // Local Machine
  // static const String chatSocketHost = "http://localhost:3001"; // Local Machine
  // ============================================================
  
  static const baseUrl = "$apiHost/api/v1/";
  static const operatorBaseUrl = "$apiHost/api/uploads/operators/";
  static const socialMediaBaseUrl = "$apiHost/api/uploads/social-media/";
  static const sliderBaseUrl = "$apiHost/api/uploads/sliders/";
  static const mobileBankingBaseUrl = "$apiHost/api/uploads/mobile-banking/";
  static const rechargeBaseUrl = "$rechargeHost/api/";



  static const register = "users/register";
  static const login = "users/login";
  static const myProfile = "users/me";
  static const wallet = "wallet";
  static const initiatePayment = "payment/initiate";
  static const verifyPayment = "payment/verify";
  static const walletAdd = "wallet/add";
  static const operators = "operators";
  static const offers = "offers";
  static const purchaseOffer = "wallet/purchase-offer";
  static const order = "wallet/purchase-offer";
  static const subscriptionAmount = "admins/subscription-amount";
  static const editProfile = "users/update";
  static const logout = "users/logout";
  static const referrals = "users/referrals";
  static const socialMedia = "users/social-media";
  static const sliders = "users/sliders";
  static const notifications = "users/notifications";
  static const notificationsUnreadCount = "users/notifications/unread-count";
  static const notificationsReadAll = "users/notifications/read-all";
  static const income = "users/income";
  static const mobileBanking = "users/mobile-banking";
  static const manualWithdrawals = "users/manual-withdrawals";
  
  // Recharge API endpoints
  static const recharge = "users/recharge";
  static const rechargeOperators = "users/recharge/operators";
  
  // Chat API endpoints
  static const chatConversations = "chat/conversations";
  static const chatUnreadCount = "chat/unread-count";
  static const chatSupportAdmin = "chat/support-admin"; // Get primary support admin ID
  
  // Recovery API endpoints
  static const recovery = "recovery";
  static const recoveryResetPassword = "recovery/reset-password";
  
  
  // E-commerce API endpoints - Base URL for ecommerce service
  static const String ecommerceBaseUrl = "$ecommerceHost/api/v1/";  // Products
  static const products = "products";
  static const productById = "products/";
  static const productsByCategory = "products/category/"; // Get products by category
  static const mobileProductsAll = "products/mobile/all";
  static const mobileProductsNew = "products/mobile/new";
  static const mobileProductsTrending = "products/mobile/trending";
  static const mobileProductsTopSelling = "products/mobile/top-selling";
  static const mobileProductsExclusive = "products/mobile/exclusive";
  static const productsFlashSale = "products/flash-sale";
  static const productsTopRated = "products/top-rated";
  static const productsBrands = "products/brands";
  static const productsTags = "products/tags";
  
  // Categories
  static const categories = "categories";
  
  // Banners
  static const banners = "banners";
  static const activeBanners = "banners/active";
  
  // Cart (Fallback to old API until new system is implemented)
  static const cart = "carts";
  static const cartItems = "carts/items";
  static const cartCount = "carts/count";
  static const cartTotal = "carts/total";
  static const cartValidate = "carts/validate";
  static const cartClear = "carts/clear";
  static const cartStats = "carts/stats";
  static const cartCheckProduct = "carts/check-product";
  static const cartBulkUpdate = "carts/bulk-update";
  static const cartExtendExpiration = "carts/extend-expiration";
  
  // Wishlist - Updated to match new API structure
  static const wishlist = "wishlists";
  static const wishlistToggle = "wishlists/toggle";
  static const wishlistCheck = "wishlists/check";
  static const wishlistCount = "wishlists/count";
  static const wishlistClear = "wishlists/clear";
  static const wishlistStats = "wishlists/stats";
  static const wishlistAdminAll = "wishlists/admin/all";
  
  // Orders
  static const orders = "orders";
  static const userOrders = "orders/my-orders";
  static const orderStats = "orders/stats/my-orders";
  
  // Addresses
  static const addresses = "addresses";
  static const defaultAddress = "addresses/default";
  static const addressesForOrder = "addresses/for-order";
  
  // Variants
  static const variants = "variants";
  static const variantById = "variants/single";
  
  // Affiliate API endpoints
  static const affiliateGenerateLink = "affiliates/links/generate";
  static const affiliateRedirect = "affiliates/links/redirect";
  static const affiliateMySales = "affiliates/sales/my";
  static const affiliateStatistics = "affiliates/statistics";
}
