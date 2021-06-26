import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:my/fragment/order/print/bluetooth_printer_layout.dart';
import 'package:my/fragment/order/print/lan_printer_layout.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/sharePreference.dart';

class PrintDialog extends StatefulWidget {
  final String orderId;

  PrintDialog({this.orderId});

  @override
  _PrintDialogState createState() => _PrintDialogState();
}

class _PrintDialogState extends State<PrintDialog>
    with SingleTickerProviderStateMixin {
  String msg = 'no_device';
  var key = new GlobalKey<ScaffoldState>();
  TabController tabController;

  int selectTab = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    tabController = new TabController(vsync: this, length: 2);
    checkHistory();
  }

  @override
  dispose() {
    super.dispose();
    tabController.dispose();
  }

  checkHistory() async {
    var position = await SharePreferences().read('default_tab_position') ?? 0;
    selectTab = position;
    tabController.animateTo(selectTab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
          key: key,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  '${AppLocalizations.of(context).translate('select_printer')}'),
            ],
          ),
          content: Container(width: 400, height: 460, child: mainContent())),
    );
  }

  Widget mainContent() {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: AppLocalizations.of(context).translate('bluetooth'),
            ),
            Tab(
              text: AppLocalizations.of(context).translate('lan'),
            ),
          ],
          onTap: (position) {
            SharePreferences().save('default_tab_position', position);
            selectTab = position;
          },
        ),
        Expanded(
          child: Container(
            child: TabBarView(controller: tabController, children: [
              BluetoothPrinterLayout(
                orderId: widget.orderId,
              ),
              LanPrinterLayout(
                orderId: widget.orderId,
              )
              //Lan Printer
            ]),
          ),
        )
      ],
    );
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate(message))));
  }
}
