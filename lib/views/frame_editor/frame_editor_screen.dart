



import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:text_editor/text_editor.dart';

import '../../model/frame_list_model/frame_list_model.dart';


class FrameEditorScreen extends StatefulWidget {
  final FrameModel? frame;
  const FrameEditorScreen({super.key, this.frame});

  @override
  State<FrameEditorScreen> createState() => _FrameEditorScreenState();
}

class _FrameEditorScreenState extends State<FrameEditorScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  List<OverlayTemplate> overlays = [];


  final fonts = [
    'OpenSans',
    'Billabong',
    'GrandHotel',
    'Oswald',
    'Quicksand',
    'BeautifulPeople',
    'BeautyMountains',
    'BiteChocolate',
    'BlackberryJam',
    'BunchBlossoms',
    'CinderelaRegular',
    'Countryside',
    'Halimun',
    'LemonJelly',
    'QuiteMagicalRegular',
    'Tomatoes',
    'TropicalAsianDemoRegular',
    'VeganStyle',
  ];
  TextStyle _textStyle = TextStyle(
    fontSize: 50,
    color: Colors.white,
    fontFamily: 'Billabong',
  );
  String _text = 'Sample Text';
  TextAlign _textAlign = TextAlign.center;



  void _tapHandler(text, textStyle, textAlign) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(
        milliseconds: 400,
      ), // how long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              // top: false,
              child: TextEditor(
                fonts: fonts,
                text: text,
                textStyle: textStyle,
                textAlingment: textAlign,
                minFontSize: 10,
                // paletteColors: [
                //   Colors.black,
                //   Colors.white,
                //   Colors.blue,
                //   Colors.red,
                //   Colors.green,
                //   Colors.yellow,
                //   Colors.pink,
                //   Colors.cyanAccent,
                // ],
                // decoration: EditorDecoration(
                //   textBackground: TextBackgroundDecoration(
                //     disable: Text('Disable'),
                //     enable: Text('Enable'),
                //   ),
                //   doneButton: Icon(Icons.close, color: Colors.white),
                //   fontFamily: Icon(Icons.title, color: Colors.white),
                //   colorPalette: Icon(Icons.palette, color: Colors.white),
                //   alignment: AlignmentDecoration(
                //     left: Text(
                //       'left',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //     center: Text(
                //       'center',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //     right: Text(
                //       'right',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
                onEditCompleted: (style, align, text) {
                  setState(() {
                    _text = text;
                    _textStyle = style;
                    _textAlign = align;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );
  }

  // Show text input dialog
  Future<void> _addTextOverlay() async {
    // _tapHandler(_text, _textStyle, _textAlign);

    // overlays.add(OverlayTemplate.text(
    // text: _text,
    // font: "Roboto",
    // color: Colors.white,
    // x: 100,
    // y: 150,
    // scale: 1,
    // rotation: 0,
    // ));
    String? text = await _showTextInputDialog();
    if (text != null && text.isNotEmpty) {
      overlays.add(OverlayTemplate.text(
        text: text,
        font: "Roboto",
        color: Colors.white,
        x: 100,
        y: 150,
        scale: 1,
        rotation: 0,
      ));

    }
    setState(() {});
  }

  // Show emoji picker dialog
  void _addEmojiOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => EmojiPicker(
        onEmojiSelected: (emoji) {
          overlays.add(OverlayTemplate.text(
            text: emoji,
            font: "Roboto",
            color: Colors.white,
            x: 200,
            y: 250,
            scale: 1.5,
            rotation: 0,
          ));
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }

  // Show sticker picker dialog
  void _addStickerOverlay() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => StickerPicker(
        onStickerSelected: (stickerPath) {
          overlays.add(OverlayTemplate.sticker(
            imagePath: stickerPath,
            x: 150,
            y: 300,
            scale: 1,
            rotation: 0,
          ));
          setState(() {});
          Navigator.pop(context);
        },
      ),
    );
  }




  // Text input dialog
  Future<String?> _showTextInputDialog() {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        title: const Text('Enter Text', style: TextStyle(color: Colors.white)),
        content:
        TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Type your text here...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage() async {
    await [Permission.storage].request();
    Uint8List? image = await _screenshotController.capture();
    if (image != null) {
      // await ImageGallerySaver.saveImage(image, quality: 100);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Image saved to gallery!')),
      );
    }
  }

  Future<void> _saveTemplate() async {
    await TemplateManager.saveTemplate(overlays);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Template saved successfully!')),
    );
  }

  Future<void> _loadTemplate() async {
    overlays = await TemplateManager.loadTemplate();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📂 Template loaded!')),
    );
  }

  @override
  Widget build(BuildContext context) {
  final size=  MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1F3A),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              "edit",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          // _buildAppBarButtonWithLabel(Icons.folder_open, _loadTemplate,),
          _buildAppBarButtonWithLabel(Icons.bookmark_border, _saveTemplate),
          _buildAppBarButtonWithLabel(Icons.download, _saveImage),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Screenshot(
          controller: _screenshotController,
          child: SizedBox(
            height: size.height*0.8,
            width: size.width*0.8,
            child: Stack(
              children: [

                Positioned(
                  top: 15,
                  left: 0,
                  right: 0,
                  child: Image.network(widget.frame?.imageUrl??'',
                      width: double.infinity, fit: BoxFit.fill),
                ),
                if (widget.frame == null)
                Text("Image not found"),
                ...overlays.map((item) {
                  if (item.type == 'text') {
                    return MovableResizableWidget(
                      key: UniqueKey(),
                      overlay: item,
                      onDelete: () {
                        setState(() {
                          overlays.remove(item);
                        });
                      },
                      child: EditableTextOverlay(
                        template: item,
                        onChanged: (updated) {
                          setState(() {
                            int i = overlays.indexOf(item);
                            overlays[i] = updated;
                          });
                        },
                      ),
                    );
                  } else {
                    return MovableResizableWidget(
                      key: UniqueKey(),
                      overlay: item,
                      onDelete: () {
                        setState(() {
                          overlays.remove(item);
                        });
                      },
                      child: Image.asset(item.imagePath!, width: 100),
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.grey[900],
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.text_fields),
              label: const Text("Text"),
              onPressed: _addTextOverlay,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.emoji_emotions),
              label: const Text("Emoji"),
              onPressed: _addEmojiOverlay,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.sticky_note_2),
              label: const Text("Sticker"),
              onPressed: _addStickerOverlay,
            ),
          ],
        ),
      ),
    );
  }
}

