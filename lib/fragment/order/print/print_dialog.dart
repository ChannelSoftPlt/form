import 'dart:async';
import 'dart:io';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/order/print/receipt_layout.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:my/utils/sharePreference.dart';

class PrintDialog extends StatefulWidget {
  final String orderId;

  PrintDialog({this.orderId});

  @override
  _PrintDialogState createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  String msg = 'no_device';
  var key = new GlobalKey<ScaffoldState>();
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  PrinterBluetooth printer;
  List<PrinterBluetooth> _devices = [];

  PrinterBluetooth selectedDevice;
  String defaultPrinter;
  bool isBluetoothOpen = false;
  bool bluetoothScan = false;
  bool isPrinting = false;

  int paperSize = 58;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bluetoothChecking();
  }

  @override
  dispose() {
    super.dispose();
    printerManager.stopScan();
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
        setState(() {
          bluetoothScan = true;
        });
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
            setState(() {
              bluetoothScan = true;
            });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        key: key,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${AppLocalizations.of(context).translate('select_printer')}'),
            IconButton(
                onPressed: () {
                  setState(() {
                    bluetoothScan = false;
                    bluetoothChecking();
                  });
                },
                icon: Icon(
                  Icons.refresh,
                  color: Colors.red,
                ))
          ],
        ),
        content: Container(width: 300, height: 480, child: mainContent()),
        actions: <Widget>[
          TextButton(
            child: Text('${AppLocalizations.of(context).translate('cancel')}'),
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
              //return is scanning
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
              //print();
            },
          ),
        ],
      ),
    );
  }

  Widget mainContent() {
    return isBluetoothOpen
        ? isPrinting
            ? printingLayout()
            : deviceList()
        : Container(
            alignment: Alignment.center,
            child: Text(
              AppLocalizations.of(context).translate(msg),
              style: TextStyle(fontSize: 13),
            ),
          );
  }

  Widget deviceList() {
    return bluetoothScan
        ? _devices.length > 0
            ? Column(children: [
                Row(
                  children: [
                    Expanded(
                        flex: 2,
                        child: Text(AppLocalizations.of(context)
                            .translate('paper_size'))),
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
                ),
                Container(
                  height: 350,
                  child: ListView.builder(
                    itemBuilder: (context, position) => ListTile(
                      tileColor: selectedDevice != null &&
                              selectedDevice.address ==
                                  _devices[position].address
                          ? Colors.black26
                          : Colors.white,
                      onTap: () {
                        setState(() {
                          selectedDevice = _devices[position];
                          //print(_devices[position].type);
                          SharePreferences()
                              .save('default_printer', selectedDevice.address);
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
                  ),
                ),
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

  Widget printingLayout() {
    return Container(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [CustomProgressBar(), Text('Connecting...')],
    ));
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    setState(() {
      isPrinting = true;
    });
    printerManager.selectPrinter(printer);
    final myTicket = await ReceiptLayout(widget.orderId)
        .ticket(paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80);

    if (myTicket != null) {
      final result = await printerManager.printTicket(myTicket);
      printResult(result.msg);
    } else {
      setState(() {
        _showSnackBar('format_error');
        isPrinting = false;
      });
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

  void initPrinter() async {
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {});
    flutterBlue.stopScan();

    printerManager.startScan(Duration(seconds: 2));
    printerManager.scanResults.listen((event) {
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

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate(message))));
  }
}
