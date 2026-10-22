import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:larnity/src/core/service/cache/user_cache_service.dart';
import 'package:larnity/src/features/auth/data/models/user_model.dart';
import 'package:larnity/src/features/auth/presentation/provider/auth_provider.dart';
import 'package:larnity/src/features/profile/presentation/provider/profile_provider.dart';
import 'package:larnity/src/features/profile/presentation/view/profile_settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeUserCacheService extends UserCacheService {
  @override
  Future<Map<String, String?>> getCachedProfile() async {
    return {
      'firstName': 'Anish',
      'lastName': 'Dandapat',
      'phoneNumber': '+91 98765 43210',
    };
  }
}

class FakeAuthNotifier extends AuthNotifier {
  final UserModel? _user;
  FakeAuthNotifier(this._user);

  @override
  AuthState build() => AuthState(user: _user);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  final testUser = UserModel(
    id: 'test-user-id',
    email: 'test@example.com',
    firstName: 'Anish',
    lastName: 'Dandapat',
    role: 'USER',
    phoneNumber: '+91 98765 43210',
  );

  Widget buildScreen() {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(() => FakeAuthNotifier(testUser)),
        userCacheServiceProvider.overrideWithValue(FakeUserCacheService()),
      ],
      child: const MaterialApp(
        home: ProfileSettingsScreen(),
      ),
    );
  }

  testWidgets(
      'Digits are stripped from First Name and Last Name fields in Profile Edit',
      (tester) async {
    await tester.pumpWidget(buildScreen());
    await tester.pumpAndSettle();

    // Find the First Name and Last Name text fields
    final firstNameField = find.widgetWithText(TextFormField, "First name");
    final lastNameField = find.widgetWithText(TextFormField, "Last name");

    expect(firstNameField, findsOneWidget);
    expect(lastNameField, findsOneWidget);

    // Try typing digits '47746899' into First Name
    await tester.enterText(firstNameField, '47746899');
    await tester.pumpAndSettle();

    // The text field should reject digits and remain empty (or stripped)
    final firstNameWidget = tester.widget<TextFormField>(firstNameField);
    expect(firstNameWidget.controller?.text, equals(''));

    // Try typing mixed letters and digits 'John123'
    await tester.enterText(firstNameField, 'John123');
    await tester.pumpAndSettle();

    // The digits should be stripped, only 'John' accepted
    expect(firstNameWidget.controller?.text, equals('John'));

    // Try typing special characters and digits into First Name
    await tester.enterText(firstNameField, 'Mary@#123 Jane!');
    await tester.pumpAndSettle();
    expect(firstNameWidget.controller?.text, equals('Mary Jane'));

    // Try typing digits '987' into Last Name
    await tester.enterText(lastNameField, '987');
    await tester.pumpAndSettle();

    final lastNameWidget = tester.widget<TextFormField>(lastNameField);
    expect(lastNameWidget.controller?.text, equals(''));

    // Try typing valid letters and space into Last Name
    await tester.enterText(lastNameField, 'Doe Smith');
    await tester.pumpAndSettle();
    expect(lastNameWidget.controller?.text, equals('Doe Smith'));
  });

  test('ProfileNotifier.createProfile rejects user with digits in first or last name',
      () async {
    final container = ProviderContainer(
      overrides: [
        authProvider.overrideWith(() => FakeAuthNotifier(testUser)),
      ],
    );
    addTearDown(container.dispose);

    String? errorReceived;

    // Test with digits in first name
    await container.read(profileProvider.notifier).createProfile(
      user: testUser.copyWith(firstName: '47746899'),
      failureCallBack: (err) {
        errorReceived = err;
      },
    );

    expect(errorReceived, equals('First name can only contain letters'));

    // Test with digits in last name
    errorReceived = null;
    await container.read(profileProvider.notifier).createProfile(
      user: testUser.copyWith(firstName: 'John', lastName: '1234'),
      failureCallBack: (err) {
        errorReceived = err;
      },
    );

    expect(errorReceived, equals('Last name can only contain letters'));
  });
}
