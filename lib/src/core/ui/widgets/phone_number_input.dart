import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:larnity/src/core/extensions/extensions.dart';
import 'package:larnity/src/core/theme/app_colors.dart';
import 'package:larnity/src/core/ui/widgets/app_dropdown.dart';
import 'package:larnity/src/features/group/data/models/country_model.dart';

// Import your existing dropdown and country model
// import 'app_dropdown.dart';
// import 'country_model.dart';

class PhoneNumberInput extends StatefulWidget {
  const PhoneNumberInput({
    super.key,
    required this.countries,
    this.onPhoneNumberChanged,
    this.onCountryChanged,
    this.initialCountry,
    this.initialPhoneNumber,
    this.hintText = 'Enter phone number',
    this.countryDropdownHint = 'Select country',
    this.decoration,
    this.enabled = true,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textStyle,
  });

  final List<CountryModel> countries;
  final Function(String phoneNumber, CountryModel? country)?
  onPhoneNumberChanged;
  final Function(CountryModel country)? onCountryChanged;
  final CountryModel? initialCountry;
  final String? initialPhoneNumber;
  final String hintText;
  final String countryDropdownHint;
  final InputDecoration? decoration;
  final bool enabled;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextStyle? textStyle;

  @override
  State<PhoneNumberInput> createState() => _PhoneNumberInputState();
}

class _PhoneNumberInputState extends State<PhoneNumberInput> {
  late TextEditingController _phoneController;
  CountryModel? _selectedCountry;
  final AppDropdownController _dropdownController = AppDropdownController();

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.initialCountry;

    // Initialize phone controller with initial value
    String initialValue = '';
    if (widget.initialPhoneNumber != null) {
      if (_selectedCountry != null &&
          widget.initialPhoneNumber!.startsWith(_selectedCountry!.code)) {
        // Remove country code from initial phone number
        initialValue = widget.initialPhoneNumber!.substring(
          _selectedCountry!.code.length,
        );
      } else if (_selectedCountry == null) {
        // Try to detect country from phone number
        _detectCountryFromPhoneNumber(widget.initialPhoneNumber!);
        initialValue = widget.initialPhoneNumber!;
      } else {
        initialValue = widget.initialPhoneNumber!;
      }
    }

    _phoneController = TextEditingController(text: initialValue);
    _phoneController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _detectCountryFromPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    if (cleanNumber.startsWith('+')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // Find matching country by code (longest match first)
    CountryModel? detectedCountry;
    int longestMatch = 0;

    for (final country in widget.countries) {
      String countryCode = country.code.replaceAll('+', '');
      if (cleanNumber.startsWith(countryCode) &&
          countryCode.length > longestMatch) {
        detectedCountry = country;
        longestMatch = countryCode.length;
      }
    }

    if (detectedCountry != null) {
      setState(() {
        _selectedCountry = detectedCountry;
      });
      widget.onCountryChanged?.call(detectedCountry);

      // Remove country code from phone number field
      String remainingNumber = cleanNumber.substring(longestMatch);
      _phoneController.text = remainingNumber;
    }
  }

