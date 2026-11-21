import 'dart:async';
import 'package:mygenie_restaurant/helper/colors.dart';
import 'package:mygenie_restaurant/helper/logo_helper.dart';
import 'package:mygenie_restaurant/helper/responsive_helper.dart';
import 'package:mygenie_restaurant/util/images.dart';
import 'package:mygenie_restaurant/view/base/custom_snackbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class GetPrinterIp extends StatefulWidget {
  const GetPrinterIp({Key? key}) : super(key: key);

  @override
  State<GetPrinterIp> createState() => _GetPrinterIpState();
}

class _GetPrinterIpState extends State<GetPrinterIp> {
  String _info = "";
  String _msj = '';
  String mac = '';
  bool connected = false;
  List<BluetoothInfo> items = [];
  final List<String> _options = [
    "permission bluetooth granted",
    "bluetooth enabled",
    "connection status",
    "update info"
  ];

  String _selectSize = "2";
  final TextEditingController _txtText =
      TextEditingController(text: "Hello developer");
  bool _progress = false;
  String _msjprogress = "";

  String optionprinttype = "58 mm";
  final List<String> options = ["58 mm", "80 mm"];

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: Get.height / 10.72,
        backgroundColor: Theme.of(context).cardColor,
        leading: IconButton(
            icon: Image.asset(Images.ic_arrow_back, height: 20),
            color: ColorTheme.appColor,
            onPressed: () async {
              if (connected) {
                await disconnect();
                if (context.mounted) Get.back();
              } else {
                if (context.mounted) Get.back();
              }
            }),
        titleSpacing: 0,
        elevation: 0,
        centerTitle: false,
        title: Column(
          children: [
            SizedBox(
              height: 60,
              child: Image.asset(logoHelper.appLogo!,
                  height: ResponsiveHelper.isMobile(context)
                      ? Get.width * 0.5
                      : 50),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Type print"),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: optionprinttype,
                    items: options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(option),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          optionprinttype = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: getBluetoots,
                    child: Row(
                      children: [
                        Visibility(
                          visible: _progress,
                          child: const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator.adaptive(
                                strokeWidth: 1, backgroundColor: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(_progress ? _msjprogress : "Search"),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: connected ? disconnect : null,
                    child: const Text("Disconnect"),
                  ),
                  ElevatedButton(
                    onPressed: connected ? printTest : null,
                    child: const Text("Print"),
                  ),
                ],
              ),
              Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    color: Colors.grey.withOpacity(0.3),
                  ),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.isNotEmpty ? items.length : 0,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          mac = items[index].macAdress;
                          connect(mac);
                        },
                        title: SelectableText('Name: ${items[index].name}'),
                        subtitle: SelectableText(
                            "macAddress: ${items[index].macAdress}"),
                        trailing: SizedBox(
                          width: Get.width * 0.25,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text:
                                          "Mac Ip: ${items[index].macAdress}"));
                                  showErrorToast('Address copied',
                                      isError: false);
                                },
                                child: const Icon(Icons.copy),
                              ),
                              if (!connected)
                                InkWell(
                                  onTap: () {
                                    mac = items[index].macAdress;
                                    connect(mac);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 5),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: ColorTheme.appColor),
                                    child: const Text(
                                      'Connect',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPlatformState() async {
    await getBluetoots();
  }

  Future<void> getBluetoots() async {
    setState(() {
      _progress = true;
      _msjprogress = "Wait";
      items = [];
    });
    final List<BluetoothInfo> listResult =
        await PrintBluetoothThermal.pairedBluetooths;

    setState(() {
      _progress = false;
    });

    if (listResult.isEmpty) {
      _msj =
          "There are no bluetoohs linked, go to settings and link the printer";
    } else {
      _msj = "Touch an item in the list to connect";
    }

    if (mounted) {
      setState(() {
        items = listResult;
      });
    }
  }

  Future<void> connect(String mac) async {
    setState(() {
      _progress = true;
      _msjprogress = "Connecting...";
      connected = false;
    });

    final bool result =
        await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    if (result) connected = true;
    if (mounted) {
      setState(() {
        _progress = false;
      });
    }
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;
    if (mounted) {
      setState(() {
        connected = false;
      });
    }
    print("status disconnect $status");
  }

  Future<void> printTest() async {
    bool conexionStatus = await PrintBluetoothThermal.connectionStatus;
    if (conexionStatus) {
      List<int> ticket = await testTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      print("print test result:  $result");
      Future.delayed(const Duration(seconds: 3), () {
        disconnect();
      });
    }
  }

  Future<List<int>> testTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    final generator = Generator(
        optionprinttype == "58 mm" ? PaperSize.mm58 : PaperSize.mm80, profile);
    bytes += generator.reset();

    bytes += generator.text('MyGenie',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    bytes += generator.feed(2);
    bytes += generator.hr(ch: '....');
    bytes += generator.text('Printer Mac IP address : $mac',
        styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2));

    bytes += generator.cut();
    return bytes;
  }
}
