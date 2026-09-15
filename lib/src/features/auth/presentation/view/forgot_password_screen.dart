import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  /// Optionally pre-fill the email from the login screen.
  final String? prefillEmail;

  const ForgotPasswordScreen({super.key, this.prefillEmail});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefillEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      showErrorToast(content: 'Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    ref
        .read(authProvider.notifier)
        .resetPassword(
          email: email,
          successCallBack: () {
            if (mounted) setState(() => _isLoading = false);
            showInfoToast(
              content: 'Password reset email sent! Check your inbox.',
            );
            if (mounted) context.pop();
          },
          failureCallBack: (error) {
            if (mounted) setState(() => _isLoading = false);
            showErrorToast(content: error);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = _isLoading;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: 0.5.sh,
              width: 1.sw,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [AppColors.darkBrown, Colors.transparent],
                  radius: 0.8,
                  stops: const [0.2, 1],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Logo
                  Center(
                    child: Image.asset(
                      AppAssets.images.logoWhite,
                      width: 0.4.sw,
                    ),
                  ),

                  AppSizes.lg.ph,

                  // Card
                  Container(
                    padding: EdgeInsets.all(AppSizes.xs),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderBrown),
                      borderRadius: BorderRadius.circular(AppSizes.xs),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back arrow + title row
                        Text(
                          'Forgot Password',
                          style: AppTextStyles.headline5(
                            color: AppColors.white,
                          ),
                        ),

                        AppSizes.xxxs.ph,

                        Text(
                          'Enter your registered email address and we\'ll send you a link to reset your password.',
                          style: AppTextStyles.overLine(
                            color: AppColors.white.withValues(alpha: 0.7),
                          ),
                        ),

                        AppSizes.xs.ph,

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: AppTextStyles.overLine(color: AppColors.white),
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black.withValues(alpha: 0.2),
                            hintText: 'Email address',
                            hintStyle: AppTextStyles.overLine(
                              color: AppColors.white.withValues(alpha: 0.4),
                            ),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.borderBrown,
                              size: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.borderBrown,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.borderBrown,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.borderBrown,
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        AppSizes.xs.ph,

                        // Send button
                        AppButton(
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                          bgColor: AppColors.white,
                          radius: AppSizes.lg,
                          label: 'Send Reset Link',
                          labelStyle: AppTextStyles.button(),
                        ),

                        AppSizes.xxs.ph,

                        // Back to login
                        Center(
                          child: GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Back to Login',
                              style:
                                  AppTextStyles.overLine(
                                    color: AppColors.white,
                                  ).copyWith(
                                    decoration: TextDecoration.underline,
                                    decorationColor: AppColors.white,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
