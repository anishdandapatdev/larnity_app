import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:larnity/src/core/config/cashfree_config.dart';
import 'package:larnity/src/core/error/failures.dart';
import 'package:larnity/src/core/service/payment/cashfree_models.dart';
import 'package:larnity/src/core/utils/logger.dart';

final cashfreeServiceProvider = Provider<CashfreeService>((ref) {
  return CashfreeService();
});

/// Production-ready Cashfree Payment Service.
/// Handles link creation, checkout URL generation, and status verification.
class CashfreeService {
  final HttpClient _httpClient;

  CashfreeService({HttpClient? httpClient})
      : _httpClient = httpClient ?? HttpClient();

  /// Create a dynamic Cashfree Payment Link.
  /// This generates a unique `link_url` that can be loaded in browser or webview.
  Future<Either<Failure, CashfreePaymentLinkResponse>> createPaymentLink({
    required String linkId,
    required double amount,
    required String purpose,
    required String customerId,
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    Map<String, dynamic>? notes,
  }) async {
    try {
      final url = Uri.parse('${CashfreeConfig.baseUrl}/links');
      Log.info('Cashfree: Creating payment link at $url for amount: ₹$amount');

      // Sanitize phone number (must be at least 10 digits for Cashfree)
      String cleanPhone = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.length > 10) {
        cleanPhone = cleanPhone.substring(cleanPhone.length - 10);
      }
      if (cleanPhone.length < 10) {
        cleanPhone = '9999999999';
      }

      // Sanitize notes: Cashfree requires every value in link_notes to be a String
      final Map<String, String> sanitizedNotes = {};
      if (notes != null) {
        notes.forEach((key, value) {
          if (value != null) {
            sanitizedNotes[key] = value.toString();
          }
        });
      }

      final payload = {
        'customer_details': {
          'customer_id': customerId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_'),
          'customer_name': customerName.trim().isNotEmpty ? customerName.trim() : 'Larnity Member',
          'customer_email': customerEmail.trim().isNotEmpty ? customerEmail.trim() : 'member@larnity.com',
          'customer_phone': cleanPhone,
        },
        'link_amount': amount,
        'link_currency': 'INR',
        'link_id': linkId,
        'link_purpose': purpose.length > 50 ? purpose.substring(0, 50) : purpose,
        'link_meta': {
          'return_url': 'https://www.larnity.com/payment-result?link_id={link_id}',
        },
        'link_notes': sanitizedNotes,
      };

      final request = await _httpClient.postUrl(url);
      request.headers.set('x-client-id', CashfreeConfig.clientId);
      request.headers.set('x-client-secret', CashfreeConfig.clientSecret);
      request.headers.set('x-api-version', CashfreeConfig.apiVersion);
      request.headers.set('Content-Type', 'application/json');

      final bodyBytes = utf8.encode(jsonEncode(payload));
      request.add(bodyBytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      Log.info('Cashfree response (${response.statusCode}): $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final result = CashfreePaymentLinkResponse.fromMap(data);
        return Right(result);
      } else {
        try {
          final errorData = jsonDecode(responseBody) as Map<String, dynamic>;
          final msg = errorData['message'] ?? 'Payment link creation failed';
          return Left(Failure(msg.toString()));
        } catch (_) {
          return Left(Failure('Payment gateway returned status ${response.statusCode}'));
        }
      }
    } catch (e) {
      Log.error('Cashfree createPaymentLink exception: $e');
      return Left(Failure('Unable to connect to Cashfree: ${e.toString()}'));
    }
  }

  /// Verify status of a Cashfree payment link.
  Future<Either<Failure, CashfreePaymentLinkResponse>> verifyPaymentLink({
    required String linkId,
  }) async {
    try {
      final url = Uri.parse('${CashfreeConfig.baseUrl}/links/$linkId');
      Log.info('Cashfree: Verifying payment link at $url');

      final request = await _httpClient.getUrl(url);
      request.headers.set('x-client-id', CashfreeConfig.clientId);
      request.headers.set('x-client-secret', CashfreeConfig.clientSecret);
      request.headers.set('x-api-version', CashfreeConfig.apiVersion);
      request.headers.set('Content-Type', 'application/json');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(responseBody) as Map<String, dynamic>;
        final result = CashfreePaymentLinkResponse.fromMap(data);
        return Right(result);
      } else {
        try {
          final errorData = jsonDecode(responseBody) as Map<String, dynamic>;
          final msg = errorData['message'] ?? 'Payment verification failed';
          return Left(Failure(msg.toString()));
        } catch (_) {
          return Left(Failure('Status verification returned ${response.statusCode}'));
        }
      }
    } catch (e) {
      Log.error('Cashfree verifyPaymentLink exception: $e');
      return Left(Failure('Error verifying payment: ${e.toString()}'));
    }
  }
}
