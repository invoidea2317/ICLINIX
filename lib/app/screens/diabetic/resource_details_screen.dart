import 'package:flutter/material.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/diabetic_controller.dart';
import 'package:iclinix/utils/dimensions.dart';
import 'package:iclinix/utils/sizeboxes.dart';
import 'package:iclinix/utils/styles.dart';

class ResourceDetailsScreen extends StatelessWidget {
  final String? id;
  final String? name;
  const ResourceDetailsScreen({super.key, required this.id, required this.name});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<DiabeticController>().getResourceDetailsApi(id!);
    });

    return Scaffold(
      appBar: CustomAppBar(title: name, isBackButtonExist: true),
      body: GetBuilder<DiabeticController>(builder: (diabeticControl) {
        final data = diabeticControl.resourceDetail;
        final isLoading = diabeticControl.isResourceDetailsLoading;

        return isLoading
            ? const Center(child: CircularProgressIndicator())
            : data == null || (data.name ?? "").isEmpty || (data.sortDescription ?? "").isEmpty
            ? const Center(child: Text('No data available'))
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name ?? "",
                  style: openSansBold.copyWith(fontSize: Dimensions.fontSize20),
                ),
                sizedBoxDefault(),
                Text(data.sortDescription ?? ""),
              ],
            ),
          ),
        );
      }),
    );
  }
}
