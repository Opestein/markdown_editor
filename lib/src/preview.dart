import 'package:flutter/material.dart';
import 'package:markdown_editor/src/action.dart';
import 'package:markdown_editor/src/markdown_editor.dart';

import 'markdown_core/markdown_core.dart';
import 'markdown_core/markdown_core_builder.dart';

class MdPreview extends StatefulWidget {
  MdPreview(
      {Key? key,
      required this.textFieldModel,
      this.isPreviewExpanded = false,
      this.previewPadding = const EdgeInsets.all(0.0),
      this.toolbarPadding = const EdgeInsets.all(0.0),
      this.onTapLink,
      this.previewImageWidget,
      this.textStyle,
      this.actionIconColor,
      this.onPreviewClicked,
      this.previewWidget})
      : super(key: key);

  final TextFieldModel textFieldModel;
  final bool isPreviewExpanded;
  final EdgeInsetsGeometry previewPadding, toolbarPadding;

  final WidgetImage? previewImageWidget;
  final TextStyle? textStyle;

  /// Change icon color, eg: co
  /// lor of font_bold icon.
  final Color? actionIconColor;
  final VoidCallback? onPreviewClicked;

  /// Call this method when it tap link of markdown.
  /// If [onTapLink] is null,it will open the link with your default browser.
  final TapLinkCallback? onTapLink;

  final Widget Function(String content)? previewWidget;

  @override
  State<StatefulWidget> createState() => MdPreviewState();
}

class MdPreviewState extends State<MdPreview>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        if (widget.previewWidget != null)
          widget.previewWidget!(
              widget.textFieldModel.textEditingController.text ?? '')
        else
          _isExpandedWidget(
            isExpanded: widget.isPreviewExpanded,
            child: SingleChildScrollView(
              padding: widget.previewPadding,
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if ((widget.textFieldModel.textEditingController.text ?? '')
                      .isEmpty) {
                    return const SizedBox();
                  }
                  return Markdown(
                    data:
                        widget.textFieldModel.textEditingController.text ?? '',
                    maxWidth: constraints.maxWidth,
                    linkTap: (link) {
                      debugPrint(link);
                      if (widget.onTapLink != null) {
                        widget.onTapLink!(link);
                      }
                    },
                    image: widget.previewImageWidget != null
                        ? widget.previewImageWidget!
                        : (url) => const SizedBox(),
                    textStyle: widget.textStyle,
                  );
                },
              ),
            ),
          ),
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
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: widget.toolbarPadding,
                child: Row(
                  children: [
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
                  ],
                ),
              )),
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

  @override
  bool get wantKeepAlive => true;
}

typedef void TapLinkCallback(String link);
