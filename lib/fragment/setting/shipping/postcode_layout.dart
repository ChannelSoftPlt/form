import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/shippingSetting/postcode.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class PostcodeLayout extends StatefulWidget {
  final Function(String) callBack;

  @override
  _PostcodeLayoutState createState() => _PostcodeLayoutState();

  PostcodeLayout({this.callBack});
}

class _PostcodeLayoutState extends State<PostcodeLayout> {
  final key = new GlobalKey<ScaffoldState>();

  List<Postcode> postcode;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPostcodeSetting();
  }

  double countHeight() {
    switch (postcode.length) {
      case 0:
        return 120;
      default:
        return (80 + (postcode.length * 82)).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return postcode != null
        ? Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: countHeight(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: postcode.length,
                          itemBuilder: (context, position) {
                            return listViewItem(postcode[position], position);
                          },
                        ),
                      ),
                      Visibility(
                        visible: postcode.length <= 0,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.center,
                          child: Text(
                            '${AppLocalizations.of(context).translate(
                              'no_postcode_found',
                            )}',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      ),
                      ButtonBar(
                        children: [
                          RaisedButton(
                            elevation: 5,
                            onPressed: () =>
                                _showAddPostcodeDialog(context, false, null),
                            child: Text(
                              '${AppLocalizations.of(context).translate('add_postcode')}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                          RaisedButton(
                            elevation: 5,
                            onPressed: () => updatePostcodeSetting(),
                            child: Text(
                              '${AppLocalizations.of(context).translate('save')}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ],
                      )
                    ],
                  )),
            ),
          )
        : Center(child: CustomProgressBar());
  }

  Widget listViewItem(Postcode postcode, position) {
    return Container(
      height: 82,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Expanded(
                    flex: 2,
                    child: Text(
                      postcode.postcodeOne,
                      textAlign: TextAlign.start,
                    )),
                Expanded(
                    flex: 1,
                    child: Text(
                      AppLocalizations.of(context).translate('to'),
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      postcode.postcodeTwo,
                      textAlign: TextAlign.start,
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      'RM ' + postcode.shippingFee,
                      textAlign: TextAlign.start,
                      maxLines: 1,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () => deletePostcodeDialog(context, postcode),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () =>
                      _showAddPostcodeDialog(context, true, postcode),
                ),
              ]),
            ),
          )
        ],
      ),
    );
  }

  fetchPostcodeSetting() async {
    try {
      Map data = await Domain().readPostcodeSetting();
      if (data['status'] == '1') {
        setState(() {
          List responseJson =
              jsonDecode(data['postcode'][0]['shipping_by_postcode']);

          postcode = responseJson
              .map((jsonObject) => Postcode.fromJson(jsonObject))
              .toList();
        });
      }
    } catch ($e) {
      setState(() {
        postcode = [];
      });
    }
  }

  updatePostcodeSetting() async {
    if (postcode.length <= 0) {
      widget.callBack('postcode_required');
      return;
    }
    Map data = await Domain().updatePostcodeShipping(jsonEncode(postcode));
    if (data['status'] == '1') {
      widget.callBack('update_success');
    }
  }

  _showAddPostcodeDialog(
      BuildContext context, bool isUpdate, Postcode postcode) {
    TextEditingController postcodeOne = new TextEditingController();
    TextEditingController postcodeTwo = new TextEditingController();
    TextEditingController shippingFee = new TextEditingController();

    if (isUpdate) {
      postcodeOne.text = postcode.postcodeOne;
      postcodeTwo.text = postcode.postcodeTwo;
      shippingFee.text = postcode.shippingFee;
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text(
                  "${AppLocalizations.of(context).translate(isUpdate ? 'edit_postcode' : 'add_postcode')}"),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                      '${AppLocalizations.of(context).translate('cancel')}'),
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
                    if (postcodeOne.text.length < 5 ||
                        postcodeTwo.text.length < 5 ||
                        shippingFee.text.isEmpty) {
                      widget.callBack('invalid_input');
                    } else {
                      setState(() {
                        double fee = double.parse(shippingFee.text);
                        if (!isUpdate) {
                          this.postcode.add(new Postcode(
                              postcodeOne: postcodeOne.text,
                              postcodeTwo: postcodeTwo.text,
                              shippingFee: fee.toStringAsFixed(2)));
                        } else {
                          postcode.shippingFee = fee.toStringAsFixed(2);
                          postcode.postcodeOne = postcodeOne.text;
                          postcode.postcodeTwo = postcodeTwo.text;
                        }
                        Navigator.of(context).pop();
                      });
                    }
                  },
                ),
              ],
              content: Theme(
                data: new ThemeData(
                  primaryColor: Colors.orange,
                ),
                child: Container(
                    width: 2000,
                    height: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: postcodeOne,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"^\d*\.?\d*")),
                                ],
                                maxLength: 5,
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14),
                                  labelText:
                                      '${AppLocalizations.of(context).translate('postcode')}',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Colors.blueGrey),
                                  border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.teal)),
                                ),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Text(
                                  AppLocalizations.of(context).translate('to'),
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                )),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                maxLength: 5,
                                controller: postcodeTwo,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: false),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"^\d*\.?\d*")),
                                ],
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14),
                                  labelText:
                                      '${AppLocalizations.of(context).translate('postcode')}',
                                  labelStyle: TextStyle(
                                      fontSize: 14, color: Colors.blueGrey),
                                  border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.teal)),
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
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r"^\d*\.?\d*")),
                          ],
                          textAlign: TextAlign.start,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(fontSize: 14),
                            labelText:
                                '${AppLocalizations.of(context).translate('shipping_fee')}',
                            labelStyle:
                                TextStyle(fontSize: 14, color: Colors.blueGrey),
                            prefixText: 'RM',
                            prefixStyle:
                                TextStyle(fontSize: 14, color: Colors.black87),
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                      ],
                    )),
              ));
        });
  }

  deletePostcodeDialog(mainContext, Postcode postcode) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text(
              '${AppLocalizations.of(mainContext).translate('delete_postcode')}'),
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
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() {
                  widget.callBack('delete_success');
                  this.postcode.remove(postcode);
                });
              },
            ),
          ],
        );
      },
    );
  }
}
