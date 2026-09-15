import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:larnity/src/core/constants/app_assets.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/extensions/screen_size_extension.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/ui/widgets/app_button.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileNotifier = ref.read(profileProvider.notifier);
    final authNotifier = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    ref.listen(authProvider, (previousState, newState) {
      if (newState.signupState == AsyncState.failure ||
          newState.loginState == AsyncState.failure) {
        showErrorToast(content: newState.error ?? "Failure");
      } else if (newState.signUpSuccessMessage != null &&
          newState.signUpSuccessMessage !=
              previousState?.signUpSuccessMessage) {
        // Only show when the message is newly set (first-time signup only)
        showInfoToast(content: newState.signUpSuccessMessage!);
      }
    });
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
                  stops: [0.2, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    Image.asset(AppAssets.images.logoWhite, width: 0.4.sw),

                    AppSizes.lg.ph,
                    // Title
                    Builder(
                      builder: (context) {
                        return Container(
                          padding: EdgeInsets.all(AppSizes.xs),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderBrown),
                            borderRadius: BorderRadius.circular(AppSizes.xs),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authState.isLogIn ? 'Login' : 'Signup',
                                style: AppTextStyles.headline5(
                                  color: AppColors.white,
                                ),
                              ),
                              AppSizes.xxxs.ph,

                              // Subtitle
                              Text(
                                'Network with people from around the world, join groups, create your own, watch courses and become the best version of yourself.',
                                style: AppTextStyles.overLine(
                                  color: AppColors.white,
                                ),
                              ),

                              AppSizes.xxxs.ph,

                              // Conditional Fields based on Login/Signup
                              if (!authState.isLogIn) ...[
                                // First Name Field (Signup only)
                                _buildTextField(
                                  controller: authNotifier.firstNameController,
                                  hintText: 'First name',
                                  obscureText: false,
                                ),
                                AppSizes.xxxs.ph,

                                // Last Name Field (Signup only)
                                _buildTextField(
                                  controller: authNotifier.lastNameController,
                                  hintText: 'Last name',
                                  obscureText: false,
                                ),
                                AppSizes.xxxs.ph,
                              ],

                              // Email Field (Both)
                              _buildTextField(
                                controller: authNotifier.emailController,
                                hintText: 'Email',
                                obscureText: false,
                                keyboardType: TextInputType.emailAddress,
                              ),

                              AppSizes.xxxs.ph,

                              // Password Field (Both)
                              _buildTextField(
                                controller: authNotifier.passController,
                                hintText: 'Password',
                                obscureText: true,
                              ),

                              // Forgot Password (Login only)
                              if (authState.isLogIn) ...[
                                AppSizes.xxxs.ph,
                                Align(
                                  alignment: Alignment.center,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: "Forgot password? ",
                                          style: AppTextStyles.overLine(
                                            color: AppColors.white,
                                          ),
                                        ),
                                        TextSpan(
                                          text: "Reset",
                                          style:
                                              AppTextStyles.overLine(
                                                color: AppColors.white,
                                              ).copyWith(
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    AppColors.white,
                                              ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              context.pushNamed(
                                                Routes.forgotPassword,
                                                extra: authNotifier
                                                    .emailController
                                                    .text
                                                    .trim(),
                                              );
                                            },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],

                              AppSizes.xs.ph,

                              // Sign In/Sign Up Button
                              AppButton(
                                isLoading:
                                    authState.loginState ==
                                        AsyncState.loading ||
                                    authState.signupState == AsyncState.loading,
                                onPressed: () {
                                  Log.info("$authState");
                                  if (authState.isLogIn) {
                                    authNotifier.signInWithEmail(
                                      successCallBack: () {
                                        if (authState.currentUserState ==
                                            AsyncState.failure) {
                                          profileNotifier.createProfile(
                                            user: UserModel(
                                              id: authState.user?.id ?? "",
                                              email: authNotifier
                                                  .emailController
                                                  .text
                                                  .trim(),
                                              firstName: authNotifier
                                                  .firstNameController
                                                  .text
                                                  .trim(),
                                              lastName: authNotifier
                                                  .lastNameController
                                                  .text
                                                  .trim(),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                    // authBloc.add(
                                    //   AuthLogin(
                                    //     email: authBloc.emailController.text
                                    //         .trim(),
                                    //     password: authBloc
                                    //         .passController
                                    //         .text
                                    //         .trim(),
                                    //   ),
                                    // );
                                  } else {
                                    authNotifier.signUpWithEmail(
                                      successCallBack: () {
                                        authNotifier.getCurrentUser();
                                      },
                                    );
                                    //   authBloc.add(
                                    //     AuthSignUp(
                                    //       email: authBloc.emailController.text
                                    //           .trim(),
                                    //       password: authBloc
                                    //           .passwordController
                                    //           .text
                                    //           .trim(),
                                    //       firstName: authBloc
                                    //           .firstNameController
                                    //           .text
                                    //           .trim(),
                                    //       lastName: authBloc
                                    //           .lastNameController
                                    //           .text
                                    //           .trim(),
                                    //     ),
                                    //   );
                                  }
                                },
                                bgColor: AppColors.white,
                                radius: AppSizes.lg,
                                label: authState.isLogIn
                                    ? 'Sign In with Email'
                                    : 'Sign Up',
                                labelStyle: AppTextStyles.button(),
                              ),
                              AppSizes.xs.ph,

                              // Toggle between Login/Signup
                              Align(
                                alignment: Alignment.center,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: authState.isLogIn
                                            ? "Don't have an account?"
                                            : "Already have an account?",
                                        style: AppTextStyles.overLine(
                                          color: AppColors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: authState.isLogIn
                                            ? 'Sign Up'
                                            : 'Sign In',
                                        style:
                                            AppTextStyles.overLine(
                                              color: AppColors.white,
                                            ).copyWith(
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor: AppColors.white,
                                            ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            authNotifier.toggleLogin();
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              AppSizes.xs.ph,

                              // OR CONTINUE WITH divider
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Text(
                                      'OR CONTINUE WITH',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey[300],
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),

                              AppSizes.xs.ph,

                              // Google Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: AppButton(
                                  onPressed:
                                      authState.loginState == AsyncState.loading
                                      ? null
                                      : () {
                                          authNotifier.signInWithGoogle(
                                            successCallBack: () {
                                              Log.info(
                                                "Google sign in success",
                                              );
                                            },
                                            failureCallBack: (error) {
                                              showErrorToast(content: error);
                                            },
                                          );
                                        },
                                  borderColor: AppColors.white,
                                  radius: AppSizes.xs,
                                  bgColor: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      HugeIcon(
                                        icon: HugeIcons.strokeRoundedGoogle,
                                        size: 20.0,
                                        color: Colors.white,
                                      ),
                                      AppSizes.xxs.pw,
                                      Text(
                                        'Google',
                                        style: AppTextStyles.button(
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    AppSizes.xxxs.ph,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,
      style: AppTextStyles.overLine(color: AppColors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.2),
        hintText: hintText,
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
          borderSide: const BorderSide(color: AppColors.borderBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}
