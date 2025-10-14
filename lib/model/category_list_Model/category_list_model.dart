class CategoryResponse {
  final bool status;
  final String message;
  final List<CategoryData> data;

  CategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CategoryResponse.fromJson(Map<String, dynamic> json) {
    return CategoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => CategoryData.fromJson(e as Map<String, dynamic>))
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

class CategoryData {
  final int categoryIdPk;
  final String categoryName;
  final String createdAt;
  final String? modifiedAt;

  CategoryData({
    required this.categoryIdPk,
    required this.categoryName,
    required this.createdAt,
    this.modifiedAt,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      categoryIdPk: json['category_id_PK'] ?? 0,
      categoryName: json['category_name'] ?? '',
      createdAt: json['created_at'] ?? '',
      modifiedAt: json['modified_at'], // nullable
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category_id_PK': categoryIdPk,
      'category_name': categoryName,
      'created_at': createdAt,
      'modified_at': modifiedAt,
    };
  }
}
