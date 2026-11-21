import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  Log Level
// ─────────────────────────────────────────────
enum PrintLogLevel { info, success, warn, error, decision, socket, skip }

extension PrintLogLevelX on PrintLogLevel {
  String get label {
    switch (this) {
      case PrintLogLevel.info:
        return 'INFO';
      case PrintLogLevel.success:
        return 'SUCCESS';
      case PrintLogLevel.warn:
        return 'WARN';
      case PrintLogLevel.error:
        return 'ERROR';
      case PrintLogLevel.decision:
        return 'DECISION';
      case PrintLogLevel.socket:
        return 'SOCKET';
      case PrintLogLevel.skip:
        return 'SKIP';
    }
  }

  Color get color {
    switch (this) {
      case PrintLogLevel.info:
        return const Color(0xFF2196F3); // blue
      case PrintLogLevel.success:
        return const Color(0xFF4CAF50); // green
      case PrintLogLevel.warn:
        return const Color(0xFFFF9800); // orange
      case PrintLogLevel.error:
        return const Color(0xFFF44336); // red
      case PrintLogLevel.decision:
        return const Color(0xFF9C27B0); // purple
      case PrintLogLevel.socket:
        return const Color(0xFF00BCD4); // cyan
      case PrintLogLevel.skip:
        return const Color(0xFF9E9E9E); // grey
    }
  }

  Color get bgColor {
    switch (this) {
      case PrintLogLevel.info:
        return const Color(0xFFE3F2FD);
      case PrintLogLevel.success:
        return const Color(0xFFE8F5E9);
      case PrintLogLevel.warn:
        return const Color(0xFFFFF3E0);
      case PrintLogLevel.error:
        return const Color(0xFFFFEBEE);
      case PrintLogLevel.decision:
        return const Color(0xFFF3E5F5);
      case PrintLogLevel.socket:
        return const Color(0xFFE0F7FA);
      case PrintLogLevel.skip:
        return const Color(0xFFFAFAFA);
    }
  }

  IconData get icon {
    switch (this) {
      case PrintLogLevel.info:
        return Icons.info_outline_rounded;
      case PrintLogLevel.success:
        return Icons.check_circle_outline_rounded;
      case PrintLogLevel.warn:
        return Icons.warning_amber_rounded;
      case PrintLogLevel.error:
        return Icons.error_outline_rounded;
      case PrintLogLevel.decision:
        return Icons.account_tree_outlined;
      case PrintLogLevel.socket:
        return Icons.wifi_rounded;
      case PrintLogLevel.skip:
        return Icons.block_rounded;
    }
  }
}

// ─────────────────────────────────────────────
//  Print Flow Tag (for filtering)
// ─────────────────────────────────────────────
enum PrintFlowTag {
  aggregator,
  normalPos,
  fixedManual,
  waiter,
  bill,
  all,
}

extension PrintFlowTagX on PrintFlowTag {
  String get label {
    switch (this) {
      case PrintFlowTag.aggregator:
        return 'Aggregator';
      case PrintFlowTag.normalPos:
        return 'Normal POS';
      case PrintFlowTag.fixedManual:
        return 'Fixed Manual';
      case PrintFlowTag.waiter:
        return 'Waiter';
      case PrintFlowTag.bill:
        return 'Bill';
      case PrintFlowTag.all:
        return 'All';
    }
  }
}

// ─────────────────────────────────────────────
//  Print Event Constant Strings
// ─────────────────────────────────────────────
class PrintEvent {
  static const String socketRx = 'SOCKET_RX';
  static const String apiStart = 'API_START';
  static const String apiSuccess = 'API_SUCCESS';
  static const String apiFail = 'API_FAIL';
  static const String decision = 'DECISION';
  static const String buildPrintData = 'BUILD_PRINT_DATA';
  static const String queueIn = 'QUEUE_IN';
  static const String queueOut = 'QUEUE_OUT';
  static const String lockWait = 'LOCK_WAIT';
  static const String lockClaim = 'LOCK_CLAIM';
  static const String lockRelease = 'LOCK_RELEASE';
  static const String lockTimeout = 'LOCK_TIMEOUT';
  static const String printStart = 'PRINT_START';
  static const String stateReset = 'STATE_RESET';
  static const String stationSplit = 'STATION_SPLIT';
  static const String printerConnect = 'PRINTER_CONNECT';
  static const String printerSend = 'PRINTER_SEND';
  static const String printerDisconnect = 'PRINTER_DISCONNECT';
  static const String printerFail = 'PRINTER_FAIL';
  static const String printEnd = 'PRINT_END';
  static const String skip = 'SKIP';
  static const String error = 'ERROR';
  static const String stateCorrupt = 'STATE_CORRUPT';
}

// ─────────────────────────────────────────────
//  Core Log Entry Model
// ─────────────────────────────────────────────
class PrintDebugLogEntry {
  final String id;
  final String traceId;
  final DateTime timestamp;
  final PrintLogLevel level;
  final String event;
  final PrintFlowTag flow;
  final bool isAuto;
  final String? orderId;
  final String? printType;
  final String? message;
  final Map<String, dynamic> details;

