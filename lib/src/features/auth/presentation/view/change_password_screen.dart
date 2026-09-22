import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final TextEditingController _currentPasswordCtrl = TextEditingController();
  final TextEditingController _newPasswordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();

  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _handleChangePassword() {
    final current = _currentPasswordCtrl.text.trim();
    final newPass = _newPasswordCtrl.text.trim();
    final confirm = _confirmPasswordCtrl.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      showErrorToast(content: "Please fill in all password fields");
      return;
    }

    if (newPass.length < 6) {
      showErrorToast(content: "New password must be at least 6 characters");
      return;
    }

    if (newPass != confirm) {
      showErrorToast(content: "New passwords do not match");
      return;
    }

    if (current == newPass) {
      showErrorToast(
        content: "New password must be different from current password",
      );
      return;
    }

    ref.read(profileProvider.notifier).changePassword(
      currentPassword: current,
      newPassword: newPass,
      successCallBack: () {
        if (!mounted) return;
        _currentPasswordCtrl.clear();
        _newPasswordCtrl.clear();
        _confirmPasswordCtrl.clear();
        showInfoToast(content: "Password updated successfully");
        if (context.canPop()) {
          context.pop();
        }
      },
      failureCallBack: (error) {
        if (!mounted) return;
        showErrorToast(content: error);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.passwordState == AsyncState.loading;

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: Text(
          'Change Password',
          style: AppTextStyles.headline2(color: AppColors.white),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Background ambient radial gradient
            Container(
              height: 0.5.sh,
              width: 1.sw,
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.darkBrown, Colors.transparent],
                  radius: 0.8,
                  stops: [0.2, 1],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xs,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSizes.xs.ph,

                  // Main card container
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.darkBgContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.skyBlue.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                color: AppColors.blue,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Update Password',
                                    style: AppTextStyles.headline2(
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Enter your current password and choose a new secure one.',
                                    style: AppTextStyles.bodyText2(
                                      color: AppColors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Current Password
                        Text(
                          "Current Password",
                          style: AppTextStyles.bodyText2(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _currentPasswordCtrl,
                          obscureText: !_showCurrentPassword,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            "Enter current password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showCurrentPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () =>
                                    _showCurrentPassword =
                                        !_showCurrentPassword,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // New Password
                        Text(
                          "New Password",
                          style: AppTextStyles.bodyText2(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _newPasswordCtrl,
                          obscureText: !_showNewPassword,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            "At least 6 characters",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showNewPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _showNewPassword = !_showNewPassword,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Confirm New Password
                        Text(
                          "Confirm New Password",
                          style: AppTextStyles.bodyText2(
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _confirmPasswordCtrl,
                          obscureText: !_showConfirmPassword,
                          enabled: !isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration(
                            "Re-enter new password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () =>
                                    _showConfirmPassword =
                                        !_showConfirmPassword,
                              ),
                            ),
                          ),
                        ),

                        if (profileState.passwordState == AsyncState.failure &&
                            profileState.passwordError != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            profileState.passwordError!,
                            style: const TextStyle(
                              color: AppColors.red,
                              fontSize: 13,
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // Submit Button
                        AppButton(
                          isExpanded: true,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleChangePassword,
                          bgColor: AppColors.blue,
                          label: "Change Password",
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          radius: 8,
                        ),
                      ],
                    ),
                  ),

                  AppSizes.xxlg.ph,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.black,
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.white.withValues(alpha: 0.3),
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.skyBlue.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.blue, width: 1.2),
      ),
    );
  }
}
