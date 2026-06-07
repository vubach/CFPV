class AppConstants {
  AppConstants._();

  // ── Timeouts ────────────────────────────────────
  static const Duration connectionTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // ── Auth ────────────────────────────────────────
  static const Duration accessTokenExpiry = Duration(minutes: 15);
  static const Duration refreshTokenExpiry = Duration(days: 30);
  static const int otpLength = 6;
  static const String hardcodedOtp = '131017'; // MVP only
  static const Duration otpExpiry = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 30);

  // ── Pagination ──────────────────────────────────
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;

  // ── Limits ──────────────────────────────────────
  static const int cartItemMaxQuantity = 99;
  static const int cartItemMinQuantity = 1;
  static const int notesMaxLength = 500;
  static const int avatarMaxSizeMb = 5;

  // ── Feature Flags ───────────────────────────────
  static const bool isOtpHardcoded = true; // Toggle for real SMS integration
  static const bool enableSearch = false; // Post-MVP
  static const bool enableRewardsRedemption = false; // Post-MVP
  static const bool enableProductCustomization = false; // Post-MVP
  static const bool enableStoreLocator = false; // Post-MVP
}
