class WishesDetailsListModel {
  final bool status;
  final String message;
  final List<WishesData> data;

  WishesDetailsListModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WishesDetailsListModel.fromJson(Map<String, dynamic> json) {
    return WishesDetailsListModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((e) => WishesData.fromJson(e))
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

class WishesData {
  final int id;
  final int categoryId;
  final String wishes;
  final int subCategoryId;
  final String createdAt;
  final String categoryName;
  final String subCategoryName;

  WishesData({
    required this.id,
    required this.categoryId,
    required this.wishes,
    required this.subCategoryId,
    required this.createdAt,
    required this.categoryName,
    required this.subCategoryName,
  });

  factory WishesData.fromJson(Map<String, dynamic> json) {
    return WishesData(
      id: json['wishes_id_PK'] ?? 0,
      categoryId: json['wishesCategory_id_FK'] ?? 0,
      wishes: json['wishes'] ?? '',
      subCategoryId: json['subCategory_id_FK'] ?? 0,
      createdAt: json['created_at'] ?? '',
      categoryName: json['wishesCategory_name'] ?? '',
      subCategoryName: json['subCategory_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishes_id_PK': id,
      'wishesCategory_id_FK': categoryId,
      'wishes': wishes,
      'subCategory_id_FK': subCategoryId,
      'created_at': createdAt,
      'wishesCategory_name': categoryName,
      'subCategory_name': subCategoryName,
    };
  }
}
