import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iclinix/app/drawer/help_screen.dart';
import 'package:iclinix/app/screens/appointment/booking_successful_screen.dart';
import 'package:iclinix/app/screens/appointment/patient_details_screen.dart';
import 'package:iclinix/app/screens/appointment/payment_screen.dart';
import 'package:iclinix/app/screens/appointment/select_slot_screen.dart';
import 'package:iclinix/app/screens/auth/lets_begin_screen.dart';
import 'package:iclinix/app/screens/auth/login_screen.dart';
import 'package:iclinix/app/screens/auth/otp_verification_screen.dart';
import 'package:iclinix/app/screens/auth/register_screen.dart';
import 'package:iclinix/app/screens/chat/messaging.dart';
import 'package:iclinix/app/screens/dashboard/dashboard_screen.dart';
import 'package:iclinix/app/screens/diabetic/add_plan_patient_details.dart';
import 'package:iclinix/app/screens/chat/chat_screen.dart';
import 'package:iclinix/app/screens/diabetic/diabetic_dashboard.dart';
import 'package:iclinix/app/screens/diabetic/payment_successful_screen.dart';
import 'package:iclinix/app/screens/diabetic/resource_details_screen.dart';
import 'package:iclinix/app/screens/home/components/view_all_services_screen.dart';
import 'package:iclinix/app/screens/home/service_details_screen.dart';
import 'package:iclinix/app/screens/notification/notification_screen.dart';
import 'package:iclinix/app/screens/onboard/splash.dart';
import 'package:iclinix/app/screens/search/search_screen.dart';
import 'package:iclinix/data/models/response/ticket_model.dart';

import '../app/screens/SubsScriptionHistory/susb_history.dart';
import '../app/screens/appointment/appointment_screen.dart';
import '../app/screens/chat/all_Tickets_screen.dart';
import '../app/screens/diabetic/plan_payment_screen.dart';
import '../data/models/body/appointment_model.dart';
import '../data/models/response/clinic_model.dart';

class RouteHelper {
  static const String initial = '/';
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String otpVerification = '/otp-verification';
  static const String letsBegin = '/lets-begin';
  static const String dashboard = '/dashboard';
  static const String selectSlot = '/select-slot';
  static const String patientDetails = '/patient-details';
  static const String paymentMethod = '/payment-method';
  static const String bookingSuccessful = '/payment-successful';
  static const String allServices = '/all-services';
  static const String clinic = '/clinic';
  static const String notification = '/notification';
  static const String search = '/search';
  static const String help = '/help';
  static const String subsHistory = '/subsHistory';
  static const String message = '/message';
  static const String serviceDetail = '/service-detail';
  static const String planPatientDetails = '/plan-patient-details';
  static const String diabeticDashboard = '/diabetic-dashboard';
  static const String planPayment = '/plan-payment';
  static const String planPaymentSuccessful = '/plan-payment-successful';
  static const String resourcesDetails = '/resources-details';
  static const String chat = '/chat';
  static const String replies = '/replies';

  /// Routes ==================>
  static String getInitialRoute() => initial;

  static String getSplashRoute() => splash;

  static String getLoginRoute() => login;

  static String getRegisterRoute() => register;

  static String getOtpVerificationRoute(
    String? phoneNo,
  ) =>
      '$otpVerification?phoneNo=$phoneNo';

  static String getLetsBeginRoute() => letsBegin;

  static String getDashboardRoute() => dashboard;

  // static String getSelectSlotRoute() => selectSlot;
  static String getSelectSlotRoute(
    String? branchImg,
    String? branchName,
    String? branchContactNo,
    String? clinicId,
  ) =>
      '$selectSlot?branchImg=$branchImg&branchName=$branchName&branchContactNo=$branchContactNo&clinicId=$clinicId';

  static String getAddPatientDetailsRoute(
    String? appointmentDate,
    String? appointmentTime,
    String? clinicId,
  ) =>
      '$patientDetails?appointmentDate=$appointmentDate&appointmentTime=$appointmentTime&clinicId=$clinicId';

  static String getPaymentMethodRoute() => paymentMethod;

  static String getBookingSuccessfulRoute(
          String? bookingTime, String? bookingDate, String? apptId) =>
      '$bookingSuccessful?bookingTime=$bookingTime&bookingDate=$bookingDate&apptId=$apptId';

  static String getAllServicesRoute() => allServices;

  static String getAllClinicRoute({bool isBackButton = false}) =>
      '$clinic?isBackButton=${isBackButton.toString()}';

  static String getNotificationRoute() => notification;

  static String getSearchRoute() => search;

  static String getHelpRoute() => help;
  static String getSubsHistoryRoute() => subsHistory;

