import 'dart:convert';

class TemplateResponse {
  final List<Template> templates;

  TemplateResponse({required this.templates});

  factory TemplateResponse.fromJson(Map<String, dynamic> json) {
    return TemplateResponse(
      templates: (json['templates'] as List?)
          ?.map((e) => Template.fromJson(e))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'templates': templates.map((e) => e.toJson()).toList(),
  };
}

class Template {
  final String frameType;
  final List<Item> items;
  final List<BackgroundItem> backgrounds;
  final Frame? frame;

  Template({
    required this.frameType,
    required this.items,
    required this.backgrounds,
    this.frame,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    // background1 may contain multiple image objects or be null
    final bgData = json['background1'];
    List<BackgroundItem> bgList = [];

    if (bgData is List) {
      for (var bg in bgData) {
        if (bg is Map<String, dynamic>) {
          bgList.add(BackgroundItem.fromJson(bg));
        }
      }
    }

    return Template(
      frameType: json['frameType'] ?? '',
      items: (json['items'] as List?)
          ?.map((e) => Item.fromJson(e))
          .toList() ??
          [],
      backgrounds: bgList,
      frame:
      json['frame'] != null ? Frame.fromJson(json['frame']) : Frame(value: ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'frameType': frameType,
    'items': items.map((e) => e.toJson()).toList(),
    'background1': backgrounds.map((e) => e.toJson()).toList(),
    'frame': frame?.toJson(),
  };
}

class Item {
  final double scale;
  final double rotation;
  final Position position;
  final String fontFamily;
  final String value;
  final double fontSize;
  final String fontWeight;
  final int color;
  final String fontStyle;
  final String type;

  Item({
    required this.scale,
    required this.rotation,
    required this.position,
    required this.fontFamily,
    required this.value,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.fontStyle,
    required this.type,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      scale: (json['scale'] ?? 1.0).toDouble(),
      rotation: (json['rotation'] ?? 0.0).toDouble(),
      position: json['position'] != null
          ? Position.fromJson(json['position'])
          : Position(dx: 0.0, dy: 0.0),
      fontFamily: json['fontFamily'] ?? '',
      value: json['value'] ?? '',
      fontSize: (json['fontSize'] ?? 14.0).toDouble(),
      fontWeight: json['fontWeight'] ?? 'FontWeight.normal',
      color: json['color'] ?? 0xFF000000,
      fontStyle: json['fontStyle'] ?? 'FontStyle.normal',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'scale': scale,
    'rotation': rotation,
    'position': position.toJson(),
    'fontFamily': fontFamily,
    'value': value,
    'fontSize': fontSize,
    'fontWeight': fontWeight,
    'color': color,
    'fontStyle': fontStyle,
    'type': type,
  };
}

class BackgroundItem {
  final String type;
  final Position position;
  final double rotation;
  final double scale;
  final String value;

  BackgroundItem({
    required this.type,
    required this.position,
    required this.rotation,
    required this.scale,
    required this.value,
  });

  factory BackgroundItem.fromJson(Map<String, dynamic> json) {
    return BackgroundItem(
      type: json['type'] ?? '',
      position: json['position'] != null
          ? Position.fromJson(json['position'])
          : Position(dx: 0.0, dy: 0.0),
      rotation: (json['rotation'] ?? 0.0).toDouble(),
      scale: (json['scale'] ?? 1.0).toDouble(),
      value: json['value'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'position': position.toJson(),
    'rotation': rotation,
    'scale': scale,
    'value': value,
  };
}

class Frame {
  final String value;

  Frame({required this.value});

  factory Frame.fromJson(Map<String, dynamic> json) {
    return Frame(value: json['value'] ?? '');
  }

  Map<String, dynamic> toJson() => {'value': value};
}

class Position {
  final double dx;
  final double dy;

  Position({required this.dx, required this.dy});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      dx: (json['dx'] ?? 0.0).toDouble(),
      dy: (json['dy'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'dx': dx,
    'dy': dy,
  };
}
