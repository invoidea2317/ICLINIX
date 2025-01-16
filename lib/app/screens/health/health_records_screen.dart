import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slide_drawer/flutter_slide_widget.dart';
import 'package:iclinix/app/widget/custom_drawer_widget.dart';
import 'package:iclinix/app/widget/custom_snackbar.dart';

import 'package:iclinix/app/widget/loading_widget.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../helper/date_converter.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/images.dart';
import '../../../utils/sizeboxes.dart';
import '../../../utils/styles.dart';
import '../../widget/common_widgets.dart';
import '../../widget/custom_app_bar.dart';
import '../../widget/custom_button_widget.dart';
import '../../widget/custom_containers.dart';
import '../../widget/custom_image_widget.dart';
import '../../widget/empty_data_widget.dart';
import '../appointment/appointment_details_screen.dart';
import 'package:iclinix/app/screens/appointment/booking_successful_screen.dart';

class HealthRecordsScreen extends StatefulWidget {
  HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<SliderDrawerWidgetState> drawerKey =
      GlobalKey<SliderDrawerWidgetState>();
  late TabController _tabController;
  dynamic filePaths = "";

  double progress = 0.0; // Track download progress
  bool isDownloading = false;

  Future<void> downloadFile(String url, String fileName) async {

    if (await Permission.storage.isDenied) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
    }

    setState(() {
      progress = 0.0;
      isDownloading = true;
    });


    setState(() {
      progress = 0.0;
      isDownloading = true;
    });
    LoadingDialog.showLoading(message: "Completed: $progress");

