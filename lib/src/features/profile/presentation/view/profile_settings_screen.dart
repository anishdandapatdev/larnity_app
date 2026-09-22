import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/service/cache/user_cache_service.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';
import 'package:larnity/src/core/utils/async_states.dart';

class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() =>
      _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  // Profile fields
  late TextEditingController firstNameCtrl;
  late TextEditingController lastNameCtrl;
  late TextEditingController phoneCtrl;

  // Password fields
  late TextEditingController currentPasswordCtrl;
  late TextEditingController newPasswordCtrl;
  late TextEditingController confirmPasswordCtrl;

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  // Image picker
  File? _pickedImage;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final currentUser = ref.read(authProvider).user;

    firstNameCtrl = TextEditingController(text: currentUser?.firstName ?? "");
    lastNameCtrl = TextEditingController(text: currentUser?.lastName ?? "");
    phoneCtrl = TextEditingController(text: currentUser?.phoneNumber ?? "");

    currentPasswordCtrl = TextEditingController();
    newPasswordCtrl = TextEditingController();
    confirmPasswordCtrl = TextEditingController();
    _loadCachedProfile();
  }

  Future<void> _loadCachedProfile() async {
    final cache = ref.read(userCacheServiceProvider);
    final cached = await cache.getCachedProfile();

    if (!mounted) return;

    if (firstNameCtrl.text.isEmpty &&
        (cached['firstName']?.isNotEmpty ?? false)) {
      setState(() => firstNameCtrl.text = cached['firstName']!);
    }
    if (lastNameCtrl.text.isEmpty &&
        (cached['lastName']?.isNotEmpty ?? false)) {
      setState(() => lastNameCtrl.text = cached['lastName']!);
    }
    if (phoneCtrl.text.isEmpty && (cached['phoneNumber']?.isNotEmpty ?? false)) {
      setState(() => phoneCtrl.text = cached['phoneNumber']!);
    }
  }

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    phoneCtrl.dispose();
    currentPasswordCtrl.dispose();
    newPasswordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not pick image: $e")));
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBgContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Image Source',
                style: AppTextStyles.bodyText2().copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.white),
                title: Text(
                  'Camera',
                  style: AppTextStyles.bodyText2().copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.white),
                title: Text(
                  'Gallery',
                  style: AppTextStyles.bodyText2().copyWith(
                    color: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider).user;
    final profileState = ref.watch(profileProvider);
    debugPrint('here is the saved Prfoiel${_loadCachedProfile().toString()}');

    ref.listen<AuthState>(authProvider, (previous, next) {
      final user = next.user;
      if (user == null) return;
      if (firstNameCtrl.text.isEmpty && (user.firstName?.isNotEmpty ?? false)) {
        firstNameCtrl.text = user.firstName!;
      }
      if (lastNameCtrl.text.isEmpty && (user.lastName?.isNotEmpty ?? false)) {
        lastNameCtrl.text = user.lastName!;
      }
      if (phoneCtrl.text.isEmpty && (user.phoneNumber?.isNotEmpty ?? false)) {
        phoneCtrl.text = user.phoneNumber!;
      }
    });

    final canPop = context.canPop();

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.black,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.grey),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'Back',
                style: AppTextStyles.bodyText2().copyWith(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            )
          : null,

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xs),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSizes.xs.ph,

              Text(
                'Profile Settings',
                style: AppTextStyles.headline1().copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              AppSizes.lg.ph,

              // ── Profile Image ──────────────────────────────────────────
              Text(
                'Profile Image',
                style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
              ),
              AppSizes.xxxs.ph,
              Row(
                children: [
                  // Avatar — shows picked file > network image > initials
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!) as ImageProvider
                            : (currentUser?.image != null &&
                                  currentUser!.image!.isNotEmpty)
                            ? NetworkImage(currentUser.image!)
                            : null,
                        child:
                            (_pickedImage == null &&
                                (currentUser?.image == null ||
                                    currentUser!.image!.isEmpty))
                            ? Text(
                                _getInitials(
                                  currentUser?.firstName,
                                  currentUser?.lastName,
                                ),
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      // Loading spinner overlay
                      if (profileState.imageState == AsyncState.loading)
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  AppSizes.sm.pw,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pick image button
                      OutlinedButton.icon(
                        onPressed: profileState.imageState == AsyncState.loading
                            ? null
                            : _showImageSourceDialog,
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Change Photo',
                          style: AppTextStyles.bodyText2().copyWith(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.xxxs),
                          ),
                        ),
                      ),
                      // Upload button — only visible when an image is picked
                      if (_pickedImage != null) ...[
                        const SizedBox(height: 6),
                        OutlinedButton.icon(
                          onPressed:
                              profileState.imageState == AsyncState.loading
                              ? null
                              : () {
                                  if (currentUser?.id == null) return;
                                  ref
                                      .read(profileProvider.notifier)
                                      .uploadProfileImage(
                                        imageFile: _pickedImage!,
                                        userId: currentUser!.id!,
                                        successCallBack: (imageUrl) {
                                          final updatedUser = currentUser
                                              .copyWith(image: imageUrl);
                                          ref
                                              .read(profileProvider.notifier)
                                              .createProfile(
                                                user: updatedUser,
                                                successCallBack: () {
                                                  setState(
                                                    () => _pickedImage = null,
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Profile photo updated",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                        },
                                        failureCallBack: (error) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Upload failed: $error",
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                },
                          icon: const Icon(
                            Icons.upload,
                            size: 16,
                            color: Colors.greenAccent,
                          ),
                          label: Text(
                            'Upload Photo',
                            style: AppTextStyles.bodyText2().copyWith(
                              color: Colors.greenAccent,
                              fontSize: 13,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.greenAccent.withValues(alpha: 0.5),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppSizes.xxxs,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              AppSizes.lg.ph,

              // ── First Name & Last Name ─────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "First Name",
                          style: AppTextStyles.bodyText2().copyWith(
                            color: Colors.white,
                          ),
                        ),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          controller: firstNameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter first name"),
                        ),
                      ],
                    ),
                  ),
                  AppSizes.xs.pw,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Name",
                          style: AppTextStyles.bodyText2().copyWith(
                            color: Colors.white,
                          ),
                        ),
                        AppSizes.xxxs.ph,
                        TextFormField(
                          controller: lastNameCtrl,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Enter last name"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              AppSizes.lg.ph,

              Text(
                "Phone Number",
                style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
              ),
              AppSizes.xxxs.ph,

              TextFormField(
                controller: phoneCtrl,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
                ],
                decoration: _inputDecoration("e.g. +91 98765 43210"),
              ),

              AppSizes.lg.ph,

              // Update Profile Button
              AppButton(
                onPressed: profileState.state == AsyncState.loading
                    ? null
                    : () {
                        if (currentUser == null) return;
                        final updatedUser = currentUser.copyWith(
                          firstName: firstNameCtrl.text.trim(),
                          lastName: lastNameCtrl.text.trim(),
                          phoneNumber: phoneCtrl.text.trim(),
                        );

                        final messenger = ScaffoldMessenger.of(context);

                        ref
                            .read(profileProvider.notifier)
                            .createProfile(
                              user: updatedUser,
                              successCallBack: () {
                                ref
                                    .read(userCacheServiceProvider)
                                    .saveUser(
                                      firstName: updatedUser.firstName,
                                      lastName: updatedUser.lastName,
                                      image: updatedUser.image,
                                      phoneNumber: updatedUser.phoneNumber,
                                    );
                                ref
                                    .read(authProvider.notifier)
                                    .getCurrentUser();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Profile updated successfully",
                                    ),
                                  ),
                                );
                              },
                            );
                      },
                label: profileState.state == AsyncState.loading
                    ? "Updating..."
                    : "Update Profile",
                bgColor: Colors.grey[300]!,
                labelStyle: AppTextStyles.button().copyWith(
                  color: Colors.black,
                ),
                radius: AppSizes.xs,
                isExpanded: false,
              ),

              AppSizes.lg.ph,

              // Divider
              Divider(color: Colors.grey.withValues(alpha: 0.3)),

              AppSizes.lg.ph,

              // ── Change Password Section ──────────────────────────────────
              Text(
                'Change Password',
                style: AppTextStyles.headline1().copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              AppSizes.xxxs.ph,
              Text(
                'Update your account password securely.',
                style: AppTextStyles.bodyText2().copyWith(
                  color: Colors.blue,
                  fontSize: 13,
                ),
              ),

              AppSizes.lg.ph,

              // Current Password
              Text(
                "Current Password",
                style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: currentPasswordCtrl,
                obscureText: !_showCurrentPassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Enter current password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showCurrentPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _showCurrentPassword = !_showCurrentPassword,
                    ),
                  ),
                ),
              ),

              AppSizes.md.ph,

              // New Password
              Text(
                "New Password",
                style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: newPasswordCtrl,
                obscureText: !_showNewPassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Enter new password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showNewPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _showNewPassword = !_showNewPassword),
                  ),
                ),
              ),

              AppSizes.md.ph,

              // Confirm Password
              Text(
                "Confirm Password",
                style: AppTextStyles.bodyText2().copyWith(color: Colors.white),
              ),
              AppSizes.xxxs.ph,
              TextFormField(
                controller: confirmPasswordCtrl,
                obscureText: !_showConfirmPassword,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Confirm new password").copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _showConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _showConfirmPassword = !_showConfirmPassword,
                    ),
                  ),
                ),
              ),

              // Password error message
              if (profileState.passwordState == AsyncState.failure &&
                  profileState.passwordError != null) ...[
                AppSizes.xs.ph,
                Text(
                  profileState.passwordError!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],

              AppSizes.lg.ph,

              // Update Password Button
              AppButton(
                onPressed: profileState.passwordState == AsyncState.loading
                    ? null
                    : () {
                        final current = currentPasswordCtrl.text.trim();
                        final newPass = newPasswordCtrl.text.trim();
                        final confirm = confirmPasswordCtrl.text.trim();

                        if (current.isEmpty ||
                            newPass.isEmpty ||
                            confirm.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Please fill in all password fields",
                              ),
                            ),
                          );
                          return;
                        }
                        if (newPass != confirm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("New passwords do not match"),
                            ),
                          );
                          return;
                        }
                        if (newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Password must be at least 6 characters",
                              ),
                            ),
                          );
                          return;
                        }
                        final messenger = ScaffoldMessenger.of(context);

                        ref
                            .read(profileProvider.notifier)
                            .changePassword(
                              currentPassword: current,
                              newPassword: newPass,
                              successCallBack: () {
                                if (!mounted) return;
                                currentPasswordCtrl.clear();
                                newPasswordCtrl.clear();
                                confirmPasswordCtrl.clear();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Password updated successfully",
                                    ),
                                  ),
                                );
                              },
                              failureCallBack: (error) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(error)),
                                );
                              },
                            );
                      },
                label: profileState.passwordState == AsyncState.loading
                    ? "Updating..."
                    : "Update Password",
                bgColor: Colors.grey[300]!,
                labelStyle: AppTextStyles.button().copyWith(
                  color: Colors.black,
                ),
                radius: AppSizes.xs,
                isExpanded: false,
              ),

              AppSizes.xxxlg.ph,
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String? firstName, String? lastName) {
    final first = (firstName != null && firstName.isNotEmpty)
        ? firstName[0]
        : '';
    final last = (lastName != null && lastName.isNotEmpty) ? lastName[0] : '';
    return '$first$last';
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.darkBgContainer,
      hintText: hint,
      hintStyle: AppTextStyles.bodyText2().copyWith(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.xxxs),
        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
      ),
    );
  }
}
