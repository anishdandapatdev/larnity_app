import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/features/group/data/models/product_model.dart';
import 'package:larnity/src/features/group/presentation/provider/group_provider.dart';
import 'package:larnity/src/features/group/presentation/widgets/add_service.dart';
import 'package:larnity/src/features/group/presentation/widgets/service_card.dart';

void main() {
  const testServiceWithPlus = ProductModel(
    id: 's1',
    name: 'Consulting',
    description: 'Expert consulting',
    price: 500,
    whatsappNumber: '+91919919191',
    imageUrl: '',
    groupId: 'group-1',
    type: 'SERVICE',
    rating: 5,
  );

  const testServiceWithEmptyNumber = ProductModel(
    id: 's2',
    name: 'Design Service',
    description: 'UI/UX design',
    price: 300,
    whatsappNumber: '',
    imageUrl: '',
    groupId: 'group-1',
    type: 'SERVICE',
    rating: 4,
  );

  Widget createServiceCardWidget(ProductModel service) {
    return ProviderScope(
      overrides: [
        isGroupAdminOrOwnerForGroupProvider.overrideWith((ref, groupId) => false),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              height: 400,
              width: 250,
              child: ServiceCard(service: service),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Buy Now handles existing +91 test number without throwing', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createServiceCardWidget(testServiceWithPlus));
    await tester.pumpAndSettle();

    final buyNowButton = find.text('Buy Now');
    expect(buyNowButton, findsOneWidget);

    // Tapping Buy Now executes sanitized _launchWhatsApp
    await tester.tap(buyNowButton);
    await tester.pumpAndSettle();

    // No unhandled exceptions thrown
    expect(tester.takeException(), isNull);
  });

  testWidgets('Buy Now shows snackbar if WhatsApp number is empty', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createServiceCardWidget(testServiceWithEmptyNumber));
    await tester.pumpAndSettle();

    final buyNowButton = find.text('Buy Now');
    expect(buyNowButton, findsOneWidget);

    await tester.tap(buyNowButton);
    await tester.pumpAndSettle();

    expect(find.text('WhatsApp contact number is not available'), findsOneWidget);
  });

  testWidgets('AddService validates that WhatsApp number must have 10 digits', (tester) async {
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddService(groupId: 'group-1'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Fill Name
    await tester.enterText(find.byType(TextFormField).at(0), 'New Service');
    // Fill Description
    await tester.enterText(find.byType(TextFormField).at(1), 'New Description');
    // Fill Price
    await tester.enterText(find.byType(TextFormField).at(2), '100');
    // Fill WhatsApp with incomplete 9 digits
    await tester.enterText(find.byType(TextFormField).at(4), '919919191');

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid 10-digit WhatsApp number'), findsOneWidget);
  });
}
