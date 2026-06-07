import 'package:flutter_test/flutter_test.dart';

import 'package:cfpv/features/auth/providers/otp_timer_provider.dart';

void main() {
  group('OtpTimerNotifier', () {
    testWidgets('starts with state 0 and isActive false', (_) async {
      final notifier = OtpTimerNotifier();
      expect(notifier.state, 0);
      expect(notifier.isActive, false);
      notifier.dispose();
    });

    testWidgets('start() sets state to cooldown seconds and activates',
        (_) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.state, 30);
      expect(notifier.isActive, true);
      notifier.reset();
    });

    testWidgets('countdown decrements state every second', (tester) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.state, 30);

      // Advance fake time by 1 second — Timer.periodic fires
      await tester.pump(const Duration(seconds: 1));
      expect(notifier.state, 29);

      // Advance another 2 seconds
      await tester.pump(const Duration(seconds: 2));
      expect(notifier.state, 27);

      notifier.reset();
    });

    testWidgets('start() cancels previous timer', (tester) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.state, 30);

      // Advance 1 second
      await tester.pump(const Duration(seconds: 1));
      expect(notifier.state, 29);

      // Call start() again — should reset to 30
      notifier.start();
      expect(notifier.state, 30);

      // Advance 1 second — should be 29 (from the new start)
      await tester.pump(const Duration(seconds: 1));
      expect(notifier.state, 29);

      notifier.reset();
    });

    testWidgets('timer stops at 0 and isActive becomes false',
        (tester) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.isActive, true);

      // Jump to the last tick before 0 to avoid the 30-second wait
      notifier.state = 1;

      // One more tick — hits the else branch, sets state=0, cancels timer
      await tester.pump(const Duration(seconds: 1));
      expect(notifier.state, 0);
      expect(notifier.isActive, false);

      // Advance more time — state stays 0 (timer cancelled)
      await tester.pump(const Duration(seconds: 2));
      expect(notifier.state, 0);
    });

    testWidgets('reset() stops countdown and sets state to 0',
        (tester) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.state, 30);

      notifier.reset();
      expect(notifier.state, 0);
      expect(notifier.isActive, false);

      // Advance time — state stays 0 (timer was cancelled)
      await tester.pump(const Duration(seconds: 2));
      expect(notifier.state, 0);
    });

    testWidgets('dispose() cancels the timer', (tester) async {
      final notifier = OtpTimerNotifier();
      notifier.start();
      expect(notifier.state, 30);

      notifier.dispose();

      // After dispose, pump should not fire the timer callback.
      // Reading state before dispose is fine, but after dispose it may throw.
      // Instead, verify no timer fires by checking the timer variable is null.
      // (Timer._timer is private, so we verify indirectly via behavior.)
      // dispose() calls _timer?.cancel() — the timer won't fire.
      await tester.pump(const Duration(seconds: 2));
      // We can't read notifier.state after dispose (throws BadState).
      // Timer is cancelled — nothing to assert about state.
      // The test passes if no unexpected behavior occurs.
    });

    testWidgets('multiple start/reset cycles work correctly',
        (tester) async {
      final notifier = OtpTimerNotifier();

      // Cycle 1
      notifier.start();
      await tester.pump(const Duration(seconds: 1));
      expect(notifier.state, 29);

      notifier.reset();
      expect(notifier.state, 0);

      // Cycle 2
      notifier.start();
      expect(notifier.state, 30);

      await tester.pump(const Duration(seconds: 2));
      expect(notifier.state, 28);

      notifier.reset();
      expect(notifier.state, 0);
    });

    testWidgets('isActive reflects state being > 0', (_) async {
      final notifier = OtpTimerNotifier();

      expect(notifier.isActive, false);

      notifier.start();
      expect(notifier.isActive, true);

      notifier.state = 0; // Protected setter — tests isActive logic directly
      expect(notifier.isActive, false);

      notifier.state = 5;
      expect(notifier.isActive, true);

      notifier.state = 0;
      expect(notifier.isActive, false);

      notifier.dispose();
    });
  });
}
