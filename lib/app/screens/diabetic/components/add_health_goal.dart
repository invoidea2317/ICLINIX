import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';

import 'package:iclinix/app/widget/custom_containers.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import 'package:iclinix/app/widget/decorated_add_button.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';
import 'package:get/get.dart';

import '../../../widget/loading_widget.dart';
import 'health_goal_detail_dialog.dart';

class AddHealthGoal extends StatefulWidget {
   AddHealthGoal({super.key});

  @override
  State<AddHealthGoal> createState() => _AddHealthGoalState();
}

class _AddHealthGoalState extends State<AddHealthGoal> {
  late ScrollController  _scrollController;

  List<Color> colors = [const Color(0xFFF8F8DF), const Color(0xFFE3FFE1), const Color(0xFFFFE8FC), const Color(0xFFFFE6E9)];

   // Random random = Random();
   final Random random = Random();

   final Map<String, Color> goalColors = {};
 // To store goal title and its assigned color

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DiabeticController>().getHealthGoalApi();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<DiabeticController>(builder: (controller) {
      return Column(
        children: [
          CustomDecoratedContainer(
            height: controller.healthGoalData?.length == 0?75:200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Health Goal',
                      style: openSansMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault),
                    ),
                    DecoratedAddButton(
                      tap: () {

                          Get.dialog(AddHealthGoalDialog());
                      },
                    ),
                  ],
                ),
                controller.healthGoalData?.length == 0?Container():const SizedBox(height: 10,),
                // CustomDropdownField(
                //   hintText: 'Goal',
                //   selectedValue: controller.healthGoal?.isEmpty ?? true
                //       ? null
                //       : controller.healthGoal,
                //   options: controller.healthGoalData
                //       ?.map((goal) => goal.title)
                //       .toSet() // Remove duplicates by converting to a Set
                //       .toList() ??
                //       [],
                //   onChanged: (String? newValue) {
                //     if (newValue != null) {
                //       // Update the health goal
                //       controller.updateHealthGoal(newValue);
                //       print(controller.healthGoal);
                //
                //       // Find the selected goal object by matching the title
                //       final selectedGoal = controller.healthGoalData?.firstWhere(
                //             (goal) => goal.title == newValue,
                //         orElse: () => MedicalRecord(title: '', description: '', ), // Return a default MedicalRecord
                //       );
                //
                //       // Open dialog only if a valid goal is found
                //       if (selectedGoal!.title.isNotEmpty && selectedGoal.description.isNotEmpty) {
                //         Get.dialog(
                //           HealthGoalDetailDialog(
                //             title: selectedGoal.title,
                //             description: selectedGoal.description,
                //           ),
                //         );
                //       }
                //     }
                //   },
                //   showTitle: false,
                // ),
                Container(
                  height: controller.healthGoalData?.length == 0?0:120,
                  child: controller.healthGoalData?.length == 0
                      ? Center(
                    child: Text(
                      'No health goals available',
                      style: TextStyle(
                        fontSize: Dimensions.fontSizeDefault,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  )
                      : Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true, // Always show the scroll indicator
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      shrinkWrap: true, // Prevent overflow when inside a scrollable widget
                      itemCount: controller.healthGoalData?.length ?? 0,
                      itemBuilder: (context, index) {
                        final goal = controller.healthGoalData![index];
                        return InkWell(
                          onTap: () {
                            Get.dialog(
                              HealthGoalDetailDialog(
                                title: goal.title,
                                description: goal.description,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0,top: 4),
                            child: Container(
                              height: 45,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length], // Cycle through colors
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      goal.title,
                                      style: TextStyle(
                                        fontSize: Dimensions.fontSizeDefault,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}

class AddHealthGoalDialog extends StatelessWidget {
  AddHealthGoalDialog({super.key});

  final titleController = TextEditingController();

  final descriptionController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print("=====>Hello");
    return Dialog(
        insetPadding:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSize10),
        child: GetBuilder<DiabeticController>(builder: (controller) {
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(
                  Dimensions.paddingSizeDefault,
                ),
                child: Column(
                  children: [
                    Container(
                      width: Get.size.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius5)),
                      padding:
                          const EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: Row(
                        children: [
                          Text(
                            'Add Health Goal',
                            style: openSansMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault,
                                color: Theme.of(context).cardColor),
                          ),
                          // DecoratedAddButton(tap: () {  },
                          // color: Theme.of(context).cardColor,)
                        ],
                      ),
                    ),
                    sizedBox20(),
                    SingleChildScrollView(
                      child: Column(
                        children: [
                          CustomTextField(
                            hintText: 'Goal Title',
                            controller: titleController,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Goal Title';
                              }
                              return null;
                            },
                          ),
                          sizedBoxDefault(),
                          CustomTextField(
                            maxLines: 4,
                            hintText: 'Goal Description',
                            controller: descriptionController,
                            validation: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Goal Description';
                              }
                              return null;
                            },
                          ),
                          sizedBox20(),
                          Row(
                            children: [
                              Flexible(
                                child: CustomButtonWidget(
                                  buttonText: 'Cancel',
                                  transparent: true,
                                  isBold: false,
                                  fontSize: Dimensions.fontSize14,
                                  onPressed: () {
                                    Get.back();
                                  },
                                ),
                              ),
                              sizedBoxW10(),
                              Flexible(
                                child: CustomButtonWidget(
                                  buttonText: 'Save',
                                  isBold: false,
                                  fontSize: Dimensions.fontSize14,
                                  onPressed: () {
                                    LoadingDialog.showLoading(message: "Please wait...");
                                    if (_formKey.currentState!.validate()) {
                                      controller.addHealthGoalApi(
                                          titleController.text,
                                          descriptionController.text).then((value) {

                                      });
                                      Get.back();

                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          // CustomButtonWidget(
                          //   buttonText: 'Add',
                          //   onPressed: () {
                          //     if (_formKey.currentState!.validate()) {
                          //       controller.addHealthGoalApi(
                          //           titleController.text,
                          //           descriptionController.text);
                          //     }
                          //   },
                          //   isBold: false,
                          //   fontSize: Dimensions.fontSize14,
                          // )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }));
  }
}
