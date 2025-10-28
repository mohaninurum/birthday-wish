import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:birthday_photo_maker/provider/Home_provider/Home_provider.dart';
import 'package:birthday_photo_maker/routes/app_routes_name.dart';
import 'package:birthday_photo_maker/widgets/BirthdayLoadingRing.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart' as igs;
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '../../constant/color/app_colors.dart';
import '../../model/frame_list_model/frame_list_model.dart';
import '../../provider/editor_provider/edit_provider.dart';

class EditorScreen extends StatefulWidget {
  final FrameData? frame;
  final int? frameType;


   EditorScreen({super.key, this.frame,this.frameType});

  @override
  _EditorScreenState createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  // Foreground active (text/sticker/emoji)
  EditableItem? _activeItem;

  // 3 independent background layers
  EditableItem? _backgroundItem1;
  EditableItem? _backgroundItem2;
  // EditableItem? _backgroundItem3;

  // Currently active background item for gesture/highlight + delete
  EditableItem? _activeBgItem;

  bool _pointerDownOnItem = false;

  // Gesture snapshots
  Offset? _initLocal; // local to canvas
  Offset? _currentPos;
  double _currentScale = 1;
  double _currentRotation = 0;
  bool _inAction = false;
  String? selectedFrame;
  List<EditableItem> items = [];
  var decodedImage;
  // Which background slot to fill next (1 -> 2 -> 3 -> 1 ...)
  int frameType = 0;

  ui.Image? _decodedFrameImage;
  Size? canvasSize;

  bool isContinue=false;


  // Screenshot
  final ScreenshotController screenshotController = ScreenshotController();

  // Canvas key (for correct local coordinates)
  final GlobalKey _canvasKey = GlobalKey();

  // Emojis and fonts
  final List<String> emojis = [
    '🎂', '🎉', '🎁', '🥳', '🎈', '🎊', '🍰', '🧁', '🍬', '🍭',
    '🎇', '🎆', '✨', '🌟', '💫', '🎶', '🎵', '🎤', '🎧', '🎷',
    '❤️', '💖', '💘', '💕', '💞', '💓', '💗', '💝', '💟', '😍',
    '😘', '🥰', '😚', '😻', '💋', '🌹', '💐', '🌸', '🌺', '🌼',
    '😄', '😃', '😀', '😁', '😂', '🤣', '😜', '😝', '😆', '😇',
    '😎', '🤩', '😋', '🤗', '😺', '🤪', '😌', '😛', '🙃', '😅',
    '🌈', '☀️', '⭐', '🌙', '🔥', '💎', '🪩', '🎨', '🎬', '📸',
  ];

  final List<String> kFontFamilies = [
    'Poppins', 'Roboto', 'Montserrat', 'Lato', 'Merriweather', 'Playfair Display',
    'Oswald', 'Raleway', 'Nunito', 'Open Sans', 'Inter', 'Noto Sans', 'Ubuntu',
    'Rubik', 'Quicksand', 'Karla', 'Josefin Sans', 'Cabin', 'PT Sans', 'Arimo',
    'Work Sans', 'Heebo', 'Manrope', 'Fira Sans', 'Mulish', 'Titillium Web',
    'Barlow', 'Catamaran', 'Domine', 'Crimson Text', 'DM Sans', 'Bebas Neue',
    'Cormorant Garamond', 'Space Grotesk', 'Overpass', 'Zilla Slab', 'Lexend',
    'Exo 2', 'Yanone Kaffeesatz', 'Noto Serif', 'PT Serif', 'Varela Round',
    'Dosis', 'Signika', 'Righteous', 'Cairo', 'Teko', 'Asap', 'Bitter',
  ];

  @override
  void initState() {
    if(widget.frame?.frameSlot=="1"){
      frameType=0;
    }else{
      frameType=1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {

      _loadFrameImage('init');
      Provider.of<EditProvider>(context, listen: false).getStickerList();
      context.read<HomeProvider>().getFrameList();
    });
    super.initState();
  }

  Size? get _canvasSize {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size;
  }

