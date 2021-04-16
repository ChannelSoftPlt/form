import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:my/object/shippingSetting/east_west.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/utils/domain.dart';

class EastWestLayout extends StatefulWidget {
  @override
  _EastWestLayoutState createState() => _EastWestLayoutState();
}

class _EastWestLayoutState extends State<EastWestLayout> {
  final key = new GlobalKey<ScaffoldState>();
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
        ? Card(
            margin: EdgeInsets.all(15),
            elevation: 5,
            child: Container(
              height: 300,
              child: Column(
                children: [],
              ),
            ),
          )
        : Center(child: CustomProgressBar());
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
