import 'package:flutter/cupertino.dart';

/// Переход между экранами как в iOS.
Route<T> applePageRoute<T>(Widget page) {
  return CupertinoPageRoute<T>(builder: (_) => page);
}
