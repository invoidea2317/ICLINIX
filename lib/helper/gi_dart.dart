
import 'package:get/get.dart';
import 'package:iclinix/controller/appointment_controller.dart';
import 'package:iclinix/controller/auth_controller.dart';
import 'package:iclinix/controller/clinic_controller.dart';
import 'package:iclinix/controller/profile_controller.dart';
import 'package:iclinix/controller/subshistory_controller.dart';
import 'package:iclinix/data/api/api_client.dart';
import 'package:iclinix/data/repo/appointment_repo.dart';
import 'package:iclinix/data/repo/auth_repo.dart';
import 'package:iclinix/data/repo/clinic_repo.dart';
import 'package:iclinix/data/repo/diabetic_repo.dart';
import 'package:iclinix/data/repo/profile_repo.dart';
import 'package:iclinix/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/chat_controller.dart';
import '../controller/diabetic_controller.dart';


Future<void>   init() async {

  /// Repository
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.baseUrl, sharedPreferences: Get.find()));



  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ProfileRepo(apiClient: Get.find()));
  Get.lazyPut(() => AppointmentRepo(apiClient: Get.find()));
  Get.lazyPut(() => ClinicRepo(apiClient: Get.find()));
  Get.lazyPut(() => DiabeticRepo(apiClient: Get.find()));



  /// Controller
  Get.lazyPut(() => AuthController(authRepo: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => AppointmentController(appointmentRepo:  Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => ClinicController(clinicRepo:  Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => ProfileController(profileRepo: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => DiabeticController(diabeticRepo: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => ChatController(clinicRepo: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => SubsHistoryController(clinicRepo: Get.find(), apiClient: Get.find()));



}