  // Context fields (all optional)
  final String? socketType;
  final String? printingOption;
  final String? defaultUser;
  final String? empId;
  final String? waiterId;
  final String? isPrintKot;
  final String? printKot;
  final bool? aggregatorAutoKot;
  final bool? aggregatorAutoBill;
  final String? aggregatorAutoBillStage;
  final bool? aggregatorAutoKotIdContainsEmp;
  final bool? isAggregator;
  final bool? isManualBillPrint;
  final bool? isKOTFromFixedStation;
  final bool? isBillFromFixedStation;
  final bool? isPrinterBusy;
  final int? orderQueueLen;
  final int? socketQueueLen;
  final int? currentPrintIndex;
  final String? stationName;
  final String? printerName;
  final String? printerMode;
  final String? printerIp;
  final int? bytesLength;
  final int? copyCount;
  final String? platform;

  PrintDebugLogEntry({
    required this.id,
    required this.traceId,
    required this.timestamp,
    required this.level,
    required this.event,
    this.flow = PrintFlowTag.all,
    this.isAuto = true,
    this.orderId,
    this.printType,
    this.message,
    this.details = const {},
    this.socketType,
    this.printingOption,
    this.defaultUser,
    this.empId,
    this.waiterId,
    this.isPrintKot,
    this.printKot,
    this.aggregatorAutoKot,
    this.aggregatorAutoBill,
    this.aggregatorAutoBillStage,
    this.aggregatorAutoKotIdContainsEmp,
    this.isAggregator,
    this.isManualBillPrint,
    this.isKOTFromFixedStation,
    this.isBillFromFixedStation,
    this.isPrinterBusy,
    this.orderQueueLen,
    this.socketQueueLen,
    this.currentPrintIndex,
    this.stationName,
    this.printerName,
    this.printerMode,
    this.printerIp,
    this.bytesLength,
    this.copyCount,
    this.platform,
  });

  // Human-readable time string with ms
  String get timeLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    final s = timestamp.second.toString().padLeft(2, '0');
    final ms = timestamp.millisecond.toString().padLeft(3, '0');
    return '$h:$m:$s.$ms';
  }

  // Short summary line for collapsed view
  String get summary {
    if (message != null && message!.isNotEmpty) return message!;
    final parts = <String>[];
    if (orderId != null) parts.add('order=$orderId');
    if (stationName != null) parts.add('station=$stationName');
    if (printerName != null) parts.add('printer=$printerName');
    if (printType != null) parts.add('type=$printType');
    if (parts.isEmpty) {
      if (details.isNotEmpty) {
        return details.entries
            .take(3)
            .map((e) => '${e.key}=${e.value}')
            .join('  ');
      }
      return event;
    }
    return parts.join('  ');
  }

  // Build a flat display map for the detail view (all non-null fields)
  Map<String, String> get flatDetails {
    final map = <String, String>{};
    if (orderId != null) map['orderId'] = orderId!;
    if (traceId.isNotEmpty) map['traceId'] = traceId;
    if (flow != PrintFlowTag.all) map['flow'] = flow.label;
    map['auto'] = isAuto ? 'yes' : 'no';
    if (socketType != null) map['socketType'] = socketType!;
    if (printType != null) map['printType'] = printType!;
    if (printingOption != null) map['printingOption'] = printingOption!;
    if (defaultUser != null) map['defaultUser'] = defaultUser!;
    if (empId != null) map['empId'] = empId!;
    if (waiterId != null) map['waiterId'] = waiterId!;
    if (isPrintKot != null) map['isPrintKot'] = isPrintKot!;
    if (printKot != null) map['printKot'] = printKot!;
    if (aggregatorAutoKot != null)
      map['aggregatorAutoKot'] = aggregatorAutoKot! ? 'Yes' : 'No';
    if (aggregatorAutoBill != null)
      map['aggregatorAutoBill'] = aggregatorAutoBill! ? 'Yes' : 'No';
    if (aggregatorAutoBillStage != null)
      map['aggregatorAutoBillStage'] = aggregatorAutoBillStage!;
    if (aggregatorAutoKotIdContainsEmp != null)
      map['autoKotIdContainsEmp'] = aggregatorAutoKotIdContainsEmp! ? 'true' : 'false';
    if (isAggregator != null)
      map['isAggregator'] = isAggregator! ? 'true' : 'false';
    if (isManualBillPrint != null)
      map['isManualBillPrint'] = isManualBillPrint! ? 'true' : 'false';
    if (isKOTFromFixedStation != null)
      map['isKOTFromFixed'] = isKOTFromFixedStation! ? 'true' : 'false';
    if (isBillFromFixedStation != null)
      map['isBillFromFixed'] = isBillFromFixedStation! ? 'true' : 'false';
    if (isPrinterBusy != null)
      map['isPrinterBusy'] = isPrinterBusy! ? 'true' : 'false';
    if (orderQueueLen != null) map['orderQueueLen'] = '$orderQueueLen';
    if (socketQueueLen != null) map['socketQueueLen'] = '$socketQueueLen';
    if (currentPrintIndex != null)
      map['currentPrintIndex'] = '$currentPrintIndex';
    if (stationName != null) map['stationName'] = stationName!;
    if (printerName != null) map['printerName'] = printerName!;
    if (printerMode != null) map['printerMode'] = printerMode!;
    if (printerIp != null) map['printerIp'] = printerIp!;
    if (bytesLength != null) map['bytesLength'] = '$bytesLength';
    if (copyCount != null) map['copyCount'] = '$copyCount';
    if (platform != null) map['platform'] = platform!;
    // Merge extra details map
    details.forEach((k, v) => map[k] = '$v');
    return map;
  }
}
