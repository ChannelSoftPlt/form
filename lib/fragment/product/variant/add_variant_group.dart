import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my/fragment/product/variant/variant_child_list_view.dart';
import 'package:my/object/category.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/translation/AppLocalizations.dart';

class AddVariantGroup extends StatefulWidget {
  final Function(VariantGroup, String) onClick;
  final bool isUpdate;
  final VariantGroup variantGroup;

  AddVariantGroup({this.onClick, this.isUpdate, this.variantGroup});

  @override
  _AddVariantGroupState createState() => _AddVariantGroupState();
}

class _AddVariantGroupState extends State<AddVariantGroup> {
  Category category;
  bool multipleChoose = false;

  //1 = compulsory, 0 = optional
  bool isCompulsory = false;

  var variantGroupLabel = TextEditingController();
  final key = new GlobalKey<ScaffoldState>();

  var childLabel = TextEditingController();
  var price = TextEditingController();

  List<VariantChild> variantChilds = [];
  bool updateChild = false;
  VariantChild selectItem;
  BuildContext myContext;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isUpdate) {
      variantGroupLabel.text = widget.variantGroup.groupName;
      multipleChoose = widget.variantGroup.type == 0;
      isCompulsory = widget.variantGroup.option == 1;
      variantChilds = widget.variantGroup.variantChild;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      appBar: AppBar(
        brightness: Brightness.dark,
        title: Text(
          '${AppLocalizations.of(context).translate('variant_group')}',
          style: GoogleFonts.cantoraOne(
            textStyle: TextStyle(
                color: Colors.orangeAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        actions: <Widget>[
          Visibility(
            visible: widget.isUpdate,
            child: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.red[200],
              ),
              onPressed: () {
                deleteVariant();
              },
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.orangeAccent,
            ),
            onPressed: () {
              save();
            },
          )
        ],
      ),
      body: mainContent(context),
    );
  }

  save() {
    if (variantGroupLabel.text.isEmpty) {
      _showSnackBar('all_field_required');
      return;
    }
    if (variantChilds.length <= 0) {
      _showSnackBar('no_variation_found');
      return;
    }
    widget.onClick(
        VariantGroup(
            groupName: variantGroupLabel.text,
            type: multipleChoose ? 0 : 1,
            option: isCompulsory ? 1 : 0,
            variantChild: variantChilds),
        !widget.isUpdate ? 'create' : 'update');

    Navigator.of(context).pop();
  }

  Widget mainContent(context) {
    return Theme(
      data: new ThemeData(
        primaryColor: Colors.orange,
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextField(
                        keyboardType: TextInputType.text,
                        controller: variantGroupLabel,
                        textAlign: TextAlign.start,
                        decoration: InputDecoration(
                          labelText:
                              '${AppLocalizations.of(context).translate('group_name')}',
                          labelStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          hintText:
                              '${AppLocalizations.of(context).translate('size')}',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Colors.blueGrey),
                          border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.teal)),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).translate('compulsory')}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Switch(
                          value: isCompulsory,
                          onChanged: (value) {
                            setState(() {
                              isCompulsory = value;
                            });
                          },
                          activeTrackColor: Colors.orangeAccent,
                          activeColor: Colors.deepOrangeAccent,
                        ),
                      ],
                    ),
                    Text(
                      '${AppLocalizations.of(context).translate('compulsory_description')}',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${AppLocalizations.of(context).translate('multiple_select')}',
                          style: TextStyle(fontSize: 14),
                        ),
                        Switch(
                          value: multipleChoose,
                          onChanged: (value) {
                            setState(() {
                              multipleChoose = value;
                            });
                          },
                          activeTrackColor: Colors.orangeAccent,
                          activeColor: Colors.deepOrangeAccent,
                        ),
                      ],
                    ),
                    Text(
                      '${AppLocalizations.of(context).translate('multiple_select_description')}',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    addVariantChild(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget addVariantChild() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${AppLocalizations.of(context).translate('variant_item')}',
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                  keyboardType: TextInputType.text,
                  controller: childLabel,
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5.0),
                    labelText:
                        '${AppLocalizations.of(context).translate('item')}',
                    labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    hintText:
                        '${AppLocalizations.of(context).translate('item_name')}',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              flex: 2,
              child: TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r"^\d*\.?\d*")),
                  ],
                  style: TextStyle(fontSize: 13),
                  controller: price,
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(5.0),
                    labelText:
                        '${AppLocalizations.of(context).translate('price')}',
                    labelStyle: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    hintText: '0.00',
                    hintStyle: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: Colors.teal)),
                  )),
            )
          ],
        ),
        Container(
          alignment: Alignment.bottomRight,
          child: ButtonBar(
            children: [
              OutlineButton(
                onPressed: () {
                  setState(() {
                    childLabel.clear();
                    price.clear();
                    updateChild = false;
                  });
                },
                child: Text(
                  '${AppLocalizations.of(context).translate('clear')}',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                ),
                color: Colors.red,
                borderSide: BorderSide(
                  color: Colors.red,
                  style: BorderStyle.solid,
                ),
              ),
              RaisedButton(
                elevation: 2,
                onPressed: () {
                  setState(() {
                    setVariantChild();
                  });
                },
                child: Text(
                  '${AppLocalizations.of(context).translate(!updateChild ? 'add' : 'update')}',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                color: Colors.orange,
              ),
            ],
          ),
        ),
        variantChildListView()
      ],
    );
  }

  setVariantChild() {
    /**
     * add new variant child
     * */
    if (childLabel.text.isEmpty || price.text.isEmpty) {
      _showSnackBar('all_field_required');
      return;
    }
    try {
      double finalPrice = double.parse(price.text);
      // String price = singleProductTotal.toStringAsFixed(2);
      if (!updateChild) {
        variantChilds.add(VariantChild(
            name: childLabel.text, price: finalPrice.toStringAsFixed(2)));
      }
      /**
       * update variant child
       * */
      else {
        variantChilds.remove(selectItem);
        variantChilds.insert(
            0,
            VariantChild(
                name: childLabel.text, price: finalPrice.toStringAsFixed(2)));
      }
      _showSnackBar(!updateChild ? 'add_success' : 'update_success');
      updateChild = false;
      childLabel.clear();
      price.clear();
    } catch ($e) {
      _showSnackBar('something_went_wrong');
    }
  }

  Widget variantChildListView() {
    return Container(
        child: variantChilds.length > 0
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 5,
                            child: Text(
                              '${AppLocalizations.of(context).translate('item')}',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            )),
                        Expanded(
                            flex: 2,
                            child: Text(
                                '${AppLocalizations.of(context).translate('price')}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: SizedBox()),
                      ],
                    ),
                  ),
                  customListView()
                ],
              )
            : Center(
                child: Text(
                    '${AppLocalizations.of(context).translate('no_item_found')}',
                    style: TextStyle(fontSize: 14, color: Colors.blueGrey))));
  }

  double countHeight() {
    double height = (variantChilds.length * 70).toDouble();
    print('height height:  $height');
    return height;
  }

  Widget customListView() {
    return Container(
      height: countHeight(),
      child: ReorderableListView(
        children: variantChilds
            .asMap()
            .map((index, variantChild) => MapEntry(
                index,
                VariantChildListView(
                  key: ValueKey(index),
                  variantChild: variantChild,
                  onClick: (VariantChild variantChild, onClick) {
                    /*
               * delete variant child
                * */
                    if (onClick == 'delete') {
                      setState(() {
                        variantChilds.remove(variantChild);
                        _showSnackBar('delete_success');
                      });
                    }
                    /*
               * update variant
               * */
                    else {
                      setState(() {
                        updateChild = true;
                        selectItem = variantChild;
                        childLabel.text = variantChild.name;
                        price.text = variantChild.price;
                      });
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
      if (newIndex > variantChilds.length) newIndex = variantChilds.length;
      if (oldIndex < newIndex) newIndex--;

      VariantChild child = variantChilds[oldIndex];
      variantChilds.removeAt(oldIndex);
      variantChilds.insert(newIndex, child);
      _showSnackBar('update_category_sequence');
    });
  }

  deleteVariant() async {
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
                widget.onClick(null, 'delete');
              },
            ),
          ],
        );
      },
    );
  }

  _showSnackBar(message) {
    key.currentState.showSnackBar(new SnackBar(
      duration: const Duration(milliseconds: 500),
      content: new Text(AppLocalizations.of(context).translate(message)),
    ));
  }
}
