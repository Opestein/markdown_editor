import 'package:flutter/material.dart';

/// Undo and move forward
class EditPerform {
  EditPerform(
    this._textEditingController, {
    this.initText = '',
  });

  /// Maximum storage length
  final _maxLength = 50;

  /// Initial Text
  final String initText;

  var _undoList = <_EditData>[];
  var _redoList = <_EditData>[];

  final TextEditingController _textEditingController;

  void change(text) {
    if (_textEditingController.text != '') {
      if (_undoList.isNotEmpty) {
        if (_textEditingController.text == _undoList.last.text) return;
      }
      if (_undoList.length >= _maxLength) _undoList.removeAt(0);
      _undoList.add(_EditData(_textEditingController.text,
          _textEditingController.selection.baseOffset));
      _redoList.clear();
    }
  }

  /// Cancel
  void undo() {
//    print(_undoList);
    if (_undoList.isNotEmpty) {
      _redoList.add(_undoList.last);
      _undoList.removeLast();
      if (_undoList.isNotEmpty) {
        _textEditingController.value = TextEditingValue(
          text: _undoList.last.text,
          selection: TextSelection(
              extentOffset: _undoList.last.position,
              baseOffset: _undoList.last.position),
        );
      } else {
        _textEditingController.value = TextEditingValue(
          text: initText,
          selection: TextSelection(
              extentOffset: initText.length, baseOffset: initText.length),
        );
      }
    }
  }

  /// Recover
  void redo() {
//    print(_redoList);
    if (_redoList.isNotEmpty) {
      _textEditingController.value = TextEditingValue(
        text: _redoList.last.text,
        selection: TextSelection(
            extentOffset: _redoList.last.position,
            baseOffset: _redoList.last.position),
      );
      _undoList.add(_redoList.last);
      _redoList.removeLast();
    }
  }
}

class _EditData {
  final String text;
  final int position;

  _EditData(this.text, this.position);

  @override
  String toString() {
    return 'text:$text position:$position';
  }
}
