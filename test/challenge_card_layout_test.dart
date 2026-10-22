import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/models/challenge_model.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/challenge_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/views/challenge_room_screen.dart';

class FakeGroupNotifier extends GroupNotifier {
  final GroupModel _fakeGroup;
  FakeGroupNotifier(this._fakeGroup);
  @override
  GroupState build() => GroupState(group: _fakeGroup);
}

final List<ChallengeModel> _testChallenges = [
  const ChallengeModel(
    id: 'c1',
    groupId: 'test-group-id',
    title: 'ftrff',
    description: 'hgujh',
    status: 'REGISTRATION_OPEN',
    type: 'PAID',
    price: 50.00,
    prize: '1st: 10, 2nd: 30, 3rd: 70',
  ),
];

class FakeChallengeNotifier extends ChallengeNotifier {
  @override
  Future<void> fetchChallenges({String? status, String? type}) async {}

  @override
  Future<void> fetchStats() async {}

  @override
  ChallengeState build(String arg) {
    return ChallengeState(
      fetchState: AsyncState.success,
      challenges: _testChallenges,
      stats: {
        'total': _testChallenges.length,
        'active': _testChallenges.where((c) => c.status == 'REGISTRATION_OPEN').length,
        'live': _testChallenges.where((c) => c.status == 'LIVE').length,
      },
    );
  }
}

void main() {
  final testGroup = GroupModel(
    id: 'test-group-id',
    name: 'Test Group',
    userId: 'test-owner-id',
    active: true,
  );

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
        challengeProvider.overrideWith(FakeChallengeNotifier.new),
        isGroupAdminOrOwnerProvider.overrideWith((ref) => true),
      ],
      child: const MaterialApp(
        home: ChallengeRoomScreen(),
      ),
    );
  }

  testWidgets(
      'Challenge card displays completely without horizontal overflow on small screen',
      (tester) async {
    // Standard phone screen size (360x740)
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Verify stat boxes render without overflow
    expect(find.text("Total Challenges"), findsOneWidget);
    expect(find.text("Active"), findsOneWidget);
    expect(find.text("Live Now"), findsOneWidget);

    // Verify challenge card contents
    expect(find.text('ftrff'), findsOneWidget);
    expect(find.text('REGISTRATION_OPEN'), findsOneWidget);
    expect(find.text('hgujh'), findsOneWidget);
    expect(find.text('\$50.00'), findsOneWidget);
    expect(find.text('Prize: 1st: 10, 2nd: 30, 3rd: 70'), findsOneWidget);

    // Scroll until "View Challenge" button is visible and fully rendered
    final viewChallengeButton = find.text('View Challenge');
    await tester.scrollUntilVisible(
      viewChallengeButton,
      100,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(viewChallengeButton, findsOneWidget);

    // Tap "View Challenge" button to ensure modal opens without overflow
    await tester.tap(viewChallengeButton);
    await tester.pumpAndSettle();

    // In bottom sheet, verify chips are present
    expect(find.text('Registration: \$50.00'), findsOneWidget);
    expect(find.text('Prize: 1st: 10, 2nd: 30, 3rd: 70'), findsNWidgets(2));
    expect(find.text('Register Now'), findsOneWidget);
  });
}
