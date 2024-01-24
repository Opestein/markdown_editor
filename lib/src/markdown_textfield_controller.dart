import 'package:flutter/material.dart';
import 'package:markdown_editor/src/action.dart';

class MarkdownTextFieldModel {
  final String? prefix;
  final String? suffix;
  final String? prefixPlaceholder;
  final String? suffixPlaceholder;
  final TextStyle? textStyle;

  MarkdownTextFieldModel(
      {this.prefix,
      this.suffix,
      this.prefixPlaceholder,
      this.suffixPlaceholder,
      this.textStyle});
}

class MarkdownTextFieldController extends TextEditingController {
  final List<MarkdownTextFieldModel> map;

  MarkdownTextFieldController(this.map);

  // // Get original

  TextEditingValue _originalEditingValue = TextEditingValue();

  TextEditingValue get originalEditingValue {
    return _originalEditingValue;
  }

  // @override
  // TextSelection get selection {
  //   return this.selection;
  // }

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );

    _originalEditingValue = value;
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context,
      TextStyle? style,
      required bool withComposing}) {
    final List<InlineSpan> children = [];
    String? patternMatched;
    String? formatText;
    TextStyle? myStyle;

    // text.splitMapJoin(
    //   pattern,
    //   onMatch: (Match match) {
    //     myStyle = map[match[0]] ??
    //         map[map.keys.firstWhere(
    //           (e) {
    //             bool ret = false;
    //             RegExp(e).allMatches(text)
    //               ..forEach((element) {
    //                 if (element.group(0) == match[0]) {
    //                   patternMatched = e;
    //                   ret = true;
    //                   return;
    //                 }
    //               });
    //             return ret;
    //           },
    //         )];
    //
    //     if (match.toString().isNotEmpty) {
    //       if (patternMatched == r"_(.*?)\_") {
    //         formatText = match[0]?.replaceAll("_", " ");
    //       } else if (patternMatched == r'\*(.*?)\*') {
    //         formatText = match[0]?.replaceAll("*", " ");
    //       } else if (patternMatched == "~(.*?)~") {
    //         formatText = match[0]?.replaceAll("~", " ");
    //       } else if (patternMatched == r'```(.*?)```') {
    //         formatText = match[0]?.replaceAll("```", "   ");
    //       } else {
    //         formatText = match[0];
    //       }
    //     }
    //
    //
    //     return "";
    //   },
    //   onNonMatch: (String text) {
    //     children.add(TextSpan(text: text, style: style));
    //     return "";
    //   },
    // );

    children.addAll(attachmentHelper(context, value,
        prefix: map.first.prefix ?? '',
        suffix: map.first.suffix ?? '',
        prefixPlaceholder: map.first.prefixPlaceholder ?? '',
        suffixPlaceholder: map.first.suffixPlaceholder ?? ''));
    // return super.buildTextSpan(
    //     context: context, style: style, withComposing: withComposing);
    return TextSpan(style: style, children: children);
  }

  List<InlineSpan> attachmentHelper(
      BuildContext context, TextEditingValue value,
      {String prefix = '',
      String suffix = '',
      String prefixPlaceholder = '',
      String suffixPlaceholder = ''}) {
    if (value.text.isEmpty) {
      return [];
    }
    final List<InlineSpan> children = [];

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
    value = TextEditingValue(
        text: newText,
        selection: isHighlightedText
            ? TextSelection(
                baseOffset: startOfPrefixPrePlaceholder,
                extentOffset: endOfPrefixPrePlaceholder)
            : TextSelection(
                baseOffset: startOfPrefixPrePlaceholder,
                extentOffset: selection.end + (prefix.length - 1)));

    TextStyle? myStyle = TextStyle(color: Colors.purple);
    children.add(TextSpan(
      text: newText,
      style: Theme.of(context).textTheme.bodyMedium?.merge(myStyle),
    ));

    return children;
  }

