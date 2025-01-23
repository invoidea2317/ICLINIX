import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_dropdown_field.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/utils/sizeboxes.dart';

class BloodSugarInput extends StatelessWidget {
  final String title;
  final String hintText;
  final String? suffixText;
  final TextInputType? inputType;
  final TextEditingController controller;
  final String? Function(String?)? validator; // Validator parameter
  final ValueChanged<String>? onChanged; // Optional onChanged parameter
  final bool readOnly; // Conditional readOnly parameter
  final bool? isDouble;
  final String? titleSecond;
  final String? hintTextSecond;
  final String? suffixTextSecond;
  final TextInputType? inputTypeSecond;
  final TextEditingController? controllerSecond;
  final String? Function(String?)? validatorSecond; // Validator parameter
  final ValueChanged<String>? onChangedSecond; // Optional onChanged parameter
  final bool? readOnlySecond;
  final int? maxLength;

  BloodSugarInput({
    super.key,
    required this.title,
    required this.hintText,
    required this.controller,
    this.suffixText,
    this.validator, // Initialize the validator parameter
    this.onChanged, // Initialize the onChanged parameter
    this.readOnly = false,
    this.inputType,
    this.maxLength,
    this.isDouble = false,
    this.titleSecond,
    this.hintTextSecond,
    this.suffixTextSecond,
    this.inputTypeSecond,
    this.controllerSecond,
    this.validatorSecond,
    this.onChangedSecond,
    this.readOnlySecond, // Initialize readOnly with a default value of false
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
        Visibility(
          visible: !(isDouble ?? false),
          child: CustomTextField(
            maxLength: maxLength,
            isFormat: true,
            readOnly: readOnly,
            // Pass the readOnly parameter to CustomTextField
            inputType: inputType ?? TextInputType.number,
            controller: controller,
            // Pass the controller here
            editText: true,
            hintText: hintText,
            // Use the provided hintText
            suffixText: suffixText ?? 'mg/dL',
            validation: validator,
            // Pass the validator function to CustomTextField
            onChanged:
                onChanged, // Pass the onChanged callback to CustomTextField
          ),
        ),
        Visibility(
          visible: (isDouble ?? false),
          child: Row(
            children: [
              Expanded(
                  child: CustomDropdownField(
                    validator: validator,
                    selectedValue: controller.text.isEmpty ? null : controller.text,
                      hintText: "Year",
                      options:
                          List.generate(50, (value) => (value + 1).toString()),
                      onChanged: (value){
                      debugPrint("Value: $value");
                        controller.text = value ?? "";
                        onChanged!(controller.text);
                      }),

                  // CustomTextField(
                  //   showTitle: false,
                  //   // upperLimit: 12,
                  //   maxLength: maxLength,
                  //   readOnly: readOnly,
                  //   // Pass the readOnly parameter to CustomTextField
                  //   inputType: inputType ?? TextInputType.number,
                  //   controller: controller,
                  //   // Pass the controller here
                  //   editText: true,
                  //   hintText: hintText,
                  //   // Use the provided hintText
                  //   suffixText: suffixText ?? 'mg/dL',
                  //   arrows: true,
                  //   validation: validator,
                  //   // Pass the validator function to CustomTextField
                  //   onChanged:
                  //   onChanged, // Pass the onChanged callback to CustomTextField
                  // ),
                  ),
              SizedBox(
                width: 20,
              ),
              Expanded(
                child: CustomTextField(
                  upperLimit: 12,
                  showTitle: false,
                  arrows: true,
                  maxLength: maxLength,
                  readOnly: readOnlySecond ?? false,
                  // Pass the readOnly parameter to CustomTextField
                  inputType: inputTypeSecond ?? TextInputType.number,
                  controller: controllerSecond,
                  // Pass the controller here
                  editText: true,
                  hintText: hintTextSecond ?? "",
                  // Use the provided hintText
                  suffixText: suffixTextSecond ?? 'mg/dL',
                  validation: validatorSecond,
                  // Pass the validator function to CustomTextField
                  onChanged:
                      onChangedSecond, // Pass the onChanged callback to CustomTextField
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
