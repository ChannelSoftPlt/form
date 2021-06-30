import 'dart:async';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/fragment/order/print/receipt_layout.dart';
import 'package:my/object/lan_printer.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LanPrinterLayout extends StatefulWidget {
  final String orderId;
  final Function(String) onClick;

  LanPrinterLayout({this.orderId, this.onClick});

  @override
  _LanPrinterLayoutState createState() => _LanPrinterLayoutState();
}

class _LanPrinterLayoutState extends State<LanPrinterLayout>
    with SingleTickerProviderStateMixin {
  String msg = 'no_device';
  var key = new GlobalKey<ScaffoldState>();
  TabController tabController;

  PrinterNetworkManager lanPrintManager = PrinterNetworkManager();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<LanPrinter> _lanDevices = [];

  LanPrinter selectedPrinter;
  bool isPrinting = false;
  bool isLoad = false;

  int paperSize = 58;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchLanPrinter();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return lanPrinterLayout();
  }

  Widget lanPrinterLayout() {
    return Column(
      children: [
        paperSizeLayout(),
        !isPrinting
            ? isLoad
                ? lanDeviceList()
                : Container(height: 298, child: CustomProgressBar())
            : Container(height: 298, child: CustomProgressBar()),
        footerLayout()
      ],
    );
  }

  Widget lanDeviceList() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () => createPrinter(context, false, null),
            child: Text(
              '${AppLocalizations.of(context).translate('add_printer')}',
              style: TextStyle(fontSize: 10, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(primary: Colors.black54),
          ),
        ),
        Container(
          height: 248,
          child: _lanDevices.length > 0
              ? SmartRefresher(
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
                  child: customList())
              : Container(
                  alignment: Alignment.center,
                  child: Text(
                    AppLocalizations.of(context).translate('no_device'),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
        ),
      ],
    );
  }

  footerLayout() {
    return ButtonBar(
      alignment: MainAxisAlignment.end,
      children: [
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
            //return if no device selected
            if (selectedPrinter == null) {
              _showSnackBar('select_a_device');
              return;
            }
            _startPrint();
          },
        ),
      ],
    );
  }

  _onRefresh() async {
    print('refresh');
    // monitor network fetch
    if (mounted)
      setState(() {
        _lanDevices.clear();
        fetchLanPrinter();
        _refreshController.resetNoData();
      });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    _refreshController.loadComplete();
  }

  customList() {
    return ListView.builder(
      itemBuilder: (context, position) => ListTile(
          tileColor: selectedPrinter != null &&
                  selectedPrinter.ip == _lanDevices[position].ip
              ? Colors.black26
              : Colors.white,
          onTap: () {
            setState(() {
              selectedPrinter = _lanDevices[position];
              SharePreferences()
                  .save('default_lan_printer', selectedPrinter.ip);
            });
          },
          leading: Icon(Icons.print),
          title: Text(
            _lanDevices[position].name,
            style: TextStyle(fontSize: 16),
          ),
          subtitle: Text(
            _lanDevices[position].ip +
                '   Port:' +
                _lanDevices[position].port.toString(),
            style: TextStyle(fontSize: 12),
            maxLines: 2,
          ),
          trailing: PopupMenuButton(
            icon: Icon(
              Icons.settings,
              color: Colors.grey,
            ),
            offset: Offset(0, 10),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text(AppLocalizations.of(context).translate('edit')),
                value: 'edit',
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text(AppLocalizations.of(context).translate('delete')),
              )
            ],
            onCanceled: () {},
            onSelected: (value) {
              if (value == 'edit') {
                createPrinter(context, true, _lanDevices[position]);
              } else {
                deletePrinter(context, _lanDevices[position].printerId);
              }
            },
          )),
      itemCount: _lanDevices.length,
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

  Future<void> _startPrint() async {
    setState(() {
      isPrinting = true;
    });
    var result;
    final myTicket = await ReceiptLayout(widget.orderId)
        .ticket(paperSize == 58 ? PaperSize.mm58 : PaperSize.mm80);
    if (myTicket != null) {
      lanPrintManager.selectPrinter(selectedPrinter.ip,
          port: selectedPrinter.port);

      result = await lanPrintManager.printTicket(myTicket);

      printResult(result.msg);
    } else {
      setState(() {
        _showSnackBar('format_error');
        isPrinting = false;
      });
    }
  }

  printResult(result) {
    print('result $result');
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

  void setDefaultPrinterSetting() async {
    //paper size
    var size = await SharePreferences().read('paper_size');
    paperSize = size != null ? size : 58;

    //select default printer
    var data = await SharePreferences().read('default_lan_printer');
    for (int i = 0; i < _lanDevices.length; i++) {
      if (_lanDevices[i].ip == data) {
        selectedPrinter = _lanDevices[i];
        break;
      }
    }
  }

  fetchLanPrinter() async {
    _lanDevices.clear();
    Map data = await Domain().readLanPrinter();
    setState(() {
      if (data['status'] == '1') {
        List printer = data['lan_printer'];
        _lanDevices.addAll(printer
            .map((jsonObject) => LanPrinter.fromJson(jsonObject))
            .toList());
        setDefaultPrinterSetting();
      }
      isLoad = true;
    });
  }

  /*
  * delete order
  * */
  deletePrinter(mainContext, printerID) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              '${AppLocalizations.of(context).translate('delete_message')}'),
          actions: <Widget>[
            TextButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Map data = await Domain().deletePrinter(printerID);
                if (data['status'] == '1') {
                  setState(() {
                    fetchLanPrinter();
                    Navigator.of(context).pop();
                  });
                } else
                  _showSnackBar('something_went_wrong');
              },
            ),
          ],
        );
      },
    );
  }

  /*
  * edit & create printer
  * */
  createPrinter(mainContext, isUpdate, LanPrinter printer) {
    var name = TextEditingController();
    var ip = TextEditingController();
    var port = TextEditingController();

    name.text = isUpdate ? printer.name : '';
    ip.text = isUpdate ? printer.ip : '';
    port.text = isUpdate ? printer.port.toString() : '9100';

    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate(isUpdate ? 'edit_printer' : 'add_printer')}"),
          content: SingleChildScrollView(
            child: Container(
              height: 250,
              child: Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.text,
                    controller: name,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.print),
                      labelText:
                          '${AppLocalizations.of(context).translate('printer_name')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText:
                          '${AppLocalizations.of(context).translate('printer_hint')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    controller: ip,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.wifi),
                      labelText:
                          '${AppLocalizations.of(context).translate('ip_address')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText: '192.168.x.x',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: port,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.usb),
                      labelText:
                          '${AppLocalizations.of(context).translate('printer_name')}',
                      labelStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText:
                          '${AppLocalizations.of(context).translate('printer_hint')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                if (ip.text.isEmpty || name.text.isEmpty || port.text.isEmpty) {
                  _showSnackBar('all_field_required');
                  return;
                }
                LanPrinter object = LanPrinter(
                    ip: ip.text,
                    name: name.text,
                    port: int.parse(port.text),
                    printerId: isUpdate ? printer.printerId : null);

                Map data = isUpdate
                    ? await Domain().updateLanPrinter(object)
                    : await Domain().createLanPrinter(object);

                print(data);

                if (data['status'] == '1') {
                  _showSnackBar(isUpdate ? 'create_success' : 'update_success');
                  _onRefresh();
                  Navigator.of(context).pop();
                } else if (data['status'] == '3') {
                  _showSnackBar('ip_repeat');
                } else
                  _showSnackBar('something_went_wrong');
              },
            ),
          ],
        );
      },
    );
  }

  _showSnackBar(message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).translate(message))));
  }
}
