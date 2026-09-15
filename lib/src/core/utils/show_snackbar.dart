import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:larnity/src/core/theme/app_colors.dart';

void showSuccessToast({
  required String content,
  double? width,
  Duration duration = const Duration(seconds: 3),
}) {
  _showCustomToast(
    content: content,
    backgroundColor: AppColors.green,
    width: width,
  );
}

void showErrorToast({
  required String content,
  double? width,
  Duration duration = const Duration(seconds: 4),
}) {
  _showCustomToast(
    content: content,
    backgroundColor: AppColors.red,
    width: width,
  );
}

void showInfoToast({
  required String content,
  double? width,
  Duration duration = const Duration(seconds: 3),
}) {
  _showCustomToast(
    content: content,
    backgroundColor: AppColors.blue,
    width: width,
  );
}

void showWarningToast({
  required String content,
  double? width,
  Duration duration = const Duration(seconds: 4),
}) {
  _showCustomToast(
    content: content,
    backgroundColor: AppColors.primaryOrange,
    width: width,
  );
}

// Private helper method
void _showCustomToast({
  required String content,
  Color? backgroundColor,
  double? width,
}) {
  Fluttertoast.showToast(
    msg: content,
    toastLength: Toast.LENGTH_LONG,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: backgroundColor,
    textColor: AppColors.white,
    fontSize: 16.0,
  );
}

// Optional: Keep the original function for backward compatibility
void showToast({
  required String content,
  double? width,
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  _showCustomToast(
    content: content,
    backgroundColor: backgroundColor,
    width: width,
  );
}
