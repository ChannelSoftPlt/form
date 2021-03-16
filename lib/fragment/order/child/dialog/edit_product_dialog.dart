import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order_item.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:toast/toast.dart';

class EditProductDialog extends StatefulWidget {
  final OrderItem order;
  final Function(OrderItem) onClick;

  EditProductDialog({this.order, this.onClick});

  @override
  _EditProductDialogState createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  var price = TextEditingController();
  var quantity = TextEditingController();
  var remark = TextEditingController();
  OrderItem object;
  bool available = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    price.text = widget.order.price;
    quantity.text = widget.order.quantity;
    remark.text = widget.order.remark;
    available = widget.order.status == '0';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text(
          '${AppLocalizations.of(context).translate('edit_order_product')}'),
      actions: <Widget>[
        FlatButton(
          child: Text('${AppLocalizations.of(context).translate('cancel')}'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            '${AppLocalizations.of(context).translate('confirm')}',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            try {
              int.parse(quantity.text);
              double.parse(price.text);

              object.quantity = quantity.text;
              object.status = available ? '0' : '1';
              object.price = price.text;
              object.remark = remark.text;

              widget.onClick(object);
            } on FormatException {
              CustomToast(
                      '${AppLocalizations.of(context).translate('invalid_input')}',
                      context,
                      gravity: Toast.BOTTOM)
                  .show();
            }
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(object.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.orange,
                    ),
                    child: TextField(
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"^\d*\.?\d*")),
                        ],
                        controller: price,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context).translate('price')}',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          hintText: '0.00',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        )),
                  ),
                ),
                SizedBox(width: 10,),
                Expanded(
                  flex: 1,
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.orange,
                    ),
                    child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: quantity,
                        decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context).translate('quantity')}',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          hintText: '0',
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        )),
                  ),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              child: Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: TextField(
                    minLines: 1,
                    maxLines: 5,
                    controller: remark,
                    decoration: InputDecoration(
                      labelText:
                          '${AppLocalizations.of(context).translate('remark')}',
                      labelStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey,
                          fontWeight: FontWeight.bold),
                      hintText:
                          '${AppLocalizations.of(context).translate('remark')}',
                      border: new OutlineInputBorder(
                          borderSide: new BorderSide(color: Colors.teal)),
                    )),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Divider(
                color: Colors.teal.shade100,
                thickness: 1.0,
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                    '${AppLocalizations.of(context).translate('product_available')}'),
                Switch(
                  value: available,
                  onChanged: (value) {
                    setState(() {
                      available = value;
                    });
                  },
                  activeTrackColor: Colors.orangeAccent,
                  activeColor: Colors.deepOrangeAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
