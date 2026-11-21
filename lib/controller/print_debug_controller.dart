import 'dart:math';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';

/// Central in-memory store for all print-pipeline debug logs.
///
/// Self-registers via [ensure] so no change to get_di.dart is needed.
/// Call [PrintDebugController.ensure()] once before using the logger
/// (the logger does this automatically on first call).
class PrintDebugController extends GetxController {
  // ─────────────────────────────────────────────
  //  Singleton access
  // ─────────────────────────────────────────────
  static PrintDebugController get instance {
    if (!Get.isRegistered<PrintDebugController>()) {
      Get.put(PrintDebugController(), permanent: true);
    }
    return Get.find<PrintDebugController>();
  }

  static void ensure() => instance;

  // ─────────────────────────────────────────────
  //  State
  // ─────────────────────────────────────────────
  static const int _maxLogs = 500;

  final List<PrintDebugLogEntry> _allLogs = [];

  // Live socket / queue / lock snapshot (updated by logger)
  bool socketConnected = false;
  bool isPrinterBusy = false;
  int orderQueueLen = 0;
  int socketQueueLen = 0;
  int activeJobCount = 0;

  // Filter state
  PrintFlowTag selectedFlow = PrintFlowTag.all;
  bool showOnlyErrors = false;
  bool showOnlyWarns = false;
  String searchQuery = '';

  // ─────────────────────────────────────────────
  //  Computed filtered list
  // ─────────────────────────────────────────────
  List<PrintDebugLogEntry> get filteredLogs {
    return _allLogs.reversed.where((log) {
      // Flow filter
      if (selectedFlow != PrintFlowTag.all && log.flow != selectedFlow) {
        return false;
      }
      // Error only
      if (showOnlyErrors && log.level != PrintLogLevel.error) return false;
      // Warn+Error
      if (showOnlyWarns &&
          log.level != PrintLogLevel.warn &&
          log.level != PrintLogLevel.error) return false;
      // Search
      if (searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final inTrace = log.traceId.toLowerCase().contains(q);
        final inOrder =
            (log.orderId ?? '').toLowerCase().contains(q);
        final inStation =
            (log.stationName ?? '').toLowerCase().contains(q);
        final inPrinter =
            (log.printerName ?? '').toLowerCase().contains(q);
        final inEvent = log.event.toLowerCase().contains(q);
        final inMsg = (log.message ?? '').toLowerCase().contains(q);
        if (!inTrace && !inOrder && !inStation && !inPrinter && !inEvent && !inMsg) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  // ─────────────────────────────────────────────
  //  Add log
  // ─────────────────────────────────────────────
  void addLog(PrintDebugLogEntry entry) {
    _allLogs.add(entry);
    // Trim oldest if over limit
    if (_allLogs.length > _maxLogs) {
      _allLogs.removeAt(0);
    }
    update();
  }

  // ─────────────────────────────────────────────
  //  Live snapshot update
  // ─────────────────────────────────────────────
  void updateSnapshot({
    bool? socketConnected,
    bool? isPrinterBusy,
    int? orderQueueLen,
    int? socketQueueLen,
    int? activeJobCount,
  }) {
    if (socketConnected != null) this.socketConnected = socketConnected;
    if (isPrinterBusy != null) this.isPrinterBusy = isPrinterBusy;
    if (orderQueueLen != null) this.orderQueueLen = orderQueueLen;
    if (socketQueueLen != null) this.socketQueueLen = socketQueueLen;
    if (activeJobCount != null) this.activeJobCount = activeJobCount;
    update();
  }

  // ─────────────────────────────────────────────
  //  Filter helpers
  // ─────────────────────────────────────────────
  void setFlowFilter(PrintFlowTag tag) {
    selectedFlow = tag;
    showOnlyErrors = false;
    showOnlyWarns = false;
    update();
  }

  void setErrorsOnly() {
    showOnlyErrors = true;
    showOnlyWarns = false;
    selectedFlow = PrintFlowTag.all;
    update();
  }

  void setWarnsOnly() {
    showOnlyWarns = true;
    showOnlyErrors = false;
    selectedFlow = PrintFlowTag.all;
    update();
  }

  void resetFilters() {
    selectedFlow = PrintFlowTag.all;
    showOnlyErrors = false;
    showOnlyWarns = false;
    searchQuery = '';
    update();
  }

  void setSearch(String q) {
    searchQuery = q;
    update();
  }

  // ─────────────────────────────────────────────
  //  Utility
  // ─────────────────────────────────────────────
  void clearAll() {
    _allLogs.clear();
    update();
  }

  int get totalCount => _allLogs.length;
  int get errorCount =>
      _allLogs.where((l) => l.level == PrintLogLevel.error).length;
  int get warnCount =>
      _allLogs.where((l) => l.level == PrintLogLevel.warn).length;

  // Build a full plain-text copy of all logs
  String buildExportText() {
    final buf = StringBuffer();
    buf.writeln('=== PRINT DEBUG LOG EXPORT ===');
    buf.writeln('Total: ${_allLogs.length} entries');
    buf.writeln('');
    for (final log in _allLogs.reversed) {
      buf.writeln(
          '[${log.timeLabel}] [${log.level.label.padRight(8)}] [${log.event.padRight(20)}] '
          'trace=${log.traceId}  ${log.summary}');
      log.flatDetails.forEach((k, v) => buf.writeln('     $k: $v'));
      buf.writeln('');
    }
    return buf.toString();
  }

  // ─────────────────────────────────────────────
  //  TraceId generation
  // ─────────────────────────────────────────────
  static String generateTraceId({bool isAggregator = false}) {
    final prefix = isAggregator ? 'AGG' : 'POS';
    final rand = Random().nextInt(99999).toString().padLeft(5, '0');
    return '$prefix-$rand';
  }

  static String generateLogId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
