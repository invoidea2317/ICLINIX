class ServicesModel {
  final int id;
  final String name;
  final String image;
  final String description;
  final int sortOrder;
  final int status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bannerUrl;
  final String? videoUrl;
  final String? videoTitle;

  ServicesModel({
    required this.id,
    this.bannerUrl,
    required this.name,
    required this.description,
    required this.image,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    this.videoUrl,
    this.videoTitle,
    this.updatedAt,
  });


  factory ServicesModel.fromJson(Map<String, dynamic> json) {
    return ServicesModel(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      sortOrder: json['sort_order'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      bannerUrl: json['banner_url'],
      videoUrl: json['video_url'],
      videoTitle: json['video_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'description': description,
      'sort_order': sortOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'banner_url': bannerUrl,
      'video_url': videoUrl,
      'video_title': videoTitle,
    };
  }
}
