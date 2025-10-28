



class WishesSubCategoryListModel {
  final bool? status;
  final String? message;
  final List<SubCategory>? data;

  WishesSubCategoryListModel({
    this.status,
    this.message,
    this.data,
  });

  factory WishesSubCategoryListModel.fromJson(Map<String, dynamic> json) {
    return WishesSubCategoryListModel(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List?)
          ?.map((e) => SubCategory.fromJson(e ?? {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((e) => e.toJson()).toList(),
  };
}

class SubCategory {
  final int? subCategoryIdPk;
  final int? wishesCategoryIdFk;
  final String? subCategoryName;
  final int? displaySequence;
  final String? createdAt;
  final String? wishesCategoryName;
  final String? wishesCategoryImage;

  SubCategory({
    this.subCategoryIdPk,
    this.wishesCategoryIdFk,
    this.subCategoryName,
    this.displaySequence,
    this.createdAt,
    this.wishesCategoryName,
    this.wishesCategoryImage,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryIdPk: json['subCategory_id_PK'] is int
          ? json['subCategory_id_PK']
          : int.tryParse(json['subCategory_id_PK']?.toString() ?? ''),
      wishesCategoryIdFk: json['wishesCategory_id_FK'] is int
          ? json['wishesCategory_id_FK']
          : int.tryParse(json['wishesCategory_id_FK']?.toString() ?? ''),
      subCategoryName: json['subCategory_name']?.toString(),
      displaySequence: json['display_sequence'] is int
          ? json['display_sequence']
          : int.tryParse(json['display_sequence']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
      wishesCategoryName: json['wishesCategory_name']?.toString(),
      wishesCategoryImage: json['wishesCategory_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'subCategory_id_PK': subCategoryIdPk,
    'wishesCategory_id_FK': wishesCategoryIdFk,
    'subCategory_name': subCategoryName,
    'display_sequence': displaySequence,
    'created_at': createdAt,
    'wishesCategory_name': wishesCategoryName,
    'wishesCategory_image': wishesCategoryImage,
  };
}
