// SugarCheckupModel.dart
class SugarChartModel {
  final DateTime testDate;
  final int? postMeal;
  final int? fastingValues;

  SugarChartModel({
    required this.testDate,
    this.postMeal,
    required this.fastingValues,
  });

  factory SugarChartModel.fromJson(Map<String, dynamic> json) {
    return SugarChartModel(
      testDate: DateTime.parse(json['test_date']),
      postMeal: json['post_meal'] != null ? (json['post_meal'] as num).toInt() : null,
      fastingValues: json['fasting_values'],
    );
  }
}

// PlanResourceModel.dart
class PlanResourceModel {
  final int id;
  final int type;
  final String name;
  final String sortDescription;
  final String? ytUrl; // Change to String?
  final String file;
  final String fileUrl;

  PlanResourceModel({
    required this.id,
    required this.type,
    required this.name,
    required this.sortDescription,
    this.ytUrl, // Optional parameter
    required this.file,
    required this.fileUrl,
  });

  factory PlanResourceModel.fromJson(Map<String, dynamic> json) {
    return PlanResourceModel(
      id: json['id'],
      type: json['type'],
      name: json['name'],
      sortDescription: json['sort_description'],
      ytUrl: json['yt_url'], // This can be null
      file: json['file'] ?? '', // Default to empty string if null
      fileUrl: json['file_url'] ?? '', // Default to empty string if null
    );
  }
}



// PlanDetailsModel.dart
class PlanDetailsModel {
  final int? planId;
  final String planName;
  final int? price;
  final int? discount;
  final int? sellingPrice;
  final int? discountType;
  final int? duration;
  final String? sortDesc;
  final String? description;
  final String? tagLine;
  final int? status;
  final int? sortOrder;
  final DateTime createdAt;
  final DateTime updateAt;
  final SubscriptionModel? subscription;
  final List<PlanResourceModel> planResources;

  PlanDetailsModel( {
    required this.planId,
    required this.planName,
    required this.price,
    required this.discount,
    required this.sellingPrice,
    required this.discountType,
    required this.duration,
    required this.sortDesc,
    required this.description,
    required this.tagLine,
    required this.status,
    required this.sortOrder,
    required this.createdAt,
    required this.updateAt,
    required this.planResources,
    required this.subscription,
  });

  factory PlanDetailsModel.fromJson(Map<String, dynamic> json) {
    return PlanDetailsModel(
      planId: json['plan_id'],
      planName: json['plan_name'],
      price: json['price'],
      discount: json['discount'],
      sellingPrice: json['selling_price'],
      discountType: json['discount_type'],
      duration: json['duration'],
      sortDesc: json['sort_desc'],
      description: json['description'],
      tagLine: json['tag_line'],
      status: json['status'],
      sortOrder: json['sort_order'],
      createdAt: DateTime.parse(json['created_at']),
      updateAt: DateTime.parse(json['update_at']),
      planResources: (json['plan_resources'] as List)
          .map((item) => PlanResourceModel.fromJson(item))
          .toList(),
      subscription: SubscriptionModel.fromJson(json['subscription']??{}),
    );
  }
}



class SubscriptionModel {
  final int? subscriptionId;
  final String? subscriptionUniqueId;
  final int? patientId;
  final int? userId;
  final int? planId;
  final int? subsHistoryId;
  final int? status;
  final String? expiredAt;
  final int? expired;
  final String? canceledAt;
  final String? createdAt;
  final String? updatedAt;

  SubscriptionModel({
    required this.subscriptionId,
    required this.subscriptionUniqueId,
    required this.patientId,
    required this.userId,
    required this.planId,
    required this.subsHistoryId,
    required this.status,
    required this.expiredAt,
    required this.expired,
    this.canceledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a SubscriptionModel from a JSON object
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      subscriptionId: json['subscription_id'] ,
      subscriptionUniqueId: json['subscription_unique_id'],
      patientId: json['patient_id'] ,
      userId: json['user_id'] ,
      planId: json['plan_id'],
      subsHistoryId: json['subs_history_id'] ,
      status: json['status'] ,
      expiredAt: json['expired_at'] ,
      expired: json['expired'] ,
      canceledAt: json['canceled_at'] ,
      createdAt: json['created_at'] ,
      updatedAt: json['updated_at'],
    );
  }

  // Method to convert the SubscriptionModel object to a JSON object
  Map<String, dynamic> toJson() {
    return {
      'subscription_id': subscriptionId,
      'subscription_unique_id': subscriptionUniqueId,
      'patient_id': patientId,
      'user_id': userId,
      'plan_id': planId,
      'subs_history_id': subsHistoryId,
      'status': status,
      'expired_at': expiredAt,
      'expired': expired,
      'canceled_at': canceledAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

// DietPlanModel.dart
class DietPlanModel {
  final int id;
  final int patientId;
  final int appointmentId;
  final String excerciseChart;
  final String dietchart;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  DietPlanModel({
    required this.id,
    required this.patientId,
    required this.appointmentId,
    required this.excerciseChart,
    required this.dietchart,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      id: json['id'],
      patientId: json['patient_id'],
      appointmentId: json['appointment_id'],
      excerciseChart: json['excercise_chart'],
      dietchart: json['dietchart'],
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}



