import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/secure_storage_service.dart';

/// Splash screen state
class SplashState {
  final bool isLoading;
  final SplashAction? action;

  const SplashState({this.isLoading = true, this.action});

  SplashState copyWith({bool? isLoading, SplashAction? action}) =>
      SplashState(
        isLoading: isLoading ?? this.isLoading,
        action: action ?? this.action,
      );
}

/// What the splash screen should do after checking auth.
enum SplashAction { goToOnboarding, goToLogin, goToHome }

class SplashNotifier extends StateNotifier<SplashState> {
  final SecureStorageService _storage;

  SplashNotifier(this._storage) : super(const SplashState());

  Future<void> checkAuth() async {
    try {
      final hasSeenOnboarding = await _storage.hasSeenOnboarding();
      final hasToken = await _storage.getAccessToken();

      SplashAction action;
      if (!hasSeenOnboarding) {
        action = SplashAction.goToOnboarding;
      } else if (hasToken == null) {
        action = SplashAction.goToLogin;
      } else {
        action = SplashAction.goToHome;
      }

      state = state.copyWith(isLoading: false, action: action);
    } catch (_) {
      state = state.copyWith(isLoading: false, action: SplashAction.goToLogin);
    }
  }
}

final splashProvider =
    StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  final storage = SecureStorageService();
  return SplashNotifier(storage);
});
