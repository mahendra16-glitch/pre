import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_address.dart';

/// Log hook so this file has no app dependencies and can be tested on its
/// own. [IosPrintTransport] forwards it to the app's PrintDebugLogger.
/// event: CONNECT, SEND, DISCONNECT, INFO.
typedef WifiPrinterLogHook = void Function(String traceId, String event,
    bool success, String message, Map<String, dynamic> details);

enum WifiPrintErrorCode {
  invalidAddress,

  /// Host unreachable. On iOS this is also what a denied
  /// Local Network permission looks like, so both are reported together.
  unreachableOrPermissionDenied,
  connectionRefused,
  timeout,
  printerBusy,

  /// Some bytes may already have reached the printer. Never resend
  /// automatically.
  sendFailed,
  closed,
}

class WifiPrintException implements Exception {
  final WifiPrintErrorCode code;
  final String message;
  final bool mayHavePrinted;
  final Object? cause;

  WifiPrintException(this.code, this.message,
      {this.mayHavePrinted = false, this.cause});

  @override
  String toString() => 'WifiPrintException($code): $message'
      '${cause != null ? ' [$cause]' : ''}';
}

enum WifiJobStatus { connecting, connected, sending, completed, failed }

/// One TCP connection to one network printer.
///
/// While a session is open it holds that printer's lock, so two jobs never
/// interleave on the same printer. Different printers have independent
/// sessions and can print at the same time.
class WifiPrinterSession {
  final NetworkPrinterTarget target;
  final WifiPrinterService _service;
  final String traceId;

  Socket? _socket;
  StreamSubscription<List<int>>? _readSub;
  bool _remoteClosed = false;
  bool _closed = false;
  bool _writing = false;
  int _bytesSent = 0;
  Timer? _idleTimer;
  WifiJobStatus status = WifiJobStatus.connecting;

  WifiPrinterSession._(this.target, this._service, this.traceId);

  bool get isOpen => !_closed && !_remoteClosed && _socket != null;
  bool get isWriting => _writing;
  int get bytesSent => _bytesSent;

  Map<String, dynamic> get _ids =>
      {'printer': target.key, 'label': target.label};

  Future<void> _connect() async {
    final socket = await _service._connectWithRetry(target, traceId);
    _attach(socket);
  }

  void _attach(Socket socket) {
    _socket = socket;
    _remoteClosed = false;
    try {
      socket.setOption(SocketOption.tcpNoDelay, true);
    } catch (_) {}
    // Drain anything the printer sends back (status bytes) and notice a
    // closed connection early.
    _readSub = socket.listen(
      (_) {},
      onError: (Object e) => _remoteClosed = true,
      onDone: () => _remoteClosed = true,
      cancelOnError: true,
    );
    status = WifiJobStatus.connected;
    _touch();
  }

  void _touch() {
    _idleTimer?.cancel();
    // If the calling code never disconnects, free the printer anyway.
    _idleTimer = Timer(WifiPrinterService.idleSessionTimeout, () {
      if (!_writing) {
        _log('Idle Wi-Fi printer session closed automatically');
        close();
      }
    });
  }

  /// Sends [bytes] to the printer.
  ///
  /// If the connection dropped before any byte of this session was sent
  /// (for example the app went to background between connect and write),
  /// it reconnects once, which is safe. If bytes were already sent, it does
  /// not reconnect and throws with `mayHavePrinted = true`, so nothing is
  /// printed twice.
  Future<void> write(List<int> bytes) async {
    if (_closed) {
      throw WifiPrintException(WifiPrintErrorCode.closed,
          'Printer connection already closed (${target.key})');
    }
    if (bytes.isEmpty) return;

    if (!isOpen) {
      if (_bytesSent == 0) {
        _log('Connection dropped before sending, reconnecting once');
        await _readSub?.cancel();
        _socket?.destroy();
        _socket = null;
        await _connect();
      } else {
        throw WifiPrintException(
          WifiPrintErrorCode.sendFailed,
          'Printer connection lost during printing (${target.label} '
          '${target.key}). Check the printout before printing again.',
          mayHavePrinted: true,
        );
      }
    }

    _writing = true;
    status = WifiJobStatus.sending;
    _idleTimer?.cancel();
    final int sentBefore = _bytesSent;
    try {
      for (int i = 0; i < bytes.length; i += WifiPrinterService.chunkSize) {
        final end = (i + WifiPrinterService.chunkSize < bytes.length)
            ? i + WifiPrinterService.chunkSize
            : bytes.length;
        if (_remoteClosed) {
          throw const SocketException('Printer closed the connection');
        }
        _socket!.add(bytes.sublist(i, end));
        await _socket!.flush().timeout(WifiPrinterService.writeTimeout);
        _bytesSent += end - i;
      }
      WifiPrinterService._emit(traceId, 'SEND', true,
          'Sent ${bytes.length} bytes', {..._ids, 'bytes': bytes.length});
    } catch (e) {
      status = WifiJobStatus.failed;
      final partial = _bytesSent > 0;
      WifiPrinterService._emit(traceId, 'SEND', false, 'Send failed: $e', {
        ..._ids,
        'bytes': bytes.length,
        'bytesSentBeforeError': _bytesSent,
        'bytesSentThisWrite': _bytesSent - sentBefore,
      });
      await close();
      throw WifiPrintException(
        WifiPrintErrorCode.sendFailed,
        'Could not finish sending to ${target.label} (${target.key}).'
        '${partial ? ' Part of the job may have printed; check before reprinting.' : ''}',
        mayHavePrinted: partial,
        cause: e,
      );
    } finally {
      _writing = false;
      if (!_closed) _touch();
    }
  }

