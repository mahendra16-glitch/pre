import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:get/get.dart';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/util/styles.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';

class PrinterDiscoveryScreen extends StatefulWidget {
  final String printerType; // bluetooth, usb, wifi/lan

  const PrinterDiscoveryScreen({Key? key, required this.printerType})
      : super(key: key);

  @override
  State<PrinterDiscoveryScreen> createState() => _PrinterDiscoveryScreenState();
}

class _PrinterDiscoveryScreenState extends State<PrinterDiscoveryScreen> {
  var _isBle = false;
  var _reconnect = false;
  var printerManager = PrinterManager.instance;
  var devices = <DiscoveredPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  bool _isScanning = false;
  String? _testingPrinterId;
  DiscoveredPrinter? _connectedPrinter;
  String? _connectingPrinterId;

  PrinterType get _printerType {
    switch (widget.printerType) {
      case 'bluetooth':
        return PrinterType.bluetooth;
      case 'usb':
        return PrinterType.usb;
      case 'wifi':
        return PrinterType.network;
      default:
        return PrinterType.bluetooth;
    }
  }

  @override
  void initState() {
    super.initState();
    _portController.text = _port;
    _initializeListeners();
    _startScan();
  }

  void _initializeListeners() {
    // Bluetooth status listener
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log('Bluetooth status: $status');
    });

    // USB status listener
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      log('USB status: $status');
    });
  }

  void _startScan() {
    setState(() {
      _isScanning = true;
      devices.clear();
    });

    _subscription =
        printerManager.discovery(type: _printerType, isBle: _isBle).listen(
      (device) {
        // Log the discovered device details
        log('Discovered device: ${device.name}');
        log('  Address: ${device.address}');
        log('  Vendor ID: ${device.vendorId}');
        log('  Product ID: ${device.productId}');

        setState(() {
          devices.add(DiscoveredPrinter(
            deviceName: device.name,
            address: device.address,
            isBle: _isBle,
            vendorId:
                device.vendorId?.isNotEmpty == true ? device.vendorId : null,
            productId:
                device.productId?.isNotEmpty == true ? device.productId : null,
            typePrinter: _printerType,
          ));
        });
      },
      onDone: () {
        setState(() {
          _isScanning = false;
        });
      },
      onError: (error) {
        setState(() {
          _isScanning = false;
        });
        showCustomSnackBar('Error scanning: $error', isError: true);
      },
    );

    // Auto-stop scanning after 10 seconds
    Future.delayed(Duration(seconds: 10), () {
      if (_isScanning) {
        _subscription?.cancel();
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    showCustomSnackBar('$label copied to clipboard', isError: false);
  }

  Future<void> _connectToPrinter(DiscoveredPrinter printer) async {
    setState(() {
      _connectingPrinterId = printer.deviceName;
    });

    try {
      // Disconnect from current printer if any
      if (_connectedPrinter != null) {
        await printerManager.disconnect(type: _connectedPrinter!.typePrinter);
      }

      // Create the appropriate printer input model based on type
      dynamic printerModel;

      if (printer.typePrinter == PrinterType.bluetooth) {
        printerModel = BluetoothPrinterInput(
          name: printer.deviceName ?? '',
          address: printer.address ?? '',
          isBle: printer.isBle ?? false,
          autoConnect: _reconnect,
        );
      } else if (printer.typePrinter == PrinterType.usb) {
        printerModel = UsbPrinterInput(
          name: printer.deviceName ?? '',
          productId: printer.productId ?? '',
          vendorId: printer.vendorId ?? '',
        );
      } else if (printer.typePrinter == PrinterType.network) {
        printerModel = TcpPrinterInput(
          ipAddress: printer.address ?? '',
          port: int.tryParse(printer.port ?? '9100') ?? 9100,
        );
      }

      // Connect to new printer
      await printerManager.connect(
        type: printer.typePrinter,
        model: printerModel,
      );

      // For USB printers, try to get additional device info after connection
      if (printer.typePrinter == PrinterType.usb) {
        // If vendor/product IDs are still null, try to extract from the model
        if (printer.vendorId == null || printer.productId == null) {
          log('USB printer connected but IDs missing. Model used: $printerModel');
          // The IDs should have been captured during discovery
          // If they're still missing, they may need to be obtained differently
        }
      }

      setState(() {
        _connectedPrinter = printer;
      });

      showCustomSnackBar('Connected to ${printer.deviceName}', isError: false);
    } catch (e) {
      log('Connection error: $e');
      showCustomSnackBar('Connection failed: $e', isError: true);
    } finally {
      setState(() {
        _connectingPrinterId = null;
      });
    }
  }

  Future<void> _disconnectFromPrinter() async {
    if (_connectedPrinter == null) return;

    try {
      await printerManager.disconnect(type: _connectedPrinter!.typePrinter);
      final printerName = _connectedPrinter!.deviceName;
      setState(() {
        _connectedPrinter = null;
      });
      showCustomSnackBar('Disconnected from $printerName', isError: false);
    } catch (e) {
      log('Disconnect error: $e');
      showCustomSnackBar('Disconnect failed: $e', isError: true);
    }
  }

  void _copyAndReturn(DiscoveredPrinter printer) {
    // Log the printer data being copied
    log('Copying printer data:');
    log('  Device Name: ${printer.deviceName}');
    log('  Address: ${printer.address}');
    log('  Vendor ID: ${printer.vendorId}');
    log('  Product ID: ${printer.productId}');
    log('  Type: ${printer.typePrinter}');

    // Return the printer data to be auto-populated
    Get.back(result: printer);
  }

  Future<void> _testPrint(DiscoveredPrinter printer) async {
    if (_connectedPrinter?.deviceName != printer.deviceName) {
      showCustomSnackBar('Printer not connected', isError: true);
      return;
    }

    setState(() {
      _testingPrinterId = printer.deviceName;
    });

    try {
      // Generate test receipt (already connected, no need to connect again)
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      // Header
      bytes += generator.text(
        'TEST PRINT',
        styles: PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
          bold: true,
        ),
      );
      bytes += generator.feed(1);
      bytes += generator.text(
        'Printer Connection Test',
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(1);
      // Dashed line with padding
      bytes += generator.text('  ${'=' * 28}  ');

      // Printer Details
      bytes += generator.text('  Printer Name: ${printer.deviceName ?? 'N/A'}');
      if (printer.address != null) {
        bytes += generator.text('  Address: ${printer.address}');
      }
      if (printer.vendorId != null) {
        bytes += generator.text('  Vendor ID: ${printer.vendorId}');
      }
      if (printer.productId != null) {
        bytes += generator.text('  Product ID: ${printer.productId}');
      }
      bytes += generator.feed(1);
      // Dashed line with padding
      bytes += generator.text('  ${'=' * 28}  ');

      // Test Pattern
      bytes += generator.text(
        'Connection Status: SUCCESS',
        styles: PosStyles(align: PosAlign.center, bold: true),
      );
      bytes += generator.feed(1);
      bytes += generator.text(
        DateTime.now().toString(),
        styles: PosStyles(align: PosAlign.center),
      );
      bytes += generator.feed(2);
      bytes += generator.cut();

      // Send to printer
      await printerManager.send(type: printer.typePrinter, bytes: bytes);

      showCustomSnackBar('Test print successful!', isError: false);
    } catch (e) {
      log('Test print error: $e');
      showCustomSnackBar('Test print failed: $e', isError: true);
    } finally {
      setState(() {
        _testingPrinterId = null;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _subscriptionUsbStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    // Disconnect printer when leaving screen
    if (_connectedPrinter != null) {
      printerManager.disconnect(type: _connectedPrinter!.typePrinter);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTheme.whiteColor,
      appBar: AppBar(
        backgroundColor: ColorTheme.whiteColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorTheme.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Discover ${widget.printerType.toUpperCase()} Printers',
          style: montserratSemiBold.copyWith(
            color: ColorTheme.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Scanning Status & Controls
          Container(
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorTheme.appColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorTheme.appColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    if (_isScanning)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: ColorTheme.appColor,
                          strokeWidth: 2,
                        ),
                      )
                    else
                      Icon(Icons.search, color: ColorTheme.appColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isScanning
                            ? 'Scanning for printers...'
                            : 'Found ${devices.length} printer(s)',
                        style: montserratMedium.copyWith(
                          color: ColorTheme.black,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (!_isScanning)
                      OutlinedButton.icon(
                        onPressed: _startScan,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Rescan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: ColorTheme.appColor,
                          side: BorderSide(color: ColorTheme.appColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.printerType == 'bluetooth' &&
                    Platform.isAndroid) ...[
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'BLE Mode',
                            style: montserratRegular.copyWith(fontSize: 12),
                          ),
                          value: _isBle,
                          onChanged: (value) {
                            setState(() {
                              _isBle = value ?? false;
                            });
                            _startScan();
                          },
                          activeColor: ColorTheme.appColor,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Auto-reconnect',
                            style: montserratRegular.copyWith(fontSize: 12),
                          ),
                          value: _reconnect,
                          onChanged: (value) {
                            setState(() {
                              _reconnect = value ?? false;
                            });
                          },
                          activeColor: ColorTheme.appColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Network Printer Manual Entry
          if (widget.printerType == 'wifi') ...[
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ColorTheme.blueColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: ColorTheme.blueColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manual Network Printer Entry',
                    style: montserratSemiBold.copyWith(
                      color: ColorTheme.black,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _ipController,
                          decoration: InputDecoration(
                            labelText: 'IP Address',
                            hintText: '192.168.1.100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          style: montserratRegular.copyWith(fontSize: 13),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Port',
                            hintText: '9100',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          style: montserratRegular.copyWith(fontSize: 13),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_ipController.text.isNotEmpty) {
                            final newPrinter = DiscoveredPrinter(
                              deviceName:
                                  'Network Printer (${_ipController.text})',
                              address: _ipController.text,
                              port: _portController.text.isEmpty
                                  ? '9100'
                                  : _portController.text,
                              typePrinter: PrinterType.network,
                            );
                            setState(() {
                              devices.add(newPrinter);
                              _ipController.clear();
                            });
                            showCustomSnackBar('Network printer added to list',
                                isError: false);
                          } else {
                            showCustomSnackBar('Please enter IP address',
                                isError: true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorTheme.appColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Icon(Icons.add, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],

          // Printer List
          Expanded(
            child: devices.isEmpty && !_isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.print_disabled,
                          size: 64,
                          color: ColorTheme.grey1.withOpacity(0.3),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No printers found',
                          style: montserratMedium.copyWith(
                            color: ColorTheme.grey1,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Try scanning again',
                          style: montserratRegular.copyWith(
                            color: ColorTheme.grey1.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final printer = devices[index];
                      final isTesting = _testingPrinterId == printer.deviceName;
                      final isConnected =
                          _connectedPrinter?.deviceName == printer.deviceName;
                      final isConnecting =
                          _connectingPrinterId == printer.deviceName;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: ColorTheme.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isConnected
                                ? ColorTheme.appColor
                                : ColorTheme.borderGrey2,
                            width: isConnected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with icon, name, and connection status
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isConnected
                                          ? ColorTheme.appColor
                                          : ColorTheme.appColor
                                              .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getPrinterIcon(),
                                      color: isConnected
                                          ? Colors.white
                                          : ColorTheme.appColor,
                                      size: 24,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          printer.deviceName ?? 'Unknown',
                                          style: montserratSemiBold.copyWith(
                                            color: ColorTheme.black,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (isConnected) ...[
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'Connected',
                                                style:
                                                    montserratMedium.copyWith(
                                                  color: Colors.green,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Copy to form button
                                  IconButton(
                                    onPressed: () => _copyAndReturn(printer),
                                    icon: Icon(Icons.content_copy, size: 20),
                                    color: ColorTheme.appColor,
                                    tooltip: 'Copy to form',
                                    padding: EdgeInsets.all(8),
                                    constraints: BoxConstraints(),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Printer Details with Copy Icons
                              if (printer.address != null &&
                                  printer.address!.isNotEmpty)
                                _buildInfoRow(
                                  'Address',
                                  printer.address!,
                                  () => _copyToClipboard(
                                      printer.address!, 'Address'),
                                ),
                              if (printer.vendorId != null &&
                                  printer.vendorId!.isNotEmpty)
                                _buildInfoRow(
                                  'Vendor ID',
                                  printer.vendorId!,
                                  () => _copyToClipboard(
                                      printer.vendorId!, 'Vendor ID'),
                                ),
                              if (printer.productId != null &&
                                  printer.productId!.isNotEmpty)
                                _buildInfoRow(
                                  'Product ID',
                                  printer.productId!,
                                  () => _copyToClipboard(
                                      printer.productId!, 'Product ID'),
                                ),
                              // Show warning for USB printers without IDs
                              if (printer.typePrinter == PrinterType.usb &&
                                  (printer.vendorId == null ||
                                      printer.productId == null ||
                                      printer.vendorId!.isEmpty ||
                                      printer.productId!.isEmpty))
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    // decoration: BoxDecoration(
                                    //   color: Colors.orange.withOpacity(0.1),
                                    //   borderRadius: BorderRadius.circular(6),
                                    //   border: Border.all(
                                    //     color: Colors.orange.withOpacity(0.3),
                                    //   ),
                                    // ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 14,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'Vendor/Product ID not detected. You can enter them manually in the form.',
                                            style: montserratRegular.copyWith(
                                              fontSize: 11,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              SizedBox(height: 12),

                              // Action Buttons Row
                              Row(
                                children: [
                                  // Connect/Disconnect Button
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: isConnecting
                                          ? null
                                          : () async {
                                              if (isConnected) {
                                                await _disconnectFromPrinter();
                                              } else {
                                                await _connectToPrinter(
                                                    printer);
                                              }
                                            },
                                      icon: isConnecting
                                          ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              isConnected
                                                  ? Icons.link_off
                                                  : Icons.link,
                                              size: 18,
                                            ),
                                      label: Text(
                                        isConnecting
                                            ? 'Connecting...'
                                            : isConnected
                                                ? 'Disconnect'
                                                : 'Connect',
                                        style: montserratMedium.copyWith(
                                            fontSize: 14),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isConnected
                                            ? Colors.redAccent
                                            : ColorTheme.appColor,
                                        foregroundColor: Colors.white,
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                    ),
                                  ),

                                  // Test Print Button (only show when connected)
                                  if (isConnected) ...[
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: isTesting
                                            ? null
                                            : () => _testPrint(printer),
                                        icon: isTesting
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Icon(Icons.print, size: 18),
                                        label: Text(
                                          isTesting
                                              ? 'Printing...'
                                              : 'Test Print',
                                          style: montserratMedium.copyWith(
                                              fontSize: 14),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, VoidCallback onCopy) {
    return Padding(
      padding: EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: montserratMedium.copyWith(
              color: ColorTheme.grey1,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: montserratRegular.copyWith(
                color: ColorTheme.black,
                fontSize: 12,
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ColorTheme.blueColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                Icons.copy,
                size: 14,
                color: ColorTheme.blueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPrinterIcon() {
    switch (widget.printerType) {
      case 'bluetooth':
        return Icons.bluetooth;
      case 'usb':
        return Icons.usb;
      case 'wifi':
        return Icons.wifi;
      default:
        return Icons.print;
    }
  }
}

class DiscoveredPrinter {
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType typePrinter;

  DiscoveredPrinter({
    this.deviceName,
    this.address,
    this.port,
    this.vendorId,
    this.productId,
    this.typePrinter = PrinterType.bluetooth,
    this.isBle = false,
  });
}
