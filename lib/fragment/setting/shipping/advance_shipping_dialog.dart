import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/shippingSetting/advance_shipping.dart';
import 'package:my/object/shippingSetting/distance.dart';
import 'package:my/translation/AppLocalizations.dart';

class AdvanceShippingDialog extends StatefulWidget {
  final Function(AdvanceShippingFee) callBack;
  final Function(String) showSnack;
  final AdvanceShippingFee advanceShippingFee;
  final bool isUpdate;

  @override
  _AdvanceShippingDialogState createState() => _AdvanceShippingDialogState();

  AdvanceShippingDialog(
      {this.callBack, this.advanceShippingFee, this.isUpdate, this.showSnack});
}

class _AdvanceShippingDialogState extends State<AdvanceShippingDialog> {
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController totalOne = new TextEditingController();
  TextEditingController totalTwo = new TextEditingController();
  TextEditingController shippingFee = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate) {
      totalOne.text = widget.advanceShippingFee.totalFee_1;
      totalTwo.text = widget.advanceShippingFee.totalFee_2;
      shippingFee.text = widget.advanceShippingFee.shippingFee;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(
            "${AppLocalizations.of(context).translate(widget.isUpdate ? 'edit_condition' : 'add_condition')}"),
        actions: <Widget>[
          TextButton(
            child: Text('${AppLocalizations.of(context).translate('cancel')}'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(
              '${AppLocalizations.of(context).translate('confirm')}',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              if (totalOne.text.isEmpty ||
                  totalTwo.text.isEmpty ||
                  shippingFee.text.isEmpty) {
                widget.showSnack('invalid_input');
              } else {
                setState(() {
                  try {
                    double.parse(shippingFee.text);
                    double.parse(totalOne.text);
                    double.parse(totalTwo.text);
                    widget.callBack(AdvanceShippingFee(
                        totalFee_1: totalOne.text,
                        totalFee_2: totalTwo.text,
                        shippingFee: shippingFee.text));
                    Navigator.of(context).pop();
                  } catch ($e) {
                    print($e);
                    widget.showSnack('invalid_input');
                  }
                });
              }
            },
          ),
        ],
        content: Container(
            width: 2000,
            height: 190,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: totalOne,
                        textAlign: TextAlign.start,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^\d*\.?\d*")),
                        ],
                        onChanged: (text) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: 14),
                          labelText:
                              '${AppLocalizations.of(context).translate('total_amount')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        ),
                      ),
                    ),
                    Expanded(
                        flex: 1,
                        child: Text(
                          AppLocalizations.of(context).translate('to'),
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        )),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: totalTwo,
                        textAlign: TextAlign.start,
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^\d*\.?\d*")),
                        ],
                        onChanged: (text) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintStyle: TextStyle(fontSize: 14),
                          labelText:
                              '${AppLocalizations.of(context).translate('total_amount')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                TextField(
                  controller: shippingFee,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  textAlign: TextAlign.start,
                  onChanged: (text) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    labelText:
                        '${AppLocalizations.of(context).translate('shipping_fee')}',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    prefixText: 'RM',
                    prefixStyle: TextStyle(fontSize: 14, color: Colors.black87),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  '${AppLocalizations.of(context).translate('label_condition')} RM${totalOne.text.isEmpty ? '-' : totalOne.text} '
                  '${AppLocalizations.of(context).translate('to')} RM${totalTwo.text.isEmpty ? '-' : totalTwo.text}'
                  '\n${AppLocalizations.of(context).translate('label_condition_2')} RM${shippingFee.text.isEmpty ? '-' : shippingFee.text}',
                  style: TextStyle(fontSize: 12),
                )
              ],
            )));
  }
}
