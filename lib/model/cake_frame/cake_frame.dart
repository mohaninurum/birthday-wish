class CakeFramesResponse {
  final bool status;
  final String message;
  final List<CakeFrame> data;

  CakeFramesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory CakeFramesResponse.fromJson(Map<String, dynamic> json) {
    return CakeFramesResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
          ?.map((e) => CakeFrame.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'message': message,
    'data': data.map((e) => e.toJson()).toList(),
  };
}

class CakeFrame {
  final int cakeFramesPK;
  final String frameType;
  final String cakeFramesImage;
  final String createdAt;

  CakeFrame({
    required this.cakeFramesPK,
    required this.frameType,
    required this.cakeFramesImage,
    required this.createdAt,
  });

  factory CakeFrame.fromJson(Map<String, dynamic> json) {
    return CakeFrame(
      cakeFramesPK: json['cake_frames_PK'] ?? 0,
      frameType: json['frame_type'] ?? '',
      cakeFramesImage: json['cake_frames_image'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'cake_frames_PK': cakeFramesPK,
    'frame_type': frameType,
    'cake_frames_image': cakeFramesImage,
    'created_at': createdAt,
  };
}
