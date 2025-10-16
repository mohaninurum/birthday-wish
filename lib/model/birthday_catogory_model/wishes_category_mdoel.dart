class WishesCategoryResponse {
  final bool status;
  final String message;
  final List<WishesCategory> data;

  WishesCategoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory WishesCategoryResponse.fromJson(Map<String, dynamic> json) {
    return WishesCategoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((item) => WishesCategory.fromJson(item))
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

class WishesCategory {
  final int id;
  final String name;
  final String image;
  final String createdAt;

  WishesCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
  });

  factory WishesCategory.fromJson(Map<String, dynamic> json) {
    return WishesCategory(
      id: json['wishesCategory_id_PK'] ?? 0,
      name: json['wishesCategory_name'] ?? '',
      image: json['wishesCategory_image'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'wishesCategory_id_PK': id,
      'wishesCategory_name': name,
      'wishesCategory_image': image,
      'created_at': createdAt,
    };
  }
}
