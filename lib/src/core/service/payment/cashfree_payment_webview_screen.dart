import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:larnity/src/core/config/cashfree_config.dart';
import 'package:larnity/src/core/constants/app_size.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/router/router.dart';
import 'package:larnity/src/core/service/payment/cashfree_models.dart';
import 'package:larnity/src/core/service/payment/cashfree_service.dart';
import 'package:larnity/src/core/service/supabase/src/supabase_provider.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/theme/theme.dart';
import 'package:larnity/src/core/utils/logger.dart';
import 'package:larnity/src/core/utils/show_snackbar.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/datasource/member_datasource.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/package/data/model/package_model.dart';
import 'package:larnity/src/features/package_subscription/data/model/package_subscription_model.dart';
import 'package:larnity/src/features/package_subscription/presentation/providers/package_subscription_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-App Cashfree Payment WebView Screen.
/// Loads the Cashfree checkout page directly inside the app without opening an external browser.
class CashfreePaymentWebViewScreen extends ConsumerStatefulWidget {
  final GroupModel? group;
  final PackageModel? package;
  final String planName;
  final int amountINR;
  final CashfreePaymentLinkResponse linkResponse;
  final Map<String, dynamic>? appliedPromo;
  final Future<void> Function()? onPaymentSuccess;

  const CashfreePaymentWebViewScreen({
    super.key,
    this.group,
    this.package,
    required this.planName,
    required this.amountINR,
    required this.linkResponse,
    this.appliedPromo,
    this.onPaymentSuccess,
  });

  @override
  ConsumerState<CashfreePaymentWebViewScreen> createState() =>
      _CashfreePaymentWebViewScreenState();
}

