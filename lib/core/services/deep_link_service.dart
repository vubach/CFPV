import 'package:go_router/go_router.dart';

/// Handles deep links from FCM notifications.
class DeepLinkService {
  /// Navigate to the appropriate screen based on deep link path.
  void handleDeepLink(GoRouter router, Uri uri) {
    final path = uri.path;

    if (path.startsWith('/order/')) {
      final orderId = path.split('/').last;
      router.go('/profile/orders/$orderId');
    } else if (path == '/rewards') {
      router.go('/rewards');
    } else if (path.startsWith('/menu/product/')) {
      final productId = path.split('/').last;
      router.go('/menu/product/$productId');
    } else if (path == '/menu') {
      router.go('/menu');
    }
  }
}
