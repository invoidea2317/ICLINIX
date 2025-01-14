class SubscribedPatientModel {
  final int? id;
  final int? userId;
  final int? parentId;
  final int? apiRegid;
  final int? branchid;
  final String? regdate;
  final String? regtime;
  final String? initial;
  final String? firstname;
  final String? lastname;
  final String? careoftype;
  final String? careofname;
  final String? mobileno;
  final String? emmergencyno;
  final String? phoneres;
  final String? sex;
  final String? dob;
  final int? ageyear;
  final int? agemonth;
  final int? agedays;
  final String? areaname;
  final String? pincode;
  final String? patientaddress;
  final String? cityname;
  final String? districtname;
  final String? statename;
  final String? countryname;
  final String? sourcename;
  final String? occupation;
  final String? partyname;
  final String? emailaddress;
  final String? adharcardno;
  final String? vip;
  final String? isdisabled;
  final String? nationality;
  final int? createSource;
  final int? diabetesProblem;
  final int? bpProblem;
  final int? eyeProblem;
  final String? height;
  final String? weight;
  final String? waistCircumference;
  final String? hipCircumference;
  final Map<String,dynamic>? duraDiabetes;
  final String? createdAt;
  final String? updatedAt;

  SubscribedPatientModel({
    this.id,
    this.userId,
    this.parentId,
    this.apiRegid,
    this.branchid,
    this.regdate,
    this.regtime,
    this.initial,
    this.firstname,
    this.lastname,
    this.careoftype,
    this.careofname,
    this.mobileno,
    this.emmergencyno,
    this.phoneres,
    this.sex,
    this.dob,
    this.ageyear,
    this.agemonth,
    this.agedays,
    this.areaname,
    this.pincode,
    this.patientaddress,
    this.cityname,
    this.districtname,
    this.statename,
    this.countryname,
    this.sourcename,
    this.occupation,
    this.partyname,
    this.emailaddress,
    this.adharcardno,
    this.vip,
    this.isdisabled,
    this.nationality,
    this.createSource,
    this.diabetesProblem,
    this.bpProblem,
    this.eyeProblem,
    this.height,
    this.weight,
    this.waistCircumference,
    this.hipCircumference,
    this.duraDiabetes,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscribedPatientModel.fromJson(Map<String, dynamic> json) {
    return SubscribedPatientModel(
      id: json['id'],
      userId: json['user_id'],
      parentId: json['parent_id'],
      apiRegid: json['api_regid'],
      branchid: json['branchid'],
      regdate: json['regdate'],
      regtime: json['regtime'],
      initial: json['initial'],
      firstname: json['firstname'],
      lastname: json['lastname'],
      careoftype: json['careoftype'],
      careofname: json['careofname'],
      mobileno: json['mobileno'],
      emmergencyno: json['emmergencyno'],
      phoneres: json['phoneres'],
      sex: json['sex'],
      dob: json['dob'],
      ageyear: json['ageyear'],
      agemonth: json['agemonth'],
      agedays: json['agedays'],
      areaname: json['areaname'],
      pincode: json['pincode'],
      patientaddress: json['patientaddress'],
      cityname: json['cityname'],
      districtname: json['districtname'],
      statename: json['statename'],
      countryname: json['countryname'],
      sourcename: json['sourcename'],
      occupation: json['occupation'],
      partyname: json['partyname'],
      emailaddress: json['emailaddress'],
      adharcardno: json['adharcardno'],
      vip: json['vip'],
      isdisabled: json['isdisabled'],
      nationality: json['nationality'],
      createSource: json['create_source'],
      diabetesProblem: json['diabetes_problem'],
      bpProblem: json['bp_problem'],
      eyeProblem: json['eye_problem'],
      height: json['height'],
      weight: json['weight'],
      waistCircumference: json['waist_circumference'],
      hipCircumference: json['hip_circumference'],
      duraDiabetes: json['dura_diabetes'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'parent_id': parentId,
      'api_regid': apiRegid,
      'branchid': branchid,
      'regdate': regdate,
      'regtime': regtime,
      'initial': initial,
      'firstname': firstname,
      'lastname': lastname,
      'careoftype': careoftype,
      'careofname': careofname,
      'mobileno': mobileno,
      'emmergencyno': emmergencyno,
      'phoneres': phoneres,
      'sex': sex,
      'dob': dob,
      'ageyear': ageyear,
      'agemonth': agemonth,
      'agedays': agedays,
      'areaname': areaname,
      'pincode': pincode,
      'patientaddress': patientaddress,
      'cityname': cityname,
      'districtname': districtname,
      'statename': statename,
      'countryname': countryname,
      'sourcename': sourcename,
      'occupation': occupation,
      'partyname': partyname,
      'emailaddress': emailaddress,
      'adharcardno': adharcardno,
      'vip': vip,
      'isdisabled': isdisabled,
      'nationality': nationality,
      'create_source': createSource,
      'diabetes_problem': diabetesProblem,
      'bp_problem': bpProblem,
      'eye_problem': eyeProblem,
      'height': height,
      'weight': weight,
      'waist_circumference': waistCircumference,
      'hip_circumference': hipCircumference,
      'dura_diabetes': duraDiabetes,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
