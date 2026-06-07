class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/api/v1',
  );

  // ── Auth ───────────────────────────────────────
  static const String register = '/auth/register';
  static const String registerVerify = '/auth/register/verify';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String forgotPasswordVerify = '/auth/forgot-password/verify';

  // ── Users ──────────────────────────────────────
  static const String usersMe = '/users/me';
  static const String usersMePassword = '/users/me/password';
  static const String usersMeSettings = '/users/me/settings';

  // ── Categories ─────────────────────────────────
  static const String categories = '/categories';

  // ── Products ───────────────────────────────────
  static const String products = '/products';
  static String productById(String id) => '/products/$id';
  static const String productsFeatured = '/products/featured';
  static String productNutrition(String id) => '/products/$id/nutrition';

  // ── Cart ───────────────────────────────────────
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static String cartItemById(String itemId) => '/cart/items/$itemId';
  static const String cartStore = '/cart/store';
  static const String cartNotes = '/cart/notes';

  // ── Orders ─────────────────────────────────────
  static const String orders = '/orders';
  static String orderById(String id) => '/orders/$id';
  static String orderConfirmPayment(String id) => '/orders/$id/confirm-payment';
  static String orderReorder(String id) => '/orders/$id/reorder';

  // ── Stores ─────────────────────────────────────
  static const String stores = '/stores';

  // ── Rewards ────────────────────────────────────
  static const String rewardsBalance = '/rewards/balance';
  static const String rewardsTransactions = '/rewards/transactions';

  // ── Notifications ──────────────────────────────
  static const String notificationsDevice = '/notifications/device';

  // ── Uploads ────────────────────────────────────
  static const String uploadsAvatar = '/uploads/avatar';
}
