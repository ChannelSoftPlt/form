import 'dart:async';
import 'dart:io';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my/fragment/order/print/receipt_layout.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class BluetoothPrinterLayout extends StatefulWidget {
  final String orderId;
  final Function(String) onClick;

  BluetoothPrinterLayout({this.orderId, this.onClick});

  @override
  _BluetoothPrinterLayoutState createState() => _BluetoothPrinterLayoutState();
}

class _BluetoothPrinterLayoutState extends State<BluetoothPrinterLayout> {
  String msg = 'no_device';

  BluetoothManager bluetoothManager = BluetoothManager.instance;
  PrinterBluetoothManager bluePrintManager = PrinterBluetoothManager();
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  FlutterBlue flutterBlue = FlutterBlue.instance;
  PrinterBluetooth printer;
  List<PrinterBluetooth> _devices = [];

  PrinterBluetooth selectedDevice;

  bool isBluetoothPrinter = true;
  bool isBluetoothOpen = false;
  bool bluetoothScan = false;
  bool isPrinting = false;

  int paperSize = 58;

  @override
  dispose() {
    super.dispose();
    bluePrintManager.stopScan();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bluetoothScan = false;
    bluetoothChecking();
  }

  bluetoothChecking() {
    /*
    * ios goes here
    * */
    if (Platform.isIOS) {
      isBluetoothOpen = true;
      initPrinter();
      //show device list after three seconds
      Timer(Duration(seconds: 2), () {
        try {
          setState(() {
            bluetoothScan = true;
          });
        } catch ($e) {}
      });
    }
    /*
    * android goes here
    * */
    else {
      bluetoothManager.state.listen((val) {
        if (!mounted) return;
        if (val == 12) {
          isBluetoothOpen = true;
          initPrinter();
          //show device list after three seconds
          Timer(Duration(seconds: 2), () {
            try {
              setState(() {
                bluetoothScan = true;
              });
            } catch ($e) {}
          });
        } else if (val == 10) {
          setState(() {
            isBluetoothOpen = false;
            selectedDevice = null;
            msg = 'enable_bluetooth';
          });
        }
      });
    }
  }

