import 'dart:developer';
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
import 'package:image_picker/image_picker.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/sizeboxes.dart';
import '../../widget/custom_snackbar.dart';
import '../CameraScreen/camera_screen.dart';

class ChatScreen extends StatefulWidget {
  String? selectedValue;
  ChatScreen({super.key, this.selectedValue});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final subjectController = TextEditingController();
  final description = TextEditingController();
  List<File> selectedFiles = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ChatController>().setType(widget.selectedValue == "Question"
          ? 1
          : widget.selectedValue == "Urgent"
          ? 3
          : widget.selectedValue == "Lifestyle Support" ? 4:2);
    });

  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatController>(builder: (chatControl) {
      return Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const CustomAppBar(
                title: 'Send Message ',
                isBackButtonExist: true,
                menuWidget: Row(
                  children: [
                    NotificationButton(),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 25,
              // ),
              Visibility(
                visible: chatControl.type != 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomDropdownField(
                          selectedValue: chatControl.type == 1 ? "Question" : chatControl.type == 3?"Urgent":"Problem",
                          hintText: '',
                          options: const ["Question", "Problem", "Urgent",],
                          onChanged: (String? newValue) {
                            chatControl.setType(newValue == "Question"
                                ? 1
                                : newValue == "Urgent"
                                ? 3:2);
                          },
                          showTitle: true, // Set to true to show title
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: chatControl.type == 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          showBorder: false,
                        controller: TextEditingController(text: 'Lifestyle Support'),
                          readOnly: true,
                          hintText: 'Lifestyle Support',
                        )
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
              //   child: Row(
              //     children: [
              //       Expanded(
              //         child: CustomTextField(
              //           controller: subjectController,
              //           showTitle: true,
              //           hintText: 'Topic',
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 15,
              // ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        maxLines: 20,
                        controller: description,
                        showTitle: false,
                        hintText: 'Description',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: (){
                    log("Message1");
                    _pickFiles();
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file),
                        onPressed: _pickFiles,
                      ),
                      const Expanded(child: Text("Add Attachment",))
                    ],
                  ),
                ),
              ),
              // Display selected files
              if (selectedFiles.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Selected Files:"),
                      const SizedBox(height: 8),
                      ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: selectedFiles.length,
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              const Icon(Icons.insert_drive_file),
                              const SizedBox(width: 8),
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
        ),
        bottomNavigationBar: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0,bottom: 20,right: 16),
            child: Row(
              children: [
                Expanded(
                  child: CustomButtonWidget(buttonText: "Send", onPressed: () {
                    if (description.text.isEmpty) {
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
   // Import the CameraScreen

  Future<void> _pickFiles() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Camera"),
              onTap: () async {
                Navigator.pop(context);
                final imagePath = await Get.to(() => CameraScreen());
                if (imagePath != null) {
                  setState(() {
                    selectedFiles.add(File(imagePath));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Gallery"),
              onTap: () async {
                Navigator.pop(context);
                final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    selectedFiles.add(File(pickedFile.path));
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Pick PDF"),
              onTap: () async {
                Navigator.pop(context);
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                );
                if (result != null) {
                  setState(() {
                    selectedFiles.add(File(result.files.single.path!));
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

}