  void _onPhoneNumberChanged() {
    final phoneNumber = _phoneController.text;

    // If user starts typing with + and no country is selected, try to detect
    if (phoneNumber.startsWith('+') && _selectedCountry == null) {
      _detectCountryFromPhoneNumber(phoneNumber);
      return;
    }

    // If user enters country code while country is selected, prevent duplication
    if (_selectedCountry != null) {
      String countryCode = _selectedCountry!.code.replaceAll('+', '');
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

      if (cleanPhone.startsWith(countryCode)) {
        String withoutCountryCode = cleanPhone.substring(countryCode.length);
        _phoneController.text = withoutCountryCode;
        _phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: withoutCountryCode.length),
        );
        return;
      }
    }

    final fullNumber = _getFullPhoneNumber();
    widget.onPhoneNumberChanged?.call(fullNumber, _selectedCountry);
  }

  void _onCountrySelected(CountryModel country) {
    setState(() {
      _selectedCountry = country;
    });
    widget.onCountryChanged?.call(country);

    final fullNumber = _getFullPhoneNumber();
    widget.onPhoneNumberChanged?.call(fullNumber, _selectedCountry);
  }

  String _getFullPhoneNumber() {
    if (_selectedCountry == null || _phoneController.text.isEmpty) {
      return _phoneController.text;
    }
    return '${_selectedCountry!.code}${_phoneController.text}';
  }

  String? _validatePhoneNumber(String? value) {
    if (widget.validator != null) {
      return widget.validator!(value);
    }

    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (_selectedCountry == null) {
      return 'Please select a country';
    }

    // Basic phone number validation
    final cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanNumber.length < 6) {
      return 'Phone number is too short';
    }

    if (cleanNumber.length > 15) {
      return 'Phone number is too long';
    }

    // Country-specific validation can be added here
    return _validateCountrySpecificPhone(cleanNumber, _selectedCountry!);
  }

  String? _validateCountrySpecificPhone(
    String phoneNumber,
    CountryModel country,
  ) {
    // Add country-specific validation rules here
    switch (country.codeAbbreviation.toUpperCase()) {
      case 'US':
      case 'CA':
        if (phoneNumber.length != 10) {
          return 'Phone number must be 10 digits';
        }
        break;
      case 'IN':
        if (phoneNumber.length != 10) {
          return 'Phone number must be 10 digits';
        }
        if (!phoneNumber.startsWith(RegExp(r'[6-9]'))) {
          return 'Invalid phone number format';
        }
        break;
      case 'GB':
        if (phoneNumber.length < 10 || phoneNumber.length > 11) {
          return 'Phone number must be 10-11 digits';
        }
        break;
      case 'AU':
        if (phoneNumber.length != 9) {
          return 'Phone number must be 9 digits';
        }
        break;
      case 'DE':
        if (phoneNumber.length < 10 || phoneNumber.length > 12) {
          return 'Phone number must be 10-12 digits';
        }
        break;
      case 'FR':
        if (phoneNumber.length != 9) {
          return 'Phone number must be 9 digits';
        }
        break;
      case 'JP':
        if (phoneNumber.length < 10 || phoneNumber.length > 11) {
          return 'Phone number must be 10-11 digits';
        }
        break;
      case 'BR':
        if (phoneNumber.length != 10 && phoneNumber.length != 11) {
          return 'Phone number must be 10-11 digits';
        }
        break;
      case 'CN':
        if (phoneNumber.length != 11) {
          return 'Phone number must be 11 digits';
        }
        break;
      case 'BD':
        if (phoneNumber.length != 10) {
          return 'Phone number must be 10 digits';
        }
        if (!phoneNumber.startsWith('1')) {
          return 'Phone number must start with 1';
        }
        break;
      default:
        // Generic validation for other countries
        if (phoneNumber.length < 6 || phoneNumber.length > 15) {
          return 'Invalid phone number length';
        }
    }
    return null;
  }

  List<AppDropdownItem<CountryModel>> _buildCountryDropdownItems() {
    return widget.countries.map((country) {
      return AppDropdownItem<CountryModel>(
        value: country,
        queryString:
            '${country.name} ${country.code} ${country.codeAbbreviation}',
        child: Row(
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 20)),
            8.pw,
            Expanded(
              child: Text(
                '${country.name} (${country.code})',
                style: const TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCountryButton() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderBrown),
        borderRadius: BorderRadius.circular(8),
        color: widget.enabled ? Colors.transparent : Colors.grey.shade100,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedCountry != null) ...[
            Text(_selectedCountry!.flag, style: const TextStyle(fontSize: 18)),
            4.pw,
            Text(
              _selectedCountry!.code,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ] else ...[
            const Icon(Icons.public, size: 18, color: Colors.grey),
            4.pw,
            Text(
              widget.countryDropdownHint,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
          4.pw,
          const Icon(Icons.arrow_drop_down, color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country Dropdown
            AppDropdown<CountryModel>(
              controller: _dropdownController,
              button: _buildCountryButton(),
              items: _buildCountryDropdownItems(),
              selectedValue: _selectedCountry,
              onItemSelected: widget.enabled ? _onCountrySelected : null,
              readOnly: !widget.enabled,
              enableSearch: true,
              overlayWidth: 300,
              overlayAlignment: Alignment.centerLeft,
              itemPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            12.pw,
            // Phone Number Input
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                enabled: widget.enabled,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
                ],
                autovalidateMode: widget.autovalidateMode,
                validator: (value) => _validatePhoneNumber(value),
                style: widget.textStyle,
                decoration:
                    widget.decoration?.copyWith(
                      hintText: widget.hintText,
                      prefixText: _selectedCountry != null
                          ? '${_selectedCountry!.code} '
                          : null,
                      prefixStyle:
                          widget.textStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                    ) ??
                    InputDecoration(
                      hintText: widget.hintText,
                      prefixText: _selectedCountry != null
                          ? '${_selectedCountry!.code} '
                          : null,
                      prefixStyle:
                          widget.textStyle ??
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderBrown,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderBrown,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppColors.borderBrown,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper extension to get full phone number
extension PhoneNumberInputExtension on PhoneNumberInput {
  String getFullPhoneNumber(
    TextEditingController controller,
    CountryModel? country,
  ) {
    if (country == null || controller.text.isEmpty) {
      return controller.text;
    }
    return '${country.code}${controller.text}';
  }
}

// Usage Example Widget
class PhoneNumberInputExample extends StatefulWidget {
  const PhoneNumberInputExample({super.key});

  @override
  State<PhoneNumberInputExample> createState() =>
      _PhoneNumberInputExampleState();
}

class _PhoneNumberInputExampleState extends State<PhoneNumberInputExample> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _fullPhoneNumber = '';
  CountryModel? _selectedCountry;

  // Sample countries data - replace with your actual data
  final List<CountryModel> _countries = [
    CountryModel(
      name: 'Bangladesh',
      code: '+880',
      flag: '🇧🇩',
      codeAbbreviation: 'BD',
      states: ['Dhaka', 'Chittagong', 'Sylhet'],
    ),
    CountryModel(
      name: 'United States',
      code: '+1',
      flag: '🇺🇸',
      codeAbbreviation: 'US',
      states: ['California', 'New York', 'Texas'],
    ),
    CountryModel(
      name: 'India',
      code: '+91',
      flag: '🇮🇳',
      codeAbbreviation: 'IN',
      states: ['Maharashtra', 'Delhi', 'Karnataka'],
    ),
    // Add more countries as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number Input Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Phone Number',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              12.ph,
              PhoneNumberInput(
                countries: _countries,
                onPhoneNumberChanged: (phoneNumber, country) {
                  setState(() {
                    _fullPhoneNumber = phoneNumber;
                    _selectedCountry = country;
                  });
                  debugPrint('Full phone number: $phoneNumber');
                  debugPrint('Selected country: ${country?.name}');
                },
                onCountryChanged: (country) {
                  debugPrint('Country changed: ${country.name}');
                },
                hintText: 'Enter your phone number',
                // initialCountry: _countries.first, // Optional
                // initialPhoneNumber: '+8801234567890', // Optional
              ),
              24.ph,
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Phone Number: $_fullPhoneNumber'),
                      ),
                    );
                  }
                },
                child: const Text('Validate & Submit'),
              ),
              16.ph,
              if (_fullPhoneNumber.isNotEmpty) ...[
                const Text(
                  'Current Phone Number:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(_fullPhoneNumber),
                8.ph,
                if (_selectedCountry != null) ...[
                  const Text(
                    'Selected Country:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${_selectedCountry!.flag} ${_selectedCountry!.name}'),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
