import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor/src/action.dart';
import 'package:markdown_editor/src/customize_physics.dart';
import 'package:markdown_editor/src/edit_perform.dart';
import 'package:markdown_editor/src/interceptor_model.dart';
import 'package:markdown_editor/src/markdown_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Future<MediaInterceptorModel?> ImageSelectCallback();

class MdEditor extends StatefulWidget {
  MdEditor(
      {Key? key,
      required this.textFieldModel,
      this.textFocusNode,
      this.titleStyle,
      this.textStyle,
      this.showToolBar = false,
      this.editorContentPadding,
      this.editorPadding = const EdgeInsets.all(0.0),
      this.toolbarPadding = const EdgeInsets.all(0.0),
      this.hintText,
      this.hintTextStyle,
      this.imageSelect,
      this.textChange,
      this.onPreviewClicked,
      this.switchViewAndRequestFocus,
      this.actionIconColor,
      this.cursorColor,
      this.appendBottomWidget,
      this.isExpanded = false,
      this.maxLines = 1,
      this.minLines,
      this.dividerColor})
      : super(key: key);

  final FocusNode? textFocusNode;

  final TextFieldModel textFieldModel;
  final TextStyle? titleStyle;
  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;
  final EdgeInsetsGeometry editorPadding;
  final EdgeInsetsGeometry toolbarPadding;
  final EdgeInsetsGeometry? editorContentPadding;
  final String? hintText;
  final bool showToolBar;

  /// see [ImageSelectCallback]
  final ImageSelectCallback? imageSelect;

  final VoidCallback? textChange;

  final VoidCallback? onPreviewClicked, switchViewAndRequestFocus;

  /// Change icon color, eg: color of font_bold icon.
  final Color? actionIconColor;

  final Color? cursorColor;

  final Widget? appendBottomWidget;

  final bool isExpanded;

  final int? maxLines;

  final int? minLines;

  final Color? dividerColor;

  @override
  State<StatefulWidget> createState() => MdEditorState();
}

class MdEditorState extends State<MdEditor> with AutomaticKeepAliveClientMixin {
  late TextFieldModel textFieldModel = widget.textFieldModel;
  var _editPerform;
  SharedPreferences? _pres;

  String getText() {
    return textFieldModel.textEditingController.value.text;
  }

  // Move the text box cursor to the end
  void moveTextCursorToEnd() {
    final str = textFieldModel.textEditingController.text;
    textFieldModel.updateField(TextEditingValue(
        text: str, selection: TextSelection.collapsed(offset: str.length)));
  }

