import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/features/group/data/models/group_model.dart';
import 'package:larnity/src/features/group/data/models/resource_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_resource.dart';
import 'package:larnity/src/features/group/presentation/widgets/resource_card.dart';

class FakeGroupNotifier extends GroupNotifier {
  final GroupModel _fakeGroup;
  FakeGroupNotifier(this._fakeGroup);
  @override
  GroupState build() => GroupState(group: _fakeGroup);
}

void main() {
  const testResourceWithInvalidLink = ResourceModel(
    id: 'r1',
    groupId: 'test-group-id',
    resourceName: 'tresure',
    resourceImg: '',
    resourceLink: 'ttt',
  );

  const testResourceWithEmptyLink = ResourceModel(
    id: 'r2',
    groupId: 'test-group-id',
    resourceName: 'Empty Resource',
    resourceImg: '',
    resourceLink: '',
  );

  final testGroup = GroupModel(
    id: 'test-group-id',
    name: 'Test Group',
    userId: 'test-owner-id',
    active: true,
  );

  Widget createResourceCardWidget(ResourceModel resource) {
    return ProviderScope(
      overrides: [
        isGroupAdminOrOwnerForGroupProvider.overrideWith((ref, groupId) => false),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 300,
              width: 200,
              child: ResourceCard(resource: resource),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Access button shows snackbar when resource link is invalid (e.g. ttt)', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createResourceCardWidget(testResourceWithInvalidLink));
    await tester.pumpAndSettle();

    final accessButton = find.text('Access');
    expect(accessButton, findsOneWidget);

    await tester.tap(accessButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Invalid resource link: please check the resource URL'),
      findsOneWidget,
    );
  });

  testWidgets('Access button shows snackbar when resource link is empty', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createResourceCardWidget(testResourceWithEmptyLink));
    await tester.pumpAndSettle();

    final accessButton = find.text('Access');
    expect(accessButton, findsOneWidget);

    await tester.tap(accessButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Resource link is not available'),
      findsOneWidget,
    );
  });

  testWidgets('AddResource validates that resource link must be a valid URL', (tester) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          groupProvider.overrideWith(() => FakeGroupNotifier(testGroup)),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddResource(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fill Resource Name
    await tester.enterText(find.byType(TextFormField).at(0), 'My Resource');
    // Fill invalid Resource Link
    await tester.enterText(find.byType(TextFormField).at(1), 'ttt');

    // Tap Create button
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(
      find.text('Please enter a valid website or document URL (e.g. drive.google.com/...)'),
      findsOneWidget,
    );
  });
}