/// 😀 Emoji Picker Widget
class EmojiPicker extends StatelessWidget {
  final Function(String) onEmojiSelected;

  const EmojiPicker({super.key, required this.onEmojiSelected});

  static const List<String> emojis = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
    '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩',
    '😘', '😗', '😚', '😙', '😋', '😛', '😜', '🤪',
    '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨',
    '😐', '😑', '😶', '😏', '😒', '🙄', '😬', '🤥',
    '😌', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕',
    '🤢', '🤮', '🤧', '🥵', '🥶', '😎', '🤓', '🧐',
    '😕', '😟', '🙁', '☹️', '😮', '😯', '😲', '😳',
    '🥺', '😦', '😧', '😨', '😰', '😥', '😢', '😭',
    '😱', '😖', '😣', '😞', '😓', '😩', '😫', '🥱',
    '👍', '👎', '👊', '✊', '🤛', '🤜', '🤞', '✌️',
    '🤟', '🤘', '👌', '🤏', '👈', '👉', '👆', '👇',
    '☝️', '👋', '🤚', '🖐️', '✋', '🖖', '👏', '🙌',
    '💪', '🦾', '🙏', '🤝', '💅', '🤳', '💃', '🕺',
    '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍',
    '💔', '❣️', '💕', '💞', '💓', '💗', '💖', '💘',
    '🔥', '✨', '💫', '⭐', '🌟', '💥', '💯', '✅',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Emoji',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onEmojiSelected(emojis[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        emojis[index],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// 🎨 Sticker Picker Widget
class StickerPicker extends StatelessWidget {
  final Function(String) onStickerSelected;

