
class AppConstants {
  static const String baseUrl = "https://lab5.invoidea.in/iclinix/public/api/";
  static const String appName = 'IClinix';
  static const double appVersion = 1.0;
  static const String fontFamily = 'OpenSans';

  /// Api Url ///

  static const String sendOtpUrl = "authenticate";
  static const String verifyOtpUrl = "verify-otp";
  static const String updateProfileUrl = "update/my-profile";
  static const String myProfileUrl = "my-profile";
  static const String privacyUrl = "page/";
  static const String planListUrl = "plan-list";
  static const String clinicListUrl = "clinic-list";
  static const String patientListUrl = "patient-list";
  static const String slotListUrl = "get-general-slots";
  static const String bookAppointmentUrl = "book-appointment";
  static const String serviceListUrl = "service-list";
  static const String appointmentListUrl = "appointment-history";
  static const String searchListUrl = "search";
  static const String serviceDetails = "service/";
  static const String addPatientDetails = "add-patient";
  static const String postDataBack = "android-webhook";
  static const String postDataBackPlans = "subs-android-webhook";
  static const String postDataBackPlansRenew = "renew-subs-android-webhook";
  static const String cancellation = "cancel-appointment";
  static const String invoiceDownload = "appt-invoice/download/";
  static const String invoiceDownloadSubs = "subscription-invoice/download/";
  static const String prescription = "prescription/download/";
  static const String subscriptionCheckout = "subscription-checkout";
  static const String subscriptionCheckoutRenew = "renew-subscription-checkout";
  static const String referEarn = "refer-earn/banners";
  static const String discountApi = "book-appointment/banners";
  static const String diabeticBanner = "schedule-appointment/banners";
  static const String dailySugarCheckup = "daily-checkup";
  static const String diabeticDashboard = "dashboard";
  static const String healthCheckup = "update-body-data";
  static const String resourceContent = "resouce-content";
  static const String subscribedPatientDetails = "subscribed-patient-details";
  static const String storeHealthGoal = "store/health-goal";
  static const String fetchHealthGoal = "get/health-goal";



  /// image url ///
  static const String serviceImageUrl = "https://lab5.invoidea.in/iclinix/public/serviceImage/";
  static const String branchImageUrl = "https://lab5.invoidea.in/iclinix/public/branch_image/";
  static const String resourcesImageUrl = "https://lab5.invoidea.in/iclinix/public/diabetic_resource/";

  // Shared Key
  static const String theme = 'theme';
  static const String subscription = 'subscription';
  static const String intro = 'intro';
  static const String token = 'token';
  static const String savedSubscription = 'savedSubscription';


}