  /// Flushes and closes the socket, then releases the printer lock.
  /// Safe to call more than once.
  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    _idleTimer?.cancel();
    final socket = _socket;
    _socket = null;
    try {
      if (socket != null) {
        await socket.flush().timeout(const Duration(seconds: 3));
        await socket.close().timeout(const Duration(seconds: 3));
      }
    } catch (_) {
      // Ignore: printer may already have closed its side.
    } finally {
      try {
        socket?.destroy();
      } catch (_) {}
      await _readSub?.cancel();
      _readSub = null;
      if (status != WifiJobStatus.failed && _bytesSent > 0) {
        status = WifiJobStatus.completed;
      }
      WifiPrinterService._emit(traceId, 'DISCONNECT', true, 'Closed',
          {..._ids, 'bytesSent': _bytesSent, 'status': status.name});
      _service._onSessionClosed(this);
    }
  }

  void _log(String msg) {
    dev.log('[WifiPrinter] $msg (${target.key})');
    WifiPrinterService._emit(traceId, 'INFO', true, msg, _ids);
  }
}

/// Simple FIFO mutex.
class _PrinterLock {
  Completer<void>? _held;

  bool get isLocked => _held != null;

  Future<void> acquire(Duration timeout) async {
    final deadline = DateTime.now().add(timeout);
    while (_held != null) {
      final remaining = deadline.difference(DateTime.now());
      if (remaining.isNegative) throw TimeoutException('printer busy');
      try {
        await _held!.future.timeout(remaining);
      } on TimeoutException {
        throw TimeoutException('printer busy');
      }
    }
    _held = Completer<void>();
  }

  void release() {
    final c = _held;
    _held = null;
    if (c != null && !c.isCompleted) c.complete();
  }
}

/// Raw TCP (port 9100) ESC/POS printing for Wi-Fi and Ethernet printers on
/// iOS and iPadOS.
///
/// Uses dart:io sockets, which run on Apple's BSD socket layer (no extra
/// native code needed). The first connection to a local address makes iOS
/// show the Local Network prompt (text from `NSLocalNetworkUsageDescription`
/// in Info.plist).
class WifiPrinterService with WidgetsBindingObserver {
  WifiPrinterService._();
  static final WifiPrinterService instance = WifiPrinterService._();

  static const Duration connectTimeout = Duration(seconds: 5);
  static const Duration writeTimeout = Duration(seconds: 15);
  static const Duration lockTimeout = Duration(seconds: 90);
  static const Duration idleSessionTimeout = Duration(seconds: 60);
  static const int connectAttempts = 2;
  static const int chunkSize = 4096;

  /// Set by the app to receive connection / send diagnostics.
  static WifiPrinterLogHook? onLog;

  static void _emit(String traceId, String event, bool success, String message,
      Map<String, dynamic> details) {
    try {
      onLog?.call(traceId, event, success, message, details);
    } catch (_) {
      // Logging must never break printing.
    }
  }

  final Map<String, _PrinterLock> _locks = {};
  final Set<WifiPrinterSession> _sessions = {};
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _initialized = false;
  int _traceCounter = 0;

