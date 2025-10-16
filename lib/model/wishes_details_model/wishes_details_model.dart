class WishesDetailsModel {
  final bool status;
  final String message;
  final List<SubCategory> data;

  WishesDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WishesDetailsModel.fromJson(Map<String, dynamic> json) {
    return WishesDetailsModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((e) => SubCategory.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String createdAt;
  final String categoryName;
  final String categoryImage;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.createdAt,
    required this.categoryName,
    required this.categoryImage,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['subCategory_id_PK'] ?? 0,
      categoryId: json['wishesCategory_id_FK'] ?? 0,
      name: json['subCategory_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryName: json['wishesCategory_name'] ?? '',
      categoryImage: json['wishesCategory_image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subCategory_id_PK': id,
      'wishesCategory_id_FK': categoryId,
      'subCategory_name': name,
      'created_at': createdAt,
      'wishesCategory_name': categoryName,
      'wishesCategory_image': categoryImage,
    };
  }
}