  const StickerPicker({super.key, required this.onStickerSelected});

  // Add your sticker paths here
  static const List<String> stickers = [
    'assets/sticker1.png',
    'assets/sticker2.png',
    'assets/sticker3.png',
    'assets/sticker4.png',
    'assets/sticker5.png',
    'assets/sticker6.png',
    'assets/sticker7.png',
    'assets/sticker8.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Sticker',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: stickers.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => onStickerSelected(stickers[index]),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[700]!),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      stickers[index],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Colors.grey,
                          size: 40,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// ✅ Overlay Data Model
class OverlayTemplate {
  final String type;
  String? text;
  String? font;
  String? color;
  final String? imagePath;
  double x, y, scale, rotation;

  OverlayTemplate({
    required this.type,
    this.text,
    this.font,
    this.color,
    this.imagePath,
    required this.x,
    required this.y,
    required this.scale,
    required this.rotation,
  });

  factory OverlayTemplate.text({
    required String text,
    required String font,
    required Color color,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) {
    return OverlayTemplate(
      type: 'text',
      text: text,
      font: font,
      color: color.value.toRadixString(16),
      x: x,
      y: y,
      scale: scale,
      rotation: rotation,
    );
  }

  factory OverlayTemplate.sticker({
    required String imagePath,
    required double x,
    required double y,
    required double scale,
    required double rotation,
  }) {
    return OverlayTemplate(
      type: 'sticker',
      imagePath: imagePath,
      x: x,
      y: y,
      scale: scale,
      rotation: rotation,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'text': text,
    'font': font,
    'color': color,
    'imagePath': imagePath,
    'x': x,
    'y': y,
    'scale': scale,
    'rotation': rotation,
  };

  static OverlayTemplate fromJson(Map<String, dynamic> json) => OverlayTemplate(
    type: json['type'],
    text: json['text'],
    font: json['font'],
    color: json['color'],
    imagePath: json['imagePath'],
    x: (json['x'] ?? 0).toDouble(),
    y: (json['y'] ?? 0).toDouble(),
    scale: (json['scale'] ?? 1).toDouble(),
    rotation: (json['rotation'] ?? 0).toDouble(),
  );
}

/// 💾 Template Save/Load
class TemplateManager {
  static Future<void> saveTemplate(List<OverlayTemplate> overlays) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonData = jsonEncode(overlays.map((e) => e.toJson()).toList());
    await prefs.setString('saved_template', jsonData);
  }

  static Future<List<OverlayTemplate>> loadTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonData = prefs.getString('saved_template');
    if (jsonData == null) return [];
    List decoded = jsonDecode(jsonData);
    return decoded.map((e) => OverlayTemplate.fromJson(e)).toList();
  }
}

/// 🎨 Draggable + Resizable + Rotatable Widget
class MovableResizableWidget extends StatefulWidget {
  final Widget child;
  final OverlayTemplate overlay;
  final VoidCallback onDelete;

  const MovableResizableWidget({
    super.key,
    required this.child,
    required this.overlay,
    required this.onDelete,
  });

  @override
  State<MovableResizableWidget> createState() => _MovableResizableWidgetState();
}

class _MovableResizableWidgetState extends State<MovableResizableWidget> {
  late double top;
  late double left;
  late double scale;
  late double rotation;
  Offset? lastFocalPoint;
  bool showControls = false;

