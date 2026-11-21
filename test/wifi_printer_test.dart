import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/network_printer_address.dart';
import 'package:mygenie_restaurant/helper/wifi_printer/wifi_printer_service.dart';

/// Fake ESC/POS printer: a local TCP server that records what it receives.
class FakePrinter {
  late ServerSocket server;
  final List<List<int>> jobs = [];
  final List<int> _current = [];
  int connections = 0;

  Future<void> start() async {
    server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((client) {
      connections++;
      client.listen(_current.addAll, onDone: () {
        jobs.add(List<int>.from(_current));
        _current.clear();
        client.destroy();
      });
    });
  }

  int get port => server.port;
  Future<void> stop() => server.close();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NetworkPrinterTarget.parse', () {
    test('default port 9100', () {
      final t = NetworkPrinterTarget.parse('192.168.1.50')!;
      expect(t.host, '192.168.1.50');
      expect(t.port, 9100);
    });
    test('custom port', () {
      expect(NetworkPrinterTarget.parse('192.168.1.50:9101')!.port, 9101);
    });
    test('IPv6 with port', () {
      final t = NetworkPrinterTarget.parse('[fe80::1]:9100')!;
      expect(t.host, 'fe80::1');
    });
    test('hostname', () {
      expect(NetworkPrinterTarget.parse('kitchen-printer.local')!.host,
          'kitchen-printer.local');
    });
    test('rejects bad input', () {
      for (final bad in [
        '',
        '   ',
        '192.168.1',
        '192.168.1.300',
        '192.168.1.5:0',
        '192.168.1.5:70000',
        '192.168.1.5:abc',
        'not a host',
      ]) {
        expect(NetworkPrinterTarget.parse(bad), isNull, reason: bad);
      }
    });
    test('paper size kept as 58 or 80', () {
      expect(NetworkPrinterTarget.parse('10.0.0.2', paperSize: 58)!.paperSize,
          58);
      expect(NetworkPrinterTarget.parse('10.0.0.2', paperSize: 0)!.paperSize,
          80);
    });
  });

  group('WifiPrinterService over real TCP', () {
    late FakePrinter printer;
    setUp(() async {
      printer = FakePrinter();
      await printer.start();
    });
    tearDown(() async {
      await WifiPrinterService.instance.disposeForTest();
      await printer.stop();
    });

    NetworkPrinterTarget target() =>
        NetworkPrinterTarget(host: '127.0.0.1', port: printer.port, label: 'T');

    test('sends exact bytes, large payload, unchanged', () async {
      final bytes = List<int>.generate(50000, (i) => i % 256);
      await WifiPrinterService.instance.printBytes(target(), bytes);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(printer.jobs.length, 1);
      expect(printer.jobs.single, bytes);
    });

    test('copies are sent the requested number of times', () async {
      await WifiPrinterService.instance.printBytes(target(), [1, 2, 3],
          copies: 2, gapBetweenCopies: Duration.zero);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(printer.jobs.single, [1, 2, 3, 1, 2, 3]);
    });

    test('two jobs on one printer do not interleave', () async {
      final a = List<int>.filled(20000, 0xAA);
      final b = List<int>.filled(20000, 0xBB);
      await Future.wait([
        WifiPrinterService.instance.printBytes(target(), a),
        WifiPrinterService.instance.printBytes(target(), b),
      ]);
      await Future.delayed(const Duration(milliseconds: 300));
      expect(printer.jobs.length, 2);
      for (final job in printer.jobs) {
        expect(job.toSet().length, 1, reason: 'job bytes were mixed');
      }
    });

    test('printer offline: clear error, nothing sent', () async {
      final port = printer.port;
      await printer.stop();
      expect(
        () => WifiPrinterService.instance.printBytes(
            NetworkPrinterTarget(host: '127.0.0.1', port: port), [1]),
        throwsA(isA<WifiPrintException>()
            .having((e) => e.mayHavePrinted, 'mayHavePrinted', false)),
      );
    });

    test('lock is released after a failed connect', () async {
      final port = printer.port;
      await printer.stop();
      final dead = NetworkPrinterTarget(host: '127.0.0.1', port: port);
      await expectLater(WifiPrinterService.instance.printBytes(dead, [1]),
          throwsA(isA<WifiPrintException>()));
      // Second attempt must fail fast too, not hang on the lock.
      await expectLater(
          WifiPrinterService.instance
              .printBytes(dead, [1])
              .timeout(const Duration(seconds: 20)),
          throwsA(isA<WifiPrintException>()));
    });
  });
}