    Directory? downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir =
          Directory('/storage/emulated/0/Download'); // Android Downloads folder
    } else if (Platform.isIOS) {
      downloadsDir =
          await getApplicationDocumentsDirectory(); // iOS app-specific folder
    }

    final filePath = "${downloadsDir?.path}/${fileName}";

    Dio dio = Dio();

    try {
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              progress = received / total;
            });
          }
        },
      );

      setState(() {
        isDownloading = false;
      });

      filePaths = filePath;
      // Open the downloaded file
      // OpenFile.open(filePath);

      LoadingDialog.hideLoading();
      showNotification(fileName, filePath);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Download Complete"),
            content: Text("The file has been downloaded successfully."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  OpenFile.open(filePath);
                },
                child: Text("Open File"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      print("Download failed: $e");
    }
  }
  int index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<AppointmentController>().getAppointmentHistory();
    });
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppointmentController>(builder: (appointmentControl) {
      final appointmentHistoryList = appointmentControl.appointmentHistoryList;
      final isListEmpty =
          appointmentHistoryList == null || appointmentHistoryList.isEmpty;
      final isLoading = appointmentControl.isAppointmentHistoryLoading;
      // if (isLoading) {
      //   LoadingDialog.showLoading(message: "Please wait...");
      // } else {
      //   // Dismiss loading dialog when loading is complete
      //   LoadingDialog.hideLoading();
      // }
      return SliderDrawerWidget(
        key: drawerKey,
        option: SliderDrawerOption(
          backgroundColor: Theme.of(context).primaryColor,
          sliderEffectType: SliderEffectType.Rounded,
          upDownScaleAmount: 30,
          radiusAmount: 30,
          direction: SliderDrawerDirection.LTR,
        ),
        drawer: const CustomDrawer(),
        body: Scaffold(
            appBar: CustomAppBar(
                title: 'Recent Appointments',
                drawerButton: CustomMenuButton(tap: () {
                  drawerKey.currentState!.toggleDrawer();
                }),
                menuWidget: const Row(
                  children: [
                    NotificationButton(),
                  ],
                )),
            body: isListEmpty
                ? Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).primaryColor,
                        labelColor: Theme.of(context).primaryColor,
                        dividerColor: Colors.grey,
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(
                            text: 'Appointments',
                          ),
                          Tab(
                            text: 'Prescriptions',
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.grey, // Color of the divider
                        thickness: 1, // Thickness of the divider
                        height: 1, // Space taken by the divider
                      ),
                      sizedBox10(),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 16.0, vertical: 4),
                      //   child: Row(
                      //     children: [
                      //       GestureDetector(
                      //         onTap: () {
                      //           appointmentControl
                      //               .setisComing(!appointmentControl.isComing!);
                      //           appointmentControl.setisVisiting(false);
                      //           appointmentControl.setisCancelled(false);
                      //
                      //         },
                      //         child: Container(
                      //           width: 83.64,
                      //           height: 33,
                      //           decoration: ShapeDecoration(
                      //             color: Color(0x262CC229),
                      //             shape: RoundedRectangleBorder(
                      //               side: BorderSide(
                      //                   width: appointmentControl.isComing!
                      //                       ? 2
                      //                       : 0,
                      //                   color: Color(0xFF2CC229)),
                      //               borderRadius: BorderRadius.circular(50),
                      //             ),
                      //           ),
                      //           child: Center(
                      //               child: Text(
                      //             'Upcoming',
                      //             style: TextStyle(
                      //               color: Color(0xFF2CC229),
                      //               fontSize: 13,
                      //               fontFamily: 'Open Sans',
                      //               fontWeight: FontWeight.w400,
                      //               height: 0,
                      //               letterSpacing: -0.26,
                      //             ),
                      //           )),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         width: 10,
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           appointmentControl.setisVisiting(
                      //               !appointmentControl.isVisiting!);
                      //           appointmentControl.setisComing(false);
                      //           appointmentControl.setisCancelled(false);
                      //         },
                      //         child: Container(
                      //           width: 83.64,
                      //           height: 33,
                      //           decoration: ShapeDecoration(
                      //             color: Color(0x26294BC2),
                      //             shape: RoundedRectangleBorder(
                      //               side: BorderSide(
                      //                   width: appointmentControl.isVisiting!
                      //                       ? 2
                      //                       : 0,
                      //                   color: Color(0xFF294BC2)),
                      //               borderRadius: BorderRadius.circular(50),
                      //             ),
                      //           ),
                      //           child: Center(
                      //               child: Text(
                      //             'Pending',
                      //             style: TextStyle(
                      //               color: Color(0xFF294BC2),
                      //               fontSize: 13,
                      //               fontFamily: 'Open Sans',
                      //               fontWeight: FontWeight.w400,
                      //               height: 0,
                      //               letterSpacing: -0.26,
                      //             ),
                      //           )),
                      //         ),
                      //       ),
                      //       SizedBox(
                      //         width: 10,
                      //       ),
                      //       GestureDetector(
                      //         onTap: () {
                      //           appointmentControl.setisVisiting(false);
                      //           appointmentControl.setisComing(false);
                      //           appointmentControl.setisCancelled(
                      //               !appointmentControl.isCancelled!);
                      //         },
                      //         child: Container(
                      //           width: 83.64,
                      //           height: 33,
                      //           decoration: ShapeDecoration(
                      //             color: Color(0x26DD2025),
                      //             shape: RoundedRectangleBorder(
                      //               side: BorderSide(
                      //                   width: appointmentControl.isCancelled!
                      //                       ? 2
                      //                       : 0,
                      //                   color: Color(0xFFDD2025)),
                      //               borderRadius: BorderRadius.circular(50),
                      //             ),
                      //           ),
                      //           child: Center(
                      //               child: Text(
                      //             'Cancelled',
                      //             style: TextStyle(
                      //               color: Color(0xFFDD2025),
                      //               fontSize: 13,
                      //               fontFamily: 'Open Sans',
                      //               fontWeight: FontWeight.w400,
                      //               height: 0,
                      //               letterSpacing: -0.26,
                      //             ),
                      //           )),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // sizedBox20(),
                      Padding(
                        padding: const EdgeInsets.only(top: 200),
                        child: Center(
                          child: EmptyDataWidget(
                            text:
                                'Nothing Available', // Change this text if needed
                            image: Images.icEmptyDataHolder,
                            fontColor: Theme.of(context).disabledColor,
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).primaryColor,
                        labelColor: Theme.of(context).primaryColor,
                        dividerColor: Colors.grey,
                        unselectedLabelColor: Colors.grey,
                        onTap: (value){
                          //debugPrint("Tab Index: $value");
                          //debugPrint("Health Records Screen: ${_tabController.index}");
                          setState(() {
                            index = value;
                          });
                        },
                        tabs: [
                          Tab(
                            text: 'Appointments',
                          ),
                          Tab(
                            text: 'Prescriptions',
                          ),
                        ],
                      ),
                      Divider(
                        color: Colors.grey, // Color of the divider
                        thickness: 1, // Thickness of the divider
                        height: 1, // Space taken by the divider
                      ),
                      sizedBox10(),
                    Visibility(
                      visible: index == 0,
                      child: Expanded(
                          child:    appointmentHistoryList.isEmpty ||
                              appointmentHistoryList.every((appointment) => appointment.patientAppointments.isEmpty)
                              ? EmptyDataWidget(
                            text: 'Nothing Available',
                            image: Images.icEmptyDataHolder,
                            fontColor: Theme.of(context).disabledColor,
                          )
                              :
                          SingleChildScrollView(
                            child: Column(
                              children: [
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 16.0, vertical: 4),
                                //   child: Row(
                                //     children: [
                                //       GestureDetector(
                                //         onTap: () {
                                //           appointmentControl.setisComing(
                                //               !appointmentControl.isComing!);
                                //           appointmentControl.setisVisiting(false);
                                //           appointmentControl
                                //               .setisCancelled(false);
                                //         },
                                //         child: Container(
                                //           width: 83.64,
                                //           height: 33,
                                //           decoration: ShapeDecoration(
                                //             color: Color(0x262CC229),
                                //             shape: RoundedRectangleBorder(
                                //               side: BorderSide(
                                //                   width:
                                //                       appointmentControl.isComing!
                                //                           ? 2
                                //                           : 0,
                                //                   color: Color(0xFF2CC229)),
                                //               borderRadius:
                                //                   BorderRadius.circular(50),
                                //             ),
                                //           ),
                                //           child: Center(
                                //               child: Text(
                                //             'Upcoming',
                                //             style: TextStyle(
                                //               color: Color(0xFF2CC229),
                                //               fontSize: 13,
                                //               fontFamily: 'Open Sans',
                                //               fontWeight: FontWeight.w400,
                                //               height: 0,
                                //               letterSpacing: -0.26,
                                //             ),
                                //           )),
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         width: 10,
                                //       ),
                                //       GestureDetector(
                                //         onTap: () {
                                //           appointmentControl.setisVisiting(
                                //               !appointmentControl.isVisiting!);
                                //           appointmentControl.setisComing(false);
                                //           appointmentControl
                                //               .setisCancelled(false);
                                //         },
                                //         child: Container(
                                //           width: 83.64,
                                //           height: 33,
                                //           decoration: ShapeDecoration(
                                //             color: Color(0x26294BC2),
                                //             shape: RoundedRectangleBorder(
                                //               side: BorderSide(
                                //                   width: appointmentControl
                                //                           .isVisiting!
                                //                       ? 2
                                //                       : 0,
                                //                   color: Color(0xFF294BC2)),
                                //               borderRadius:
                                //                   BorderRadius.circular(50),
                                //             ),
                                //           ),
                                //           child: Center(
                                //               child: Text(
                                //             'Pending',
                                //             style: TextStyle(
                                //               color: Color(0xFF294BC2),
                                //               fontSize: 13,
                                //               fontFamily: 'Open Sans',
                                //               fontWeight: FontWeight.w400,
                                //               height: 0,
                                //               letterSpacing: -0.26,
                                //             ),
                                //           )),
                                //         ),
                                //       ),
                                //       SizedBox(
                                //         width: 10,
                                //       ),
                                //       GestureDetector(
                                //         onTap: () {
                                //           appointmentControl.setisVisiting(false);
                                //           appointmentControl.setisComing(false);
                                //           appointmentControl.setisCancelled(
                                //               !appointmentControl.isCancelled!);
                                //
                                //         },
                                //         child: Container(
                                //           width: 83.64,
                                //           height: 33,
                                //           decoration: ShapeDecoration(
                                //             color: Color(0x26DD2025),
                                //             shape: RoundedRectangleBorder(
                                //               side: BorderSide(
                                //                   width: appointmentControl
                                //                           .isCancelled!
                                //                       ? 2
                                //                       : 0,
                                //                   color: Color(0xFFDD2025)),
                                //               borderRadius:
                                //                   BorderRadius.circular(50),
                                //             ),
                                //           ),
                                //           child: Center(
                                //               child: Text(
                                //             'Cancelled',
                                //             style: TextStyle(
                                //               color: Color(0xFFDD2025),
                                //               fontSize: 13,
                                //               fontFamily: 'Open Sans',
                                //               fontWeight: FontWeight.w400,
                                //               height: 0,
                                //               letterSpacing: -0.26,
                                //             ),
                                //           )),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),

                                ListView.builder(
                                  padding: EdgeInsets.zero,
                                  // separatorBuilder: (BuildContext context, int index) => sizedBox10(),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: appointmentHistoryList.length,
                                  itemBuilder: (_, i) {
                                    final appointment = appointmentHistoryList[i];
                                    final patientAppointments = appointment.patientAppointments;
                                    return Visibility(
                                        visible: patientAppointments.isNotEmpty,
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: patientAppointments.length,
                                          itemBuilder: (_, j) {
                                            final patientAppointment =
                                                patientAppointments[j];
                                            //debugPrint(
                                            //     'Patient Appointment: ${patientAppointments[j].branchName}');
                                            return patientAppointment.status == 1?null:Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8.0, vertical: 5),
                                              child: CustomDecoratedContainer(
                                                // verticalPadding: 0,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${AppointmentDateTimeConverter.formatDate(patientAppointment.opdDate.toString())}  ${patientAppointment.opdTime == null || patientAppointment.opdTime!.isEmpty ? '' : patientAppointment.opdTime}',
                                                          style: openSansBold
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSize13,
                                                            color:
                                                                Theme.of(context)
                                                                    .primaryColor,
                                                          ),
                                                        ),
                                                        // Text(
                                                        //   ' (${patientAppointment.status == 0? "Not Visited" : "Visited"})',
                                                        //   style: openSansBold
                                                        //       .copyWith(
                                                        //     fontSize: Dimensions
                                                        //         .fontSize13,
                                                        //     color: patientAppointment.status == 0 ? Colors.red : Colors.green,
                                                        //   ),
                                                        // ),
                                                        Spacer(),
                                                        appointmentControl.apptId == null  ?
                                                        SizedBox() :
                                                        GestureDetector(
                                                          onTap: () async {
                                                            try {
                                                              print(appointmentControl.apptId);
                                                              var response = await appointmentControl.getInvoice(
                                                                patientAppointment.id.toString(),
                                                              );
                                                              if (appointmentControl.apptId != null && appointmentControl.apptId!.isNotEmpty) {
                                                                downloadFile(appointmentControl.apptId!, 'invoice.pdf');
                                                              } else {
                                                                showCustomSnackBar("Invoice not available");
                                                              }
                                                            } catch (e) {
                                                              print("Error: $e");
                                                              showCustomSnackBar("Invoice not available");

                                                            }
                                                          },
                                                          child: Icon(
                                                            Icons.download,
                                                            color:
                                                                Theme.of(context)
                                                                    .primaryColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    sizedBox20(),
                                                    Column(
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            CustomNetworkImageWidget(
                                                              height: 80,
                                                              width: 80,
                                                              image:
                                                                  patientAppointment
                                                                      .branchImage,
                                                            ),
                                                            sizedBoxW10(),
                                                            Expanded(
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  RichText(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Branch: ",
                                                                          style: openSansRegular
                                                                              .copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSize12,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text: patientAppointment
                                                                              .branchName,
                                                                          style: openSansBold
                                                                              .copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSize13,
                                                                            color: Theme.of(context)
                                                                                .disabledColor
                                                                                .withOpacity(0.70),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  sizedBox10(),
                                                                  RichText(
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    text:
                                                                        TextSpan(
                                                                      children: [
                                                                        TextSpan(
                                                                          text:
                                                                              "Name: ",
                                                                          style: openSansRegular
                                                                              .copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSize12,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                          ),
                                                                        ),
                                                                        TextSpan(
                                                                          text:
                                                                              '${appointment.firstName} ${appointment.lastName}',
                                                                          style: openSansBold
                                                                              .copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSize13,
                                                                            color: Theme.of(context)
                                                                                .disabledColor
                                                                                .withOpacity(0.70),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  sizedBox10(),
                                                                  Row(
                                                                    children: [
                                                                      RichText(
                                                                        maxLines: 1,
                                                                        overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                        text:
                                                                            TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text:
                                                                                  "Status: ",
                                                                              style: openSansRegular
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                    Dimensions.fontSize12,
                                                                                color:
                                                                                    Theme.of(context).primaryColor,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text: patientAppointment.status ==
                                                                                      0
                                                                                  ? "Failed"
                                                                                  : patientAppointment.status == 2
                                                                                          ? "Cancelled"
                                                                                          : patientAppointment.status == 3?"Booked":"",
                                                                              style: openSansBold
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                    Dimensions.fontSize13,
                                                                                color: patientAppointment.status ==
                                                                                    0
                                                                                    ? Colors.red
                                                                                    : patientAppointment.status == 1
                                                                                    ? Colors.green
                                                                                    : patientAppointment.status == 2
                                                                                    ? Colors.red
                                                                                    : Theme.of(context)
                                                                                    .disabledColor
                                                                                    .withOpacity(0.70),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Spacer(),
                                                                      // Visibility(
                                                                      //   visible:
                                                                      //   patientAppointment
                                                                      //       .status !=
                                                                      //       2 && patientAppointment.status != 1,
                                                                      //   child: GestureDetector(
                                                                      //     onTap: () {
                                                                      //       appointmentControl.getCancelling(
                                                                      //           patientAppointment
                                                                      //               .id
                                                                      //               .toString());
                                                                      //     },
                                                                      //     child: Text("Cancel",
                                                                      //       style: TextStyle(
                                                                      //         color: Colors.red,
                                                                      //         fontSize: 14,
                                                                      //         fontWeight: FontWeight.bold,
                                                                      //       ),
                                                                      //     ),
                                                                      //   ),
                                                                      // ),
                                                                    ],
                                                                  ),
                                                                  sizedBox10(),

                                                                  // Align(
                                                                  //   alignment: Alignment.centerRight,
                                                                  //   child: GestureDetector(
                                                                  //     onTap: () {
                                                                  //       Get.to(AppointmentDetailsScreen(appointmentHistoryModel: appointmentHistoryList[i],));
                                                                  //     },
                                                                  //     child: Container(
                                                                  //       decoration: BoxDecoration(
                                                                  //         color: Theme.of(context).primaryColor ,
                                                                  //         borderRadius: BorderRadius.circular(Dimensions.radius10),
                                                                  //       ),
                                                                  //       child: Padding(
                                                                  //         padding: const EdgeInsets.all(8.0),
                                                                  //         child: Text(
                                                                  //           'View Details',
                                                                  //           style: openSansSemiBold.copyWith(
                                                                  //             fontSize: Dimensions.fontSize14,
                                                                  //             color: Theme.of(context).cardColor,
                                                                  //           ),
                                                                  //         ),
                                                                  //       ),
                                                                  //     ),
                                                                  //   ),
                                                                  // )
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        sizedBoxDefault(),
                                                        Row(
                                                          children: [
                                                            // Expanded(
                                                            //   child: CustomButtonWidget(
                                                            //     textColor: Theme.of(
                                                            //         context)
                                                            //         .primaryColor,
                                                            //     buttonText:
                                                            //     'Reschedule',
                                                            //     onPressed: () {
                                                            //       // Get.to(
                                                            //       //     AppointmentDetailsScreen(
                                                            //       //       appointmentHistoryModel:
                                                            //       //       appointmentHistoryList[
                                                            //       //       i],
                                                            //       //     ));
                                                            //     },
                                                            //     height: 40,
                                                            //     isBold: false,
                                                            //     fontSize: Dimensions
                                                            //         .paddingSizeDefault,
                                                            //     color: Colors.white
                                                            //   ),
                                                            // ),
                                                            // SizedBox(
                                                            //   width: 10,
                                                            // ),
                                                            // Visibility(
                                                            //   visible:
                                                            //   patientAppointment
                                                            //       .status !=
                                                            //       2,
                                                            //   child: Expanded(
                                                            //     child:
                                                            //     CustomButtonWidget(
                                                            //       buttonText:
                                                            //       'Cancel',
                                                            //       onPressed:
                                                            //           () {
                                                            //         appointmentControl.getCancelling(
                                                            //             patientAppointment
                                                            //                 .id
                                                            //                 .toString());
                                                            //       },
                                                            //       height: 40,
                                                            //       isBold:
                                                            //       false,
                                                            //       fontSize:
                                                            //       Dimensions
                                                            //           .paddingSizeDefault,
                                                            //       color: Theme.of(
                                                            //           context)
                                                            //           .primaryColor,
                                                            //     ),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ));

                                  },
                                ),
                                SizedBox(height: 100)
                              ],
                            ),
                          ),
                        ),
                    ),
                      Visibility(
                          visible: index == 1,
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height-200,
                            child: appointmentHistoryList.isEmpty ||
                                appointmentHistoryList.every((appointment) => appointment.patientAppointments.isEmpty)
                                ? EmptyDataWidget(
                              text: 'Nothing Available',
                              image: Images.icEmptyDataHolder,
                              fontColor: Theme.of(context).disabledColor,
                            ):SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ListView.builder(
                                    padding: EdgeInsets.zero,
                                    // separatorBuilder: (BuildContext context, int index) => sizedBox10(),
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: appointmentHistoryList.length,
                                    itemBuilder: (_, i) {
                                      final appointment = appointmentHistoryList[i];
                                      final patientAppointments =
                                          appointment.patientAppointments;
                                      return Visibility(
                                          visible: patientAppointments.isNotEmpty && index == 1 ,
                                          child: ListView.builder(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            physics:
                                            const NeverScrollableScrollPhysics(),
                                            itemCount: patientAppointments.length,
                                            itemBuilder: (_, j) {
                                              final patientAppointment =
                                              patientAppointments[j];
                                              debugPrint(
                                                  'Patient Appointment: ${patientAppointments[j].status}');
                                              return Visibility(
                                                visible:  patientAppointments[j].status == 1,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                      horizontal: 8.0, vertical: 5),
                                                  child: CustomDecoratedContainer(
                                                    // verticalPadding: 0,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              '${AppointmentDateTimeConverter.formatDate(patientAppointment.opdDate.toString())} ${patientAppointment.opdTime != null ?"-":""} ${(patientAppointment.opdTime ?? "").toString()}',
                                                              style: openSansBold
                                                                  .copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSize13,
                                                                color:
                                                                Theme.of(context)
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                            // Text(
                                                            //   ' (${patientAppointment.status == 0? "Not Visited" : "Visited"})',
                                                            //   style: openSansBold
                                                            //       .copyWith(
                                                            //     fontSize: Dimensions
                                                            //         .fontSize13,
                                                            //     color: patientAppointment.status == 0 ? Colors.red : Colors.green,
                                                            //   ),
                                                            // ),
                                                            Spacer(),
                                                            GestureDetector(
                                                              onTap: () {
                                                                // Get.to(HealthRecordsScreen());
                                                                appointmentControl.getInvoice(
                                                                    patientAppointment
                                                                        .id
                                                                        .toString()).then((value) {
                                                                  if(appointmentControl.apptId != null && appointmentControl.apptId != ""){
                                                                    downloadFile(appointmentControl.apptId, 'invoice.pdf');
                                                                  }

                                                                });

                                                              },
                                                              child: Icon(
                                                                Icons.download,
                                                                color:
                                                                Theme.of(context)
                                                                    .primaryColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        sizedBox20(),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                CustomNetworkImageWidget(
                                                                  height: 80,
                                                                  width: 80,
                                                                  image:
                                                                  patientAppointment
                                                                      .branchImage,
                                                                ),
                                                                sizedBoxW10(),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                    children: [
                                                                      RichText(
                                                                        maxLines: 1,
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                        text:
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text:
                                                                              "Branch: ",
                                                                              style: openSansRegular
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                Dimensions.fontSize12,
                                                                                color:
                                                                                Theme.of(context).primaryColor,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text:
                                                                              // "b",
                                                                              patientAppointment
                                                                                  .branchName,
                                                                              style: openSansBold
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                Dimensions.fontSize13,
                                                                                color: Theme.of(context)
                                                                                    .disabledColor
                                                                                    .withOpacity(0.70),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      sizedBox10(),
                                                                      RichText(
                                                                        maxLines: 1,
                                                                        overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                        text:
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text:
                                                                              "Name: ",
                                                                              style: openSansRegular
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                Dimensions.fontSize12,
                                                                                color:
                                                                                Theme.of(context).primaryColor,
                                                                              ),
                                                                            ),
                                                                            TextSpan(
                                                                              text:
                                                                              // "fndl",
                                                                              '${appointment.firstName} ${appointment.lastName}',
                                                                              style: openSansBold
                                                                                  .copyWith(
                                                                                fontSize:
                                                                                Dimensions.fontSize13,
                                                                                color: Theme.of(context)
                                                                                    .disabledColor
                                                                                    .withOpacity(0.70),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      sizedBox10(),
                                                                      Row(
                                                                        children: [
                                                                          RichText(
                                                                            maxLines: 1,
                                                                            overflow:
                                                                            TextOverflow
                                                                                .ellipsis,
                                                                            text:
                                                                            TextSpan(
                                                                              children: [
                                                                                TextSpan(
                                                                                  text:
                                                                                  "Status: ",
                                                                                  style: openSansRegular
                                                                                      .copyWith(
                                                                                    fontSize:
                                                                                    Dimensions.fontSize12,
                                                                                    color:
                                                                                    Theme.of(context).primaryColor,
                                                                                  ),
                                                                                ),
                                                                                TextSpan(
                                                                                  text: patientAppointment.status ==
                                                                                      0
                                                                                      ? "Failed"
                                                                                      : patientAppointment.status == 1
                                                                                      ? "Confirmed"
                                                                                      : patientAppointment.status == 2
                                                                                      ? "Cancelled"
                                                                                      : "Pending",
                                                                                  style: openSansBold
                                                                                      .copyWith(
                                                                                    fontSize:
                                                                                    Dimensions.fontSize13,
                                                                                    color: patientAppointment.status ==
                                                                                        0
                                                                                        ? Colors.red
                                                                                        : patientAppointment.status == 1
                                                                                        ? Colors.green
                                                                                        : patientAppointment.status == 2
                                                                                        ? Colors.red
                                                                                        : Theme.of(context)
                                                                                        .disabledColor
                                                                                        .withOpacity(0.70),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                      //     Spacer(),
                                                                      //     Visibility(
                                                                      //       visible:
                                                                      //       patientAppointment
                                                                      //           .status !=
                                                                      //           2,
                                                                      //       child: GestureDetector(
                                                                      //         onTap: () {
                                                                      //           appointmentControl.getCancelling(
                                                                      //               patientAppointment
                                                                      //                   .id
                                                                      //                   .toString());
                                                                      //         },
                                                                      //         child: Text("Cancel",
                                                                      //           style: TextStyle(
                                                                      //             color: Colors.red,
                                                                      //             fontSize: 14,
                                                                      //             fontWeight: FontWeight.bold,
                                                                      //           ),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //   ],
                                                                      // ),
                                                                      // sizedBox10(),

                                                                      // Align(
                                                                      //   alignment: Alignment.centerRight,
                                                                      //   child: GestureDetector(
                                                                      //     onTap: () {
                                                                      //       Get.to(AppointmentDetailsScreen(appointmentHistoryModel: appointmentHistoryList[i],));
                                                                      //     },
                                                                      //     child: Container(
                                                                      //       decoration: BoxDecoration(
                                                                      //         color: Theme.of(context).primaryColor ,
                                                                      //         borderRadius: BorderRadius.circular(Dimensions.radius10),
                                                                      //       ),
                                                                      //       child: Padding(
                                                                      //         padding: const EdgeInsets.all(8.0),
                                                                      //         child: Text(
                                                                      //           'View Details',
                                                                      //           style: openSansSemiBold.copyWith(
                                                                      //             fontSize: Dimensions.fontSize14,
                                                                      //             color: Theme.of(context).cardColor,
                                                                      //           ),
                                                                      //         ),
                                                                      //       ),
                                                                      //     ),
                                                                      //   ),
                                                                      // )
                                                                    ],
                                                                  ),
                                                                ]),)
                                                              ],
                                                            ),
                                                            sizedBoxDefault(),
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  child: CustomButtonWidget(
                                                                    textColor: Theme.of(
                                                                        context)
                                                                        .primaryColor,
                                                                    buttonText:
                                                                    'Download Prescription',
                                                                    onPressed: () {
                                                                      appointmentControl.getPrescription(
                                                                          patientAppointment
                                                                              .id
                                                                              .toString()).then((value) {
                                                                        if(appointmentControl.prescription != null && appointmentControl.prescription != ""){
                                                                          downloadFile(appointmentControl.prescription, 'prescription.pdf');
                                                                        }

                                                                      });
                                                                    },
                                                                    height: 40,
                                                                    isBold: false,
                                                                    fontSize: Dimensions
                                                                        .paddingSizeDefault,
                                                                    color: Colors.white
                                                                  ),
                                                                ),
                                                                // SizedBox(
                                                                //   width: 10,
                                                                // ),
                                                                // Visibility(
                                                                //   visible:
                                                                //   patientAppointment
                                                                //       .status !=
                                                                //       2,
                                                                //   child: Expanded(
                                                                //     child:
                                                                //     CustomButtonWidget(
                                                                //       buttonText:
                                                                //       'Cancel',
                                                                //       onPressed:
                                                                //           () {
                                                                //         appointmentControl.getCancelling(
                                                                //             patientAppointment
                                                                //                 .id
                                                                //                 .toString());
                                                                //       },
                                                                //       height: 40,
                                                                //       isBold:
                                                                //       false,
                                                                //       fontSize:
                                                                //       Dimensions
                                                                //           .paddingSizeDefault,
                                                                //       color: Theme.of(
                                                                //           context)
                                                                //           .primaryColor,
                                                                //     ),
                                                                //   ),
                                                                // ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ));
                              
                                    },
                                  ),
                                  // EmptyDataWidget(text: 'Nothing Available',
                                  //   image: Images.icEmptyDataHolder,
                                  //   fontColor: Theme.of(context).disabledColor,),
                                ],
                              ),
                            ),
                          ))
                    ],
                  )),
      );
    });
  }
}
