import 'package:mygenie_restaurant/controller/print_debug_controller.dart';
import 'package:mygenie_restaurant/data/model/print_debug_log_model.dart';

/// ─────────────────────────────────────────────────────────────
/// PrintDebugLogger
///
/// Drop-in static logger for the print pipeline.
/// Call any method anywhere – no controller reference needed.
///
/// Example usage:
///   PrintDebugLogger.socketRx(
///     traceId: myTrace,
///     orderId: data[1].toString(),
///     socketType: data[0].toString(),
///     flow: PrintFlowTag.aggregator,
///     details: {'restaurantId': data[2]},
///   );
/// ─────────────────────────────────────────────────────────────
class PrintDebugLogger {
  PrintDebugLogger._();

  // ─────────────────────────────────────────────
  //  Internal write
  // ─────────────────────────────────────────────
  static void _write(PrintDebugLogEntry entry) {
    try {
      PrintDebugController.instance.addLog(entry);
    } catch (_) {
      // Never let logger crash the print flow
    }
  }

  // ─────────────────────────────────────────────
  //  Socket received
  // ─────────────────────────────────────────────
  static void socketRx({
    required String traceId,
    String? orderId,
    String? socketType,
    PrintFlowTag flow = PrintFlowTag.all,
    bool isAuto = true,
    String? empId,
    String? restaurantId,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.socket,
      event: PrintEvent.socketRx,
      flow: flow,
      isAuto: isAuto,
      orderId: orderId,
      socketType: socketType,
      empId: empId,
      message: '${flow.label} socket received: $socketType',
      details: {
        if (restaurantId != null) 'restaurantId': restaurantId,
        ...details,
      },
    ));
  }

  // ─────────────────────────────────────────────
  //  API calls
  // ─────────────────────────────────────────────
  static void apiStart({
    required String traceId,
    String? orderId,
    String? controller,
    String? apiName,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.apiStart,
      flow: flow,
      orderId: orderId,
      message: 'API call: $controller.$apiName',
      details: details,
    ));
  }

  static void apiSuccess({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    int? httpStatus,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.success,
      event: PrintEvent.apiSuccess,
      flow: flow,
      orderId: orderId,
      message: 'API success status=$httpStatus',
      details: details,
    ));
  }

  static void apiFail({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    int? httpStatus,
    String? reason,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.error,
      event: PrintEvent.apiFail,
      flow: flow,
      orderId: orderId,
      message: 'API FAILED status=$httpStatus reason=$reason',
      details: details,
    ));
  }

  // ─────────────────────────────────────────────
  //  Decision / conditions
  // ─────────────────────────────────────────────
  static void decision({
    required String traceId,
    String? orderId,
    required String result,
    required String reason,
    PrintFlowTag flow = PrintFlowTag.all,
    bool isAuto = true,
    String? printingOption,
    String? defaultUser,
    String? empId,
    String? waiterId,
    String? isPrintKot,
    String? printKot,
    bool? aggregatorAutoKot,
    bool? aggregatorAutoBill,
    String? aggregatorAutoBillStage,
    bool? aggregatorAutoKotIdContainsEmp,
    bool? isAggregator,
    bool? isManualBillPrint,
    bool? isKOTFromFixedStation,
    bool? isBillFromFixedStation,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.decision,
      event: PrintEvent.decision,
      flow: flow,
      isAuto: isAuto,
      orderId: orderId,
      message: 'Decision → $result | $reason',
      printingOption: printingOption,
      defaultUser: defaultUser,
      empId: empId,
      waiterId: waiterId,
      isPrintKot: isPrintKot,
      printKot: printKot,
      aggregatorAutoKot: aggregatorAutoKot,
      aggregatorAutoBill: aggregatorAutoBill,
      aggregatorAutoBillStage: aggregatorAutoBillStage,
      aggregatorAutoKotIdContainsEmp: aggregatorAutoKotIdContainsEmp,
      isAggregator: isAggregator,
      isManualBillPrint: isManualBillPrint,
      isKOTFromFixedStation: isKOTFromFixedStation,
      isBillFromFixedStation: isBillFromFixedStation,
      details: {
        'result': result,
        'reason': reason,
        ...details,
      },
    ));
  }

  // ─────────────────────────────────────────────
  //  Queue operations
  // ─────────────────────────────────────────────
  static void queueIn({
    required String traceId,
    String? orderId,
    required String queueName,
    required String jobType,
    required int queueLen,
    PrintFlowTag flow = PrintFlowTag.all,
    bool isAuto = true,
    bool? isPrinterBusy,
    Map<String, dynamic> details = const {},
  }) {
    final ctrl = PrintDebugController.instance;
    ctrl.updateSnapshot(orderQueueLen: queueLen, isPrinterBusy: isPrinterBusy);
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.queueIn,
      flow: flow,
      isAuto: isAuto,
      orderId: orderId,
      isPrinterBusy: isPrinterBusy,
      message: '→ $queueName  jobType=$jobType  queueLen=$queueLen',
      details: {
        'queue': queueName,
        'jobType': jobType,
        'queueLen': queueLen,
        ...details,
      },
    ));
  }

  static void queueOut({
    required String traceId,
    String? orderId,
    required int queueLen,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.queueOut,
      flow: flow,
      orderId: orderId,
      message: '← dequeued  remaining=$queueLen',
      details: {'remainingQueue': queueLen, ...details},
    ));
  }

  // ─────────────────────────────────────────────
  //  Lock operations
  // ─────────────────────────────────────────────
  static void lockWait({
    required String traceId,
    String? orderId,
    required int waitCycle,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.warn,
      event: PrintEvent.lockWait,
      flow: flow,
      orderId: orderId,
      isPrinterBusy: true,
      message: 'Printer busy – waiting (cycle $waitCycle)',
      details: {'waitCycle': waitCycle, ...details},
    ));
  }

  static void lockClaim({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    PrintDebugController.instance.updateSnapshot(isPrinterBusy: true);
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.lockClaim,
      flow: flow,
      orderId: orderId,
      isPrinterBusy: true,
      message: 'Lock CLAIMED – printer busy = true',
      details: details,
    ));
  }

  static void lockRelease({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    String? source,
    String? note,
    Map<String, dynamic> details = const {},
  }) {
    PrintDebugController.instance.updateSnapshot(isPrinterBusy: false);
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.lockRelease,
      flow: flow,
      orderId: orderId,
      isPrinterBusy: false,
      message:
          'Lock RELEASED${source != null ? ' source=$source' : ''}${note != null ? ' ⚠ $note' : ''}',
      details: {
        if (source != null) 'source': source,
        if (note != null) 'note': note,
        ...details,
      },
    ));
  }

  static void lockTimeout({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.warn,
      event: PrintEvent.lockTimeout,
      flow: flow,
      orderId: orderId,
      message: '⚠ Lock TIMEOUT – force-cleared isPrinterBusy',
      details: details,
    ));
  }

  // ─────────────────────────────────────────────
  //  Print lifecycle
  // ─────────────────────────────────────────────
  static void printStart({
    required String traceId,
    String? orderId,
    String? printType,
    required int currentPrintIndex,
    String? stationName,
    String? printerName,
    String? printerMode,
    String? printerIp,
    int? copyCount,
    String? platform,
    PrintFlowTag flow = PrintFlowTag.all,
    bool isAuto = true,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.printStart,
      flow: flow,
      isAuto: isAuto,
      orderId: orderId,
      printType: printType,
      currentPrintIndex: currentPrintIndex,
      stationName: stationName,
      printerName: printerName,
      printerMode: printerMode,
      printerIp: printerIp,
      copyCount: copyCount,
      platform: platform,
      message:
          'Print START [$printType] index=$currentPrintIndex station=$stationName printer=$printerName',
      details: details,
    ));
  }

  static void stateReset({
    required String traceId,
    PrintFlowTag flow = PrintFlowTag.all,
    String? note,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.warn,
      event: PrintEvent.stateReset,
      flow: flow,
      message: '⚠ Shared state RESET${note != null ? ': $note' : ''}',
      details: details,
    ));
  }

  static void stationSplit({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    required int printerCount,
    required int totalItems,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: PrintEvent.stationSplit,
      flow: flow,
      orderId: orderId,
      message:
          'Station split: $totalItems items → $printerCount printers',
      details: {
        'printerCount': printerCount,
        'totalItems': totalItems,
        ...details,
      },
    ));
  }

  static void printerConnect({
    required String traceId,
    String? orderId,
    required bool success,
    String? printerMode,
    String? printerIp,
    String? printerName,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: success ? PrintLogLevel.success : PrintLogLevel.error,
      event: PrintEvent.printerConnect,
      flow: flow,
      orderId: orderId,
      printerMode: printerMode,
      printerIp: printerIp,
      printerName: printerName,
      message:
          'Printer CONNECT ${success ? '✓' : '✗'} mode=$printerMode ip=$printerIp',
      details: {'success': success, ...details},
    ));
  }

  static void printerSend({
    required String traceId,
    String? orderId,
    required bool success,
    int? bytesLength,
    String? printerMode,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: success ? PrintLogLevel.success : PrintLogLevel.error,
      event: PrintEvent.printerSend,
      flow: flow,
      orderId: orderId,
      bytesLength: bytesLength,
      printerMode: printerMode,
      message:
          'Printer SEND ${success ? '✓' : '✗'} bytes=${bytesLength ?? '?'}',
      details: {'success': success, ...details},
    ));
  }

  static void printerDisconnect({
    required String traceId,
    PrintFlowTag flow = PrintFlowTag.all,
    bool success = true,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: success ? PrintLogLevel.info : PrintLogLevel.warn,
      event: PrintEvent.printerDisconnect,
      flow: flow,
      message: 'Printer DISCONNECT ${success ? '✓' : '(failed)'}',
      details: details,
    ));
  }

  static void printEnd({
    required String traceId,
    String? orderId,
    PrintFlowTag flow = PrintFlowTag.all,
    int? nextIndex,
    int? remainingStations,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.success,
      event: PrintEvent.printEnd,
      flow: flow,
      orderId: orderId,
      currentPrintIndex: nextIndex,
      message:
          'Print END  nextIndex=$nextIndex remainingStations=$remainingStations',
      details: {
        if (nextIndex != null) 'nextIndex': nextIndex,
        if (remainingStations != null) 'remainingStations': remainingStations,
        ...details,
      },
    ));
  }

  // ─────────────────────────────────────────────
  //  Skip / Error / State Corrupt
  // ─────────────────────────────────────────────
  static void skip({
    required String traceId,
    String? orderId,
    required String reason,
    PrintFlowTag flow = PrintFlowTag.all,
    bool isAuto = true,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.skip,
      event: PrintEvent.skip,
      flow: flow,
      isAuto: isAuto,
      orderId: orderId,
      message: 'SKIPPED: $reason',
      details: details,
    ));
  }

  static void error({
    required String traceId,
    String? orderId,
    required String message,
    PrintFlowTag flow = PrintFlowTag.all,
    Object? exception,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.error,
      event: PrintEvent.error,
      flow: flow,
      orderId: orderId,
      message: 'ERROR: $message',
      details: {
        if (exception != null) 'exception': exception.toString(),
        ...details,
      },
    ));
  }

  static void stateCorrupt({
    required String traceId,
    String? orderId,
    required String message,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.error,
      event: PrintEvent.stateCorrupt,
      flow: flow,
      orderId: orderId,
      message: '🔴 STATE CORRUPT: $message',
      details: details,
    ));
  }

  // ─────────────────────────────────────────────
  //  General info / warn
  // ─────────────────────────────────────────────
  static void info({
    required String traceId,
    String? orderId,
    required String message,
    required String event,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.info,
      event: event,
      flow: flow,
      orderId: orderId,
      message: message,
      details: details,
    ));
  }

  static void warn({
    required String traceId,
    String? orderId,
    required String message,
    required String event,
    PrintFlowTag flow = PrintFlowTag.all,
    Map<String, dynamic> details = const {},
  }) {
    _write(PrintDebugLogEntry(
      id: PrintDebugController.generateLogId(),
      traceId: traceId,
      timestamp: DateTime.now(),
      level: PrintLogLevel.warn,
      event: event,
      flow: flow,
      orderId: orderId,
      message: message,
      details: details,
    ));
  }
}
