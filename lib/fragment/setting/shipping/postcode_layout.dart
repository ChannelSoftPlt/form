import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my/object/shippingSetting/advance_shipping.dart';
import 'package:my/object/shippingSetting/postcode.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

import 'advance_shipping_dialog.dart';

class PostcodeLayout extends StatefulWidget {
  final Function(String) callBack;

  @override
  _PostcodeLayoutState createState() => _PostcodeLayoutState();

  PostcodeLayout({this.callBack});
}

class _PostcodeLayoutState extends State<PostcodeLayout> {
  final key = new GlobalKey<ScaffoldState>();
  List<Postcode> postcode;

  //for advance shipping purpose
  List<AdvanceShippingFee> advanceShipping;
  StreamController refreshSteam;

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
        return (80 + (postcode.length * 96)).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return postcode != null
        ? Padding(
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
                          onPressed: () => _showAddPostcodeDialog(
                              context, false, null, null),
                          child: Text(
                            '${AppLocalizations.of(context).translate('add_postcode')}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
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
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          color: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                      ],
                    )
                  ],
                )),
          )
        : Center(child: CustomProgressBar());
  }

  Widget listViewItem(Postcode postcode, position) {
    return Container(
      height: postcode.advanceShippingFee.length > 0 ? 100 : 82,
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Card(
            elevation: 5,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          flex: 2,
                          child: Text(
                            postcode.postcodeOne,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 12),
                          )),
                      Expanded(
                          flex: 1,
                          child: Text(
                            AppLocalizations.of(context).translate('to'),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            postcode.postcodeTwo,
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 12),
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'RM ' + postcode.shippingFee,
                            textAlign: TextAlign.start,
                            maxLines: 1,
                            style: TextStyle(
                                fontSize: 12, fontWeight: FontWeight.bold),
                          )),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () =>
                            deletePostcodeDialog(context, postcode),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => _showAddPostcodeDialog(
                            context, true, postcode, position),
                      ),
                    ]),
                    Visibility(
                      visible: postcode.advanceShippingFee.length > 0,
                      child: Text(
                        AppLocalizations.of(context)
                            .translate('advance_setting'),
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )),
          ),
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
      BuildContext context, bool isUpdate, Postcode postcode, position) {
    TextEditingController postcodeOne = new TextEditingController();
    TextEditingController postcodeTwo = new TextEditingController();
    TextEditingController shippingFee = new TextEditingController();
    refreshSteam = StreamController();
    advanceShipping = [];

    if (isUpdate) {
      postcodeOne.text = postcode.postcodeOne;
      postcodeTwo.text = postcode.postcodeTwo;
      shippingFee.text = postcode.shippingFee;
      advanceShipping = postcode.advanceShippingFee;
      refreshSteam.add('refresh');
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              insetPadding: EdgeInsets.fromLTRB(15, 0, 15, 20),
              title: Text(
                  "${AppLocalizations.of(context).translate(isUpdate ? 'edit_postcode' : 'add_postcode')}"),
              actions: <Widget>[
                TextButton(
                  child: Text(
                      '${AppLocalizations.of(context).translate('cancel')}'),
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
                    if (postcodeOne.text.length < 5 ||
                        postcodeTwo.text.length < 5 ||
                        shippingFee.text.isEmpty) {
                      widget.callBack('invalid_input');
                    } else {
                      if (checkInput(
                          postcodeOne.text, postcodeTwo.text, position))
                        setState(() {
                          double fee = double.parse(shippingFee.text);
                          if (!isUpdate) {
                            this.postcode.add(new Postcode(
                                postcodeOne: postcodeOne.text,
                                postcodeTwo: postcodeTwo.text,
                                shippingFee: fee.toStringAsFixed(2),
                                advanceShippingFee: advanceShipping));
                          } else {
                            postcode.shippingFee = fee.toStringAsFixed(2);
                            postcode.postcodeOne = postcodeOne.text;
                            postcode.postcodeTwo = postcodeTwo.text;
                            postcode.advanceShippingFee = advanceShipping;
                          }
                          Navigator.of(context).pop();
                        });
                    }
                  },
                ),
              ],
              content: SingleChildScrollView(
                child: Container(
                    width: 2000,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                                '${AppLocalizations.of(context).translate('default_fee')}',
                            labelStyle:
                                TextStyle(fontSize: 14, color: Colors.blueGrey),
                            prefixText: 'RM',
                            prefixStyle:
                                TextStyle(fontSize: 14, color: Colors.black87),
                            border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.teal)),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLocalizations.of(context).translate('advance_setting')}',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  showAdvanceSettingDialog(context, null),
                              child: Text(
                                AppLocalizations.of(context)
                                    .translate('add_condition'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                              style: ElevatedButton.styleFrom(
                                  primary: Colors.black54),
                            )
                          ],
                        ),
                        Text(
                          AppLocalizations.of(context)
                              .translate('condition_description'),
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        StreamBuilder(
                            stream: refreshSteam.stream,
                            builder: (context, object) {
                              if (object.hasData &&
                                  object.data.toString().length >= 1) {
                                if (advanceShipping != null &&
                                    advanceShipping.length > 0)
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: advanceShipping.length,
                                    itemBuilder: (context, position) {
                                      return advancedShippingItem(
                                          advanceShipping[position], position);
                                    },
                                  );
                              }
                              return Container(
                                height: 80,
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)
                                      .translate('no_condition'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 12),
                                ),
                              );
                            })
                      ],
                    )),
              ));
        });
  }

  Widget advancedShippingItem(AdvanceShippingFee object, position) {
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
                      ' RM' + object.totalFee_1,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12),
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
                      ' RM' + object.totalFee_2,
                      textAlign: TextAlign.start,
                      style: TextStyle(fontSize: 12),
                      maxLines: 1,
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      'RM ' + object.shippingFee,
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 1,
                    child: advancedShippingActionMenu(context, object)),
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget advancedShippingActionMenu(context, object) {
    return new PopupMenuButton(
      icon: Icon(
        Icons.settings,
        color: Colors.black54,
      ),
      offset: Offset(0, 10),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text(AppLocalizations.of(context).translate('edit')),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(AppLocalizations.of(context).translate('delete')),
        )
      ],
      onCanceled: () {},
      onSelected: (value) {
        if (value == 'edit')
          showAdvanceSettingDialog(context, object);
        else
          deleteAdvanceSettingDialog(context, object);
      },
    );
  }

  showAdvanceSettingDialog(mainContext, AdvanceShippingFee object) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        return AdvanceShippingDialog(
          advanceShippingFee: object,
          isUpdate: object != null,
          showSnack: (msg) => widget.callBack(msg),
          callBack: (AdvanceShippingFee result) {
            print(result);
            if (object == null) {
              advanceShipping.add(result);
            } else {
              object.totalFee_1 = result.totalFee_1;
              object.totalFee_2 = result.totalFee_2;
              object.shippingFee = result.shippingFee;
            }
            refreshSteam.add('refresh');
          },
        );
      },
    );
  }

  deleteAdvanceSettingDialog(mainContext, AdvanceShippingFee object) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text(
              '${AppLocalizations.of(mainContext).translate('delete_distance')}'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                widget.callBack('delete_success');
                this.advanceShipping.remove(object);
                refreshSteam.add('refresh');
              },
            ),
          ],
        );
      },
    );
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
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
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

  bool checkInput(fromPostcode, toPostcode, position) {
    try {
      int postcode1 = int.parse(fromPostcode);
      int postcode2 = int.parse(toPostcode);
      if (postcode1 >= postcode2) {
        widget.callBack('invalid_postcode');
        return false;
      }

      for (int i = 0; i < postcode.length; i++) {
        //if is update then no need to compare with the same position
        if (position != null && i == position) {
          continue;
        }

        if (postcode1 >= int.parse(postcode[i].postcodeOne) &&
            postcode2 <= int.parse(postcode[i].postcodeTwo)) {
          widget.callBack('overlay_postcode');
          return false;
        }

        if (postcode1 <= int.parse(postcode[i].postcodeOne) &&
            postcode2 >= int.parse(postcode[i].postcodeTwo)) {
          widget.callBack('overlay_postcode');
          return false;
        }

        if (position != null && i + 1 <= postcode.length && i > position) {
          if (postcode2 > int.parse(postcode[i].postcodeOne)) {
            widget.callBack('overlay_postcode');
            return false;
          }
        }

        if (position != null && i < position) {
          if (postcode1 < int.parse(postcode[i].postcodeTwo)) {
            widget.callBack('overlay_postcode');
            return false;
          }
        }
      }
    } catch ($e) {
      return false;
    }
    return true;
  }
}
