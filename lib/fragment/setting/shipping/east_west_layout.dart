import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:my/object/shippingSetting/east_west.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class EastWestLayout extends StatefulWidget {
  final Function(String) callBack;

  @override
  _EastWestLayoutState createState() => _EastWestLayoutState();

  EastWestLayout({this.callBack});
}

class _EastWestLayoutState extends State<EastWestLayout> {
  final key = new GlobalKey<ScaffoldState>();

  List<TextEditingController> flatRate1s = new List();
  List<TextEditingController> flatRate2s = new List();
  List<TextEditingController> breakPoints = new List();
  var flat = TextEditingController();
  List<EastWest> eastWest;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchEastWestSetting();
  }

  @override
  Widget build(BuildContext context) {
    return eastWest != null
        ? Container(
            height: 750,
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              itemCount: eastWest.length,
              itemBuilder: (context, position) {
                flatRate1s.add(new TextEditingController());
                flatRate2s.add(new TextEditingController());
                breakPoints.add(new TextEditingController());

                flatRate1s[position].text = eastWest[position].firstFee;
                flatRate2s[position].text = eastWest[position].secondFee;
                breakPoints[position].text = eastWest[position].pricePoint;

                return listViewItem(eastWest[position], position);
              },
            ))
        : Center(child: CustomProgressBar());
  }

  Widget listViewItem(EastWest eastWest, position) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Card(
          elevation: 3,
          key: Key(eastWest.id.toString()),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Text(
                    AppLocalizations.of(context).translate(eastWest.region),
                    style: TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  value: eastWest.status == '0',
                  onChanged: (newValue) {
                    setState(() {
                      eastWest.status = newValue ? '0' : '1';
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.trailing, //  <-- leading Checkbox
                ),
                TextField(
                  controller: flatRate1s[position],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    labelText:
                        '${AppLocalizations.of(context).translate('flat_rate_1')}',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    prefixText: 'RM',
                    prefixStyle: TextStyle(fontSize: 14, color: Colors.black87),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      '${AppLocalizations.of(context).translate('break_point_description')}',
                      style: TextStyle(fontSize: 12),
                    )),
                    Expanded(
                      child: TextField(
                        controller: breakPoints[position],
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
                              '${AppLocalizations.of(context).translate('break_point')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          prefixText: 'RM',
                          prefixStyle:
                              TextStyle(fontSize: 14, color: Colors.black87),
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
                  controller: flatRate2s[position],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 14),
                    labelText:
                        '${AppLocalizations.of(context).translate('flat_rate_2')}',
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
                Container(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: 40.0,
                    child: RaisedButton(
                      elevation: 5,
                      onPressed: () {
                        updateEastWestShipping(eastWest, position);
                      },
                      child: Text(
                        '${AppLocalizations.of(context).translate('update_setting')}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.orange,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 5,
        )
      ],
    );
  }

  fetchEastWestSetting() async {
    Map data = await Domain().readEastWestSetting();
    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['east_west'];

        eastWest = responseJson
            .map((jsonObject) => EastWest.fromJson(jsonObject))
            .toList();

        print('size: ' + eastWest.length.toString());
      });
    }
  }

  updateEastWestShipping(EastWest eastWest, position) async {
    eastWest.firstFee =
        flatRate1s[position].text.isEmpty ? 0 : flatRate1s[position].text;

    eastWest.secondFee =
        flatRate2s[position].text.isEmpty ? '0' : flatRate2s[position].text;

    eastWest.pricePoint =
        breakPoints[position].text.isEmpty ? '0' : breakPoints[position].text;

    Map data = await Domain().updateEastWestShipping(eastWest);
    if (data['status'] == '1') {
      widget.callBack('update_success');
    }
  }
}
