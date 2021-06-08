import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:my/object/category.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class ProductFilter extends StatefulWidget {
  final Function(String, Category, int) onClick;
  final Category category;
  final int orderType;

  ProductFilter({this.onClick, this.category, this.orderType});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<ProductFilter> {
  Category category;
  int orderType = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (orderType != null) orderType = widget.orderType;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        insetPadding: EdgeInsets.all(0),
        title: new Text('${AppLocalizations.of(context).translate('sorting')}'),
        actions: <Widget>[
          FlatButton(
            child: Text('${AppLocalizations.of(context).translate('cancel')}'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(
              '${AppLocalizations.of(context).translate('apply')}',
              style: TextStyle(color: Colors.red),
            ),
            onPressed: () {
              widget.onClick('', category, orderType);
            },
          ),
        ],
        content: mainContent(context));
  }

  Widget mainContent(context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          chooseCategory(),
        ],
      ),
    );
  }

  Widget chooseCategory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(
          height: 5,
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                '${AppLocalizations.of(context).translate('order_sequence')}',
                style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: DropdownButton(
                  isExpanded: true,
                  itemHeight: 50,
                  value: orderType,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                  items: [
                    DropdownMenuItem(
                      child:
                          Text(AppLocalizations.of(context).translate('create_time')),
                      value: 0,
                    ),
                    DropdownMenuItem(
                      child: Text(
                        AppLocalizations.of(context).translate('sequence'),
                        textAlign: TextAlign.center,
                      ),
                      value: 1,
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      orderType = value;
                    });
                  }),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        DropdownSearch<Category>(
            mode: Mode.BOTTOM_SHEET,
            label:
                '${AppLocalizations.of(context).translate('select_category')}',
            popupTitle: Text(
              '${AppLocalizations.of(context).translate('existing_category')}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            searchBoxDecoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              prefixIcon: Icon(Icons.search),
              labelText:
                  '${AppLocalizations.of(context).translate('search_category')}',
            ),
            showSearchBox: true,
            showClearButton: true,
            selectedItem: widget.category,
            onFind: (String filter) => getData(filter),
            itemAsString: (Category u) => u.categoryAsString(),
            onChanged: (Category data) => category = data),
      ],
    );
  }

  Future<List<Category>> getData(filter) async {
    Map data = await Domain().fetchCategory();
    var models;
    if (data['status'] == '1') {
      models = Category.fromJsonList(data['category']);
    }
    return models;
  }
}
