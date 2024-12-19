import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iclinix/controller/chat_controller.dart';
import 'package:iclinix/app/widget/common_widgets.dart';
import 'package:iclinix/app/widget/custom_app_bar.dart';
import 'package:iclinix/app/widget/custom_button_widget.dart';
import 'package:iclinix/app/widget/custom_dropdown_field.dart';
import 'package:iclinix/app/widget/custom_textfield.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/sizeboxes.dart';
import '../../widget/custom_snackbar.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final subjectController = TextEditingController();
  final description = TextEditingController();
  List<File> selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatControl) {
      return Scaffold(
        body: Column(
          children: [
            CustomAppBar(
              title: 'Send Message ',
              isBackButtonExist: true,
              menuWidget: const Row(
                children: [
                  NotificationButton(),
                ],
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdownField(
                      selectedValue: chatControl.type == 1 ? "Question" : "Problem",
                      hintText: 'Select Type',
                      options: ["Question", "Problem", "Urgent"],
                      onChanged: (String? newValue) {
                        chatControl.setType(newValue == "Question"
                            ? 1
                            : newValue == "Urgent"
                            ? 3
                            : 2);
                      },
                      showTitle: true, // Set to true to show title
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: subjectController,
                      showTitle: true,
                      hintText: 'Subject',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      maxLines: 3,
                      controller: description,
                      showTitle: true,
                      hintText: 'Description',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.attach_file),
                    onPressed: _pickFiles,
                  ),
                ],
              ),
            ),
            // Display selected files
            if (selectedFiles.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selected Files:"),
                    SizedBox(height: 8),
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: selectedFiles.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Icon(Icons.insert_drive_file),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(selectedFiles[index].path.split('/').last),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        bottomNavigationBar: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(buttonText: "Send", onPressed: () {
                    if (subjectController.text.isEmpty) {
                      showCustomSnackBar('Please enter subject');
                    } else if (description.text.isEmpty) {
                      showCustomSnackBar('Please enter description');
                    } else {
                      chatControl.sendMessage(chatControl.type, subjectController.text, description.text, selectedFiles);
                    }
                  }),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Allow multiple files to be selected
    );

    if (result != null) {
      setState(() {
        selectedFiles = result.paths.map((path) => File(path!)).toList();
      });
    }
  }
}
