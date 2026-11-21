import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

Future<DateTime?> pickedDate(String? currentDate,
    {DateTime? minDate, DateTime? maxDate}) async {
  DateTime selectedDate = DateTime.now();
  if (currentDate != null) {
    DateFormat format = DateFormat("dd-MM-yyyy");
    DateTime parsedDate = format.parse(currentDate ?? "");
    selectedDate = parsedDate;
  }

  final DateTime? picked = await showDatePicker(
    context: Get.key.currentContext!,
    initialDate: selectedDate,
    firstDate: DateTime(2000),
    lastDate: maxDate ?? DateTime.now(),
  );

  if (picked != null) {
    log('picked date :$picked');
    return picked;
  } else {
    log('No Pick Date');
    return null;
  }
}