  Offset? _toLocal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.globalToLocal(global);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit'),
        backgroundColor: AppColors.appSecondaryColor.withValues(alpha: 0.6),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              for (final element in items) {
                // ignore: avoid_print
                print([
                  element.fontWeight,
                  element.fontSize,
                  element.fontStyle,
                  element.value,
                  element.type,
                  element.fontFamily,
                  element.position,
                  element.rotation,
                  element.scale,
                ]);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _saveToGallery(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child:  Center(
                child: AspectRatio(
                  aspectRatio: selectedFrame != null? canvasSize!.width / canvasSize!.height:1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onScaleStart: (details) {
                      if (_activeItem == null && _activeBgItem == null) return;

                      _initLocal = _toLocal(details.focalPoint);

                      if (_activeItem != null) {
                        _currentPos = _activeItem!.position;
                        _currentScale = _activeItem!.scale;
                        _currentRotation = _activeItem!.rotation;
                      } else if (_activeBgItem != null) {
                        _currentPos = _activeBgItem!.position;
                        _currentScale = _activeBgItem!.scale;
                        _currentRotation = _activeBgItem!.rotation;
                      }
                    },
                    onScaleUpdate: (details) {
                      if (_activeItem == null && _activeBgItem == null) return;
                      final size = _canvasSize;
                      final local = _toLocal(details.focalPoint);
                      if (size == null || _initLocal == null || local == null) return;

                      final delta = local - _initLocal!;
                      final dx = delta.dx / size.width;
                      final dy = delta.dy / size.height;

                      setState(() {
                        if (_activeItem != null) {
                          _activeItem!.position =
                              Offset((_currentPos?.dx ?? 0) + dx, (_currentPos?.dy ?? 0) + dy);
                          _activeItem!.rotation = details.rotation + _currentRotation;
                          _activeItem!.scale =
                              math.max(math.min(details.scale * _currentScale, 3), 0.3);
                        } else if (_activeBgItem != null) {
                          _activeBgItem!.position =
                              Offset((_currentPos?.dx ?? 0) + dx, (_currentPos?.dy ?? 0) + dy);
                          _activeBgItem!.rotation = details.rotation + _currentRotation;
                          _activeBgItem!.scale =
                              math.max(math.min(details.scale * _currentScale, 3), 0.3);
                        }
                      });
                    },
                    // Keep background selection after gesture (so delete button visible)
                    onScaleEnd: (_) {
                      _initLocal = null;
                    },
                    onTapDown: (_) {
                      if (!_pointerDownOnItem) {
                        setState(() {
                          _activeItem = null;
                          _activeBgItem = null; // clear background selection too
                        });
                      }
                    },


                    child: selectedFrame != null? Container(
                      // width: canvasSize!.width,
                      // height: canvasSize!.height,
                      color: Colors.black,
                      child: Stack(
                        children: [
                          // Canvas background holder with key (important for size/coords)
                          Container(
                              key: _canvasKey, color: Colors.black87),
                          // Background layers (each independently draggable + deletable)
                          if (_backgroundItem1 != null)
                            _buildItemWidget(_backgroundItem1!, true),

                          if (_backgroundItem2 != null)
                            _buildItemWidget(_backgroundItem2!, true),

                          // if (_backgroundItem3 != null)
                          //   _buildItemWidget(_backgroundItem3!, true),

                          // Selected frame overlay (IgnorePointer so touches pass-through)
                          if (selectedFrame != null)
                            IgnorePointer(
                              ignoring: true,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: CachedNetworkImage(
                                  width: canvasSize!.width,
                                  height: canvasSize!.height,
                                  fit: BoxFit.contain,
                                  imageUrl: selectedFrame!,
                                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                                  const Center(child: BirthdayLoadingRing()),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: Text(
                                "Add Frame",
                                style: TextStyle(color: AppColors.appWhiteColor),
                              ),
                            ),

                          // Foreground items (text/emoji/sticker)
                          ...items.map((e) => _buildItemWidget(e, false)).toList(),
                        ],
                      ),
                    ):isContinue? const Center(
                      child: Text(
                        "Add Frame",
                        style: TextStyle(color: AppColors.appWhiteColor),
                      ),
                    ):BirthdayLoadingRing(),
                  ),
                ),
              ),
            ),
          ),

