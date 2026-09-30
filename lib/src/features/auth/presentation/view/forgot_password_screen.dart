import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:hugeicons/styles/stroke_rounded.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/router/router.dart';
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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;

  bool _isLoading = false;
  bool _isEmailSent = false;
  String _sentToEmail = '';

  // Resend cooldown timer
  Timer? _resendTimer;
  int _cooldownSeconds = 0;

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefillEmail ?? '');
    _emailController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _resendTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  void _navigateBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goNamed(Routes.auth);
    }
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    setState(() => _isLoading = true);

    ref
        .read(authProvider.notifier)
        .resetPassword(
          email: email,
          successCallBack: () {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _isEmailSent = true;
              _sentToEmail = email;
            });
            _startCooldown(60);
            showInfoToast(
              content: 'Password reset link sent! Please check your email.',
            );
          },
          failureCallBack: (error) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            showErrorToast(content: error);
          },
        );
  }

  void _resend() {
    if (_cooldownSeconds > 0 || _isLoading) return;
    final email = _sentToEmail.isNotEmpty
        ? _sentToEmail
        : _emailController.text.trim();

    if (email.isEmpty) return;

    setState(() => _isLoading = true);

    ref
        .read(authProvider.notifier)
        .resetPassword(
          email: email,
          successCallBack: () {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _startCooldown(60);
            showInfoToast(
              content: 'A new password reset link has been sent to your email.',
            );
          },
          failureCallBack: (error) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            showErrorToast(content: error);
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // Background Gradient Glow
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

              // Scrollable Content to avoid keyboard overflows
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Top Bar with Back Button
                    InkWell(
                      onTap: _navigateBack,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                          border: Border.all(
                            color: AppColors.borderBrown,
                            width: 1,
                          ),
                        ),
                        child: const HugeIcon(
                          icon: HugeIconsStrokeRounded.arrowLeft01,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Brand Logo
                    Center(
                      child: Image.asset(
                        AppAssets.images.logoWhite,
                        width: 0.4.sw,
                      ),
                    ),

                    AppSizes.lg.ph,

                    // Interactive Card (Form State vs Email Sent Confirmation State)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: _isEmailSent
                          ? _buildEmailSentCard()
                          : _buildInputFormCard(),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Initial input form state
  Widget _buildInputFormCard() {
    return Container(
      key: const ValueKey('input_form_card'),
      padding: EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        border: Border.all(color: AppColors.borderBrown),
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot Password',
              style: AppTextStyles.headline5(color: AppColors.white),
            ),

            AppSizes.xxxs.ph,

            Text(
              "Enter your registered email address and we'll send you a link to reset your password.",
              style: AppTextStyles.overLine(
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),

            AppSizes.xs.ph,

            // Email text field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.email],
              onFieldSubmitted: (_) => _submit(),
              enabled: !_isLoading,
              style: AppTextStyles.overLine(color: AppColors.white),
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!_emailRegex.hasMatch(trimmed)) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.25),
                hintText: 'Email address',
                hintStyle: AppTextStyles.overLine(
                  color: AppColors.white.withValues(alpha: 0.4),
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  child: HugeIcon(
                    icon: HugeIconsStrokeRounded.mail01,
                    color: AppColors.creamWhite,
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),
                suffixIcon: _emailController.text.isNotEmpty && !_isLoading
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppColors.creamWhite,
                        ),
                        onPressed: () {
                          _emailController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderBrown),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.borderBrown),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.primaryOrange,
                    width: 1.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppColors.red,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            AppSizes.xs.ph,

            // Send reset link button
            AppButton(
              isLoading: _isLoading,
              onPressed: _isLoading ? null : _submit,
              bgColor: AppColors.white,
              radius: AppSizes.lg,
              label: 'Send Reset Link',
              labelStyle: AppTextStyles.button(color: AppColors.black),
            ),

            AppSizes.xxs.ph,

            // Back to login
            Center(
              child: GestureDetector(
                onTap: _navigateBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    'Back to Login',
                    style: AppTextStyles.overLine(
                      color: AppColors.white,
                    ).copyWith(
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Success state after email dispatch
  Widget _buildEmailSentCard() {
    return Container(
      key: const ValueKey('email_sent_card'),
      padding: EdgeInsets.all(AppSizes.xs),
      decoration: BoxDecoration(
        color: AppColors.darkBgContainer,
        border: Border.all(color: AppColors.borderBrown),
        borderRadius: BorderRadius.circular(AppSizes.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppSizes.xxs.ph,

          // Icon Indicator
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryOrange.withValues(alpha: 0.15),
              border: Border.all(
                color: AppColors.primaryOrange.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: const HugeIcon(
              icon: HugeIconsStrokeRounded.mail01,
              color: AppColors.primaryOrange,
              size: 32,
            ),
          ),

          AppSizes.xs.ph,

          Text(
            'Check Your Email',
            style: AppTextStyles.headline5(color: AppColors.white),
            textAlign: TextAlign.center,
          ),

          AppSizes.xxxs.ph,

          Text(
            "We have sent password reset instructions to:",
            style: AppTextStyles.overLine(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),

          AppSizes.xxs.ph,

          // Sent-to Email pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderBrown),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: AppColors.green,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _sentToEmail,
                    style: AppTextStyles.subtitle2(color: AppColors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          AppSizes.xs.ph,

          Text(
            "Click the link inside the email to reset your password. If you don't see it, please check your spam or junk folder.",
            style: AppTextStyles.caption2(
              color: AppColors.creamWhite.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),

          AppSizes.xs.ph,

          // Back to Login / Done button
          AppButton(
            onPressed: _navigateBack,
            bgColor: AppColors.white,
            radius: AppSizes.lg,
            label: 'Back to Login',
            labelStyle: AppTextStyles.button(color: AppColors.black),
          ),

          AppSizes.xs.ph,

          // Resend or switch email actions
          if (_cooldownSeconds > 0)
            Text(
              'Resend email in ${_cooldownSeconds}s',
              style: AppTextStyles.caption2(
                color: AppColors.white.withValues(alpha: 0.5),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive email? ",
                  style: AppTextStyles.caption2(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),
                GestureDetector(
                  onTap: _isLoading ? null : _resend,
                  child: Text(
                    'Resend',
                    style: AppTextStyles.caption2(
                      color: AppColors.primaryOrange,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.primaryOrange,
                    ),
                  ),
                ),
              ],
            ),

          AppSizes.xxs.ph,

          // Change Email Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isEmailSent = false;
              });
            },
            child: Text(
              'Use a different email',
              style: AppTextStyles.overLine(
                color: AppColors.creamWhite,
              ).copyWith(
                decoration: TextDecoration.underline,
                decorationColor: AppColors.creamWhite,
              ),
            ),
          ),

          AppSizes.xxxs.ph,
        ],
      ),
    );
  }
}
