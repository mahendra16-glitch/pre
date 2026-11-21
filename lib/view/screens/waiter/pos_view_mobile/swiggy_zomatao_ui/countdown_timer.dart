import 'dart:async';
import 'package:mygenie_restaurant/controller/swiggy_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../util/styles.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int? prepTimeMins;
  final String? scheduleAt;
  final String? orderId;
  final String?
      readyAt; // Not used in this widget, but included for completeness
  final String? createdAt; // Format: "yyyy-MM-dd HH:mm:ss"

  const CountdownTimerWidget({
    Key? key,
    this.prepTimeMins,
    this.scheduleAt,
    this.orderId,
    this.readyAt,
    this.createdAt,
  }) : super(key: key);

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  DateTime? preparationTime;
  DateTime? deliveryTime;
  DateTime? createdAtTime;
  DateTime? readyAtTime;
  Timer? timer;
  Duration currentDurationPrep = Duration.zero;
  Duration currentDurationDel = Duration.zero;
  bool isCountingUp = false;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  @override
  void didUpdateWidget(covariant CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.prepTimeMins != widget.prepTimeMins ||
        oldWidget.scheduleAt != widget.scheduleAt ||
        oldWidget.readyAt != widget.readyAt ||
        oldWidget.createdAt != widget.createdAt) {
      _restartCountdown();
    }
  }

  void _restartCountdown() {
    timer?.cancel();
    _initializeCountdown();
  }

  void _initializeCountdown() {
    createdAtTime = DateTime.parse(widget.createdAt!);
    if (widget.scheduleAt != null)
      deliveryTime = DateTime.parse(widget.scheduleAt!);
    if (widget.readyAt != null) readyAtTime = DateTime.parse(widget.readyAt!);

    if (widget.readyAt != null)
      preparationTime =
          readyAtTime!.add(Duration(minutes: widget.prepTimeMins!));

    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (deliveryTime != null) {
        if (now.isBefore(deliveryTime!)) {
          currentDurationDel = deliveryTime!.difference(now);
          isCountingUp = false;
        } else {
          currentDurationDel = now.difference(deliveryTime!);
          isCountingUp = true;
        }
      }
      if (preparationTime != null && now.isBefore(preparationTime!)) {
        currentDurationPrep = preparationTime!.difference(now);
        isCountingUp = false;
      } else if (preparationTime != null) {
        currentDurationPrep = now.difference(preparationTime!);
        isCountingUp = true;
      }
      if (mounted) {
        setState(() {});
      }
      Get.find<SwiggyController>().update();
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      widget.scheduleAt != null && widget.scheduleAt!.isNotEmpty
          ? 'Rider reaching in : ${formatDuration(currentDurationDel)}'
          : 'Food ready in : ${formatDuration(currentDurationPrep)}',
      style: montserratMedium.copyWith(
        fontSize: 12,
        color: isCountingUp ? Colors.red : Colors.green,
      ),
    );
  }
}
