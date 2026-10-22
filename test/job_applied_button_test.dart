import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/group/data/models/job_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/job_application_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/job_card.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() {
    return AuthState(
      loginState: AsyncState.success,
      user: UserModel(id: 'test-user-id', email: 'test@example.com'),
      isAuthenticated: true,
    );
  }
}

class FakeAppliedJobNotifier extends JobApplicationNotifier {
  @override
  JobApplicationState build(String arg) => const JobApplicationState(
        applyState: AsyncState.initial,
        checkState: AsyncState.success,
        hasApplied: true,
      );

  @override
  Future<void> checkIfApplied({required String userId}) async {}
}

class FakeNotAppliedJobNotifier extends JobApplicationNotifier {
  @override
  JobApplicationState build(String arg) => const JobApplicationState(
        applyState: AsyncState.initial,
        checkState: AsyncState.success,
        hasApplied: false,
      );

  @override
  Future<void> checkIfApplied({required String userId}) async {}
}

void main() {
  final testJob = JobModel(
    id: 'job-123',
    groupId: 'group-123',
    title: 'developer',
    description: 'gh',
    createdAt: DateTime.now(),
    postingEndDate: DateTime.now().add(const Duration(days: 30)),
  );

  Widget createWidget({required bool hasApplied}) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(FakeAuthNotifier.new),
        isGroupAdminOrOwnerForGroupProvider.overrideWith((ref, groupId) => false),
        jobApplicationProvider.overrideWith(
          hasApplied
              ? FakeAppliedJobNotifier.new
              : FakeNotAppliedJobNotifier.new,
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: JobCard(job: testJob),
          ),
        ),
      ),
    );
  }

  testWidgets('When already applied, clicking Applied button displays feedback bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget(hasApplied: true));
    await tester.pumpAndSettle();

    // Verify "✓ Applied" button is rendered
    final appliedButton = find.text('✓ Applied');
    expect(appliedButton, findsOneWidget);

    // Tap the Applied button
    await tester.tap(appliedButton);
    await tester.pumpAndSettle();

    // Verify the bottom sheet opens with clear indication
    expect(find.text('Application Submitted'), findsOneWidget);
    expect(find.text('APPLIED'), findsOneWidget);
    expect(
      find.text('You have already applied for this position. The job poster will review your submission and profile.'),
      findsOneWidget,
    );
    expect(find.text('Got it'), findsOneWidget);

    // Dismiss bottom sheet via "Got it"
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    // Bottom sheet should be dismissed
    expect(find.text('Application Submitted'), findsNothing);
  });

  testWidgets('When not applied, clicking Apply Now opens apply bottom sheet', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createWidget(hasApplied: false));
    await tester.pumpAndSettle();

    // Verify "Apply Now" button is rendered
    final applyNowButton = find.text('Apply Now');
    expect(applyNowButton, findsOneWidget);

    // Tap the Apply Now button
    await tester.tap(applyNowButton);
    await tester.pumpAndSettle();

    // Verify apply sheet opens
    expect(find.text('Submit Application'), findsOneWidget);
  });
}
