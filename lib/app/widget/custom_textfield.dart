import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FocusNode? nextFocus;
  final TextInputType inputType;
  final TextInputAction inputAction;
  final bool isPassword;
  final Function? onChanged;
  final Function? onSubmit;
  final bool isEnabled;
  final int maxLines;
  final TextCapitalization capitalization;
  final String? prefixImage;
  final IconData? prefixIcon;
  final bool divider;
  final bool showTitle;
  final bool isAmount;
  final bool isNumber;
  final bool isPhone;
  final String? countryDialCode;
  final bool showBorder;
  final double iconSize;
  final bool isRequired;
  final bool readOnly;
  final bool editText;
  final FormFieldValidator<String>? validation;
  final Function()? onTap;
  final bool isCalenderIcon;
  final bool isClockIcon;
  final int? maxLength;
  final String? suffixText;
  final bool arrows;
  final int? upperLimit;
  final int? lowerLimit;
  final bool? isFormat;
  final bool? isSugarAdding;// New property for disallowing dots

  const CustomTextField({
    super.key,
    this.hintText = 'Write something...',
    this.controller,
    this.focusNode,
    this.nextFocus,
    this.isEnabled = true,
    this.inputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
    this.maxLines = 1,
    this.onSubmit,
    this.onChanged,
    this.prefixImage,
    this.prefixIcon,
    this.capitalization = TextCapitalization.none,
    this.isPassword = false,
    this.divider = false,
    this.showTitle = false,
    this.isAmount = false,
    this.isNumber = false,
    this.isPhone = false,
    this.countryDialCode,
    this.showBorder = true,
    this.iconSize = 18,
    this.isRequired = false,
    this.readOnly = false,
    this.editText = false,
    this.validation,
    this.onTap,
    this.isCalenderIcon = false,
    this.isClockIcon = false,
    this.maxLength,
    this.suffixText,
    this.arrows = false,
    this.upperLimit,
    this.lowerLimit,
    this.isFormat, this.isSugarAdding = false,
  });

  @override
  CustomTextFieldState createState() => CustomTextFieldState();
}

class CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showTitle
            ? Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            widget.hintText,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        )
            : const SizedBox(),
        SizedBox(height: widget.showTitle ? 5 : 0),
        TextFormField(
          onTap: widget.onTap,
          validator: widget.validation,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          controller: widget.controller,
          focusNode: widget.focusNode,
          style: const TextStyle(fontSize: 16),
          textInputAction: widget.inputAction,
          keyboardType:
          widget.isAmount ? TextInputType.number : widget.inputType,
          cursorColor: Theme.of(context).primaryColor,
          textCapitalization: widget.capitalization,
          enabled: widget.isEnabled,
          autofocus: false,
          minLines: widget.maxLines,
          obscureText: widget.isPassword ? _obscureText : false,
          inputFormatters: _getInputFormatters(),
          decoration: InputDecoration(
            suffixText: widget.suffixText,
            counterText: "",
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                width: 0.3,
                color: Theme.of(context).primaryColorDark.withOpacity(0.80),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                width: 1,
                color: Theme.of(context).primaryColor,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
              borderSide: BorderSide(
                style: widget.showBorder ? BorderStyle.solid : BorderStyle.none,
                width: 0.3,
                color: Theme.of(context).primaryColorDark.withOpacity(0.80),
              ),
            ),
            isDense: true,
            hintText: widget.hintText,
            errorStyle: TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
            fillColor: Theme.of(context).cardColor,
            hintStyle: TextStyle(
              fontSize: 14,
              color: Theme.of(context).hintColor,
            ),
            filled: true,
          ),
          onChanged: widget.onChanged as void Function(String)?,
        ),
        widget.divider
            ? const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Divider(),
        )
            : const SizedBox(),
      ],
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  List<TextInputFormatter>? _getInputFormatters() {

    if (widget.isFormat == true) {
      return [
        FilteringTextInputFormatter.deny(RegExp(r'\.')),
      ];
    }
    return widget.isAmount
        ? [FilteringTextInputFormatter.allow(RegExp(r'\d'))]
        : widget.isNumber
        ? [
      FilteringTextInputFormatter.allow(RegExp(r'\d')),
      LengthLimitingTextInputFormatter(widget.maxLength ?? 10),
    ]
        : widget.isPhone
        ? [FilteringTextInputFormatter.allow(RegExp('[0-9+]'))]
        : null;
  }
}
