import 'dart:async';

import 'package:flutter/material.dart';

///  Action image button of markdown editor.
class ActionImage extends StatefulWidget {
  ActionImage({
    Key? key,
    required this.type,
    required this.tap,
    this.imageSelect,
    required this.color,
    this.getCursorPosition,
  })  : super(key: key);

  final ActionType type;
  final TapFinishCallback tap;
  final ImageSelectCallback? imageSelect;
  final GetCursorPosition? getCursorPosition;

  final Color? color;

  @override
  ActionImageState createState() => ActionImageState();
}

class ActionImageState extends State<ActionImage> {
  IconData? _getImageIconCode() {
    return _defaultImageAttributes
        .firstWhere((img) => img.type == widget.type)
        .iconData;
  }

  void _disposeAction() {
    var firstWhere =
        _defaultImageAttributes.firstWhere((img) => img.type == widget.type);
    if (firstWhere.type == ActionType.image && widget.getCursorPosition != null) {
      var cursorPosition = widget.getCursorPosition!();
      if (widget.imageSelect != null) {
        widget.imageSelect!().then(
          (str) {
            debugPrint('Image select $str');
            if (str.isNotEmpty) {
              // Delay its execution and wait for TextFiled to get focus
              // Otherwise, the text will not be successfully inserted.
              Timer(const Duration(milliseconds: 200), () {
                widget.tap(widget.type, '![]($str)', 0, cursorPosition);
              });
            }
          },
          onError: print,
        );
        return;
      }
    }
    widget.tap(widget.type, firstWhere.text ?? '', firstWhere.positionReverse ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      preferBelow: false,
      message: _defaultImageAttributes
          .firstWhere((img) => img.type == widget.type)
          .tip,
      child: IconButton(
        icon: Icon(
          _getImageIconCode(),
          color: widget.color,
        ),
        onPressed: _disposeAction,
      ),
    );
  }
}

const _defaultImageAttributes = <ImageAttributes>[
  ImageAttributes(
    type: ActionType.undo,
    tip: 'Cancel',
    iconData: Icons.undo,
  ),
  ImageAttributes(
    type: ActionType.redo,
    tip: 'Recover',
    iconData: Icons.redo,
  ),
  ImageAttributes(
    type: ActionType.image,
    text: '![]()',
    tip: 'Picture',
    positionReverse: 3,
    iconData: Icons.image,
  ),
  ImageAttributes(
    type: ActionType.link,
    text: '[]()',
    tip: 'Link',
    positionReverse: 3,
    iconData: Icons.link,
  ),
  ImageAttributes(
    type: ActionType.fontBold,
    text: '****',
    tip: 'Bold',
    positionReverse: 2,
    iconData: Icons.font_download,
  ),
  ImageAttributes(
    type: ActionType.fontItalic,
    text: '**',
    tip: 'Italics',
    positionReverse: 1,
    iconData:Icons.format_italic,
  ),
  ImageAttributes(
    type: ActionType.fontStrikethrough,
    text: '~~~~',
    tip: 'Strikethrough',
    positionReverse: 2,
    iconData: Icons.format_strikethrough,
  ),
  ImageAttributes(
    type: ActionType.textQuote,
    text: '\n>',
    tip: 'Character Quote',
    positionReverse: 0,
    iconData:Icons.format_quote,
  ),
  ImageAttributes(
    type: ActionType.list,
    text: '\n- ',
    tip: 'Unordered list',
    positionReverse: 0,
    iconData: Icons.format_list_bulleted,
  ),
  // ImageAttributes(
  //   type: ActionType.h4,
  //   text: '\n#### ',
  //   tip: 'Level 4 heading',
  //   positionReverse: 0,
  //   iconData: const IconData(
  //     0xe75e,
  //     fontFamily: 'MyIconFont',
  //     fontPackage: _fontPackage,
  //   ),
  // ),
  // ImageAttributes(
  //   type: ActionType.h5,
  //   text: '\n##### ',
  //   tip: 'Level 5 heading',
  //   positionReverse: 0,
  //   iconData: const IconData(
  //     0xe75f,
  //     fontFamily: 'MyIconFont',
  //     fontPackage: _fontPackage,
  //   ),
  // ),
  // ImageAttributes(
  //   type: ActionType.h1,
  //   text: '\n# ',
  //   tip: 'First Level Title',
  //   positionReverse: 0,
  //   iconData: const IconData(
  //     0xe75b,
  //     fontFamily: 'MyIconFont',
  //     fontPackage: _fontPackage,
  //   ),
  // ),
  // ImageAttributes(
  //   type: ActionType.h2,
  //   text: '\n## ',
  //   tip: 'Second level title',
  //   positionReverse: 0,
  //   iconData: const IconData(
  //     0xe75c,
  //     fontFamily: 'MyIconFont',
  //     fontPackage: _fontPackage,
  //   ),
  // ),
  // ImageAttributes(
  //   type: ActionType.h3,
  //   text: '\n### ',
  //   tip: 'Level 3 headings',
  //   positionReverse: 0,
  //   iconData: const IconData(
  //     0xe75d,
  //     fontFamily: 'MyIconFont',
  //     fontPackage: _fontPackage,
  //   ),
  // ),
];

enum ActionType {
  undo,
  redo,
  image,
  link,
  fontBold,
  fontItalic,
  fontStrikethrough,
  fontDeleteLine,
  textQuote,
  list,
  h1,
  h2,
  h3,
  h4,
  h5,
}

class ImageAttributes {
  const ImageAttributes({
    this.tip = '',
    this.text,
    this.positionReverse,
    required this.type,
    required this.iconData,
  });

  final ActionType type;
  final IconData iconData;
  final String tip;
  final String? text;
  final int? positionReverse;
}

/// Call this method after clicking the [ActionImage] and completing a series of actions.
/// [text] Adding text.
/// [position] Cursor position that reverse order.
/// [cursorPosition] Will start insert text at this position.
typedef void TapFinishCallback(
  ActionType type,
  String text,
  int positionReverse, [
  int? cursorPosition,
]);

/// Call this method after clicking the ImageAction.
/// return your select image path.
typedef Future<String> ImageSelectCallback();

/// Get the current cursor position.
typedef int GetCursorPosition();
