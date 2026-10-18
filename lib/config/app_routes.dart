import 'package:get/get.dart';
import '../features/address/presentation/view/address_screen.dart';
import '../features/auth/presentation/view/login_page.dart';
import '../features/auth/presentation/view/register_page.dart';
import '../features/cart/presentation/view/cart_items_screen.dart';
import '../features/categories/presentation/view/all_categories_screen.dart';
import '../features/categories/presentation/view/category_screen.dart';
import '../features/checkout/presentation/view/checkout_screen.dart';
import '../features/favorites/presentation/view/favorites_list_screen.dart';
import '../features/notifications/presentation/view/notifications_screen.dart';
import '../features/offline/no_wifi.dart';
import '../features/onboarding/view/get_started_screen.dart';
import '../features/onboarding/view/onboard_screen.dart';
import '../features/orders/presentation/view/order_details_screen.dart';
import '../features/orders/presentation/view/orders_screen.dart';
import '../features/products/presentation/view/product_details_screen.dart';
import '../features/root/view/root_view.dart';
import '../features/splash/views/splash_view.dart';
import '../features/store/presentation/view/open_store_page.dart';
import '../features/store/presentation/view/store_category_screen.dart';
import '../features/store/presentation/view/store_details_screen.dart';
import '../features/store/presentation/view/stores_list_screen.dart';
import '../features/stories/presentation/view/story_viewer_screen.dart';
import '../features/vendor/presentation/view/my_ads_screen.dart';
import '../features/vendor/presentation/view/vendor_dashboard_screen.dart';
import '../features/vendor/presentation/view/vendor_profile_screen.dart';
import '../features/categories/data/models/main_category_model.dart';
import '../features/orders/data/models/order_model.dart';
import '../features/stories/domain/entities/story_entity.dart';

final List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const SplashView(),
  ),
  GetPage(
    name: '/onboarding',
    page: () => const OnboardScreen(),
  ),
  GetPage(
    name: '/get-started',
    page: () => const GetStartedScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginPage(),
  ),
  GetPage(
    name: '/register',
    page: () => const RegisterPage(),
  ),
  GetPage(
    name: '/home',
    page: () => const RootView(),
  ),
  GetPage(
    name: '/no-wifi',
    page: () => const NoWifi(),
  ),
  GetPage(
    name: '/product-details',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final productId = args?['productId'] as String?;
      if (productId == null) {
        throw ArgumentError('productId is required for product details screen');
      }
      return ProductDetailsScreen(productId: productId);
    },
  ),

  // Categories
  GetPage(
    name: '/all-categories',
    page: () => const AllCategoriesScreen(),
  ),
  GetPage(
    name: '/category',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final category = args?['category'] as CategoryModel?;
      if (category == null) {
        throw ArgumentError('CategoryModel is required for category screen');
      }
      return CategoryScreen(category: category);
    },
  ),

  // Store
  GetPage(
    name: '/store-details',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final vendorId = args?['vendorId'] as String?;
      if (vendorId == null) {
        throw ArgumentError('vendorId is required for store details screen');
      }
      return StoreDetailsScreen(vendorId: vendorId);
    },
  ),
  GetPage(
    name: '/store-category',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final category = args?['category'] as CategoryModel?;
      if (category == null) {
        throw ArgumentError('CategoryModel is required for store category screen');
      }
      return StoreCategoryScreen(category);
    },
  ),
  GetPage(
    name: '/stores-list',
    page: () => const StoresListScreen(),
  ),
  GetPage(
    name: '/open-store',
    page: () => const OpenStoreView(),
  ),

  // Cart & Checkout
  GetPage(
    name: '/cart',
    page: () => const CartItemsScreen2(),
  ),
  GetPage(
    name: '/checkout',
    page: () => const CheckoutScreen(),
  ),

  // Orders
  GetPage(
    name: '/orders',
    page: () => const OrdersScreen(),
  ),
  GetPage(
    name: '/order-details',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final order = args?['order'] as OrderModel?;
      if (order == null) {
        throw ArgumentError('OrderModel is required for order details screen');
      }
      return OrderDetailsScreen(order: order);
    },
  ),

  // Address
  GetPage(
    name: '/addresses',
    page: () => const AddressScreen(),
  ),

  // Vendor
  GetPage(
    name: '/vendor-dashboard',
    page: () => const VendorDashboardScreen(),
  ),
  GetPage(
    name: '/vendor-profile',
    page: () => const VendorProfileScreen(),
  ),
  GetPage(
    name: '/my-ads',
    page: () => const MyAdsScreen(),
  ),

  // Other Features
  GetPage(
    name: '/favorites',
    page: () => const FavoritesListScreen(),
  ),
  GetPage(
    name: '/notifications',
    page: () => const NotificationsScreen(),
  ),
  GetPage(
    name: '/story-viewer',
    page: () {
      final args = Get.arguments as Map<String, dynamic>?;
      final stories = args?['stories'] as List<StoryEntity>?;
      final initialIndex = args?['initialIndex'] as int? ?? 0;
      if (stories == null) {
        throw ArgumentError('stories is required for story viewer screen');
      }
      return StoryViewerScreen(
        stories: stories,
        initialStoryIndex: initialIndex,
      );
    },
  ),
];
