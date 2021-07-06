import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:my/fragment/setting/shipping/advance_shipping_dialog.dart';
import 'package:my/object/shippingSetting/advance_shipping.dart';
import 'package:my/object/shippingSetting/distance.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';
import 'package:my/utils/sharePreference.dart';

class DistanceLayout extends StatefulWidget {
  final Function(String) callBack;

  @override
  _DistanceLayoutState createState() => _DistanceLayoutState();

  DistanceLayout({this.callBack});
}

class _DistanceLayoutState extends State<DistanceLayout> {
  final key = new GlobalKey<ScaffoldState>();
  TextEditingController address = new TextEditingController();
  List<Distance> distance;
  bool avoidToll = false;

  //for advance shipping purpose
  List<AdvanceShippingFee> advanceShipping;
  StreamController refreshSteam;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDistanceSetting();
  }

  double countHeight() {
    switch (distance.length) {
      case 0:
        return 330;
      default:
        return (300 + (distance.length * 96)).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return distance != null
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                height: countHeight(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Card(
                      elevation: 2,
                      child: CheckboxListTile(
                        title: Text(
                          "${AppLocalizations.of(context).translate('avoid_tol')}",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          '${AppLocalizations.of(context).translate('avoid_tol_description')}',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        value: avoidToll,
                        onChanged: (newValue) {
                          setState(() {
                            avoidToll = newValue;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .trailing, //  <-- leading Checkbox
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      controller: address,
                      textAlign: TextAlign.start,
                      minLines: 3,
                      maxLines: 5,
                      maxLengthEnforced: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.location_on),
                        labelText:
                            '${AppLocalizations.of(context).translate('merchant_address')}',
                        labelStyle:
                            TextStyle(fontSize: 16, color: Colors.blueGrey),
                        hintText:
                            '${AppLocalizations.of(context).translate('full_address')}',
                        border: new OutlineInputBorder(
                            borderSide: new BorderSide(color: Colors.teal)),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${AppLocalizations.of(context).translate('merchant_address_description')}',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 13),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: distance.length,
                        itemBuilder: (context, position) {
                          return listViewItem(distance[position], position);
                        },
                      ),
                    ),
                    Visibility(
                      visible: distance.length <= 0,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.center,
                        child: Text(
                          '${AppLocalizations.of(context).translate(
                            'no_distance_found',
                          )}',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    ButtonBar(
                      children: [
                        RaisedButton(
                          elevation: 5,
                          onPressed: () => _showAddDistanceDialog(
                              context, false, null, null),
                          child: Text(
                            '${AppLocalizations.of(context).translate('add_distance')}',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          color: Colors.orange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                        ),
                        RaisedButton(
                          elevation: 5,
                          onPressed: () => updateDistanceSetting(),
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

  Widget listViewItem(Distance distance, position) {
    return Container(
      height: distance.advanceShippingFee.length > 0 ? 100 : 82,
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
                            distance.distanceOne + ' KM',
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
                            distance.distanceTwo + ' KM',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 12),
                          )),
                      Expanded(
                          flex: 2,
                          child: Text(
                            'RM ' + distance.shippingFee,
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
                            deleteDistanceDialog(context, distance),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => _showAddDistanceDialog(
                            context, true, distance, position),
                      ),
                    ]),
                    Visibility(
                      visible: distance.advanceShippingFee.length > 0,
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
          )
        ],
      ),
    );
  }

  fetchDistanceSetting() async {
    try {
      Map data = await Domain().readDistanceSetting();
      if (data['status'] == '1') {
        setState(() {
          print(data);

          List responseJson =
              jsonDecode(data['distance'][0]['shipping_by_distance']);

          distance = responseJson
              .map((jsonObject) => Distance.fromJson(jsonObject))
              .toList();

          print(data['distance'][0]['distance_shipping_avoid_tolls']);

          avoidToll =
              data['distance'][0]['distance_shipping_avoid_tolls'].toString() ==
                      'false'
                  ? false
                  : true;

          address.text = data['distance'][0]['address_long_lat'];
        });
      }
    } catch ($e) {
      setState(() {
        distance = [];
      });
    }
  }

  updateDistanceSetting() async {
    if (address.text.isEmpty) {
      widget.callBack('address_missing');
      return;
    }
    if (distance.length <= 0) {
      widget.callBack('distance_required');
      return;
    }
    try {
      String apiKey = await SharePreferences().read('google_api_key');
      var addresses =
          await Geocoder.google(apiKey).findAddressesFromQuery(address.text);

      var addressCoordinate = addresses.first;

      Map data = await Domain().updateDistanceShipping(
          jsonEncode(distance),
          address.text,
          addressCoordinate.coordinates.longitude.toString(),
          addressCoordinate.coordinates.latitude.toString(),
          avoidToll.toString());

      if (data['status'] == '1') {
        widget.callBack('update_success');
      }
    } catch ($e) {
      print($e);
      widget.callBack('invalid_address');
    }
  }

  Future<void> _showAddDistanceDialog(
      BuildContext context, bool isUpdate, Distance distance, position) {
    TextEditingController distanceOne = new TextEditingController();
    TextEditingController distanceTwo = new TextEditingController();
    TextEditingController shippingFee = new TextEditingController();
    refreshSteam = StreamController();
    advanceShipping = [];

    if (isUpdate) {
      distanceOne.text = distance.distanceOne;
      distanceTwo.text = distance.distanceTwo;
      shippingFee.text = distance.shippingFee;
      advanceShipping = distance.advanceShippingFee;
      refreshSteam.add('refresh');
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 0),
              insetPadding: EdgeInsets.fromLTRB(15, 0, 15, 20),
              title: Text(
                  "${AppLocalizations.of(context).translate('edit_distance')}"),
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
                    if (distanceOne.text.isEmpty ||
                        distanceTwo.text.isEmpty ||
                        shippingFee.text.isEmpty) {
                      widget.callBack('invalid_input');
                    } else {
                      if (checkInput(
                          distanceOne.text, distanceTwo.text, position))
                        setState(() {
                          double fee = double.parse(shippingFee.text);
                          if (!isUpdate) {
                            this.distance.add(new Distance(
                                distanceOne: distanceOne.text,
                                distanceTwo: distanceTwo.text,
                                shippingFee: fee.toStringAsFixed(2),
                                advanceShippingFee: advanceShipping));
                          } else {
                            distance.shippingFee = fee.toStringAsFixed(2);
                            distance.distanceOne = distanceOne.text;
                            distance.distanceTwo = distanceTwo.text;
                            distance.advanceShippingFee = advanceShipping;
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
                                controller: distanceOne,
                                textAlign: TextAlign.start,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"^\d*\.?\d*")),
                                ],
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14),
                                  labelText:
                                      '${AppLocalizations.of(context).translate('distance_label')}',
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
                                controller: distanceTwo,
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r"^\d*\.?\d*")),
                                ],
                                textAlign: TextAlign.start,
                                decoration: InputDecoration(
                                  hintStyle: TextStyle(fontSize: 14),
                                  labelText:
                                      '${AppLocalizations.of(context).translate('distance_label')}',
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
                                    physics: NeverScrollableScrollPhysics(),
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

  deleteDistanceDialog(mainContext, Distance distance) {
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text(
              '${AppLocalizations.of(mainContext).translate('delete_distance')}'),
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
                  this.distance.remove(distance);
                });
              },
            ),
          ],
        );
      },
    );
  }

  bool checkInput(fromDistance, toDistance, position) {
    try {
      double distance1 = double.parse(fromDistance);
      double distance2 = double.parse(toDistance);
      if (distance1 >= distance2) {
        widget.callBack('invalid_distance');
        return false;
      }
      for (int i = 0; i < distance.length; i++) {
        //if is update then no need to compare with the same position
        if (position != null && i == position) {
          continue;
        }

        if (distance1 >= double.parse(distance[i].distanceOne) &&
            distance2 <= double.parse(distance[i].distanceTwo)) {
          widget.callBack('overlay_distance');
          return false;
        }

        if (distance1 <= double.parse(distance[i].distanceOne) &&
            distance2 >= double.parse(distance[i].distanceTwo)) {
          widget.callBack('overlay_distance');
          return false;
        }

        if (position != null && i + 1 <= distance.length && i > position) {
          if (distance2 > double.parse(distance[i].distanceOne)) {
            widget.callBack('overlay_distance');
            return false;
          }
        }

        if (position != null && i < position) {
          if (distance1 < double.parse(distance[i].distanceTwo)) {
            widget.callBack('overlay_distance');
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
