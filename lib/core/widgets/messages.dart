import 'package:flutter/material.dart';

extension ScaffoldMessengerMessages on ScaffoldMessengerState {
  /// Shows [text] immediately, replacing any visible message instead of
  /// queueing behind it.
  void showMessage(String text) {
    hideCurrentSnackBar();
    showSnackBar(SnackBar(content: Text(text)));
  }
}
