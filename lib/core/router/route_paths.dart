/// Central route path definitions for GoRouter.
/// Source: specification-phase.md §5.3
class RoutePaths {
  RoutePaths._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerVerifyOtp = '/register/verify-otp';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String menu = '/menu';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String rewards = '/rewards';
  static const String profile = '/profile';

  // ── Parameterized Routes ──────────────────────────
  static const String menuCategory = '/menu/category/:categoryId';
  static const String menuProduct = '/menu/product/:productId';
  static const String orderConfirmation = '/order/:orderId/confirmation';
  static const String profileEdit = '/profile/edit';
  static const String profileOrders = '/profile/orders';
  static const String profileOrderDetail = '/profile/orders/:orderId';
  static const String profileSettings = '/profile/settings';
  static const String profileChangePassword = '/profile/settings/change-password';
  static const String profileHelp = '/profile/help';

  // ── Helper Builders ───────────────────────────────
  static String categoryProducts(String categoryId) =>
      '/menu/category/$categoryId';

  static String productDetail(String productId) => '/menu/product/$productId';

  static String orderSummary(String orderId) => '/order/$orderId/confirmation';

  static String orderDetail(String orderId) => '/profile/orders/$orderId';
}
