import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order_item.dart';
import 'package:my/shareWidget/toast.dart';
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
  OrderItem object;
  bool available = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    object = widget.order;
    price.text = widget.order.price;
    quantity.text = widget.order.quantity;
    available = widget.order.status == '0';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Edit Order Product'),
      actions: <Widget>[
        FlatButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        FlatButton(
          child: Text(
            'Confirm',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            try {
              int.parse(quantity.text);
              double.parse(price.text);

              object.quantity = quantity.text;
              object.status = available ? '0' : '1';
              object.price = price.text;

              widget.onClick(object);
            } on FormatException {
              CustomToast('Invalid input! 输入不正确!', context,
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
            Image.network(
              'https://petkeeper.com.my/demo1/wp-content/uploads/2017/11/h1-300x300.jpg',
              height: 80,
            ),
            Text(object.name, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 50,
                  child: Theme(
                    data: new ThemeData(
                      primaryColor: Colors.orange,
                    ),
                    child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                        ],
                        controller: price,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'Price',
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
                Container(
                  width: 100,
                  height: 50,
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
                          labelText: 'Quantity',
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
              height: 5,
            ),
            Row(
              children: <Widget>[
                Text('Product Available'),
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