  @override
  void initState() {
    super.initState();
    top = widget.overlay.y;
    left = widget.overlay.x;
    scale = widget.overlay.scale;
    rotation = widget.overlay.rotation;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
        },
        onScaleStart: (details) {
          lastFocalPoint = details.focalPoint;
        },
        onScaleUpdate: (details) {
          setState(() {
            // translation
            if (lastFocalPoint != null) {
              final dx = details.focalPoint.dx - lastFocalPoint!.dx;
              final dy = details.focalPoint.dy - lastFocalPoint!.dy;
              left += dx;
              top += dy;
              widget.overlay.x = left;
              widget.overlay.y = top;
            }
            lastFocalPoint = details.focalPoint;

            // scaling
            scale = widget.overlay.scale * details.scale.clamp(0.3, 5.0);
            widget.overlay.scale = scale;

            // rotation
            rotation = widget.overlay.rotation + details.rotation;
            widget.overlay.rotation = rotation;
          });
        },
        onScaleEnd: (_) {
          widget.overlay.x = left;
          widget.overlay.y = top;
          widget.overlay.scale = scale;
          widget.overlay.rotation = rotation;
          lastFocalPoint = null;
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Transform(
              transform: Matrix4.identity()
                ..translate(0.0, 0.0)
                ..rotateZ(rotation)
                ..scale(scale),
              alignment: Alignment.center,
              child: Container(
                decoration: showControls
                    ? BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                )
                    : null,
                child: widget.child,
              ),
            ),
            if (showControls)
              Positioned(
                right: -12,
                top: -12,
                child: GestureDetector(
                  onTap: widget.onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ✍️ Editable Text Overlay with Font & Color Picker
class EditableTextOverlay extends StatefulWidget {
  final OverlayTemplate template;
  final Function(OverlayTemplate) onChanged;

  const EditableTextOverlay({
    super.key,
    required this.template,
    required this.onChanged,
  });

  @override
  State<EditableTextOverlay> createState() => _EditableTextOverlayState();
}

class _EditableTextOverlayState extends State<EditableTextOverlay> {
  late String currentFont;
  late Color textColor;

  final fonts = {
    'Roboto': GoogleFonts.roboto,
    'Lobster': GoogleFonts.lobster,
    'Pacifico': GoogleFonts.pacifico,
    'Oswald': GoogleFonts.oswald,
    'DancingScript': GoogleFonts.dancingScript,
    'Bangers': GoogleFonts.bangers,
    'Righteous': GoogleFonts.righteous,
  };

  final List<Color> colorPalette = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    currentFont = widget.template.font ?? 'Roboto';
    textColor = Color(int.parse(widget.template.color ?? 'ffffffff', radix: 16));
  }

  void _showFontPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Select Font', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: fonts.keys.map((fontName) {
              return ListTile(
                title: Text(
                  fontName,
                  style: fonts[fontName]!(
                    textStyle: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                trailing: currentFont == fontName
                    ? const Icon(Icons.check, color: Colors.blue)
                    : null,
                onTap: () {
                  setState(() {
                    currentFont = fontName;
                    widget.template.font = fontName;
                    widget.onChanged(widget.template);
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Select Color', style: TextStyle(color: Colors.white)),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colorPalette.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  textColor = color;
                  widget.template.color = color.value.toRadixString(16);
                  widget.onChanged(widget.template);
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: textColor == color ? Colors.blue : Colors.grey,
                    width: textColor == color ? 3 : 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.template.text ?? '',
          style: fonts[currentFont]!(
            textStyle: TextStyle(
              fontSize: 30,
              color: textColor,
              shadows: const [Shadow(blurRadius: 5, color: Colors.black)],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _showFontPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.font_download, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      currentFont,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _showColorPicker,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: textColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
Widget _buildAppBarButtonWithLabel(
    IconData icon,
    VoidCallback onPressed,
    ) {
  return TextButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, color: Colors.white),
    label: Text(
      '',
      style: TextStyle(color: Colors.white),
  ));
}
