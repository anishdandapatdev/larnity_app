part of 'router.dart';

class Routes {
  static const String explore = 'explore';
  static const String auth = 'auth';
  static const String notification = 'notification';
  static const String packageSubscription = 'package-subscription';
  static const String package = 'package';
  static const String packageDetails = 'package-details';
  static const String groupDetails = 'group-details';
  static const String group = 'group';
  static const String generalSettings = 'general-settings';
  static const String subscriptionSettings = 'subscription-settings';
  static const String paymentSettings = 'payment-settings';
  static const String offerSettings = 'offer-settings';
  static const String challengeSettings = 'challenge-settings';
  static const String integrationSettings = 'integration-settings';
  static const String promoCodeSettings = 'promo-code-settings';
  static const String memberManagementSettings = 'member-management-settings';
  static const String leaveReasonsSettings = 'leave-reasons-settings';
  static const String managerSettings = 'manager-settings';
  static const String profileSettings = 'profile-settings';
  static const String purchaseCourse = 'purchase-course';
  static const String createGroup = 'create-group';
  static const String chatting = 'chatting';
  static const String choosePlan = 'choose-plan';
  static const String payment = 'payment';
  static const String forgotPassword = 'forgot-password';
  static const String changePassword = 'change-password';

  // Room Routes
  static const String discussionRoom = 'discussion-room';
  static const String classRoom = 'class-room';
  static const String liveClassRoom = 'live-class-room';
  static const String eventRoom = 'event-room';
  static const String membersRoom = 'members-room';
  static const String doubtRoom = 'doubt-room';
  static const String challengeRoom = 'challenge-room';
  static const String treasureRoom = 'treasure-room';
  static const String productRoom = 'product-room';
  static const String serviceRoom = 'service-room';
  static const String jobRoom = 'job-room';
  static const String courseDetail = 'course-detail';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  // final authNotifier = ref.read(authProvider.notifier);
  return GoRouter(
    refreshListenable: GoRouterRefreshStream(
      ref.watch(supabaseClientProvider).auth.onAuthStateChange,
    ),
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation == Routes.auth.p;
      final isExploreRoute = state.matchedLocation == Routes.explore.p;

      Log.info("Is Logged in: $isLoggedIn (location: ${state.matchedLocation})");

      // If the user is not logged in and trying to access explore, redirect to auth
      if (!isLoggedIn && isExploreRoute) {
        return Routes.auth.p;
      }

      // If the user is logged in and on the login route, redirect to explore
      if (isLoggedIn && isAuthRoute) {
        return Routes.explore.p;
      }

      // No redirection needed
      return null;
    },
    initialLocation: Routes.explore.p,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => Routes.explore.p, // Redirect to explore
      ),
      _buildExploreShellRoutes(),
      _buildAuthScreenRoute(),
      _buildForgotPasswordScreenRoute(),
      _buildChangePasswordScreenRoute(),
      _buildNotificationScreenRoute(),
      _buildGroupShellRoutes(),
      _buildCourseDetailScreenRoute(),
      _buildJobRoomScreenRoute(),
    ],
  );
});

// Helper class to convert Stream to ChangeNotifier for GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

StatefulShellRoute _buildGroupShellRoutes() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return GroupNavBar(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(routes: [_buildGroupScreenRoute()]),
      StatefulShellBranch(routes: [_buildDiscussionRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildClassRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildLiveClassRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildEventRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildMembersRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildDoubtRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildChallengeRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildTreasureRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildProductRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildServiceRoomScreenRoute()]),
      StatefulShellBranch(routes: [_buildSubscriptionSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildPaymentSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildOfferSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildChallengeSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildIntegrationSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildPromoCodeSettingsScreenRoute()]),
      StatefulShellBranch(
        routes: [_buildMemberManagementSettingsScreenRoute()],
      ),
      StatefulShellBranch(routes: [_buildLeaveReasonsSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildManagerSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildGeneralSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildChattingScreenRoute()]),
    ],
  );
}

