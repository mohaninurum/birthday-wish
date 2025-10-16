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

// class FrameResponse {
//   final bool? status;
//   final String? message;
//   final List<FrameData>? data;
//
//   FrameResponse({
//     this.status,
//     this.message,
//     this.data,
//   });
//
//   factory FrameResponse.fromJson(Map<String, dynamic> json) {
//     return FrameResponse(
//       status: json['status'] as bool?,
//       message: json['message'] as String?,
//       data: (json['data'] as List<dynamic>?)
//           ?.map((item) => FrameData.fromJson(item as Map<String, dynamic>))
//           .toList(),
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'status': status,
//     'message': message,
//     'data': data?.map((item) => item.toJson()).toList(),
//   };
// }

// class FrameData {
//   final int? frameIdPk;
//   final int? categoryIdFk;
//   final String? frameImage;
//   final String? createdAt;
//   final String? categoryName;
//
//   FrameData({
//     this.frameIdPk,
//     this.categoryIdFk,
//     this.frameImage,
//     this.createdAt,
//     this.categoryName,
//   });
//
//   factory FrameData.fromJson(Map<String, dynamic> json) {
//     return FrameData(
//       frameIdPk: json['frame_id_PK'] as int?,
//       categoryIdFk: json['category_id_FK'] as int?,
//       frameImage: json['frame_image'] as String?,
//       createdAt: json['created_at'] as String?,
//       categoryName: json['category_name'] as String?,
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'frame_id_PK': frameIdPk,
//     'category_id_FK': categoryIdFk,
//     'frame_image': frameImage,
//     'created_at': createdAt,
//     'category_name': categoryName,
//   };
// }




// lib/model/frame_list_model/frame_list_model.dart
// class FrameResponse {
//   final bool? status;
//   final String? message;
//   final List<FrameData>? data;
//
//   FrameResponse({this.status, this.message, this.data});
//
//   factory FrameResponse.fromJson(Map<String, dynamic> j) {
//     return FrameResponse(
//       status: j['status'] as bool?,
//       message: j['message'] as String?,
//       data: (j['data'] as List?)
//           ?.map((e) => FrameData.fromJson(e as Map<String, dynamic>))
//           .toList(),
//     );
//   }
// }
//
// class FrameData {
//   final int? frameIdPK;
//   final int? categoryIdFK;
//   final String? frameImage;
//   final String? categoryName;
//
//   // NEW: 1 = Single, 2+ = Multiple
//   final int slots;
//
//   FrameData({
//     this.frameIdPK,
//     this.categoryIdFK,
//     this.frameImage,
//     this.categoryName,
//     this.slots = 1,
//   });
//
//   factory FrameData.fromJson(Map<String, dynamic> j) {
//     return FrameData(
//       frameIdPK: j['frame_id_PK'] as int?,
//       categoryIdFK: j['category_id_FK'] as int?,
//       // sanitize in case of spaces
//       frameImage: (j['frame_image'] as String?)?.replaceAll(' ', ''),
//       categoryName: j['category_name'] as String?,
//       slots: (j['slots'] as num?)?.toInt() ?? 1,
//     );
//   }
//
// }



////////////////////

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
      data: (json['data'] as List?)
          ?.map((item) => FrameData.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
    };
  }
}

class FrameData {
  final int? frameId;
  final int? categoryId;
  final String? frameImage;
  final String? createdAt;
  final String? frameSlot;
  final String? categoryName;

  FrameData({
    this.frameId,
    this.categoryId,
    this.frameImage,
    this.createdAt,
    this.frameSlot,
    this.categoryName,
  });

  factory FrameData.fromJson(Map<String, dynamic> json) {
    return FrameData(
      frameId: json['frame_id_PK'] != null
          ? int.tryParse(json['frame_id_PK'].toString())
          : null,
      categoryId: json['category_id_FK'] != null
          ? int.tryParse(json['category_id_FK'].toString())
          : null,
      frameImage: json['frame_image'] as String?,
      createdAt: json['created_at'] as String?,
      frameSlot: json['frame_slot']?.toString(),
      categoryName: json['category_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'frame_id_PK': frameId,
      'category_id_FK': categoryId,
      'frame_image': frameImage,
      'created_at': createdAt,
      'frame_slot': frameSlot,
      'category_name': categoryName,
    };
  }
}
