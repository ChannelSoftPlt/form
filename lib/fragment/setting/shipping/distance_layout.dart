import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchDistanceSetting();
  }

  double countHeight() {
    switch (distance.length) {
      case 0:
        return 205;
      default:
        return (205 + (distance.length * 82)).toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return distance != null
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
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 13),
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
                            onPressed: () =>
                                _showAddDistanceDialog(context, false, null),
                            child: Text(
                              '${AppLocalizations.of(context).translate('add_distance')}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
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

  Widget listViewItem(Distance distance, position) {
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
                      distance.distanceOne + ' KM',
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
                      distance.distanceTwo + ' KM',
                      textAlign: TextAlign.start,
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      'RM ' + distance.shippingFee,
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
                  onPressed: () => deleteDistanceDialog(context, distance),
                ),
                IconButton(
                  icon: Icon(
                    Icons.edit,
                    color: Colors.blueGrey,
                  ),
                  onPressed: () =>
                      _showAddDistanceDialog(context, true, distance),
                ),
              ]),
            ),
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
          List responseJson =
              jsonDecode(data['distance'][0]['shipping_by_distance']);

          distance = responseJson
              .map((jsonObject) => Distance.fromJson(jsonObject))
              .toList();

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
          addressCoordinate.coordinates.latitude.toString());

      if (data['status'] == '1') {
        widget.callBack('update_success');
      }
    } catch ($e) {
      widget.callBack('invalid_address');
    }
  }

  Future<void> _showAddDistanceDialog(
      BuildContext context, bool isUpdate, Distance distance) {
    TextEditingController distanceOne = new TextEditingController();
    TextEditingController distanceTwo = new TextEditingController();
    TextEditingController shippingFee = new TextEditingController();

    if (isUpdate) {
      distanceOne.text = distance.distanceOne;
      distanceTwo.text = distance.distanceTwo;
      shippingFee.text = distance.shippingFee;
    }

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
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
                      setState(() {
                        double fee = double.parse(shippingFee.text);
                        if (!isUpdate) {
                          this.distance.add(new Distance(
                              distanceOne: distanceOne.text,
                              distanceTwo: distanceTwo.text,
                              shippingFee: fee.toStringAsFixed(2)));
                        } else {
                          distance.shippingFee = fee.toStringAsFixed(2);
                          distance.distanceOne = distanceOne.text;
                          distance.distanceTwo = distanceTwo.text;
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: distanceOne,
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

  deleteDistanceDialog(mainContext, Distance distance) {
    // flutter defined function
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
}