StatefulShellRoute _buildExploreShellRoutes() {
  return StatefulShellRoute.indexedStack(
    builder: (context, state, navigationShell) {
      return ExploreNestedRoute(navigationShell: navigationShell);
    },
    branches: [
      StatefulShellBranch(routes: [_buildExploreScreenRoute()]),
      StatefulShellBranch(routes: [_buildPurchaseCourseScreenRoute()]),
      StatefulShellBranch(routes: [_buildCreateGroupScreenRoute()]),
      StatefulShellBranch(routes: [_buildProfileSettingsScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageSubscriptionScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageScreenRoute()]),
      StatefulShellBranch(routes: [_buildPackageDetailsScreenRoute()]),
      StatefulShellBranch(routes: [_buildGroupDetailsScreenRoute()]),
      StatefulShellBranch(routes: [_buildChoosePlanScreenRoute()]),
      StatefulShellBranch(routes: [_buildPaymentScreenRoute()]),
    ],
  );
}

GoRoute _buildExploreScreenRoute() => GoRoute(
  name: Routes.explore,
  path: Routes.explore.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ExploreScreen(),
  ),
);

GoRoute _buildPurchaseCourseScreenRoute() => GoRoute(
  name: Routes.purchaseCourse,
  path: Routes.purchaseCourse.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const PurchaseCourseScreen(),
  ),
);

GoRoute _buildCreateGroupScreenRoute() => GoRoute(
  name: Routes.createGroup,
  path: Routes.createGroup.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const CreateGroupScreen(),
  ),
);

GoRoute _buildNotificationScreenRoute() => GoRoute(
  name: Routes.notification,
  path: Routes.notification.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => NotificationScreen(),
  ),
);

GoRoute _buildPackageSubscriptionScreenRoute() => GoRoute(
  name: Routes.packageSubscription,
  path: Routes.packageSubscription.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PackageSubscriptionScreen(),
  ),
);

GoRoute _buildPackageScreenRoute() => GoRoute(
  name: Routes.package,
  path: Routes.package.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PackageScreen(),
  ),
);

GoRoute _buildPackageDetailsScreenRoute() => GoRoute(
  name: Routes.packageDetails,
  path: Routes.packageDetails.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) {
      final package = state.extra as PackageModel?;
      if (package == null) {
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Learning Content Found',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return PackageDetailsScreen(package: package);
    },
  ),
);

GoRoute _buildGroupDetailsScreenRoute() => GoRoute(
  name: Routes.groupDetails,
  path: Routes.groupDetails.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => GroupDetailsScreen(
      group: state.extra as GroupModel?,
    ),
  ),
);

GoRoute _buildGroupScreenRoute() => GoRoute(
  name: Routes.group,
  path: Routes.group.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => GroupHomeScreen(),
  ),
);

GoRoute _buildDiscussionRoomScreenRoute() => GoRoute(
  name: Routes.discussionRoom,
  path: Routes.discussionRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => DiscussionRoomScreen(),
  ),
);

GoRoute _buildClassRoomScreenRoute() => GoRoute(
  name: Routes.classRoom,
  path: Routes.classRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ClassRoomScreen(),
  ),
);

GoRoute _buildLiveClassRoomScreenRoute() => GoRoute(
  name: Routes.liveClassRoom,
  path: Routes.liveClassRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => LiveClassRoomScreen(),
  ),
);

GoRoute _buildEventRoomScreenRoute() => GoRoute(
  name: Routes.eventRoom,
  path: Routes.eventRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => EventRoomScreen(),
  ),
);

GoRoute _buildMembersRoomScreenRoute() => GoRoute(
  name: Routes.membersRoom,
  path: Routes.membersRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => MembersRoomScreen(),
  ),
);

GoRoute _buildDoubtRoomScreenRoute() => GoRoute(
  name: Routes.doubtRoom,
  path: Routes.doubtRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => DoubtRoomScreen(),
  ),
);

GoRoute _buildChallengeRoomScreenRoute() => GoRoute(
  name: Routes.challengeRoom,
  path: Routes.challengeRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ChallengeRoomScreen(),
  ),
);

GoRoute _buildTreasureRoomScreenRoute() => GoRoute(
  name: Routes.treasureRoom,
  path: Routes.treasureRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => TreasureRoomScreen(),
  ),
);

GoRoute _buildProductRoomScreenRoute() => GoRoute(
  name: Routes.productRoom,
  path: Routes.productRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ProductRoomScreen(),
  ),
);

GoRoute _buildServiceRoomScreenRoute() => GoRoute(
  name: Routes.serviceRoom,
  path: Routes.serviceRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ServiceRoomScreen(),
  ),
);

GoRoute _buildCourseDetailScreenRoute() => GoRoute(
  name: Routes.courseDetail,
  path: Routes.courseDetail.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) {
      final extra = state.extra as Map<String, dynamic>;
      return CourseDetailScreen(
        courseId: extra['courseId'] as String,
        courseName: extra['courseName'] as String,
      );
    },
  ),
);

