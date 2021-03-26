import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my/fragment/product/variant/add_variant_group.dart';
import 'package:my/fragment/product/variant/variant_list_view.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/translation/AppLocalizations.dart';

import 'duplicate_variant_dialog.dart';

class VariantLayout extends StatefulWidget {
  final Function(String) onChange;
  final String variant;

  VariantLayout({this.onChange, this.variant});

  @override
  _VariantLayoutState createState() => _VariantLayoutState();
}

class _VariantLayoutState extends State<VariantLayout> {
  StreamController controller;
  List<VariantGroup> variant = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = StreamController();
    controller.add('display');
    if (widget.variant != '') {
      setupData(widget.variant);
    }
  }

  void setupData(String variantData) {
    try {
      List data = jsonDecode(variantData);
      variant.addAll(
          data.map((jsonObject) => VariantGroup.fromJson(jsonObject)).toList());
    } catch ($e) {
      print($e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(elevation: 5, child: mainContent(context));
  }

  Widget mainContent(context) {
    return StreamBuilder(
        stream: controller.stream,
        builder: (context, object) {
          if (object.hasData && object.data.toString().length >= 1) {
            return content();
          }
          return CustomProgressBar();
        });
  }

  Widget content() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 0, 8),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context).translate('product_variant')}',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(
              height: 10,
            ),
            Visibility(visible: variant.length > 0, child: customListView()),
            SizedBox(
              height: 10,
            ),
            Column(
              children: [
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: [
                    OutlineButton(
                      onPressed: () {
                        showDuplicateDialog(context);
                      },
                      borderSide: BorderSide(
                        color: Colors.red,
                        style: BorderStyle.solid,
                      ),
                      child: Text(
                        '${AppLocalizations.of(context).translate('duplicate_variant')}',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                      color: Colors.orange,
                    ),
                    RaisedButton(
                      elevation: 2,
                      onPressed: () => showAddVariantGroup(false, null),
                      child: Text(
                        '${AppLocalizations.of(context).translate('create_variant')}',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      color: Colors.orange,
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  showDuplicateDialog(mainContext) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return DuplicateDialog(
          duplicateVariant: (variation) {
            setState(() {
              setupData(variation);
              widget.onChange(variation);
              _showSnackBar('duplicate_success');
            });
          },
        );
      },
    );
  }

  Future<void> showAddVariantGroup(bool update, int position) async {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => AddVariantGroup(
                isUpdate: update,
                variantGroup: update ? variant[position] : null,
                onClick: (VariantGroup variantGroup, action) {
                  setState(() {
                    if (action == 'create') {
                      variant.add(variantGroup);
                      _showSnackBar('create_success');
                    } else if (action == 'update') {
                      variant[position] = variantGroup;
                      _showSnackBar('update_success');
                    } else {
                      variant.removeAt(position);
                      _showSnackBar('delete_success');
                    }
                  });
                  widget.onChange(jsonEncode(variant));
                },
              )),
    );
  }

  countHeight() {
    var height = 120 * variant.length;
    //count child size
    for (int i = 0; i < variant.length; i++) {
      if (variant[i].variantChild != null &&
          variant[i].variantChild.length > 0) {
        height = height + (25 * variant[i].variantChild.length);
      }
    }
    return height.toDouble();
  }

  Widget customListView() {
    return Container(
      height: countHeight(),
      child: ReorderableListView(
        padding: EdgeInsets.zero,
        children: variant
            .asMap()
            .map((index, variantChild) => MapEntry(
                index,
                VariantListItem(
                  key: ValueKey(index),
                  variantGroup: variant[index],
                  onClick: (action) {
                    if (action == 'delete') {
                      deleteVariant(index);
                    } else {
                      showAddVariantGroup(true, index);
                    }
                  },
                )))
            .values
            .toList(),
        onReorder: _onReorder,
      ),
    );
  }

  _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > variant.length) newIndex = variant.length;
      if (oldIndex < newIndex) newIndex--;

      VariantGroup child = variant[oldIndex];
      variant.removeAt(oldIndex);
      variant.insert(newIndex, child);
      _showSnackBar('update_category_sequence');
    });
  }

  deleteVariant(int position) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('delete_message')}"),
          actions: <Widget>[
            FlatButton(
              child:
                  Text('${AppLocalizations.of(context).translate('cancel')}'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                '${AppLocalizations.of(context).translate('confirm')}',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                setState(() {
                  variant.removeAt(position);
                  _showSnackBar('delete_success');
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  _showSnackBar(message) {
    Scaffold.of(context).showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 500),
      content: new Text(AppLocalizations.of(context).translate(message)),
    ));
  }
}
