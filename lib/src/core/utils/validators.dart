String? validateEmail(String? value, String? fieldName) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? 'Email'} is required';
  }
  const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  final regex = RegExp(emailPattern);
  if (!regex.hasMatch(value)) {
    return 'Enter a valid email';
  }
  return null;
}

String? validatePhoneNumber(String? value, String? fieldName) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? 'Phone number'} is required';
  }

  // Pattern: +<digits> <digits> — space is required between code and number
  const phonePattern = r'^\+\d{1,4}\s\d{4,14}$';
  final regex = RegExp(phonePattern);

  if (!regex.hasMatch(value)) {
    return 'Enter a valid ${fieldName ?? 'Phone number'} (e.g. +91 9876543210)';
  }

  return null;
}

String? validatePassword(String? value, String? fieldName) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? 'Password'} is required';
  }
  if (value.length < 6) {
    return '${fieldName ?? 'Password'} must be at least 6 characters long';
  }
  if (!RegExp('[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter';
  }
  if (!RegExp('[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter';
  }
  if (!RegExp('[0-9]').hasMatch(value)) {
    return 'Password must contain at least one digit';
  }
  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
    return 'Password must contain at least one special character';
  }
  return null;
}

String? validateName(String? value, String? fieldName) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? 'Name'} is required';
  }
  if (value.length < 2) {
    return '${fieldName ?? 'Name'} must be at least 2 characters long';
  }
  if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
    return "${fieldName ?? 'Name'} must contain only letters, spaces, or valid characters (' and -)";
  }
  return null;
}

String? validateNameNumber(String? value, String? fieldName) {
  if (value == null || value.isEmpty) {
    return '${fieldName ?? 'Name'} is required';
  }
  if (value.length < 2) {
    return '${fieldName ?? 'Name'} must be at least 2 characters long';
  }
  // if (!RegExp(r"^[a-zA-Z\s'-]+$").hasMatch(value)) {
  //   return "${fieldName ?? 'Name'} must contain only letters, spaces, or valid characters (' and -)";
  // }
  return null;
}

String? cardNumberValidator(String? value) {
  if (value == null || value.isEmpty) return 'Card number is required';

  final digitsOnly = value.replaceAll(RegExp(r'\s+'), '');
  if (digitsOnly.length < 13 || digitsOnly.length > 19) {
    return 'Invalid card number length';
  }

  if (!_luhnCheck(digitsOnly)) {
    return 'Invalid card number';
  }

  return null;
}

bool _luhnCheck(String number) {
  var sum = 0;
  var alternate = false;
  for (var i = number.length - 1; i >= 0; i--) {
    var n = int.parse(number[i]);
    if (alternate) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

String? expiryDateValidator(String? value) {
  if (value == null || value.isEmpty) return 'Expiry date is required';
  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
    return 'Invalid format (MM/YY)';
  }

  final parts = value.split('/');
  final month = int.tryParse(parts[0]);
  final year = int.tryParse(parts[1]);

  if (month == null || year == null || month < 1 || month > 12) {
    return 'Invalid expiry date';
  }

  final now = DateTime.now();
  final fourDigitYear = 2000 + year;
  final expiry = DateTime(fourDigitYear, month + 1); // first day of next month

  if (expiry.isBefore(now)) {
    return 'Card has expired';
  }

  return null;
}

String? cvcValidator(String? value) {
  if (value == null || value.isEmpty) return 'CVC is required';
  if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
    return 'Invalid CVC';
  }
  return null;
}

String? routingNumberValidator(String? value) {
  if (value == null || value.isEmpty) return 'Routing number is required';
  if (!RegExp(r'^\d{8}$').hasMatch(value)) {
    return 'Routing number must be 9 digits';
  }

  if (!_isValidRoutingNumber(value)) {
    return 'Invalid routing number';
  }

  return null;
}

bool _isValidRoutingNumber(String number) {
  if (number.length != 9) return false;

  final digits = number.split('').map(int.parse).toList();
  final checksum =
      3 * (digits[0] + digits[3] + digits[6]) +
      7 * (digits[1] + digits[4] + digits[7]) +
      (digits[2] + digits[5] + digits[8]);

  return checksum % 10 == 0;
}

String? bankAccountNumberValidator(String? value) {
  if (value == null || value.isEmpty) {
    return 'Account number is required';
  }

  if (!RegExp(r'^\d{6,17}$').hasMatch(value)) {
    return 'Account number must be 6 to 17 digits';
  }

  return null;
}
