import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import '../../../Utils/box_sizes.dart';
import '../../../Utils/text_field_types.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String placeholder;
  final TextFieldType type;
  final BoxSize boxSize;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? customFormatters;

  const CustomTextField({
    Key? key,
    required this.placeholder,
    required this.type,
    required this.boxSize,
    this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.keyboardType,
    this.customFormatters,
  }) : super(key: key);

  @override
  CustomTextFieldState  createState() => CustomTextFieldState ();
}

class CustomTextFieldState  extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  List<TextInputFormatter>? _getFormatters() {
    if (widget.customFormatters != null) {
      return widget.customFormatters!;
    }

    switch (widget.type) {
      case TextFieldType.numeric:
        return [
          FilteringTextInputFormatter.digitsOnly,
        ];

      case TextFieldType.phone:
        return [
          PhoneInputFormatter(),
        ];

      case TextFieldType.date:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9/]')),
          LengthLimitingTextInputFormatter(10),
          DateInputFormatter(), // Use custom formatter below
        ];

      case TextFieldType.currency:
        return [
          CurrencyInputFormatter(
            leadingSymbol: CurrencySymbols.DOLLAR_SIGN,
            useSymbolPadding: true,
          ),
        ];

      case TextFieldType.decimal:
        return [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
          DecimalInputFormatter(), // Use custom formatter below
        ];

      case TextFieldType.email:
        return [
          FilteringTextInputFormatter.deny(RegExp(r'\s')),
        ];

      default:
        return null; // Return null instead of empty list
    }
  }

  TextInputType _getKeyboardType() {
    if (widget.keyboardType != null) {
      return widget.keyboardType!;
    }

    switch (widget.type) {
      case TextFieldType.numeric:
      case TextFieldType.currency:
      case TextFieldType.decimal:
        return TextInputType.numberWithOptions(
          decimal: widget.type == TextFieldType.decimal,
          signed: false,
        );

      case TextFieldType.phone:
        return TextInputType.phone;

      case TextFieldType.email:
        return TextInputType.emailAddress;

      case TextFieldType.date:
        return TextInputType.datetime;

      default:
        return TextInputType.text;
    }
  }

  double _getWidth() {
    switch (widget.boxSize) {
      case BoxSize.small:
        return 120;
      case BoxSize.medium:
        return 200;
      case BoxSize.large:
        return 280;
      case BoxSize.full:
        return double.infinity;
    }
  }

  String? _getHintText() {
    if (widget.placeholder.isNotEmpty) {
      return widget.placeholder;
    }

    switch (widget.type) {
      case TextFieldType.date:
        return 'YYYY/MM/DD'; // Simplified hint text
      case TextFieldType.phone:
        return '+1 (234) 567-8900';
      case TextFieldType.email:
        return 'email@example.com';
      default:
        return widget.placeholder;
    }
  }

  void _handleOnChanged(String value) {
    if (widget.onChanged != null) {
      // For numeric formatters, get the original value
      if (widget.type == TextFieldType.decimal) {
        final formatters = _getFormatters();
        if (formatters != null && formatters.isNotEmpty) {
          final formatter = formatters.first;
          if (formatter is DecimalInputFormatter) {
            // For flutter_multi_formatter, we need to parse manually
            final cleanValue = value.replaceAll(' ', '');
            widget.onChanged!(cleanValue);
            return;
          }
        }
      }
      widget.onChanged!(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPasswordType = widget.type == TextFieldType.password;

    return SizedBox(
      width: _getWidth(),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: _getHintText(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          filled: true,
          fillColor: widget.enabled ? Colors.white : Colors.grey[100],
          suffixIcon: isPasswordType
              ? IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: widget.maxLines! > 1 ? 16.0 : 12.0,
          ),
        ),
        inputFormatters: _getFormatters(), // This can be null now
        keyboardType: _getKeyboardType(),
        obscureText: isPasswordType && !_isPasswordVisible,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        onChanged: _handleOnChanged,
        validator: widget.validator,
      ),
    );
  }
}

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');

    // Auto-insert slashes for date format YYYY/MM/DD
    if (text.length > 4 && !text.contains('/')) {
      text = '${text.substring(0, 4)}/${text.substring(4)}';
    }
    if (text.length > 7 && text.substring(5).length > 2) {
      text = '${text.substring(0, 7)}/${text.substring(7)}';
    }

    // Limit to YYYY/MM/DD format
    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class DecimalInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    var text = newValue.text;

    // Allow only numbers and one decimal point
    if (text.isEmpty) return newValue;

    // Check for multiple decimal points
    if (text.split('.').length > 2) {
      return oldValue;
    }

    // Validate the format
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    // Limit decimal places to 5
    if (text.contains('.')) {
      final parts = text.split('.');
      if (parts[1].length > 5) {
        return oldValue;
      }
    }

    return newValue;
  }
}
