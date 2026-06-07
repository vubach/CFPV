import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/auth_state.dart';
import '../../../../core/router/route_paths.dart';
import '../../../../shared/theme/colors.dart';
import '../../../../shared/theme/spacing.dart';
import '../../../../shared/theme/radius.dart';
import '../../../../shared/theme/typography.dart';
import '../../../../shared/widgets/inputs/floating_label_input.dart';
import '../../../../shared/widgets/buttons/primary_pill_button.dart';

/// Full-screen edit profile page with name, email, and phone form fields.
class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with current user data
    final authState = ref.read(authProvider);
    if (authState is AuthStateAuthenticated) {
      _nameController.text = authState.fullName;
      _emailController.text = authState.email ?? '';
      _phoneController.text = authState.phone;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return;

    final filePath = picked.path;
    if (!mounted) return;
    await ref.read(authProvider.notifier).updateAvatar(filePath);
    if (!mounted) return;

    final authState = ref.read(authProvider);
    if (authState is AuthStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload: ${authState.message}'),
          backgroundColor: CFPVColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Avatar updated'),
          backgroundColor: CFPVColors.greenAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    await ref.read(authProvider.notifier).updateProfile(
          fullName: name,
          email: email.isNotEmpty ? email : null,
          phone: phone.isNotEmpty ? phone : null,
        );

    if (!mounted) return;

    // Check for errors
    final authState = ref.read(authProvider);
    if (authState is AuthStateError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: ${authState.message}'),
          backgroundColor: CFPVColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
      return;
    }

    // Success
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: CFPVColors.greenAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CFPVRadius.card),
          ),
        ),
      );
    if (!mounted) return;
    context.go(RoutePaths.profile);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: CFPVColors.neutralWarm,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: CFPVColors.white,
        surfaceTintColor: CFPVColors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(CFPVSpacing.space4),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar section ────────────────────
              Center(
                child: _AvatarSection(
                  avatarUrl: authState is AuthStateAuthenticated
                      ? authState.avatarUrl
                      : null,
                  onChangePhoto: _pickAndUploadAvatar,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space5),

              // ── Form fields ───────────────────────
              Text(
                'Full Name',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              FloatingLabelInput(
                label: 'Full Name',
                controller: _nameController,
                keyboardType: TextInputType.name,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 2) return 'Name is too short';
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: CFPVSpacing.space4),

              Text(
                'Email Address',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              FloatingLabelInput(
                label: 'Email Address',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: CFPVSpacing.space4),

              Text(
                'Phone Number',
                style: CFPVTypography.smallBold.copyWith(
                  color: CFPVColors.textBlackSoft,
                ),
              ),
              const SizedBox(height: CFPVSpacing.space2),
              FloatingLabelInput(
                label: 'Phone Number',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (v.trim().length < 7) return 'Enter a valid phone number';
                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: CFPVSpacing.space5),

              // ── Save button ───────────────────────
              PrimaryPillButton.fullWidth(
                label: 'Save Changes',
                isLoading: isLoading,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar section with the current user's avatar/initials and a change button.
class _AvatarSection extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onChangePhoto;

  const _AvatarSection({
    this.avatarUrl,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: CFPVColors.starbucksGreen,
          backgroundImage: avatarUrl != null
              ? NetworkImage(avatarUrl!)
              : null,
          child: avatarUrl == null
              ? Text(
                  '?',
                  style: CFPVTypography.h1.copyWith(
                    color: CFPVColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                )
              : null,
        ),
        const SizedBox(height: CFPVSpacing.space2),
        TextButton.icon(
          onPressed: onChangePhoto,
          icon: const Icon(Icons.camera_alt_outlined, size: 18),
          label: const Text('Change Photo'),
          style: TextButton.styleFrom(
            foregroundColor: CFPVColors.greenAccent,
            textStyle: CFPVTypography.smallBold,
          ),
        ),
      ],
    );
  }
}