  @override
  void initState() {
    super.initState();

    _editPerform = EditPerform(
      textFieldModel.textEditingController,
      initText: textFieldModel.textEditingController.text,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  TextEditingValue attachmentHelper(TextEditingValue value,
      {String prefix = '',
      String suffix = '',
      String prefixPlaceholder = '',
      String suffixPlaceholder = ''}) {
    String currentText = value.text;
    TextSelection selection = value.selection;
    // Extract the highlighted text
    String highlightedText =
        currentText.substring(selection.start, selection.end);

    print('value: ${value.text}');
    bool isHighlightedText = selection.start != selection.end;

    // Gets the index of the first part of the prefix.
    // e.g. if prefix is ** in a text, this would return the position of selection.start/cursor + 2
    int startOfPrefixPrePlaceholder =
        selection.start + prefix.indexOf('placeholder');
    int endOfPrefixPrePlaceholder =
        selection.end + prefix.indexOf('placeholder');
    // Check if this is an highlighted text, replace with the highlighted text, else use the placeholder
    prefix = prefix.replaceAll(
        'placeholder', isHighlightedText ? highlightedText : prefixPlaceholder);

    // use the placeholder for suffix
    suffix = suffix.replaceAll('placeholder', suffixPlaceholder);

    // Add characters at the start and end of the highlighted text
    String newText = currentText.replaceRange(
        selection.start, selection.end, prefix + suffix);

    // Update text and move cursor to end of word
    return TextEditingValue(
        text: newText,
        selection: isHighlightedText
            ? TextSelection(
                baseOffset: startOfPrefixPrePlaceholder,
                extentOffset: endOfPrefixPrePlaceholder)
            : TextSelection(
                baseOffset: startOfPrefixPrePlaceholder,
                extentOffset: selection.end + (prefix.length - 1)));
  }

  TextEditingValue insertInBetweenHelper(TextSelection selection,
      {String prefix = '', String suffix = '', String placeHolder = ''}) {
    String currentText = textFieldModel.textEditingController.text;
    // Extract the highlighted text
    String highlightedText =
        currentText.substring(selection.start, selection.end);

    bool isHighlightedText = selection.start != selection.end;

    // Add characters at the start and end of the highlighted text
    String newText = currentText.replaceRange(selection.start, selection.end,
        prefix + (isHighlightedText ? highlightedText : placeHolder) + suffix);

    // Update text and move cursor to end of word
    return TextEditingValue(
        text: newText,
        selection: isHighlightedText
            ? TextSelection(
                baseOffset: selection.start + prefix.length,
                extentOffset: selection.end + prefix.length)
            : TextSelection(
                baseOffset: selection.start + prefix.length,
                extentOffset:
                    selection.start + placeHolder.length + prefix.length));
  }

  TextEditingValue insertUsingNewLineHelper(TextSelection selection,
      {String prefix = ''}) {
    String currentText = textFieldModel.textEditingController.text;
    // Extract the highlighted text
    String highlightedText =
        currentText.substring(selection.start, selection.end);

    bool isHighlightedText = selection.start != selection.end;
    if (selection.start < 1) {
      // remove the new line if it's the beginning of text
      prefix = prefix.replaceFirst('\n', '');
    }
    // Add characters at the start and end of the highlighted text
    String newText = currentText.replaceRange(
        selection.start, selection.end, prefix + highlightedText);

    // Update text and move cursor to end of word
    return TextEditingValue(
        text: newText,
        selection: isHighlightedText
            ? TextSelection(
                baseOffset: selection.start + prefix.length,
                extentOffset: selection.end + prefix.length)
            : TextSelection(
                baseOffset: selection.start + prefix.length,
                extentOffset: selection.start + prefix.length));
  }

  List<String> breaks = ['\n- '];

  String oldValue = '';

  TextEditingValue onNewLineOnTextChangedListener(TextSelection selection) {
    String currentText = textFieldModel.textEditingController.text;
    int cursorPosition = textFieldModel.textEditingController.selection.start;
    bool isDelete = currentText.length < oldValue.length;
    if (!isDelete &&
        cursorPosition > 1 &&
        currentText.substring(cursorPosition - 1).startsWith('\n')) {
      // Find the start and end of the current line
      int cursorIndexPreNewLine =
          textFieldModel.textEditingController.selection.start;

      // Get the text from the start to the cursor
      String editableText = currentText.substring(0, cursorIndexPreNewLine - 1);
      // Get the text from the previous line break to in editableText
      print('cursorPosition: $cursorPosition');
      print('editableText: ${editableText}');

      // If the last index of the editableText is greater than -1; this means there was a previous line break
      // else use the editableText as it is
      String editableTextLastLineBreak = editableText.lastIndexOf('\n') > 0
          ? editableText.substring(editableText.lastIndexOf('\n'))
          : editableText;

      String suffixText = '';
      // Check if the text in the last line break contains any of out markers
      for (var item in breaks) {
        // Replace all line break to make sure only the symbol remains.
        // Replacement is done so it can apply to if line break being applied to beginning of a text without line break
        if (editableTextLastLineBreak
            .replaceFirst('\n', '')
            .startsWith(item.replaceFirst('\n', ''))) {
          suffixText = item;
        }
      }

      if (suffixText.isEmpty) {
        // This means there is no custom line break
        oldValue = currentText;
        return textFieldModel.textEditingController.value;
      }

      editableText = editableText + suffixText;

      // Get the text from the after the cursor to date
      String postEditableText = currentText.substring(cursorIndexPreNewLine);

      currentText = editableText + postEditableText;

      // print('editableText: $editableText');
      // print('postEditableText: $postEditableText');
      // print('editableText lastIndexOf: ${editableText.lastIndexOf('\n')}');
      // print(
      //     'editableText indexOf: ${editableText.indexOf(' ', editableText.lastIndexOf('\n'))}');
      // print(
      //     'postEditableText lastIndexOf: ${postEditableText.lastIndexOf('\n')}');
      oldValue = currentText;
      return TextEditingValue(
          text: currentText,
          selection: selection.copyWith(
              baseOffset: selection.baseOffset +
                  (suffixText.replaceFirst('\n', '')).length,
              extentOffset: selection.baseOffset +
                  (suffixText.replaceFirst('\n', '')).length));
    }

    oldValue = currentText;
    return textFieldModel.textEditingController.value;
  }

  /// Get cursor position
  int _getCursorPosition() {
    if (textFieldModel.textEditingController.text.isEmpty) return 0;
    if (textFieldModel.textEditingController.selection.base.offset < 0)
      return textFieldModel.textEditingController.text.length;
    return textFieldModel.textEditingController.selection.base.offset;
  }

  Future<void> _initSharedPreferences() async {
    _pres = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        _isExpandedWidget(
          isExpanded: widget.isExpanded,
          child: Padding(
            padding: widget.editorPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _isExpandedWidget(
                  isExpanded: widget.isExpanded,
                  child: TextField(
                    expands: widget.isExpanded,
                    maxLines: widget.isExpanded ? null : widget.maxLines,
                    minLines: widget.isExpanded ? null : widget.minLines,
                    // contentInsertionConfiguration:
                    //     ContentInsertionConfiguration(
                    //   onContentInserted: (_) {
                    //     /*your cb here*/
                    //   },
                    //   allowedMimeTypes: [
                    //     "image/png", /*...*/
                    //   ],
                    // ),
                    cursorColor: widget.cursorColor,
                    cursorWidth: 1.5,
                    controller: textFieldModel.textEditingController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    textAlignVertical: TextAlignVertical.top,
                    focusNode: widget.textFocusNode,
                    // scrollPhysics: const CustomizePhysics(),
                    style: widget.textStyle ??
                        theme.textTheme.bodyLarge!.copyWith(
                          height: kIsWeb ? null : 1.3,
                        ),
                    // onChanged: (text) {
                    //   _editPerform.change(text);
                    //   if (widget.textChange != null) widget.textChange!();
                    // },
                    onChanged: (value) {
                      textFieldModel.updateField(onNewLineOnTextChangedListener(
                          textFieldModel.textEditingController.selection));

                      final _tempKey = '$preferenceKey';
                      _pres?.setInt(
                          _tempKey, (_pres?.getInt(_tempKey) ?? 0) + 1);
                      debugPrint('$_tempKey   ${_pres?.getInt(_tempKey)}');

                      _editPerform
                          .change(textFieldModel.textEditingController.text);
                    },
                    decoration: InputDecoration(
                      contentPadding: widget.editorContentPadding,
                      alignLabelWithHint: true,
                      hintText: widget.hintText ?? 'Please enter content',
                      border: InputBorder.none,
                      hintStyle: widget.hintTextStyle,
                    ),
                  ),
                ),
                widget.appendBottomWidget ?? const SizedBox(),
              ],
            ),
          ),
        ),
        if (widget.showToolBar)
          Container(
            height: 40.0,
            width: MediaQuery.of(context).size.width,
            child: Ink(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(color: theme.scaffoldBackgroundColor),
                ],
              ),
              child: FutureBuilder(
                future: _pres == null ? _initSharedPreferences() : null,
                builder: (con, snap) {
                  final _imageActionWidgets = <ActionImage>[
                    ..._getImageActionWidgets().map((sort) => sort.widget)
                  ];

                  final _textFormatActionWidgets = <ActionImage>[
                    ..._getTextFormatActionWidgets().map((sort) => sort.widget)
                  ];
                  final _listActionWidgets = <ActionImage>[
                    ..._getListActionWidgets().map((sort) => sort.widget)
                  ];
                  final _previewActionWidgets = <ActionImage>[
                    ActionImage(
                        type: ActionType.preview,
                        color: widget.actionIconColor,
                        tap: (ActionType type, String prefix, String suffix,
                            int positionReverse,
                            [int? cursorPosition]) {
                          //   Open preview page
                          if (widget.onPreviewClicked != null) {
                            widget.onPreviewClicked!();
                          }
                        })
                  ];
                  final _redoUndoActionWidgets = <ActionImage>[
                    ActionImage(
                      type: ActionType.undo,
                      color: widget.actionIconColor,
                      tap: (t, p, s, i, [cp]) {
                        _editPerform.undo();
                      },
                    ),
                    ActionImage(
                      type: ActionType.redo,
                      color: widget.actionIconColor,
                      tap: (t, p, s, i, [cp]) {
                        _editPerform.redo();
                      },
                    )
                  ];

                  final _divider = VerticalDivider(
                      width: 4,
                      indent: 8,
                      endIndent: 8,
                      color: widget.dividerColor ?? theme.dividerColor,
                      thickness: 1);
                  return SingleChildScrollView(
                    padding: widget.toolbarPadding,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ..._imageActionWidgets.map((e) => e).toList(),
                        _divider,
                        ..._textFormatActionWidgets.map((e) => e).toList(),
                        _divider,
                        ..._listActionWidgets.map((e) => e).toList(),
                        _divider,
                        ..._previewActionWidgets.map((e) => e).toList(),
                        // _divider,
                        // ..._redoUndoActionWidgets.map((e) => e).toList()
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _isExpandedWidget({required bool isExpanded, required Widget child}) {
    if (isExpanded) {
      return Expanded(child: child);
    }

    return child;
  }

  final preferenceKey = 'markdown_editor';

  /// Sort action buttons by used count.
  List<_SortActionWidget> _getImageActionWidgets() {
    final sortWidget = <_SortActionWidget>[];
    final getSortValue = (ActionType type) {
      return int.parse(
          (_pres?.get('${preferenceKey}_${type.toString()}') ?? '0')
              .toString());
    };
    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.image),
      widget: ActionImage(
        type: ActionType.image,
        color: widget.actionIconColor,
        tap:
            (ActionType type, String prefix, String suffix, int positionReverse,
                [int? cursorPosition]) async {
          if (widget.imageSelect != null) {
            var value = textFieldModel.textEditingController.value;
            MediaInterceptorModel? mediaInterceptorModel =
                await widget.imageSelect!();

            if (widget.switchViewAndRequestFocus != null) {
              widget.switchViewAndRequestFocus!();
            }

            textFieldModel.updateField(attachmentHelper(value,
                prefix: prefix,
                suffix: suffix,
                prefixPlaceholder: mediaInterceptorModel?.title ?? 'Desc',
                suffixPlaceholder: mediaInterceptorModel?.link ?? 'https://'));
          }
        },
        getCursorPosition: _getCursorPosition,
      ),
    ));
    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.link),
      widget: ActionImage(
          type: ActionType.link,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) async {
            textFieldModel.updateField(attachmentHelper(
                textFieldModel.textEditingController.value,
                prefix: prefix,
                suffix: suffix,
                prefixPlaceholder: 'Desc',
                suffixPlaceholder: 'https://'));
          }),
    ));

    return sortWidget;
  }

  List<_SortActionWidget> _getTextFormatActionWidgets() {
    final sortWidget = <_SortActionWidget>[];
    final getSortValue = (ActionType type) {
      return int.parse(
          (_pres?.get('${preferenceKey}_${type.toString()}') ?? '0')
              .toString());
    };

    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.fontBold),
      widget: ActionImage(
          type: ActionType.fontBold,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) {
            textFieldModel.updateField(insertInBetweenHelper(
                textFieldModel.textEditingController.selection,
                prefix: prefix,
                suffix: suffix,
                placeHolder: 'Bold'));
          }),
    ));
    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.fontItalic),
      widget: ActionImage(
          type: ActionType.fontItalic,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) {
            textFieldModel.updateField(insertInBetweenHelper(
                textFieldModel.textEditingController.selection,
                prefix: prefix,
                suffix: suffix,
                placeHolder: 'Italic'));
          }),
    ));
    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.fontStrikethrough),
      widget: ActionImage(
          type: ActionType.fontStrikethrough,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) {
            textFieldModel.updateField(insertInBetweenHelper(
                textFieldModel.textEditingController.selection,
                prefix: prefix,
                suffix: suffix,
                placeHolder: 'Strike'));
          }),
    ));
    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.textQuote),
      widget: ActionImage(
          type: ActionType.textQuote,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) {
            textFieldModel.updateField(insertInBetweenHelper(
                textFieldModel.textEditingController.selection,
                prefix: prefix,
                suffix: suffix,
                placeHolder: 'Blockquote'));
          }),
    ));

    return sortWidget;
  }

  List<_SortActionWidget> _getListActionWidgets() {
    final sortWidget = <_SortActionWidget>[];
    final getSortValue = (ActionType type) {
      return int.parse(
          (_pres?.get('${preferenceKey}_${type.toString()}') ?? '0')
              .toString());
    };

    sortWidget.add(_SortActionWidget(
      sortValue: getSortValue(ActionType.list),
      widget: ActionImage(
          type: ActionType.list,
          color: widget.actionIconColor,
          tap: (ActionType type, String prefix, String suffix,
              int positionReverse,
              [int? cursorPosition]) {
            textFieldModel.updateField(insertUsingNewLineHelper(
                textFieldModel.textEditingController.selection,
                prefix: prefix));
          }),
    ));
    // sortWidget.add(_SortActionWidget(
    //   sortValue: getSortValue(ActionType.h4),
    //   widget: ActionImage(
    //     type: ActionType.h4,
    //     color: widget.actionIconColor,
    //     tap: _disposeText,
    //   ),
    // ));
    // sortWidget.add(_SortActionWidget(
    //   sortValue: getSortValue(ActionType.h5),
    //   widget: ActionImage(
    //     type: ActionType.h5,
    //     color: widget.actionIconColor,
    //     tap: _disposeText,
    //   ),
    // ));
    // sortWidget.add(_SortActionWidget(
    //   sortValue: getSortValue(ActionType.h1),
    //   widget: ActionImage(
    //     type: ActionType.h1,
    //     color: widget.actionIconColor,
    //     tap: _disposeText,
    //   ),
    // ));
    // sortWidget.add(_SortActionWidget(
    //   sortValue: getSortValue(ActionType.h2),
    //   widget: ActionImage(
    //     type: ActionType.h2,
    //     color: widget.actionIconColor,
    //     tap: _disposeText,
    //   ),
    // ));
    // sortWidget.add(_SortActionWidget(
    //   sortValue: getSortValue(ActionType.h3),
    //   widget: ActionImage(
    //     type: ActionType.h3,
    //     color: widget.actionIconColor,
    //     tap: _disposeText,
    //   ),
    // )
    // );

    // sortWidget.sort((a, b) => (b.sortValue).compareTo(a.sortValue));

    return sortWidget;
  }

  @override
  bool get wantKeepAlive => true;
}

class _SortActionWidget {
  final ActionImage widget;
  final int sortValue;

  _SortActionWidget({
    required this.widget,
    required this.sortValue,
  });
}
