library markdown_editor;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:markdown_editor/src/action.dart';
import 'package:markdown_editor/src/editor.dart';
import 'package:markdown_editor/src/markdown_core/markdown_core_builder.dart';
import 'package:markdown_editor/src/preview.dart';

class MarkdownText {
  const MarkdownText(this.text);

  final String text;
}

enum PageType { editor, preview }

class MarkdownEditor extends StatefulWidget {
  MarkdownEditor(
      {Key? key,
      this.isEditorExpanded = false,
      this.isPreviewExpanded = false,
      this.editorContentPadding,
      this.editorPadding = const EdgeInsets.all(0.0),
      this.previewPadding = const EdgeInsets.all(0.0),
      this.editorToolbarPadding = const EdgeInsets.all(0.0),
      this.previewToolbarPadding = const EdgeInsets.all(0.0),
      this.initText,
      this.hintText,
      this.onTapLink,
      this.imageSelect,
      this.textChange,
      this.actionIconColor = Colors.grey,
      this.cursorColor,
      this.dividerColor,
      this.textStyle,
      this.hintTextStyle,
      this.appendBottomWidget,
      this.previewWidget,
      this.previewImageWidget,
      this.maxLines = 1,
      this.minLines,
      this.onViewChange,
      this.toolBarPosition = MdEditorToolBarPosition.bottom})
      : super(key: key);

  final bool isEditorExpanded, isPreviewExpanded;
  final EdgeInsetsGeometry? editorContentPadding;
  final EdgeInsetsGeometry editorPadding,
      previewPadding,
      editorToolbarPadding,
      previewToolbarPadding;

  final String? initText;

  final String? hintText;

  /// see [MdPreview.onTapLink]
  final TapLinkCallback? onTapLink;

  /// see [ImageSelectCallback]
  final ImageSelectCallback? imageSelect;

  /// When page change to [PageType.preview] or [PageType.editor]
  // final TabChange? tabChange;

  /// When title or text changed
  final VoidCallback? textChange;

  /// Change icon color, eg: color of font_bold icon.
  final Color? actionIconColor;

  /// Change cursor color
  final Color? cursorColor;

  final Color? dividerColor;

  final TextStyle? textStyle;
  final TextStyle? hintTextStyle;

  final Widget? appendBottomWidget;

  final int? maxLines;

  final int? minLines;

  final WidgetImage? previewImageWidget;

  final Widget Function(String content)? previewWidget;
  final Function(PageType pageType)? onViewChange;

  final MdEditorToolBarPosition toolBarPosition;

  @override
  State<StatefulWidget> createState() => MarkdownEditorWidgetState();
}

class MarkdownEditorWidgetState extends State<MarkdownEditor>
    with SingleTickerProviderStateMixin {
  late final TextFieldModel textFieldModel =
      TextFieldModel(value: TextEditingValue(text: widget.initText ?? ''));

  final FocusNode textFocusNode = FocusNode();
  final GlobalKey<MdEditorState> _editorKey = GlobalKey();
  String _previewText = '';
  PageType _pageType = PageType.editor;

  /// Get edited Markdown title and text
  String markdownText = '';

  bool isPreviewSelected = true;
  bool showToolBar = false;

  /// Change current [PageType]
  void setCurrentPage(PageType type) {
    setState(() {
      _pageType = type;
      if (_pageType == PageType.preview) {
        _previewText = _editorKey.currentState?.getText() ?? '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    textFocusNode.addListener(_focusListener);
  }

  @override
  void dispose() {
    textFocusNode.removeListener(_focusListener);
    textFocusNode.dispose();
    textFieldModel.disposeCC();
    super.dispose();
  }

  _focusListener() {
    if (textFocusNode.hasPrimaryFocus) {
      setState(() {
        showToolBar = true;
      });
    } else {
      setState(() {
        showToolBar = false;
      });
      switchView();
    }
  }

  switchView() {
    setState(() {
      isPreviewSelected = !isPreviewSelected;
    });
  }

  switchViewAndRequestFocus() {
    setState(() {
      isPreviewSelected = false;
      textFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return isPreviewSelected
        ? GestureDetector(
            onTap: () {
              switchViewAndRequestFocus();
            },
            child: Container(
              color: Colors.transparent,
              child: MdPreview(
                textFieldModel: textFieldModel,
                toolbarPadding: widget.previewToolbarPadding,
                previewPadding: widget.previewPadding,
                isPreviewExpanded: widget.isPreviewExpanded,
                previewImageWidget: widget.previewImageWidget,
                actionIconColor: widget.actionIconColor,
                previewWidget: widget.previewWidget,
                onPreviewClicked: switchView,
              ),
            ),
          )
        : MdEditor(
            key: _editorKey,
            textFieldModel: textFieldModel,
            textFocusNode: textFocusNode,
            showToolBar: showToolBar,
            editorContentPadding: widget.editorContentPadding,
            editorPadding: widget.editorPadding,
            toolbarPadding: widget.editorToolbarPadding,
            hintText: widget.hintText,
            textStyle: widget.textStyle,
            hintTextStyle: widget.hintTextStyle,
            imageSelect: widget.imageSelect,
            textChange: widget.textChange,
            actionIconColor: widget.actionIconColor,
            cursorColor: widget.cursorColor,
            appendBottomWidget: widget.appendBottomWidget,
            isExpanded: widget.isEditorExpanded,
            maxLines: widget.maxLines,
            minLines: widget.minLines,
            onPreviewClicked: switchView,
            switchViewAndRequestFocus: switchViewAndRequestFocus,
            dividerColor: widget.dividerColor,
            toolBarPosition: widget.toolBarPosition,
          );
  }
}

class TextFieldModel extends ChangeNotifier {
  TextFieldModel({TextEditingValue? value}) {
    if (value != null) updateField(value);
  }

  TextEditingController _textEditingController = TextEditingController();

  TextEditingController get textEditingController => _textEditingController;

  initListeners() {}

  disposeCC() {
    _textEditingController.dispose();
  }

  updateField(TextEditingValue value) {
    _textEditingController.value = value;
    notifyListeners();
  }
}
