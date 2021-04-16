import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my/object/shippingSetting/east_west.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class EastWestLayout extends StatefulWidget {
  @override
  _EastWestLayoutState createState() => _EastWestLayoutState();
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
        ? Theme(
            data: new ThemeData(
              primaryColor: Colors.orange,
            ),
            child: Container(
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
                )),
          )
        : Center(child: CustomProgressBar());
  }

  Widget listViewItem(EastWest eastWest, position) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Card(
          key: Key(eastWest.id.toString()),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CheckboxListTile(
                  title: Text(
                    AppLocalizations.of(context).translate(eastWest.region),
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
                  value: eastWest.status == '1',
                  onChanged: (newValue) {
                    setState(() {
                      eastWest.status = newValue ? '1' : '0';
                    });
                  },
                  controlAffinity:
                      ListTileControlAffinity.trailing, //  <-- leading Checkbox
                ),
                TextField(
                  controller: flatRate1s[position],
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
                TextField(
                  controller: flatRate1s[position],
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
              ],
            ),
          ),
        ),
        SizedBox(
          height: 10,
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
}
