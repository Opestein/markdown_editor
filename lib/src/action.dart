import 'dart:async';

import 'package:flutter/material.dart';

///  Action image button of markdown editor.
class ActionImage extends StatefulWidget {
  ActionImage({
    Key? key,
    required this.type,
    required this.tap,
    required this.color,
    this.getCursorPosition,
  }) : super(key: key);

  final ActionType type;
  final TapFinishCallback tap;
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
    // if (firstWhere.type == ActionType.image &&
    //     widget.getCursorPosition != null) {
    //   var cursorPosition = widget.getCursorPosition!();
    //   if (widget.imageSelect != null) {
    //     widget.imageSelect!().then(
    //       (str) {
    //         debugPrint('Image select $str');
    //         if (str.isNotEmpty) {
    //           // Delay its execution and wait for TextFiled to get focus
    //           // Otherwise, the text will not be successfully inserted.
    //           Timer(const Duration(milliseconds: 200), () {
    //             widget.tap(widget.type, '![desc]','(https://)', 0, cursorPosition);
    //           });
    //         }
    //       },
    //       onError: print,
    //     );
    //     return;
    //   }
    // }
    widget.tap(widget.type, firstWhere.prefix ?? '', firstWhere.suffix ?? '',
        firstWhere.positionReverse ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Tooltip(
      preferBelow: false,
      message: _defaultImageAttributes
          .firstWhere((img) => img.type == widget.type)
          .tip,
      child: IconButton(
        icon: Icon(
          _getImageIconCode(),
          color: widget.color ?? theme.iconTheme.color,
        ),
        onPressed: _disposeAction,
      ),
    );
  }
}

const _defaultImageAttributes = <ImageAttributes>[
  ImageAttributes(
    type: ActionType.image,
    prefix: '![placeholder]',
    suffix: '(placeholder)',
    tip: 'Picture',
    positionReverse: 3,
    iconData: Icons.image,
  ),
  ImageAttributes(
    type: ActionType.link,
    prefix: '[placeholder]',
    suffix: '(placeholder)',
    tip: 'Link',
    positionReverse: 3,
    iconData: Icons.link,
  ),
  ImageAttributes(
    type: ActionType.fontBold,
    prefix: '**',
    suffix: '**',
    tip: 'Bold',
    positionReverse: 2,
    iconData: Icons.font_download,
  ),
  ImageAttributes(
    type: ActionType.fontItalic,
    prefix: '*',
    suffix: '*',
    tip: 'Italics',
    positionReverse: 1,
    iconData: Icons.format_italic,
  ),
  ImageAttributes(
    type: ActionType.fontStrikethrough,
    prefix: '~~',
    suffix: '~~',
    tip: 'Strikethrough',
    positionReverse: 2,
    iconData: Icons.format_strikethrough,
  ),
  ImageAttributes(
    type: ActionType.textQuote,
    prefix: '\n> ',
    tip: 'Character Quote',
    positionReverse: 0,
    iconData: Icons.format_quote,
  ),
  ImageAttributes(
    type: ActionType.list,
    prefix: '\n- ',
    tip: 'Unordered list',
    positionReverse: 0,
    iconData: Icons.format_list_bulleted,
  ),
  ImageAttributes(
    type: ActionType.preview,
    prefix: '\n- ',
    tip: 'Preview Content',
    positionReverse: 0,
    iconData: Icons.preview,
  ),
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
  image,
  link,
  fontBold,
  fontItalic,
  fontStrikethrough,
  fontDeleteLine,
  textQuote,
  list,
  preview,
  undo,
  redo,
  // h1,
  // h2,
  // h3,
  // h4,
  // h5,
}

class ImageAttributes {
  const ImageAttributes({
    this.tip = '',
    this.prefix,
    this.suffix,
    this.positionReverse,
    required this.type,
    required this.iconData,
  });

  final ActionType type;
  final IconData iconData;
  final String tip;
  final String? prefix;
  final String? suffix;
  final int? positionReverse;
}

/// Call this method after clicking the [ActionImage] and completing a series of actions.
/// [text] Adding text.
/// [position] Cursor position that reverse order.
/// [cursorPosition] Will start insert text at this position.
typedef void TapFinishCallback(
    ActionType type, String prefix, String suffix, int positionReverse,
    [int? cursorPosition]);

/// Get the current cursor position.
typedef int GetCursorPosition();
