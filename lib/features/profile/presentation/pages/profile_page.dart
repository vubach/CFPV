import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/buttons/confirmation_action_button.dart';

/// Full-screen profile page with user info, settings, and logout.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final userName = switch (authState) {
      AuthStateAuthenticated(:final fullName) => fullName,
      _ => 'User',
    };
    final userEmail = switch (authState) {
      AuthStateAuthenticated(:final email) => email,
      _ => null,
    };
    final userPhone = switch (authState) {
      AuthStateAuthenticated(:final phone) => phone,
      _ => '',
    };
    final avatarUrl = switch (authState) {
      AuthStateAuthenticated(:final avatarUrl) => avatarUrl,
      _ => null,
    };

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        children: [
          // ── User Info Card ─────────────────────
          _UserInfoCard(
            userName: userName,
            userEmail: userEmail,
            userPhone: userPhone,
            avatarUrl: avatarUrl,
          ),
          const SizedBox(height: CFPVSpacing.space4),

          // ── Settings Menu ──────────────────────
          _SettingsCard(
            items: [
              _SettingsItem(
                icon: Icons.receipt_long_outlined,
                label: 'Order History',
                onTap: () => context.go(RoutePaths.profileOrders),
              ),
              _SettingsItem(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                onTap: () => context.push(RoutePaths.profileEdit),
              ),
              _SettingsItem(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () => context.push(RoutePaths.profileChangePassword),
              ),
              _SettingsItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Help — Coming soon'),
                      backgroundColor: CFPVColors.textBlackSoft,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(CFPVRadius.card),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: CFPVSpacing.space5),

          // ── Logout Button ──────────────────────
          ConfirmationActionButton(
            icon: Icons.logout,
            label: 'Log Out',
            dialogTitle: 'Log Out',
            dialogContent:
                'Are you sure you want to log out? You will need to sign in again to access your account.',
            confirmLabel: 'Log Out',
            cancelLabel: 'Cancel',
            onConfirm: () => ref.read(authProvider.notifier).logout(),
          ),

          const SizedBox(height: CFPVSpacing.space8),
        ],
      ),
    );
  }

}

// ── Sub-widgets ─────────────────────────────────────────────

/// User info card with avatar, name, email, and phone.
class _UserInfoCard extends StatelessWidget {
  final String userName;
  final String? userEmail;
  final String userPhone;
  final String? avatarUrl;

  const _UserInfoCard({
    required this.userName,
    this.userEmail,
    required this.userPhone,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(userName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CFPVSpacing.space4),
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 0),
            blurRadius: 0.5,
            color: Colors.black.withOpacity(0.14),
          ),
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 1,
            color: Colors.black.withOpacity(0.24),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 40,
            backgroundColor: CFPVColors.starbucksGreen,
            child: avatarUrl != null
                ? null // Would use NetworkImage if available
                : Text(
                    initials,
                    style: CFPVTypography.h1.copyWith(
                      color: CFPVColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(height: CFPVSpacing.space3),

          // Name
          Text(
            userName,
            style: CFPVTypography.h1.copyWith(
              color: CFPVColors.textBlack,
            ),
          ),
          const SizedBox(height: CFPVSpacing.space1),

          // Email (if available)
          if (userEmail != null) ...[
            Text(
              userEmail!,
              style: CFPVTypography.body.copyWith(
                color: CFPVColors.textBlackSoft,
              ),
            ),
            const SizedBox(height: 2),
          ],

          // Phone
          Text(
            userPhone,
            style: CFPVTypography.body.copyWith(
              color: CFPVColors.textBlackSoft,
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }
}

/// Settings card with a list of menu items.
class _SettingsCard extends StatelessWidget {
  final List<_SettingsItem> items;

  const _SettingsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CFPVColors.white,
        borderRadius: BorderRadius.circular(CFPVRadius.card),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isFirst = index == 0;
          final isLast = index == items.length - 1;
          return Column(
            children: [
              if (!isFirst)
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: CFPVSpacing.space3,),
                  child: Divider(height: 1, color: CFPVColors.hairline),
                ),
              InkWell(
                onTap: item.onTap,
                borderRadius: isFirst
                    ? const BorderRadius.vertical(
                        top: Radius.circular(CFPVRadius.card),)
                    : isLast
                        ? const BorderRadius.vertical(
                            bottom: Radius.circular(CFPVRadius.card),)
                        : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: CFPVSpacing.space3,
                    vertical: CFPVSpacing.space3,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 22,
                        color: CFPVColors.textBlackSoft,
                      ),
                      const SizedBox(width: CFPVSpacing.space3),
                      Expanded(
                        child: Text(
                          item.label,
                          style: CFPVTypography.body.copyWith(
                            color: CFPVColors.textBlack,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 20,
                        color: CFPVColors.textBlackSoft.withOpacity(0.4),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// A single settings menu item definition.
class _SettingsItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