  void initPrinter() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (int i = 0; i < results.length; i++) {
        print(results[i].device.name);
        print(results[i].device.type);
        print(results[i].device.toString());
      }
    });
    flutterBlue.stopScan();

    bluePrintManager.startScan(Duration(seconds: 2));
    bluePrintManager.scanResults.listen((event) {
      if (!mounted) return;
      setState(() {
        _devices = event;
        //print(_devices.length);
        if (selectedDevice == null) setDefaultPrinterSetting();
      });

      if (_devices.isEmpty)
        setState(() {
          msg = 'No devices';
        });
    });
  }

  void setDefaultPrinterSetting() async {
    //paper size
    var size = await SharePreferences().read('paper_size');
    paperSize = size != null ? size : 58;

    //select default printer
    var data = await SharePreferences().read('default_printer');
    for (int i = 0; i < _devices.length; i++) {
      if (_devices[i].address == data) {
        selectedDevice = _devices[i];
        break;
      }
    }
  }

  printResult(result) {
    switch (result) {
      case 'Success':
        Navigator.of(context).pop();
        CustomToast(
          '${AppLocalizations.of(context).translate('print_success')}',
          context,
        ).show();
        break;
      case 'Error. Printer connection timeout':
        _showSnackBar('connection_timeout');
        break;
      case 'Error. Printer not selected':
        _showSnackBar('select_a_device');
        break;
      case 'Error. Ticket is empty':
        _showSnackBar('ticket_empty');
        break;
      case 'Error. Another print in progress':
        _showSnackBar('print_in_progress');
        break;
      case 'Error. Printer scanning in progress':
        _showSnackBar('scanning_in_progress');
        break;
      default:
        _showSnackBar('something_went_wrong');
    }
    setState(() {
      isPrinting = false;
    });
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate(message))));
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    setState(() {
      isPrinting = true;
    });
    var result;
    final myTicket = await ReceiptLayout(widget.orderId)
        .ticket(paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80);
    if (myTicket != null) {
      bluePrintManager.selectPrinter(printer);
      result = await bluePrintManager.printTicket(myTicket);
      printResult(result.msg);
    } else {
      setState(() {
        _showSnackBar('format_error');
        isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return bluetoothPrinter();
  }

  Widget bluetoothPrinter() {
    return Column(
      children: [
        paperSizeLayout(),
        Container(
          height: 296,
          child: isBluetoothOpen
              ? isPrinting
                  ? printingLayout()
                  : blueDeviceList()
              : Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context).translate(msg),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '${AppLocalizations.of(context).translate('print')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                if (bluetoothScan == false) {
                  _showSnackBar('scan_device_around');
                  return;
                }
                //return if no device selected
                if (selectedDevice == null) {
                  _showSnackBar('select_a_device');
                  return;
                }
                _startPrint(selectedDevice);
              },
            ),
          ],
        )
      ],
    );
  }

  Widget blueDeviceList() {
    return bluetoothScan
        ? _devices.length > 0
            ? Column(children: [
                Container(
                    height: 296,
                    child: SmartRefresher(
                        enablePullDown: true,
                        enablePullUp: true,
                        header: WaterDropHeader(),
                        footer: CustomFooter(
                          builder: (BuildContext context, LoadStatus mode) {
                            Widget body;
                            if (mode == LoadStatus.idle) {
                              body = Text(
                                  '${AppLocalizations.of(context).translate('pull_up_load')}');
                            } else if (mode == LoadStatus.loading) {
                              body = CustomProgressBar();
                            } else if (mode == LoadStatus.failed) {
                              body = Text(
                                  '${AppLocalizations.of(context).translate('load_failed')}');
                            } else if (mode == LoadStatus.canLoading) {
                              body = Text(
                                  '${AppLocalizations.of(context).translate('release_to_load_more')}');
                            } else {
                              body = Text(
                                  '${AppLocalizations.of(context).translate('no_more_data')}');
                            }
                            return Container(
                              height: 55.0,
                              child: Center(child: body),
                            );
                          },
                        ),
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoading,
                        child: customList())),
              ])
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppLocalizations.of(context).translate('no_device'),
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    AppLocalizations.of(context).translate('no_device_2'),
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context).translate('retry'),
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: () {
                      setState(() {
                        bluetoothScan = false;
                        bluetoothChecking();
                      });
                    },
                  )
                ],
              )
        : Container(
            child: CustomProgressBar(),
          );
  }

  _onRefresh() async {
    if (mounted)
      setState(() {
        bluetoothScan = false;
        bluetoothChecking();
        _refreshController.resetNoData();
      });
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    _refreshController.loadComplete();
  }

  customList() {
    return ListView.builder(
      itemBuilder: (context, position) => ListTile(
        tileColor: selectedDevice != null &&
                selectedDevice.address == _devices[position].address
            ? Colors.black26
            : Colors.white,
        onTap: () {
          setState(() {
            selectedDevice = _devices[position];
            //print(_devices[position].type);
            SharePreferences().save('default_printer', selectedDevice.address);
          });
        },
        leading: Icon(Icons.print),
        title: Text(
          _devices[position].name,
          style: TextStyle(fontSize: 16),
        ),
        subtitle: Text(
          _devices[position].address,
          style: TextStyle(fontSize: 12),
          maxLines: 2,
        ),
      ),
      itemCount: _devices.length,
    );
  }

  Widget paperSizeLayout() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(AppLocalizations.of(context).translate('paper_size'))),
        Expanded(
          flex: 2,
          child: DropdownButton(
              isExpanded: true,
              itemHeight: 50,
              value: paperSize,
              style: TextStyle(fontSize: 15, color: Colors.black87),
              items: [
                DropdownMenuItem(
                  child: Text(
                    '58mm',
                    textAlign: TextAlign.center,
                  ),
                  value: 58,
                ),
                DropdownMenuItem(
                  child: Text(
                    '80mm',
                    textAlign: TextAlign.center,
                  ),
                  value: 80,
                ),
              ],
              onChanged: (value) {
                setState(() {
                  paperSize = value;
                  SharePreferences().save('paper_size', paperSize);
                });
              }),
        ),
      ],
    );
  }

  Widget printingLayout() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CustomProgressBar(), Text('Connecting...')],
    ));
  }
}
