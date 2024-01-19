import 'package:flutter/material.dart';

import 'package:markdown/markdown.dart';

import 'markdown_core_builder.dart';
import 'markdown_core_text_style.dart';

class Markdown extends StatefulWidget {
  const Markdown({
    Key? key,
    required this.data,
    required this.linkTap,
    required this.image,
    this.maxWidth,
    this.textStyle,
  }) : super(key: key);

  final String data;

  final LinkTap linkTap;

  final WidgetImage image;

  final double? maxWidth;

  final TextStyle? textStyle;

  @override
  MarkdownState createState() => MarkdownState();
}

class MarkdownState extends State<Markdown> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _parseMarkdown(),
    );
  }

  List<Widget> _parseMarkdown() {
    // debugPrint(markdownToHtml(
    //   widget.data,
    //   extensionSet: ExtensionSet.gitHubWeb,
    // ));
    final List<String> lines = widget.data.split(RegExp(r'\r?\n'));
    final nodes = Document(
      extensionSet: ExtensionSet.gitHubWeb,
    ).parseLines(lines);
    return MarkdownBuilder(
      context,
      widget.linkTap,
      widget.image,
      widget.maxWidth ?? MediaQuery.of(context).size.width,
      widget.textStyle ?? defaultTextStyle(context),
    ).build(nodes);
  }
}
