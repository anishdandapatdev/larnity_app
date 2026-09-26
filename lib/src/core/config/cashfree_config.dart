import 'package:larnity/src/core/env/env.dart';

/// Configuration class for Cashfree Payment Gateway integration.
class CashfreeConfig {
  /// Cashfree API Version
  static const String apiVersion = '2023-08-01';

  /// Returns Client ID from environment or secure config
  static String get clientId {
    const fromEnv = String.fromEnvironment('CASHFREE_CLIENT_ID');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppEnv.cashfreeClientId;
  }

  /// Returns Client Secret from environment or secure config
  static String get clientSecret {
    const fromEnv = String.fromEnvironment('CASHFREE_CLIENT_SECRET');
    if (fromEnv.isNotEmpty) return fromEnv;
    return AppEnv.cashfreeClientSecret;
  }

  /// Determines whether the current environment is Sandbox (Test) or Production
  static bool get isSandbox {
    return clientId.startsWith('TEST');
  }

  /// Returns the appropriate Cashfree API Base URL
  static String get baseUrl {
    return isSandbox
        ? 'https://sandbox.cashfree.com/pg'
        : 'https://api.cashfree.com/pg';
  }
}
