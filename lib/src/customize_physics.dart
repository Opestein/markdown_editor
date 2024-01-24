import 'package:flutter/material.dart';

class CustomizePhysics extends ScrollPhysics {
  const CustomizePhysics({
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  CustomizePhysics applyTo(ScrollPhysics? ancestor) {
    return CustomizePhysics(parent: buildParent(ancestor));
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) => false;

  @override
  bool get allowImplicitScrolling => false;

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    return 0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    return null;
  }
}
//
// class TextFieldColorizer extends TextEditingController {
//   final Map<String, TextStyle> map;
//   final Pattern pattern;
//
//   TextFieldColorizer(this.map)
//       : pattern = RegExp(
//             map.keys.map((key) {
//               return key;
//             }).join('|'),
//             multiLine: true);
//
//   @override
//   set text(String newText) {
//     value = value.copyWith(
//       text: newText,
//       selection: TextSelection.collapsed(offset: newText.length),
//       composing: TextRange.empty,
//     );
//   }
//
//   @override
//   TextSpan buildTextSpan(
//       {required BuildContext context,
//       TextStyle? style,
//       required bool withComposing}) {
//     final List<InlineSpan> children = [];
//     String? patternMatched;
//     String? formatText;
//     TextStyle? myStyle;
//     text.splitMapJoin(
//       pattern,
//       onMatch: (Match match) {
//         myStyle = map[match[0]] ??
//             map[map.keys.firstWhere(
//               (e) {
//                 bool ret = false;
//                 RegExp(e).allMatches(text)
//                   ..forEach((element) {
//                     if (element.group(0) == match[0]) {
//                       patternMatched = e;
//                       ret = true;
//                       return;
//                     }
//                   });
//                 return ret;
//               },
//             )];
//
//         if (match.toString().isNotEmpty) {
//           if (patternMatched == r"_(.*?)\_") {
//             formatText = match[0]?.replaceAll("_", " ");
//           } else if (patternMatched == r'\*(.*?)\*') {
//             formatText = match[0]?.replaceAll("*", " ");
//           } else if (patternMatched == "~(.*?)~") {
//             formatText = match[0]?.replaceAll("~", " ");
//           } else if (patternMatched == r'```(.*?)```') {
//             formatText = match[0]?.replaceAll("```", "   ");
//           } else {
//             formatText = match[0];
//           }
//         }
//
//         children.add(TextSpan(
//           text: formatText,
//           style: style?.merge(myStyle),
//         ));
//         return "";
//       },
//       onNonMatch: (String text) {
//         children.add(TextSpan(text: text, style: style));
//         return "";
//       },
//     );
//
//     // return super.buildTextSpan(
//     //     context: context, style: style, withComposing: withComposing);
//     return TextSpan(style: style, children: children);
//   }
// }
