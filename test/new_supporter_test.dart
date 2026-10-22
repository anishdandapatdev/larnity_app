import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/core/utils/async_states.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/data/models/member_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/member_provider.dart';
import 'package:larnity/src/features/group/presentation/provider/supporter_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/new_supporter.dart';

class FakeGroupNotifier extends GroupNotifier {
  final GroupModel _fakeGroup;
  FakeGroupNotifier(this._fakeGroup);
  @override
  GroupState build() => GroupState(group: _fakeGroup);
}

class FakeMemberNotifierWithMembers extends MemberNotifier {
  @override
  Future<void> fetchMembers() async {}

  @override
  MemberState build(String arg) => MemberState(
        members: const [
          MemberModel(
            id: 'm1',
            groupId: 'test-group-id',
            userId: 'u1',
            profile: {
              'firstname': 'Alice',
              'lastname': 'Smith',
              'phoneNumber': '9876543210',
            },
          ),
          MemberModel(
            id: 'm2',
            groupId: 'test-group-id',
            userId: 'u2',
            role: 'ADMIN',
            planType: 'OWNER',
            profile: {
              'firstname': 'Bob',
              'lastname': 'Jones',
              'phoneNumber': '9123456789',
            },
          ),
        ],
        fetchState: AsyncState.success,
      );
}

class FakeMemberNotifierLoading extends MemberNotifier {
  @override
  Future<void> fetchMembers() async {}

  @override
  MemberState build(String arg) => MemberState(
        members: null,
        fetchState: AsyncState.loading,
      );
}

class FakeMemberNotifierEmpty extends MemberNotifier {
  @override
  Future<void> fetchMembers() async {}

  @override
  MemberState build(String arg) => MemberState(
        members: const [],
        fetchState: AsyncState.success,
      );
}

class FakeSupporterNotifier extends SupporterNotifier {
  @override
  Future<void> fetchSupporters() async {}

  @override
  SupporterState build(String arg) =>
      SupporterState(fetchState: AsyncState.success);
}

void main() {
  final testGroup = GroupModel(
    id: 'test-group-id',
    name: 'Test Group',
    userId: 'test-owner-id',
    active: true,
  );

  testWidgets('NewSupporter dropdown lets user select a member', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
          memberProvider.overrideWith(FakeMemberNotifierWithMembers.new),
          supporterProvider.overrideWith(FakeSupporterNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NewSupporter(groupId: 'test-group-id'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final dropdownFinder = find.byType(DropdownButton<String>);
    expect(dropdownFinder, findsOneWidget);

    final dropdown = tester.widget<DropdownButton<String>>(dropdownFinder);
    expect(dropdown.items?.length, 2);

    // Tap dropdown to open
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    expect(find.text('Alice Smith'), findsWidgets);
    expect(find.text('Bob Jones'), findsWidgets);

    // Select Alice Smith
    await tester.tap(find.text('Alice Smith').last);
    await tester.pumpAndSettle();

    // Verify phone number was auto-filled
    expect(find.text('9876543210'), findsWidgets);
  });

  testWidgets('NewSupporter shows loading state while members are fetching',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
          memberProvider.overrideWith(FakeMemberNotifierLoading.new),
          supporterProvider.overrideWith(FakeSupporterNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NewSupporter(groupId: 'test-group-id'),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Loading members...'), findsOneWidget);
  });

  testWidgets('NewSupporter shows empty message when no members exist',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
          memberProvider.overrideWith(FakeMemberNotifierEmpty.new),
          supporterProvider.overrideWith(FakeSupporterNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: NewSupporter(groupId: 'test-group-id'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No members available'), findsOneWidget);

    // Tapping gives feedback rather than being dead
    await tester.tap(find.text('No members available'));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