          // Bottom toolbar
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.black87,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildToolbarItem(Icons.photo, Colors.pinkAccent, 'Add Image', _pickBackgroundImage),
                  _buildToolbarItem(Icons.camera_alt, Colors.blue, 'Camera', _captureBackgroundImage),
                  _buildToolbarItem(Icons.filter_frames, Colors.purple, 'Select Frame', _showFramePicker),
                  _buildToolbarItem(Icons.text_fields, Colors.deepPurple, 'Add Text', _showTextEditor),
                  _buildToolbarItem(Icons.emoji_emotions, Colors.orange, 'Add Emoji', () {
                    showPrettyEmojiPicker(
                      context,
                      emojis: emojis,
                      onSelected: (e) {
                        setState(() {
                          items.add(EditableItem(type: ItemType.Emoji, value: e));
                        });
                      },
                    );
                  }),
                  _buildToolbarItem(Icons.sticky_note_2, Colors.green, 'Add Sticker', () {
                    showPrettyStickerPicker(
                      context,
                      onSelected: (imageUrl) {
                        setState(() {
                          items.add(EditableItem(
                            type: ItemType.Sticker,
                            value: imageUrl,
                          ));
                        });
                        print(items[0].scale);
                        print(items[0].rotation);
                        print(items[0].position);
                        print(items[0].fontFamily);
                        print(items[0].value);
                        print(items[0].fontSize);
                        print(items[0].fontWeight);
                        print(items[0].color);
                        print(items[0].fontStyle);
                        print(items[0].type);
                        print(frameType);
                        print(_backgroundItem1);
                        print(_backgroundItem2);

                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarItem(IconData icon, Color color, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 4),
            Text(text, style: const TextStyle(fontSize: 12, color: AppColors.appWhiteColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(EditableItem e, bool isBackground) {
    final Size fallback = MediaQuery.of(context).size;
    final Size canvas = _canvasSize ?? fallback;

    final theme = Theme.of(context);

    // Active states (foreground vs background)
    final bool isFgActive = !isBackground && identical(_activeItem, e);
    final bool isBgActive = isBackground && identical(_activeBgItem, e);
    final bool showActive = isFgActive || isBgActive;

    Widget content;
    switch (e.type) {
      case ItemType.Text:
        content = Text(
          e.value,
          style: GoogleFonts.getFont(
            e.fontFamily ?? 'Poppins',
            color: e.color,
            fontSize: e.fontSize,
            fontWeight: e.fontWeight,
            fontStyle: e.fontStyle,
          ),
        );
        break;
      case ItemType.Emoji:
        content = Text(e.value, style: const TextStyle(fontSize: 50));
        break;
      case ItemType.Sticker:
        content = Image.network(e.value, height: 100, width: 100);
        break;
      case ItemType.Image:
        content = Image.file(
          File(e.value),
          fit: BoxFit.contain,
          height: canvas.height,
          width: canvas.width,
        );
        break;
    }

    // Select border + delete icon for BOTH foreground and background when selected
    final framed = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: showActive ? AppColors.appPrimaryPink : Colors.transparent,
              width: 1,
            ),
          ),
          child: content,
        ),
        if (showActive)
          Positioned(
            top: -14,
            right: -14,
            child: Transform.rotate(
              angle: -e.rotation, // keep upright
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    setState(() {
                      if (isBackground) {
                        // Delete correct background slot
                        if (identical(_backgroundItem1, e)) _backgroundItem1 = null;
                        else if (identical(_backgroundItem2, e)) _backgroundItem2 = null;
                        // else if (identical(_backgroundItem3, e)) _backgroundItem3 = null;
                        if (identical(_activeBgItem, e)) _activeBgItem = null;
                      } else {
                        items.removeWhere((it) => identical(it, e));
                        if (identical(_activeItem, e)) _activeItem = null;
                      }
                    });
                  },
                  child: Ink(
                    width: 30,
                    height: 30,
                    decoration: ShapeDecoration(
                      color: theme.colorScheme.error,
                      shape: const CircleBorder(),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.20),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.delete_rounded, size: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Positioned(
      top: e.position.dy * canvas.height,
      left: e.position.dx * canvas.width,
      child: Transform.scale(
        scale: e.scale,
        child: Transform.rotate(
          angle: e.rotation,
          child: Listener(
            onPointerDown: (details) {
              if (_inAction) return;
              _inAction = true;
              _pointerDownOnItem = true;

              // Select item for gesture
              if (isBackground) {
                _activeBgItem = e;
                _activeItem = null;
              } else {
                _activeItem = e;
                _activeBgItem = null;
              }

              _initLocal = _toLocal(details.position);
              _currentPos = e.position;
              _currentScale = e.scale;
              _currentRotation = e.rotation;
              setState(() {});
            },
            onPointerUp: (_) {
              _inAction = false;
              _pointerDownOnItem = false;
            },
            onPointerCancel: (_) {
              _inAction = false;
              _pointerDownOnItem = false;
            },
            child: framed,
          ),
        ),
      ),
    );
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if(frameType==0){
          print("singleFrame");
          _backgroundItem1 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
        }else if (frameType == 1) {
          _backgroundItem1 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
          frameType = 2;
        } else if (frameType == 2) {
          _backgroundItem2 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
          frameType = 1;
        } else {
          // _backgroundItem3 = EditableItem(
          //   type: ItemType.Image,
          //   value: picked.path,
          //   position: const Offset(0.0, 0.0),
          //   scale: 1.0,
          //   rotation: 0.0,
          // );
          // frameType = 1;
        }
      });
    }
  }


  Future<void> _loadFrameImage(String fmUlr) async {
    String? frameUrl='';
    if(fmUlr=='init'){
     final args = ModalRoute.of(context)?.settings.arguments as FrameData?;
      frameUrl = args?.frameImage ?? widget.frame?.frameImage;
      print("Frame>>>>>>>>>>>>>>$frameUrl");
      if(frameUrl!=null){
      }else{
        isContinue=true;
        setState(() {

        });
      }
   }else{
      frameUrl = fmUlr;
    }

    if (frameUrl == null) return;

    // Fetch from network
    final response = await http.get(Uri.parse(frameUrl));
     decodedImage = await decodeImageFromList(response.bodyBytes);
    if (mounted) {
      setState(() {
        selectedFrame = frameUrl;
        _decodedFrameImage = decodedImage;
        canvasSize = Size(decodedImage.width.toDouble(), decodedImage.height.toDouble());
      });
    }
  }


  Future<void> _captureBackgroundImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    if (picked != null) {
      setState(() {
        if(frameType==0){
          print("singleFrame");
          _backgroundItem1 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
        }else if (frameType == 1) {
          _backgroundItem1 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
          frameType = 2;
        } else if (frameType == 2) {
          _backgroundItem2 = EditableItem(
            type: ItemType.Image,
            value: picked.path,
            position: const Offset(0.0, 0.0),
            scale: 1.0,
            rotation: 0.0,
          );
          frameType = 1;
        } else {
          // _backgroundItem3 = EditableItem(
          //   type: ItemType.Image,
          //   value: picked.path,
          //   position: const Offset(0.0, 0.0),
          //   scale: 1.0,
          //   rotation: 0.0,
          // );
          // frameType = 1;
        }
        ////
        // if (frameType == 1) {
        //   _backgroundItem1 = EditableItem(
        //     type: ItemType.Image,
        //     value: picked.path,
        //     position: const Offset(0.0, 0.0),
        //     scale: 1.0,
        //     rotation: 0.0,
        //   );
        //   frameType = 2;
        // } else if (frameType == 2) {
        //   _backgroundItem2 = EditableItem(
        //     type: ItemType.Image,
        //     value: picked.path,
        //     position: const Offset(0.0, 0.0),
        //     scale: 1.0,
        //     rotation: 0.0,
        //   );
        //   frameType = 1;
        // } else {
        //   // _backgroundItem3 = EditableItem(
        //   //   type: ItemType.Image,
        //   //   value: picked.path,
        //   //   position: const Offset(0.0, 0.0),
        //   //   scale: 1.0,
        //   //   rotation: 0.0,
        //   // );
        //   // frameType = 1;
        // }
      });
    }
  }

  void _showFramePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: false,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Select Frame',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(ctx).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer<HomeProvider>(
                      builder: (context, provider, _) {
                        final raw = provider.frameResponse?.data;
                        final isLoading = raw == null;

                        final frameUrls = (raw ?? [])
                            .map<String?>((f) {
                          try {
                            final d = f as dynamic;
                            return d.frameImage as String? ??
                                d.image as String? ??
                                d.url as String?;
                          } catch (_) {
                            return null;
                          }
                        })
                            .whereType<String>()
                            .where((u) => u.isNotEmpty)
                            .toList();

                        if (isLoading) {
                          return _FrameLoadingRow(
                            tileSize: 120,
                            background: theme.colorScheme.surfaceVariant
                                .withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.5),
                          );
                        }

                        if (frameUrls.isEmpty) {
                          return const _EmptySmall(message: 'No frames found');
                        }

                        return _FrameHorizontalList(
                          items: frameUrls,
                          tileSize: 120,
                          onTap: (url) {
                            _loadFrameImage(url);
                            setState((){
                              selectedFrame = null;
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTextEditor() {
    final controller = TextEditingController();
    Color selectedColor = Colors.pinkAccent;
    String selectedFont = 'Poppins';
    double selectedSize = 32;
    FontWeight selectedWeight = FontWeight.w600;
    FontStyle selectedStyle = FontStyle.normal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 42,
                            height: 5,
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              controller.text.isEmpty ? 'Aa Preview' : controller.text,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.getFont(
                                selectedFont,
                                color: selectedColor,
                                fontSize: selectedSize,
                                fontWeight: selectedWeight,
                                fontStyle: selectedStyle,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: controller,
                            maxLines: 2,
                            style: GoogleFonts.getFont(
                              selectedFont,
                              color: selectedColor,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter text',
                              hintStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.white24),
                              ),
                            ),
                            onChanged: (_) => setModalState(() {}),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: ctx,
                                    builder: (dialogCtx) {
                                      Color temp = selectedColor;
                                      return AlertDialog(
                                        backgroundColor: const Color(0xFF1E1E1E),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ColorPicker(
                                              pickerColor: selectedColor,
                                              onColorChanged: (c) => temp = c,
                                              enableAlpha: true,
                                              pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(12)),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(dialogCtx),
                                                  child: const Text('Cancel'),
                                                ),
                                                const Spacer(),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    setModalState(() => selectedColor = temp);
                                                    Navigator.pop(dialogCtx);
                                                  },
                                                  child: const Text('Apply'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white54),
                                    gradient: LinearGradient(
                                      colors: [selectedColor, selectedColor.withOpacity(0.6)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedFont,
                                    dropdownColor: const Color(0xFF1E1E1E),
                                    iconEnabledColor: Colors.white,
                                    items: kFontFamilies.map((family) {
                                      return DropdownMenuItem(
                                        value: family,
                                        child: Text(
                                          'Aa  $family',
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.getFont(family, color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (v) => setModalState(() => selectedFont = v!),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _MiniToggle(
                                icon: Icons.format_bold,
                                isOn: selectedWeight == FontWeight.w700,
                                onTap: () => setModalState(() {
                                  selectedWeight = selectedWeight == FontWeight.w700 ? FontWeight.w500 : FontWeight.w700;
                                }),
                              ),
                              const SizedBox(width: 6),
                              _MiniToggle(
                                icon: Icons.format_italic,
                                isOn: selectedStyle == FontStyle.italic,
                                onTap: () => setModalState(() {
                                  selectedStyle = selectedStyle == FontStyle.italic ? FontStyle.normal : FontStyle.italic;
                                }),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.text_fields, color: Colors.white70, size: 18),
                              Expanded(
                                child: Slider(
                                  min: 12,
                                  max: 96,
                                  value: selectedSize,
                                  onChanged: (v) => setModalState(() => selectedSize = v),
                                ),
                              ),
                              Text(
                                selectedSize.toStringAsFixed(0),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => Navigator.pop(sheetCtx),
                                child: const Text('Cancel'),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: () {
                                  final text = controller.text.trim();
                                  if (text.isEmpty) return;

                                  setState(() {
                                    items.add(EditableItem(
                                      fontWeight: selectedWeight,
                                      type: ItemType.Text,
                                      value: text,
                                      color: selectedColor,
                                      fontFamily: selectedFont,
                                      fontSize: selectedSize,
                                      fontStyle: selectedStyle,
                                    ));
                                  });

                                  Navigator.pop(sheetCtx);
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Add'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> showPrettyEmojiPicker(
      BuildContext context, {
        required List<String> emojis,
        required ValueChanged<String> onSelected,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: _EmojiPickerSheet(
                emojis: emojis,
                onSelected: (e) {
                  onSelected(e);
                  Navigator.of(ctx).pop();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> showPrettyStickerPicker(
      BuildContext context, {
        required ValueChanged<String> onSelected,
      }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.78,
              child: Consumer<EditProvider>(
                builder: (context, provider, _) {
                  final raw = provider.stickerResponse?.data;
                  final isLoading = raw == null;

                  final stickers = (raw ?? [])
                      .map<String?>((s) {
                    try {
                      return (s as dynamic).stickerImage as String?;
                    } catch (_) {
                      return null;
                    }
                  })
                      .whereType<String>()
                      .where((u) => u.isNotEmpty)
                      .toList();

                  return _StickerPickerSheet(
                    stickers: stickers,
                    isLoading: isLoading,
                    onSelected: (url) {
                      HapticFeedback.selectionClick();
                      onSelected(url);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    // Permissions
    if (Platform.isAndroid) {
      await Permission.storage.request(); // Android <= 12
    } else if (Platform.isIOS) {
      await Permission.photosAddOnly.request();
    }

    final bytes = await screenshotController.capture(pixelRatio: 3.0);
    if (bytes == null) return;

    // image_gallery_saver_plus v4 API
    final result = await igs.ImageGallerySaverPlus.saveImage(
      bytes,
      quality: 100,
      name: 'birthday_${DateTime.now().millisecondsSinceEpoch}',
      isReturnImagePathOfIOS: true,
    );

    bool ok = false;
    String? savedPath;

    if (result is Map) {
      ok = result['isSuccess'] == true || result['is_success'] == true;
      savedPath = (result['filePath'] ??
          result['file_path'] ??
          result['path'] ??
          result['file'])
          ?.toString();
    } else if (result is bool) {
      ok = result;
    }

    if (!context.mounted) return;

    if (ok) {
      await _showSavedBottomSheet(context, bytes, savedPath: savedPath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $result')),
      );
    }
  }

  Future<void> _showSavedBottomSheet(
      BuildContext context,
      Uint8List bytes, {
        String? savedPath,
      }) async {
    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Saved to Gallery 🎉',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: const ButtonStyle(
                        overlayColor: MaterialStatePropertyAll(Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        Navigator.pushNamed(context, AppRoutesName.homeScreen);
                      },
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Go Home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareImage(context, bytes, savedPath: savedPath),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _shareImage(
      BuildContext context,
      Uint8List bytes, {
        String? savedPath,
      }) async {
    try {
      XFile? xfile;
      if (savedPath != null) {
        final normalized = _normalizePath(savedPath);
        final f = File(normalized);
        if (await f.exists()) {
          xfile = XFile(f.path, mimeType: 'image/png', name: 'image.png');
        }
      }
      xfile ??= await _tempXFileFromBytes(bytes);
      await Share.shareXFiles([xfile], text: 'Check this out 🎉', subject: 'My Image');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: $e')),
      );
    }
  }

  String _normalizePath(String p) {
    if (p.startsWith('file://')) {
      return Uri.parse(p).toFilePath();
    }
    return p;
  }

  Future<XFile> _tempXFileFromBytes(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path, mimeType: 'image/png', name: 'image.png');
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sentiment_neutral_rounded,
              size: 36, color: theme.colorScheme.outline),
          const SizedBox(height: 8),
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _EmojiTile extends StatefulWidget {
  const _EmojiTile({
    Key? key,
    required this.emoji,
    required this.background,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  final String emoji;
  final Color background;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_EmojiTile> createState() => _EmojiTileState();
}

class _EmojiTileState extends State<_EmojiTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: widget.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
          boxShadow: _pressed
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _pressed ? 0.9 : 1.0,
            child: Text(widget.emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
      ),
    );
  }
}

class _MiniToggle extends StatelessWidget {
  const _MiniToggle({
    Key? key,
    required this.icon,
    required this.isOn,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isOn ? Colors.white.withOpacity(0.16) : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isOn ? Colors.white70 : Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _EmojiPickerSheet extends StatefulWidget {
  const _EmojiPickerSheet({
    Key? key,
    required this.emojis,
    required this.onSelected,
  }) : super(key: key);

  final List<String> emojis;
  final ValueChanged<String> onSelected;

  @override
  State<_EmojiPickerSheet> createState() => _EmojiPickerSheetState();
}

class _EmojiPickerSheetState extends State<_EmojiPickerSheet> {
  static final List<String> _recent = <String>[];

  final TextEditingController _search = TextEditingController();
  int _tabIndex = 0; // 0 = All, 1 = Recent.

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _applyFilters() {
    List<String> pool = _tabIndex == 1 ? _recent : widget.emojis;
    final q = _search.text.trim();
    if (q.isEmpty) return List<String>.from(pool);
    return pool.where((e) => e.contains(q)).toList();
  }

  void _select(String emoji) {
    HapticFeedback.lightImpact();
    setState(() {
      _recent.remove(emoji);
      _recent.insert(0, emoji);
      if (_recent.length > 24) _recent.removeLast();
    });
    widget.onSelected(emoji);
  }

  void _clearRecent() {
    setState(() => _recent.clear());
  }

  void _preview(String e) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e, style: const TextStyle(fontSize: 80)),
              const SizedBox(height: 8),
              Text('Hold to preview, tap to select',
                  style: Theme.of(ctx).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVariant = theme.colorScheme.surfaceVariant
        .withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.5);

    final items = _applyFilters();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select Emoji',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _tabIndex == 0,
                  onSelected: (_) => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Recent'),
                  selected: _tabIndex == 1,
                  onSelected: (_) => setState(() => _tabIndex = 1),
                ),
                if (_tabIndex == 1 && _recent.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearRecent,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: items.isEmpty
                  ? _EmptyState(
                message: _search.text.isEmpty
                    ? (_tabIndex == 1
                    ? 'No recent emojis yet'
                    : 'No emojis')
                    : 'No matches for “${_search.text}”',
              )
                  : LayoutBuilder(
                builder: (ctx, constraints) {
                  const tileSize = 52.0;
                  final columns =
                  (constraints.maxWidth / tileSize).floor().clamp(5, 10);
                  return GridView.builder(
                    key: ValueKey(
                        '${_tabIndex}_${_search.text}_${items.length}'),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final e = items[i];
                      return _EmojiTile(
                        emoji: e,
                        background: surfaceVariant,
                        onTap: () => _select(e),
                        onLongPress: () => _preview(e),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingGrid extends StatelessWidget {
  const _LoadingGrid({Key? key, required this.background}) : super(key: key);
  final Color background;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        const tileSize = 96.0;
        final columns =
        (constraints.maxWidth / tileSize).floor().clamp(3, 7);
        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: 16,
          itemBuilder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: background,
              child: const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: BirthdayLoadingRing(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StickerPreviewDialog extends StatelessWidget {
  const _StickerPreviewDialog({Key? key, required this.url}) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 40, color: theme.colorScheme.outline),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: SizedBox(
                          height: 36,
                          width: 36,
                          child: BirthdayLoadingRing(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton.filledTonal(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}

class _StickerTile extends StatefulWidget {
  const _StickerTile({
    Key? key,
    required this.url,
    required this.background,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);

  final String url;
  final Color background;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  State<_StickerTile> createState() => _StickerTileState();
}

class _StickerTileState extends State<_StickerTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
            boxShadow: _pressed
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Smooth fade-in image
                Image.network(
                  widget.url,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (wasSync) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 250),
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image_rounded,
                        size: 32, color: theme.colorScheme.outline),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: BirthdayLoadingRing(),
                      ),
                    );
                  },
                ),
                // Subtle pressed scale
                AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  scale: _pressed ? 0.97 : 1.0,
                  child: const SizedBox.expand(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StickerPickerSheet extends StatefulWidget {
  const _StickerPickerSheet({
    Key? key,
    required this.stickers,
    required this.isLoading,
    required this.onSelected,
  }) : super(key: key);

  final List<String> stickers;
  final bool isLoading;
  final ValueChanged<String> onSelected;

  @override
  State<_StickerPickerSheet> createState() => _StickerPickerSheetState();
}

class _StickerPickerSheetState extends State<_StickerPickerSheet> {
  static final List<String> _recent = <String>[];

  final TextEditingController _search = TextEditingController();
  int _tabIndex = 0; // 0 = All, 1 = Recent

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<String> _applyFilters() {
    final pool = _tabIndex == 1 ? _recent : widget.stickers;
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return List<String>.from(pool);
    return pool.where((url) {
      final name = Uri.decodeComponent(url.split('/').last).toLowerCase();
      return name.contains(q);
    }).toList();
  }

  void _select(String url) {
    HapticFeedback.lightImpact();
    setState(() {
      _recent.remove(url);
      _recent.insert(0, url);
      if (_recent.length > 36) _recent.removeLast();
    });
    widget.onSelected(url);
  }

  void _clearRecent() => setState(_recent.clear);

  void _preview(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => _StickerPreviewDialog(url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceVariant = Colors.black54
        .withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.5);

    final items = _applyFilters();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select Sticker',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                tooltip: 'Close',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        // Tabs hint (optional search removed for brevity)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _tabIndex == 0,
                  onSelected: (_) => setState(() => _tabIndex = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Recent'),
                  selected: _tabIndex == 1,
                  onSelected: (_) => setState(() => _tabIndex = 1),
                ),
                if (_tabIndex == 1 && _recent.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: _clearRecent,
                    icon: const Icon(Icons.delete_sweep_rounded, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: widget.isLoading && widget.stickers.isEmpty
                  ? _LoadingGrid(
                background: surfaceVariant,
              )
                  : (items.isEmpty
                  ? _EmptyState(
                message: _search.text.isEmpty
                    ? (_tabIndex == 1
                    ? 'No recent stickers yet'
                    : 'No stickers found')
                    : 'No matches',
              )
                  : LayoutBuilder(
                builder: (ctx, constraints) {
                  const tileSize = 96.0; // target tile width
                  final columns = (constraints.maxWidth / tileSize)
                      .floor()
                      .clamp(3, 7);
                  return GridView.builder(
                    key: ValueKey(
                        '${_tabIndex}_${_search.text}_${items.length}'),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final url = items[i];
                      return _StickerTile(
                        url: url,
                        background: surfaceVariant,
                        onTap: () => _select(url),
                        onLongPress: () => _preview(url),
                      );
                    },
                  );
                },
              )),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySmall extends StatelessWidget {
  const _EmptySmall({Key? key, required this.message}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 20, color: theme.colorScheme.outline),
          const SizedBox(width: 6),
          Text(
            message,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _FrameLoadingRow extends StatelessWidget {
  const _FrameLoadingRow({
    Key? key,
    required this.tileSize,
    required this.background,
  }) : super(key: key);

  final double tileSize;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: tileSize,
          height: tileSize,
          color: background,
          child: const Center(
            child: SizedBox(
              height: 22,
              width: 22,
              child: BirthdayLoadingRing(),
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  const _EdgeFade({Key? key, required this.isLeft}) : super(key: key);
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surface;
    return Container(
      width: 18,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: isLeft ? Alignment.centerLeft : Alignment.centerRight,
          end: isLeft ? Alignment.centerRight : Alignment.centerLeft,
          colors: [base, base.withOpacity(0.0)],
        ),
      ),
    );
  }
}

class _FrameTile extends StatefulWidget {
  const _FrameTile({
    Key? key,
    required this.url,
    required this.size,
    required this.background,
    required this.onTap,
  }) : super(key: key);

  final String url;
  final double size;
  final Color background;
  final VoidCallback onTap;

  @override
  State<_FrameTile> createState() => _FrameTileState();
}

class _FrameTileState extends State<_FrameTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onHighlightChanged: (v) => setState(() => _pressed = v),
        borderRadius: BorderRadius.circular(14),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: theme.dividerColor.withOpacity(0.08)),
            boxShadow: _pressed
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  widget.url,
                  fit: BoxFit.cover,
                  frameBuilder: (context, child, frame, wasSync) {
                    if (wasSync) return child;
                    return AnimatedOpacity(
                      opacity: frame == null ? 0 : 1,
                      duration: const Duration(milliseconds: 220),
                      child: child,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image_rounded,
                        size: 30, color: theme.colorScheme.outline),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: BirthdayLoadingRing(), // your loader
                      ),
                    );
                  },
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 120),
                  scale: _pressed ? 0.98 : 1.0,
                  child: const SizedBox.expand(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrameHorizontalList extends StatelessWidget {
  const _FrameHorizontalList({
    Key? key,
    required this.items,
    required this.onTap,
    required this.tileSize,
  }) : super(key: key);

  final List<String> items;
  final ValueChanged<String> onTap;
  final double tileSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      children: [
        ListView.separated(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (ctx, i) {
            final url = items[i];
            return _FrameTile(
              url: url,
              size: tileSize,
              background: theme.colorScheme.surfaceVariant
                  .withOpacity(theme.brightness == Brightness.dark ? 0.18 : 0.5),
              onTap: () => onTap(url),
            );
          },
        ),
        // Subtle edge fades
        Positioned.fill(
          child: IgnorePointer(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _EdgeFade(isLeft: true),
                _EdgeFade(isLeft: false),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum ItemType { Text, Emoji, Sticker, Image }

class EditableItem {
  double? fontSize;
  FontWeight? fontWeight;
  FontStyle? fontStyle;
  Offset position;
  double scale;
  double rotation;
  ItemType type;
  String value;
  Color color;
  String? fontFamily;

  EditableItem({
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.position = const Offset(0.4, 0.4),
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.type,
    required this.value,
    this.color = Colors.white,
    this.fontFamily,
  });

  EditableItem copyWith({
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Offset? position,
    double? scale,
    double? rotation,
    ItemType? type,
    String? value,
    Color? color,
    String? fontFamily,
  }) {
    return EditableItem(
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      fontStyle: fontStyle ?? this.fontStyle,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      type: type ?? this.type,
      value: value ?? this.value,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}