GoRoute _buildJobRoomScreenRoute() => GoRoute(
  name: Routes.jobRoom,
  path: Routes.jobRoom.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => JobRoomScreen(),
  ),
);

GoRoute _buildGeneralSettingsScreenRoute() => GoRoute(
  name: Routes.generalSettings,
  path: Routes.generalSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => GeneralSettingsScreen(),
  ),
);

GoRoute _buildSubscriptionSettingsScreenRoute() => GoRoute(
  name: Routes.subscriptionSettings,
  path: Routes.subscriptionSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => SubscriptionSettingsScreen(),
  ),
);

GoRoute _buildPaymentSettingsScreenRoute() => GoRoute(
  name: Routes.paymentSettings,
  path: Routes.paymentSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PaymentSettingsScreen(),
  ),
);

GoRoute _buildOfferSettingsScreenRoute() => GoRoute(
  name: Routes.offerSettings,
  path: Routes.offerSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => OfferSettingsScreen(),
  ),
);

GoRoute _buildChallengeSettingsScreenRoute() => GoRoute(
  name: Routes.challengeSettings,
  path: Routes.challengeSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ChallengeSettingsScreen(),
  ),
);

GoRoute _buildIntegrationSettingsScreenRoute() => GoRoute(
  name: Routes.integrationSettings,
  path: Routes.integrationSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => IntegrationSettingsScreen(),
  ),
);

GoRoute _buildPromoCodeSettingsScreenRoute() => GoRoute(
  name: Routes.promoCodeSettings,
  path: Routes.promoCodeSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => PromoCodeSettingsScreen(),
  ),
);

GoRoute _buildMemberManagementSettingsScreenRoute() => GoRoute(
  name: Routes.memberManagementSettings,
  path: Routes.memberManagementSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => MemberManagementScreen(),
  ),
);

GoRoute _buildLeaveReasonsSettingsScreenRoute() => GoRoute(
  name: Routes.leaveReasonsSettings,
  path: Routes.leaveReasonsSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => LeaveReasonScreen(),
  ),
);

GoRoute _buildManagerSettingsScreenRoute() => GoRoute(
  name: Routes.managerSettings,
  path: Routes.managerSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ManagerSettingsScreen(),
  ),
);

GoRoute _buildProfileSettingsScreenRoute() => GoRoute(
  name: Routes.profileSettings,
  path: Routes.profileSettings.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ProfileSettingsScreen(),
  ),
);

GoRoute _buildChattingScreenRoute() => GoRoute(
  name: Routes.chatting,
  path: Routes.chatting.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => ChattingScreen(),
  ),
);
GoRoute _buildAuthScreenRoute() => GoRoute(
  name: Routes.auth,
  path: Routes.auth.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => AuthScreen(),
  ),
);

GoRoute _buildForgotPasswordScreenRoute() => GoRoute(
  name: Routes.forgotPassword,
  path: Routes.forgotPassword.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) {
      final email = state.extra as String?;
      return ForgotPasswordScreen(prefillEmail: email);
    },
  ),
);

GoRoute _buildChangePasswordScreenRoute() => GoRoute(
  name: Routes.changePassword,
  path: Routes.changePassword.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const ChangePasswordScreen(),
  ),
);

GoRoute _buildChoosePlanScreenRoute() => GoRoute(
  name: Routes.choosePlan,
  path: Routes.choosePlan.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const ChoosePlanScreen(),
  ),
);

GoRoute _buildPaymentScreenRoute() => GoRoute(
  name: Routes.payment,
  path: Routes.payment.p,
  pageBuilder: _getDefaultPageBuilderByPlatform(
    childBuilder: (_, state) => const PaymentScreen(),
  ),
);

//-------- Platform Wrapper-----------//

GoRouterPageBuilder _getDefaultPageBuilderByPlatform({
  required Widget Function(BuildContext context, GoRouterState goRouterState)
  childBuilder,
}) =>
    (context, goRouterState) =>
        _getPageByPlatform(child: childBuilder(context, goRouterState));

Page<T> _getPageByPlatform<T>({required Widget child}) {
  if (kIsWeb) {
    return MaterialPage(child: child);
  } else {
    if (Platform.isAndroid) {
      return MaterialPage(child: child);
    }
    if (Platform.isIOS) {
      return CupertinoPage(child: child);
    }
    return MaterialPage(child: child);
  }
}