  /// Registers the lifecycle and network-change listeners. Called
  /// automatically the first time a Wi-Fi printer is used.
  void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    try {
      WidgetsBinding.instance.addObserver(this);
    } catch (_) {}
    try {
      _connectivitySub = Connectivity()
          .onConnectivityChanged
          .listen(_onConnectivityChanged, onError: (_) {});
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // iOS suspends the app soon after it goes to background. Close sockets
    // that are not sending, so no half-open connection is left behind. A
    // job that is already sending is left alone to finish while iOS allows.
    // Unrestricted background printing is not possible on iOS.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _closeIdleSessions('app moved to background');
    }
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    // On a network switch, existing sockets point at the old network.
    _closeIdleSessions(
        'network changed: ${results.map((e) => e.name).join(',')}');
  }

  void _closeIdleSessions(String reason) {
    for (final s in _sessions.toList()) {
      // Sessions that have not sent anything yet are kept: their next
      // write reconnects safely if the socket died.
      if (!s.isWriting && s.bytesSent > 0) {
        s._log('Closing Wi-Fi printer session: $reason');
        s.close();
      }
    }
  }

  String _newTraceId() =>
      'wifi-${DateTime.now().millisecondsSinceEpoch}-${_traceCounter++}';

  /// Opens a session to [target], waiting if another job is printing on the
  /// same printer. Call [WifiPrinterSession.close] when done.
  Future<WifiPrinterSession> openSession(NetworkPrinterTarget target) async {
    ensureInitialized();
    final traceId = _newTraceId();
    final lock = _locks.putIfAbsent(target.key, () => _PrinterLock());
    if (lock.isLocked) {
      _emit(traceId, 'INFO', true, 'Waiting for previous job on ${target.key}',
          {'printer': target.key});
    }
    try {
      await lock.acquire(lockTimeout);
    } on TimeoutException {
      throw WifiPrintException(WifiPrintErrorCode.printerBusy,
          '${target.label} (${target.key}) is busy with another print job');
    }
    final session = WifiPrinterSession._(target, this, traceId);
    _sessions.add(session);
    try {
      await session._connect();
      return session;
    } catch (e) {
      _sessions.remove(session);
      session._closed = true;
      lock.release();
      rethrow;
    }
  }

  void _onSessionClosed(WifiPrinterSession session) {
    if (_sessions.remove(session)) {
      _locks[session.target.key]?.release();
    }
  }

  Future<Socket> _connectWithRetry(
      NetworkPrinterTarget target, String traceId) async {
    if (!NetworkPrinterTarget.isValidHost(target.host) ||
        !NetworkPrinterTarget.isValidPort(target.port)) {
      throw WifiPrintException(WifiPrintErrorCode.invalidAddress,
          'Invalid printer address ${target.key}');
    }
    final ids = {'printer': target.key, 'label': target.label};
    WifiPrintException? last;
    // Retrying the connect step is safe: nothing has been sent yet.
    for (int attempt = 1; attempt <= connectAttempts; attempt++) {
      try {
        final socket = await Socket.connect(target.host, target.port,
            timeout: connectTimeout);
        _emit(traceId, 'CONNECT', true, 'Connected',
            {...ids, 'attempt': attempt});
        return socket;
      } catch (e) {
        last = _mapConnectError(target, e);
        _emit(traceId, 'CONNECT', false, last.message,
            {...ids, 'attempt': attempt, 'error': e.toString()});
        // Do not retry when the outcome will not change.
        if (last.code == WifiPrintErrorCode.invalidAddress ||
            last.code == WifiPrintErrorCode.unreachableOrPermissionDenied) {
          break;
        }
        if (attempt < connectAttempts) {
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }
    }
    throw last!;
  }

  WifiPrintException _mapConnectError(NetworkPrinterTarget t, Object e) {
    if (e is SocketException) {
      final code = e.osError?.errorCode;
      final msg = (e.osError?.message ?? e.message).toLowerCase();
      // Darwin errno: 61 ECONNREFUSED, 60 ETIMEDOUT, 65 EHOSTUNREACH,
      // 51 ENETUNREACH, 1 EPERM (blocked by policy).
      if (code == 61 || msg.contains('refused')) {
        return WifiPrintException(
            WifiPrintErrorCode.connectionRefused,
            '${t.label} (${t.key}) refused the connection. Check the port '
            '(usually 9100) and that no other device is holding the printer.',
            cause: e);
      }
      if (code == 65 ||
          code == 51 ||
          code == 1 ||
          msg.contains('no route') ||
          msg.contains('unreachable') ||
          msg.contains('not permitted')) {
        return WifiPrintException(
            WifiPrintErrorCode.unreachableOrPermissionDenied,
            '${t.label} (${t.key}) is not reachable. Check that this device '
            'and the printer are on the same network, and that Local Network '
            'access is on in Settings > Privacy & Security > Local Network.',
            cause: e);
      }
      if (code == 60 || msg.contains('timed out')) {
        return WifiPrintException(WifiPrintErrorCode.timeout,
            '${t.label} (${t.key}) did not answer in time.',
            cause: e);
      }
    }
    if (e is TimeoutException) {
      return WifiPrintException(WifiPrintErrorCode.timeout,
          '${t.label} (${t.key}) did not answer in time.',
          cause: e);
    }
    return WifiPrintException(WifiPrintErrorCode.unreachableOrPermissionDenied,
        'Could not connect to ${t.label} (${t.key}).',
        cause: e);
  }

  /// One-shot print: connect, send [bytes] [copies] times, close.
  /// Use this for independent printers in parallel.
  Future<void> printBytes(
    NetworkPrinterTarget target,
    List<int> bytes, {
    int copies = 1,
    Duration gapBetweenCopies = const Duration(milliseconds: 800),
  }) async {
    final session = await openSession(target);
    try {
      for (int i = 0; i < copies; i++) {
        if (i > 0) await Future.delayed(gapBetweenCopies);
        await session.write(bytes);
      }
    } finally {
      await session.close();
    }
  }

  /// Checks that the printer accepts a TCP connection. Prints nothing.
  Future<bool> testConnection(NetworkPrinterTarget target) async {
    try {
      final session = await openSession(target);
      await session.close();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Closes every session (for logout or tests).
  Future<void> closeAll() async {
    for (final s in _sessions.toList()) {
      await s.close();
    }
  }

  @visibleForTesting
  Future<void> disposeForTest() async {
    await closeAll();
    await _connectivitySub?.cancel();
    _connectivitySub = null;
    try {
      WidgetsBinding.instance.removeObserver(this);
    } catch (_) {}
    _initialized = false;
  }
}
