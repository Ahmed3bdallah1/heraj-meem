abstract class ApiPath {
  /// Matches heraj_environment.json (`server_url`, `base_url`).
  static const serverUrl = 'https://api.baho.com.sa';
  static const baseurl = '$serverUrl/api/';
  static const uploadPath = '$serverUrl/';
  static const sharePath = '$serverUrl/';
  static const refresh = 'auth/v1/token?grant_type=refresh_token';
  static const userPreRegister = 'auth/register';
  static const vendorRegister = 'vendors/register';
  static const support = 'website/contacts';
  static const checkPhone = 'verify-phone';
  static const updateProfileImage = 'students/profile/picture/';
  static const updateProfile = 'auth/update-profile';
  static const uploadImage = 'uploads/images';

  static const getSliders = "sliders";
  static const getHomeSliders = "home-sliders";
  static const getProducts = "products";
  static String searchProductByName(String query) =>
      "products/search?q=$query&limit=10";
  static const getCategories = "categories";
  static const getCategoriesTree = "categories/tree";
  static const getAdminCategories = "admin-categories/tree";
  static String getCategoryDetails(String catId) => 'categories/$catId';
  static const getUser = 'auth/me';
  static const googleLogin = 'auth/google/mobile';
  static const selectRole = 'auth/select-role';
  static const sendOTP = 'auth/otp/request';
  static const verifyOTP = 'auth/otp/verify';
  static const refreshSession = 'auth/refresh';
  static const userRegister = 'auth/verify';
  static const logOut = 'auth/logout';
  static const deleteAccount = 'auth/delete-account';
  static const registerFCMToken = 'auth/fcm-token';
  static const removeFCMToken = 'auth/fcm-token';
  static const settings = 'settings';
  static const getOrders = 'orders';
  static const getPlans = 'customer-subscriptions/plans';
  static const getMySubscription = 'customer-subscriptions/my-subscription';
  static const getVendorPlans = 'vendors/plans';
  static const getCartItems = 'cart';
  static const applyCoupon = 'cart/apply-coupon';
  static const getFavorites = 'favorites';
  static String toggleFavorite(String adId) => 'favorites/$adId/toggle';
  static String removeFavorite(String adId) => 'favorites/$adId';
  static const getAddresses = 'auth/addresses';
  static const addAddress = 'auth/add-address';
  static const updateAddress = 'auth/update-address';
  static const deleteAddress = 'auth/delete-address';

  static const updateCartItem = 'cart/update';
  static const cartActions = 'cart/add';
  static String deleteFromCart(String id) => 'cart/remove/$id';

  static String getProductReviews(String productId) =>
      'reviews/product/$productId';

  static String addReview(String productId) => 'reviews/product/$productId';

  static String reviewHelpful(String reviewId) => 'reviews/$reviewId/helpful';

  static String getVendorProducts(String vendorId,
          {int page = 1, int limit = 20}) =>
      'products/vendor/$vendorId?page=$page&limit=$limit';
  static const createProduct = 'products';
  static String updateProduct(String productId) => 'products/$productId';

  static const changePassword = 'forget/password/change/password';
  static const forgetPassword = 'forget/password';
  static const notifications = 'notifications';
  static const notificationsUnreadCount = 'notifications/unread-count';
  static const notificationsReadAll = 'notifications/read-all';
  static const seen = 'seen/';
  static const upload = 'upload/file';
  static const validateOTPForgetPassword = 'api/login-otp';
  static const countries = 'getCountryWithCity';
  static const filter = 'filter';
  static const loyaltyPoints = 'loyalty-points';
  static const getVendors = 'vendors';
  static const getVendorProfile = 'vendors/me/profile';
  static const getMyProducts = 'products/my-products';
  static const getRegions = 'locations/regions';
  static const getCities = 'locations/cities';
  static String getCityDistricts(String cityId) =>
      'locations/cities/$cityId/districts';
  static String getDistricts(String cityCode) =>
      'locations/cities/$cityCode/districts';
  static const updateUserMe = 'users/me';
  static String getPublicProfile(String userId) => 'users/$userId';
  static const getAds = 'ads';
  static const createAd = 'ads';
  static const createMedia = 'media';
  static String promoteAdMedia(String adId) => 'media/ads/$adId/promote';
  static String deleteMedia(String mediaId) => 'media/$mediaId';
  static const getMyAds = 'ads/mine';
  static String getAd(String adId) => 'ads/$adId';
  static String getMyAd(String adId) => 'ads/mine/$adId';
  static const searchSuggestions = 'search/suggestions';
  static String getNeighborhoods(String cityCode, String districtName) =>
      'locations/neighborhoods/$cityCode/${Uri.encodeComponent(districtName)}';
  static const checkoutOrder = 'orders/checkout';
  static String cancelOrder(String orderId) => 'orders/$orderId/cancel';
  static const getStorePage = 'store-page';
  static String getStoreCategoryProducts(String catId) =>
      'store-page/category/$catId';
  static String getStoreCategoryDetails(String catId) =>
      'admin-categories/$catId';
  static const getHomeData = 'home';
  static String getProductBundles(String productId) =>
      'bundles/product/$productId';
  static const getCartSuggestions = 'bundles/cart-suggestions';
  static const getMyPayments = 'payments/my-payments';
  static String viewStory(String storyId) => 'stories/$storyId/view';
  static const createStory = 'stories';
  static const getChats = 'chat/conversations';
  static String getChatMessages(String chatId) =>
      'chat/conversations/$chatId/messages';
  static String sendMessage(String chatId) =>
      'chat/conversations/$chatId/messages';
  static String markChatAsRead(String chatId) => 'chat/$chatId/read';
  static const createChat = 'chat/conversations';
  static String reverseGeocode(double lat, double lng) =>
      'geocode/reverse?lat=$lat&lng=$lng';
  static const shippingCompanies = 'shipping/companies';
  static const shippingCalculate = 'shipping/calculate';

  // Get this from: Firebase Console -> Authentication -> Sign-in method -> Google -> Web Client ID
  static const googleSignInServerClientId =
      '520930212972-gipoqiaj6tbt0suhbi0bc9gtoclfl8t3.apps.googleusercontent.com';
}