class _CashfreePaymentWebViewScreenState
    extends ConsumerState<CashfreePaymentWebViewScreen> {
  InAppWebViewController? _webViewController;
  double _progress = 0;
  bool _isSuccess = false;
  bool _isVerifying = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _startBackgroundPolling();
  }

  void _startBackgroundPolling() {
    // Poll Cashfree link status in background every 4 seconds
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_isSuccess || _isVerifying) return;
      _checkPaymentStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    try {
      _webViewController?.stopLoading();
      _webViewController?.pause();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _safePop() async {
    _pollTimer?.cancel();
    try {
      await _webViewController?.stopLoading();
      await _webViewController?.pause();
    } catch (_) {}
    if (mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _checkPaymentStatus() async {
    final res = await ref
        .read(cashfreeServiceProvider)
        .verifyPaymentLink(linkId: widget.linkResponse.linkId);

    if (!mounted) return;

    res.fold(
      (_) {},
      (statusRes) {
        if (statusRes.isPaid && !_isSuccess) {
          _pollTimer?.cancel();
          _handlePaymentSuccess();
        }
      },
    );
  }

  Future<void> _handlePaymentSuccess() async {
    if (_isSuccess) return;
    setState(() {
      _isSuccess = true;
      _isVerifying = false;
    });

    final user = ref.read(authProvider).user;
    if (user == null || user.id == null) return;

    // Increment promo uses if applied
    if (widget.appliedPromo != null && widget.appliedPromo!['id'] != null) {
      try {
        final client = ref.read(supabaseClientProvider);
        final currentUses =
            (widget.appliedPromo!['currentUses'] as num?)?.toInt() ?? 0;
        await client
            .from('PromoCode')
            .update({'currentUses': currentUses + 1})
            .eq('id', widget.appliedPromo!['id']);
      } catch (_) {}
    }

    if (widget.onPaymentSuccess != null) {
      await widget.onPaymentSuccess!();
    } else if (widget.package != null) {
      final now = DateTime.now();
      final endDate = widget.package!.isFree
          ? now.add(Duration(days: widget.package!.freeTrialDays ?? 30))
          : now.add(const Duration(days: 30));

      await ref
          .read(packageSubscriptionProvider.notifier)
          .createPackageSubscription(
            subscription: PackageSubscriptionModel(
              userId: user.id!,
              packageId: widget.package!.id,
              subscriptionStartDate: now,
              subscriptionEndDate: endDate,
              isActive: true,
              totalGroupsCreated: 0,
            ),
          );

      if (!mounted) return;

      // Small delay to show celebratory green checkmark
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop(true);
      showSuccessToast(
        content: "🎉 ${widget.package!.name} activated successfully!",
      );
      context.goNamed(Routes.packageSubscription);
      return;
    } else if (widget.group != null) {
      final groupId = widget.group!.id;
      if (groupId != null && groupId.isNotEmpty) {
        final now = DateTime.now();
        final isYearly = widget.planName.toLowerCase().contains('yearly');
        final isLifetime = widget.planName.toLowerCase().contains('lifetime');
        final endDate = isLifetime
            ? null
            : (isYearly
                ? now.add(const Duration(days: 365))
                : now.add(const Duration(days: 30)));

        final member = MemberModel(
          groupId: groupId,
          userId: user.id!,
          subscriptionStartDate: now,
          subscriptionEndDate: endDate,
          isActive: true,
          planType: widget.planName,
          planPrice: widget.amountINR.toDouble(),
          role: 'MEMBER',
        );

        // Enroll member into Supabase
        await ref.read(memberDataSourceProvider).addOrUpdateMember(member: member);

        // Refresh user's groups
        ref.read(groupProvider.notifier).refreshGroupsForCurrentUser();

        if (!mounted) return;

        // Small delay to show celebratory green checkmark
        await Future.delayed(const Duration(milliseconds: 1500));
        if (!mounted) return;

        Navigator.of(context, rootNavigator: true).pop(true); // Close webview screen
        showSuccessToast(
          content: "🎉 Welcome to ${widget.group!.name}! Membership activated.",
        );

        ref.read(groupProvider.notifier).setSelectedGroup(widget.group!);
        context.pushNamed(Routes.group);
        return;
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_isSuccess) return true;

    try {
      await _webViewController?.pause();
    } catch (_) {}

    if (!mounted) return true;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkBgContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Cancel Payment?",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to exit the payment screen?",
          style: TextStyle(color: AppColors.creamWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text("Continue Payment", style: TextStyle(color: AppColors.primaryOrange)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text("Exit", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );

    if (shouldCancel != true) {
      try {
        await _webViewController?.resume();
      } catch (_) {}
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          await _safePop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.black,
        appBar: AppBar(
          backgroundColor: AppColors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.white),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                await _safePop();
              }
            },
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Cashfree Checkout",
                    style: AppTextStyles.subtitle1(color: AppColors.white).copyWith(
                      fontWeight: AppFontWeights.bold,
                    ),
                  ),
                  if (CashfreeConfig.isSandbox) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.6)),
                      ),
                      child: const Text(
                        "TEST",
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                "${widget.group?.name ?? widget.package?.name ?? widget.planName} • ₹${widget.amountINR}",
                style: AppTextStyles.overLine(
                  color: AppColors.creamWhite.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.creamWhite),
              tooltip: "Reload",
              onPressed: () => _webViewController?.reload(),
            ),
          ],
        ),
        body: Stack(
          children: [
            // Embedded In-App WebView
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri(widget.linkResponse.linkUrl),
              ),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: true,
                javaScriptEnabled: true,
                domStorageEnabled: true,
                supportZoom: false,
                clearCache: false,
                useHybridComposition: false, // TextureView rendering eliminates Android transition stutter
                hardwareAcceleration: true,
                transparentBackground: true,
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
              onProgressChanged: (controller, progress) {
                setState(() {
                  _progress = progress / 100;
                });
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final uri = navigationAction.request.url;
                if (uri == null) return NavigationActionPolicy.ALLOW;

                final urlString = uri.toString();
                Log.info("Cashfree InAppWebView URL: $urlString");

                // Launch external UPI apps (Google Pay, PhonePe, Paytm, etc.)
                if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
                  try {
                    final launched = await launchUrl(
                      Uri.parse(urlString),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!launched) {
                      showErrorToast(content: "Could not open UPI payment app");
                    }
                  } catch (e) {
                    Log.error("Error opening UPI scheme: $e");
                  }
                  return NavigationActionPolicy.CANCEL;
                }

                // Check for return / success URL
                if (urlString.contains('payment-result') ||
                    urlString.contains('return_url') ||
                    urlString.contains('payment/success') ||
                    urlString.contains('cf_status=SUCCESS')) {
                  _checkPaymentStatus();
                  return NavigationActionPolicy.CANCEL;
                }

                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                if (url != null) {
                  final urlStr = url.toString();
                  if (urlStr.contains('payment-result') ||
                      urlStr.contains('payment/success') ||
                      urlStr.contains('cf_status=SUCCESS')) {
                    _checkPaymentStatus();
                  }
                }
              },
            ),

            // Top Linear Progress Bar
            if (_progress < 1.0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primaryOrange,
                  ),
                  minHeight: 2.5,
                ),
              ),

            // Success Overlay
            if (_isSuccess)
              Container(
                color: AppColors.black.withValues(alpha: 0.95),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green.withValues(alpha: 0.2),
                          border: Border.all(color: AppColors.green, width: 2.5),
                        ),
                        child: const Center(
                          child: Icon(Icons.check_circle_rounded,
                              color: AppColors.green, size: 52),
                        ),
                      ),
                      AppSizes.sm.ph,
                      Text(
                        "Payment Successful!",
                        style: AppTextStyles.headline4(color: AppColors.white).copyWith(
                          fontWeight: AppFontWeights.bold,
                        ),
                      ),
                      AppSizes.xxs.ph,
                      Text(
                        widget.package != null
                            ? "Upgraded to ${widget.package!.name}"
                            : "Welcome to ${widget.group?.name ?? widget.planName}",
                        style: AppTextStyles.bodyText2(
                          color: AppColors.creamWhite.withValues(alpha: 0.8),
                        ),
                      ),
                      AppSizes.md.ph,
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                        strokeWidth: 2,
                      ),
                      AppSizes.xs.ph,
                      Text(
                        widget.package != null
                            ? "Activating package subscription..."
                            : "Opening community...",
                        style: AppTextStyles.overLine(
                          color: AppColors.creamWhite.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        bottomNavigationBar: CashfreeConfig.isSandbox
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFF1E1705),
                child: SafeArea(
                  child: Row(
                    children: [
                      const Icon(Icons.bug_report, color: Colors.amber, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Sandbox Test Mode",
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _handlePaymentSuccess,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "Simulate Success",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
