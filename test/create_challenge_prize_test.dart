import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/settings/create_challenge.dart';

class FakeGroupNotifier extends GroupNotifier {
  final GroupModel _fakeGroup;
  FakeGroupNotifier(this._fakeGroup);
  @override
  GroupState build() => GroupState(group: _fakeGroup);
}

void main() {
  final testGroup = GroupModel(
    id: 'test-group-id',
    name: 'Test Group',
    userId: 'test-owner-id',
    active: true,
  );

  Widget buildWidget() {
    return ProviderScope(
      overrides: [
        groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: CreateChallenge(),
        ),
      ),
    );
  }

  testWidgets('Shows error when 3rd prize is higher than 1st prize',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Find fields by hints:
    final firstPrizeField = find.widgetWithText(TextFormField, "e.g. \$500");
    final secondPrizeField = find.widgetWithText(TextFormField, "e.g. \$250");
    final thirdPrizeField = find.widgetWithText(TextFormField, "e.g. \$100");

    expect(firstPrizeField, findsOneWidget);
    expect(secondPrizeField, findsOneWidget);
    expect(thirdPrizeField, findsOneWidget);

    // Enter: 1st: 10, 2nd: 5, 3rd: 70
    await tester.enterText(firstPrizeField, "10");
    await tester.enterText(secondPrizeField, "5");
    await tester.enterText(thirdPrizeField, "70");
    await tester.pumpAndSettle();

    expect(find.text("3rd prize cannot be higher than 1st prize"), findsOneWidget);
  });

  testWidgets('Shows error when 2nd prize is higher than 1st prize',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final firstPrizeField = find.widgetWithText(TextFormField, "e.g. \$500");
    final secondPrizeField = find.widgetWithText(TextFormField, "e.g. \$250");
    final thirdPrizeField = find.widgetWithText(TextFormField, "e.g. \$100");

    // Enter: 1st: 10, 2nd: 30, 3rd: 5
    await tester.enterText(firstPrizeField, "10");
    await tester.enterText(secondPrizeField, "30");
    await tester.enterText(thirdPrizeField, "5");
    await tester.pumpAndSettle();

    expect(find.text("2nd prize cannot be higher than 1st prize"), findsOneWidget);
  });

  testWidgets('Shows error when both 2nd and 3rd prizes are higher than 1st prize',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final firstPrizeField = find.widgetWithText(TextFormField, "e.g. \$500");
    final secondPrizeField = find.widgetWithText(TextFormField, "e.g. \$250");
    final thirdPrizeField = find.widgetWithText(TextFormField, "e.g. \$100");

    // Enter: 1st: 10, 2nd: 30, 3rd: 70 (like the user request)
    await tester.enterText(firstPrizeField, "10");
    await tester.enterText(secondPrizeField, "30");
    await tester.enterText(thirdPrizeField, "70");
    await tester.pumpAndSettle();

    expect(find.text("2nd and 3rd prizes cannot be higher than 1st prize"), findsOneWidget);
  });

  testWidgets('Shows error when 3rd prize is higher than 2nd prize',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final firstPrizeField = find.widgetWithText(TextFormField, "e.g. \$500");
    final secondPrizeField = find.widgetWithText(TextFormField, "e.g. \$250");
    final thirdPrizeField = find.widgetWithText(TextFormField, "e.g. \$100");

    // Enter: 1st: 100, 2nd: 30, 3rd: 50
    await tester.enterText(firstPrizeField, "\$100");
    await tester.enterText(secondPrizeField, "\$30");
    await tester.enterText(thirdPrizeField, "\$50");
    await tester.pumpAndSettle();

    expect(find.text("3rd prize cannot be higher than 2nd prize"), findsOneWidget);
  });

  testWidgets('No error when prizes are descending or equal',
      (tester) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    final firstPrizeField = find.widgetWithText(TextFormField, "e.g. \$500");
    final secondPrizeField = find.widgetWithText(TextFormField, "e.g. \$250");
    final thirdPrizeField = find.widgetWithText(TextFormField, "e.g. \$100");

    // Enter: 1st: $100, 2nd: $50, 3rd: $25
    await tester.enterText(firstPrizeField, "\$100");
    await tester.enterText(secondPrizeField, "\$50");
    await tester.enterText(thirdPrizeField, "\$25");
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.error_outline), findsNothing);
  });
}
