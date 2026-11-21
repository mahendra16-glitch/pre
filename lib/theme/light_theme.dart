import 'package:flutter/material.dart';

ThemeData light = ThemeData(
  primaryColor: Color(0xFFF26B33),
  secondaryHeaderColor: Color(0xFF000743),
  disabledColor: Color(0xFFA0A4A8),
  brightness: Brightness.light,
  hintColor: Color(0xFF9F9F9F),
  cardColor: Colors.white,
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: Color(0xFFF26B33))),
  colorScheme: ColorScheme.light(
          primary: Color(0xFFF26B33), secondary: Color(0xFFF26B33))
      .copyWith(error: Color(0xFFE84D4F)),
);
