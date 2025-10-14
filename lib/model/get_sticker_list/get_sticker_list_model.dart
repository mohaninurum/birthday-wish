class StickerResponse {
  final bool status;
  final String message;
  final List<StickerData> data;

  StickerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory StickerResponse.fromJson(Map<String, dynamic> json) {
    return StickerResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => StickerData.fromJson(e as Map<String, dynamic>))
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

class StickerData {
  final int stickerIdPk;
  final int categoryIdFk;
  final String stickerImage;
  final String createdAt;
  final String categoryName;

  StickerData({
    required this.stickerIdPk,
    required this.categoryIdFk,
    required this.stickerImage,
    required this.createdAt,
    required this.categoryName,
  });

  factory StickerData.fromJson(Map<String, dynamic> json) {
    return StickerData(
      stickerIdPk: json['sticker_id_PK'] ?? 0,
      categoryIdFk: json['category_id_FK'] ?? 0,
      stickerImage: json['sticker_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sticker_id_PK': stickerIdPk,
      'category_id_FK': categoryIdFk,
      'sticker_image': stickerImage,
      'created_at': createdAt,
      'category_name': categoryName,
    };
  }
}
