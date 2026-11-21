import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mygenie_restaurant/controller/report_summary_controller.dart';
import 'package:mygenie_restaurant/helper/colors.dart';

class RevenueTrendChart extends StatefulWidget {
  final ReportSummeryController controller;

  const RevenueTrendChart({super.key, required this.controller});

  @override
  State<RevenueTrendChart> createState() => _RevenueTrendChartState();
}

class _RevenueTrendChartState extends State<RevenueTrendChart> {
  static const double _leftAxis = 40;
  static const double _rightAxis = 44;
  static const double _bottomAxis = 32;
  static const Color _barTop = Color(0xFF5B9BFF);
  static const Color _barBottom = Color(0xFFD6E6FF);
  static const Color _line = Color(0xFFF28C28);

  final GlobalKey _chartKey = GlobalKey();
  OverlayEntry? _tip;
  Worker? _pointsWorker;

  @override
  void initState() {
    super.initState();
    _pointsWorker = ever(widget.controller.insightsDailyPoints, (_) {
      _removeTip();
    });
  }

  @override
  void dispose() {
    _pointsWorker?.dispose();
    _removeTip();
    super.dispose();
  }

  void _removeTip() {
    _tip?.remove();
    _tip = null;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.controller.isLoadingInsightsSales.value) {
        return const Center(child: CircularProgressIndicator());
      }
      final List<InsightsSalesPoint> points =
          widget.controller.insightsDailyPoints.toList();
      if (points.isEmpty) {
        return const SizedBox.shrink();
      }
      return LayoutBuilder(
        builder: (context, constraints) {
          final double plotWidth = math.max(
            1,
            constraints.maxWidth - _leftAxis - _rightAxis,
          );
          final double slot = plotWidth / points.length;
          final double barWidth = math.max(2, math.min(36, slot * 0.55));
          final double maxRevenue = points
              .map((point) => point.revenue)
              .reduce((a, b) => a > b ? a : b);
          final double maxCumulative = points.last.cumulative;
          final double barStep = _axisStep(maxRevenue);
          final double lineStep = _axisStep(maxCumulative);
          final double barMax =
              maxRevenue <= 0 ? barStep : (maxRevenue / barStep).ceil() * barStep;
          final double lineMax = maxCumulative <= 0
              ? lineStep
              : (maxCumulative / lineStep).ceil() * lineStep;

          return SizedBox.expand(
            child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTapUp: (details) => _handleTap(details, points),
            child: Stack(
              key: _chartKey,
              children: [
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    minY: 0,
                    maxY: barMax,
                    barTouchData: BarTouchData(enabled: false),
                    borderData: FlBorderData(show: false),
                    backgroundColor: Colors.transparent,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: barStep,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: const Color(0xFFE6E6E6),
                        strokeWidth: 1,
                        dashArray: [4, 4],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _rightAxis,
                          getTitlesWidget: (value, meta) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _leftAxis,
                          interval: barStep,
                          getTitlesWidget: (value, meta) =>
                              _axisLabel(value, barMax),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: _bottomAxis,
                          interval: 1,
                          getTitlesWidget: (value, meta) =>
                              _bottomLabel(value, points),
                        ),
                      ),
                    ),
                    barGroups: List.generate(points.length, (index) {
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: points[index].revenue,
                            width: barWidth,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(3),
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [_barTop, _barBottom],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                IgnorePointer(
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: points.length.toDouble(),
                      minY: 0,
                      maxY: lineMax,
                      backgroundColor: Colors.transparent,
                      lineTouchData: const LineTouchData(enabled: false),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _leftAxis,
                            getTitlesWidget: (value, meta) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _bottomAxis,
                            getTitlesWidget: (value, meta) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: _rightAxis,
                            getTitlesWidget: (value, meta) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: List.generate(points.length, (index) {
                            return FlSpot(
                              index + 0.5,
                              points[index].cumulative,
                            );
                          }),
                          isCurved: false,
                          color: _line,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) {
                              return FlDotCirclePainter(
                                radius: 3.5,
                                color: _line,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _line.withOpacity(0.28),
                                _line.withOpacity(0.02),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      );
    });
  }

  void _handleTap(TapUpDetails details, List<InsightsSalesPoint> points) {
    final RenderBox? box =
        _chartKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || points.isEmpty) return;
    final Offset local = box.globalToLocal(details.globalPosition);
    final double plotRight = box.size.width - _rightAxis;
    if (local.dx < _leftAxis || local.dx > plotRight) return;
    if (local.dy > box.size.height - _bottomAxis) return;
    final double plotWidth = plotRight - _leftAxis;
    final int index =
        ((local.dx - _leftAxis) / plotWidth * points.length).floor().clamp(
              0,
              points.length - 1,
            );
    _showTip(details.globalPosition, points[index]);
  }

  void _showTip(Offset global, InsightsSalesPoint point) {
    _removeTip();
    final List<String> parts = point.date.split('-');
    final DateTime when = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final String day = DateFormat('EEE').format(when);
    final double average =
        point.orders == 0 ? 0 : point.revenue / point.orders;
    _tip = OverlayEntry(
      builder: (context) {
        final Size size = MediaQuery.of(context).size;
        const double width = 190;
        double left = global.dx - width / 2;
        double top = global.dy - 88;
        if (left < 8) left = 8;
        if (left + width > size.width - 8) left = size.width - width - 8;
        if (top < 8) top = global.dy + 16;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeTip,
              ),
            ),
            Positioned(
              left: left,
              top: top,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: width,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${point.date} ($day)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: '● ',
                                style: TextStyle(color: _barTop),
                              ),
                              TextSpan(
                                text:
                                    'Revenue: ₹${point.revenue.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${point.orders} orders · Avg ₹${average.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    Overlay.of(context).insert(_tip!);
  }

  Widget _axisLabel(double value, double maxY) {
    if (value < -0.001 || value > maxY + 0.001) {
      return const SizedBox.shrink();
    }
    return Text(
      _compact(value),
      style: const TextStyle(
        color: ColorTheme.greyColor,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _bottomLabel(double value, List<InsightsSalesPoint> points) {
    final int index = value.round();
    if ((value - index).abs() > 0.01 ||
        index < 0 ||
        index >= points.length) {
      return const SizedBox.shrink();
    }
    final bool show = points.length == 1 ||
        points.length <= 7 ||
        index == 0 ||
        index == 7 ||
        index == 14 ||
        index == 21 ||
        index == points.length - 1;
    if (!show) return const SizedBox.shrink();
    final String date = points[index].date;
    final String label = date.length >= 10 ? date.substring(5) : date;
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        label,
        style: const TextStyle(
          color: ColorTheme.greyColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  double _axisStep(double maxValue) {
    if (maxValue <= 0) return 1;
    final double rough = maxValue / 4;
    final int exponent = (math.log(rough) / math.ln10).floor();
    final double magnitude = math.pow(10, exponent).toDouble();
    for (final double multiplier in [1, 2, 2.5, 5, 10]) {
      final double step = multiplier * magnitude;
      if (maxValue / step <= 4) return step;
    }
    return magnitude * 10;
  }

  String _compact(double value) {
    if (value.abs() >= 1000) {
      final double thousands = value / 1000;
      final String text = thousands == thousands.roundToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${text}k';
    }
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(1);
  }
}
