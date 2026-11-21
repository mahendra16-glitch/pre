import 'package:flutter/material.dart';

class MenuModel {
  final String icon;
  final String title;
  final Color backgroundColor;
  final String route;
  final bool isBlocked;
  final bool isNotSubscribe;

  MenuModel({
    required this.icon,
    required this.title,
    required this.backgroundColor,
    required this.route,
    this.isBlocked = false,
    this.isNotSubscribe = false,
  });
}