// TextEditingValue insertInBetweenHelper(TextSelection selection,
//     {String prefix = '', String suffix = '', String placeHolder = ''}) {
//   String currentText = textFieldModel.textEditingController.text;
//   // Extract the highlighted text
//   String highlightedText =
//   currentText.substring(selection.start, selection.end);
//
//   bool isHighlightedText = selection.start != selection.end;
//
//   // Add characters at the start and end of the highlighted text
//   String newText = currentText.replaceRange(selection.start, selection.end,
//       prefix + (isHighlightedText ? highlightedText : placeHolder) + suffix);
//
//   // Update text and move cursor to end of word
//   return TextEditingValue(
//       text: newText,
//       selection: isHighlightedText
//           ? TextSelection(
//           baseOffset: selection.start + prefix.length,
//           extentOffset: selection.end + prefix.length)
//           : TextSelection(
//           baseOffset: selection.start + prefix.length,
//           extentOffset:
//           selection.start + placeHolder.length + prefix.length));
// }
//
// TextEditingValue insertUsingNewLineHelper(TextSelection selection,
//     {String prefix = ''}) {
//   String currentText = textFieldModel.textEditingController.text;
//   // Extract the highlighted text
//   String highlightedText =
//   currentText.substring(selection.start, selection.end);
//
//   bool isHighlightedText = selection.start != selection.end;
//   if (selection.start < 1) {
//     // remove the new line if it's the beginning of text
//     prefix = prefix.replaceFirst('\n', '');
//   }
//   // Add characters at the start and end of the highlighted text
//   String newText = currentText.replaceRange(
//       selection.start, selection.end, prefix + highlightedText);
//
//   // Update text and move cursor to end of word
//   return TextEditingValue(
//       text: newText,
//       selection: isHighlightedText
//           ? TextSelection(
//           baseOffset: selection.start + prefix.length,
//           extentOffset: selection.end + prefix.length)
//           : TextSelection(
//           baseOffset: selection.start + prefix.length,
//           extentOffset: selection.start + prefix.length));
// }
//
// List<String> breaks = ['\n- '];
//
// String oldValue = '';
//
// TextEditingValue onNewLineOnTextChangedListener(TextSelection selection) {
//   String currentText = textFieldModel.textEditingController.text;
//   int cursorPosition = textFieldModel.textEditingController.selection.start;
//   bool isDelete = currentText.length < oldValue.length;
//   if (!isDelete &&
//       cursorPosition > 1 &&
//       currentText.substring(cursorPosition - 1).startsWith('\n')) {
//     // Find the start and end of the current line
//     int cursorIndexPreNewLine =
//         textFieldModel.textEditingController.selection.start;
//
//     // Get the text from the start to the cursor
//     String editableText = currentText.substring(0, cursorIndexPreNewLine - 1);
//     // Get the text from the previous line break to in editableText
//     print('cursorPosition: $cursorPosition');
//     print('editableText: ${editableText}');
//
//     // If the last index of the editableText is greater than -1; this means there was a previous line break
//     // else use the editableText as it is
//     String editableTextLastLineBreak = editableText.lastIndexOf('\n') > 0
//         ? editableText.substring(editableText.lastIndexOf('\n'))
//         : editableText;
//
//     String suffixText = '';
//     // Check if the text in the last line break contains any of out markers
//     for (var item in breaks) {
//       // Replace all line break to make sure only the symbol remains.
//       // Replacement is done so it can apply to if line break being applied to beginning of a text without line break
//       if (editableTextLastLineBreak
//           .replaceFirst('\n', '')
//           .startsWith(item.replaceFirst('\n', ''))) {
//         suffixText = item;
//       }
//     }
//
//     if (suffixText.isEmpty) {
//       // This means there is no custom line break
//       oldValue = currentText;
//       return textFieldModel.textEditingController.value;
//     }
//
//     editableText = editableText + suffixText;
//
//     // Get the text from the after the cursor to date
//     String postEditableText = currentText.substring(cursorIndexPreNewLine);
//
//     currentText = editableText + postEditableText;
//
//     // print('editableText: $editableText');
//     // print('postEditableText: $postEditableText');
//     // print('editableText lastIndexOf: ${editableText.lastIndexOf('\n')}');
//     // print(
//     //     'editableText indexOf: ${editableText.indexOf(' ', editableText.lastIndexOf('\n'))}');
//     // print(
//     //     'postEditableText lastIndexOf: ${postEditableText.lastIndexOf('\n')}');
//     oldValue = currentText;
//     return TextEditingValue(
//         text: currentText,
//         selection: selection.copyWith(
//             baseOffset: selection.baseOffset +
//                 (suffixText.replaceFirst('\n', '')).length,
//             extentOffset: selection.baseOffset +
//                 (suffixText.replaceFirst('\n', '')).length));
//   }
//
//   oldValue = currentText;
//   return textFieldModel.textEditingController.value;
// }
}
