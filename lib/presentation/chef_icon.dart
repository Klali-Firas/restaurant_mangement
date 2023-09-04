import 'package:flutter/widgets.dart';

//custom made Icons for the chef and the waiter

class CustomIcons {
  CustomIcons._();

  static const _kFontFam = 'Icon Font';
  static const String? _kFontPkg = null;

  static const IconData waiter =
      IconData(0xe800, fontFamily: _kFontFam, fontPackage: _kFontPkg);
  static const IconData chef =
      IconData(0xe801, fontFamily: _kFontFam, fontPackage: _kFontPkg);
}
