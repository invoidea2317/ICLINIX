import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

class BloodSugarInput extends StatelessWidget {
  final String title;
  final String hintText;
  final String? suffixText;
  final TextInputType? inputType;
  final TextEditingController controller;
  final String? Function(String?)? validator; // Validator parameter
  final ValueChanged<String>? onChanged; // Optional onChanged parameter
  final bool readOnly; // Conditional readOnly parameter

  BloodSugarInput({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.suffixText,
    this.validator, // Initialize the validator parameter
    this.onChanged, // Initialize the onChanged parameter
    this.readOnly = false, this.inputType, // Initialize readOnly with a default value of false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sizedBox5(),
        // Text(
        //   title,
        //   style: openSansSemiBold.copyWith(
        //     fontSize: Dimensions.fontSize14,
        //     color: Theme.of(context).disabledColor.withOpacity(0.30),
        //   ),
        // ),
        // sizedBoxDefault(), // Assuming you have a custom SizedBox widget
        CustomTextField(
          readOnly: readOnly, // Pass the readOnly parameter to CustomTextField
          inputType: inputType ?? TextInputType.number,
          controller: controller, // Pass the controller here
          editText: true,
          hintText: hintText, // Use the provided hintText
          suffixText: suffixText ?? 'mg/dL',
          validation: validator, // Pass the validator function to CustomTextField
          onChanged: onChanged, // Pass the onChanged callback to CustomTextField
        ),
      ],
    );
  }
}
