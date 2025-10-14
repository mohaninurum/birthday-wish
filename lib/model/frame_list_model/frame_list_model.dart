class FrameModel {
  final String id;
  final String imageUrl;
  final bool isLocked;
  final String? discount;

  FrameModel({
    required this.id,
    required this.imageUrl,
    this.isLocked = false,
    this.discount,
  });
}
// frame_model.dart

class FrameResponse {
  final bool? status;
  final String? message;
  final List<FrameData>? data;

  FrameResponse({
    this.status,
    this.message,
    this.data,
  });

  factory FrameResponse.fromJson(Map<String, dynamic> json) {
    return FrameResponse(
      status: json['status'] as bool?,
      message: json['message'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) => FrameData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data?.map((item) => item.toJson()).toList(),
  };
}

class FrameData {
  final int? frameIdPk;
  final int? categoryIdFk;
  final String? frameImage;
  final String? createdAt;
  final String? categoryName;

  FrameData({
    this.frameIdPk,
    this.categoryIdFk,
    this.frameImage,
    this.createdAt,
    this.categoryName,
  });

  factory FrameData.fromJson(Map<String, dynamic> json) {
    return FrameData(
      frameIdPk: json['frame_id_PK'] as int?,
      categoryIdFk: json['category_id_FK'] as int?,
      frameImage: json['frame_image'] as String?,
      createdAt: json['created_at'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'frame_id_PK': frameIdPk,
    'category_id_FK': categoryIdFk,
    'frame_image': frameImage,
    'created_at': createdAt,
    'category_name': categoryName,
  };
}