  static String getMessageRoute() => message;

  static String getServiceDetailRoute(
    String? id,
    String? title,
  ) =>
      '$serviceDetail?id=$id&title=$title';

  static String getAddPlanPatientDetailsRoute(String? planId) =>
      '$planPatientDetails?planId=$planId';

  static String getDiabeticDashboardRoute() => diabeticDashboard;

  static String getPlanPaymentRoute(
    String? patientId,
    String? planId,
  ) =>
      '$planPayment?patientId=$patientId&planId=$planId';

  // static String getPlanPaymentRoute() => planPayment;
  static String getPlanPaymentSuccessfulRoute() => planPaymentSuccessful;

  static String getResourcesDetailsRoute(
    String? id,
    String? name,
  ) =>
      '$resourcesDetails?id=$id&name=$name';

  static String getChatRoute() => chat;

  static String getRepliesRoute() => replies;

  /// Pages ==================>
  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(name: register, page: () => RegisterScreen()),
    GetPage(
        name: otpVerification,
        page: () => OtpVerificationScreen(phoneNo: Get.parameters['phoneNo'])),
    GetPage(name: dashboard, page: () => const DashboardScreen(pageIndex: 0)),
    GetPage(
        name: selectSlot,
        page: () => SelectSlotScreen(
              branchImg: Get.parameters['branchImg'],
              branchName: Get.parameters['branchName'],
              branchContactNo: Get.parameters['branchContactNo'],
              clinicId: Get.parameters['clinicId'],
            )),
    // GetPage(
    //   name: selectSlot,
    //   page: () => SelectSlotScreen(clinicModel: Get.arguments as ClinicModel?), // Get the argument passed during navigation
    // ),

    // GetPage(
    //   name: RouteHelper.selectSlot,
    //   page: () => SelectSlotScreen(model: Get.arguments['model'], isSearchModel: Get.arguments['isSearchModel']),
    // ),
    // GetPage(name: selectSlot, page: () =>  SelectSlotScreen()),
    GetPage(name: letsBegin, page: () => LetsBeginScreen()),
    GetPage(
        name: patientDetails,
        page: () => PatientDetailsScreen(
              appointmentDate: Get.parameters['appointmentDate'],
              appointmentTime: Get.parameters['appointmentTime'],
              clinicId: Get.parameters['clinicId'],
            )),
    GetPage(
      name: paymentMethod,
      page: () {
        // Extract the appointment model from arguments
        final AppointmentModel appointmentModel = Get.arguments;
        return PaymentScreen(appointmentModel: appointmentModel);
      },
    ),
    GetPage(
        name: bookingSuccessful,
        page: () => BookingSuccessfulScreen(
              time: Get.parameters['bookingTime'],
              date: Get.parameters['bookingDate'],
              apptId: Get.parameters['apptId'],
            )),
    GetPage(name: allServices, page: () => const ViewAllServicesScreen()),
    GetPage(
        name: clinic,
        page: () => AppointmentScreen(
            isBackButton: Get.parameters['isBackButton'] == 'true')),
    GetPage(name: notification, page: () => const NotificationScreen()),
    GetPage(name: search, page: () => SearchScreen()),
    GetPage(name: help, page: () => const HelpScreen()),
    GetPage(name: subsHistory, page: () => const SubsHistory()),
    GetPage(
        name: serviceDetail,
        page: () => ServiceDetailsScreen(
              id: Get.parameters['id'],
              title: Get.parameters['title'],
            )),
    GetPage(
        name: planPatientDetails,
        page: () => AddPlanPatientDetails(
              planId: Get.parameters['planId'],
            )),
    GetPage(name: diabeticDashboard, page: () => DiabeticDashboard()),
    GetPage(
        name: planPayment,
        page: () => PlanPaymentScreen(
              patientId: Get.parameters['patientId'],
              planId: Get.parameters['planId'],
            )),
    GetPage(
        name: planPaymentSuccessful,
        page: () => const PlanBookingSuccessfulScreen()),
    GetPage(
        name: resourcesDetails,
        page: () => ResourceDetailsScreen(
              id: Get.parameters['id'],
              name: Get.parameters['name'],
            )),
    GetPage(name: chat, page: () => ChatScreen()),
    GetPage(name: message, page: () => AllTicketsScreen()),
    GetPage(
      name: replies,
      page: () {
        debugPrint('Arguments: ${Get.arguments}');
        // Extract the appointment model from arguments
        final List<TicketReply> replies = Get.arguments['replies'];
        final String id = Get.arguments['id'];
        final String subject = Get.arguments['subject'];
        return Messaging(replies: replies, id: id, subject: subject,);
      },
    ),
  ];
}
