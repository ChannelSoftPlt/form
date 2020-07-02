import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/order.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/utils/domain.dart';
import 'package:toast/toast.dart';

class EditAddressDialog extends StatefulWidget {
  final Order order;
  final Function(Order) onClick;

  EditAddressDialog({this.order, this.onClick});

  @override
  _EditAddressDialogState createState() => _EditAddressDialogState();
}

class _EditAddressDialogState extends State<EditAddressDialog> {
  var address = TextEditingController();
  var postcode = TextEditingController();
  var city = TextEditingController();
  var state = TextEditingController();
  Order order;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    address.text = widget.order.address;
    postcode.text = widget.order.postcode;
    city.text = widget.order.city;
    state.text = widget.order.state;

    order = widget.order;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: new Text('Edit Address'),
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
            if (address.text.length > 0 &&
                postcode.text.length > 0 &&
                city.text.length > 0 &&
                state.text.length > 0) {
              order.address = address.text;
              order.postcode = postcode.text;
              order.city = city.text;
              order.state = state.text;
              widget.onClick(order);
            } else
              CustomToast('Invalid input! 输入不正确!', context,
                      gravity: Toast.BOTTOM)
                  .show();
          },
        ),
      ],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Theme(
              data: new ThemeData(
                primaryColor: Colors.orange,
              ),
              child: TextField(
                  keyboardType: TextInputType.multiline,
                  controller: address,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                    hintText: 'Delivery Address 送货地址',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
            ),
            SizedBox(
              height: 10,
            ),
            Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
                  controller: postcode,
                  maxLength: 5,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Postcode',
                    labelStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold),
                    hintText: '81100',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  ),
                  onChanged: (text) {
                    if (text.length >= 5) {
                      fetchPostcodeDetails(text);
                    }
                  },
                )),
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
                        enabled: false,
                        style: TextStyle(fontSize: 12),
                        keyboardType: TextInputType.text,
                        controller: city,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'City',
                          labelStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          hintText: '81100',
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
                        enabled: false,
                        style: TextStyle(fontSize: 12),
                        keyboardType: TextInputType.text,
                        controller: state,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'State',
                          labelStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold),
                          hintText: 'Johor',
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  fetchPostcodeDetails(text) async {
    Map data = await Domain().fetchPostcodeDetails(text);
//    print(text);
    if (data['status'] == '1') {
      state.text = data['postcode'][0]['state'];
      city.text = data['postcode'][0]['city'];
    } else {
      state.text = '-';
      city.text = '-';
    }
  }
}
