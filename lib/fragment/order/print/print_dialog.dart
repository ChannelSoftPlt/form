import 'dart:async';
import 'dart:io';

import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bluetooth_basic/flutter_bluetooth_basic.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:flutter_blue/flutter_blue.dart';

class PrintDialog extends StatefulWidget {
  @override
  _PrintDialogState createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog> {
  String _devicesMsg = 'No Device';
  var key = new GlobalKey<ScaffoldState>();
  BluetoothManager bluetoothManager = BluetoothManager.instance;
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  FlutterBlue flutterBlue = FlutterBlue.instance;
  PrinterBluetooth printer;
  List<PrinterBluetooth> _devices = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bluetoothChecking();
  }

  bluetoothChecking() {
    if (Platform.isIOS) {
      print('ios here');
      initPrinter();
    } else {
      bluetoothManager.state.listen((val) {
        print("state = $val");
        if (!mounted) return;
        if (val == 12) {
          print('on');
          initPrinter();
        } else if (val == 10) {
          print('off');
          setState(() {
            _devicesMsg = 'Please enable bluetooth to print';
          });
        }
        print('state is $val');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('order')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: _devices.length > 0,
            child: Container(
              height: 200,
              child: ListView.builder(
                itemBuilder: (context, position) => ListTile(
                  onTap: () {
                    _startPrint(_devices[position]);
                  },
                  leading: Icon(Icons.print),
                  title: Text(_devices[position].name),
                  subtitle: Text(_devices[position].address),
                ),
                itemCount: _devices.length,
              ),
            ),
          ),
          Text(_devicesMsg),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          initPrinter();
          // _startPrint(printer);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _startPrint(PrinterBluetooth printer) async {
    printerManager.selectPrinter(printer);
    final myTicket = await _ticket(PaperSize.mm58);
    final result = await printerManager.printTicket(myTicket);
    print('scan result: ${result.msg}');
  }

  void initPrinter() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));

// Listen to scan results
    flutterBlue.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
      }
    });

// Stop scanning
    flutterBlue.stopScan();

    printerManager.startScan(Duration(seconds: 5));
    print('start scanning');
    printerManager.scanResults.listen((event) {
      print(event);
      if (!mounted) return;
      setState(() {
        _devices = event;
      });

      if (_devices.isEmpty)
        setState(() {
          _devicesMsg = 'No devices';
        });
    });
  }

  Future<Ticket> _ticket(PaperSize paper) async {
    final Ticket ticket = Ticket(paper);

    ticket.text(
        'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
    ticket.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
        styles: PosStyles(codeTable: PosCodeTable.westEur));
    ticket.text('Special 2: blåbærgrød',
        styles: PosStyles(codeTable: PosCodeTable.westEur));

    ticket.text('Bold text', styles: PosStyles(bold: true));
    ticket.text('Reverse text', styles: PosStyles(reverse: true));
    ticket.text('Underlined text',
        styles: PosStyles(underline: true), linesAfter: 1);
    ticket.text('Align left', styles: PosStyles(align: PosAlign.left));
    ticket.text('Align center', styles: PosStyles(align: PosAlign.center));
    ticket.text('Align right',
        styles: PosStyles(align: PosAlign.right), linesAfter: 1);

    ticket.text('Text size 200%',
        styles: PosStyles(
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }
}
