import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:my/object/category.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class ProductFilter extends StatefulWidget {
  final Function(String, Category) onClick;
  final Category category;

  ProductFilter({this.onClick, this.category});

  @override
  _FilterDialogState createState() => _FilterDialogState();
}

class _FilterDialogState extends State<ProductFilter> {
  Category category;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              widget.onClick('', category);
            },
          ),
        ],
        content: mainContent(context));
  }

  Widget mainContent(context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        chooseCategory(),
      ],
    );
  }

  Widget chooseCategory() {
    return Column(
      children: <Widget>[
        Text(
          '${AppLocalizations.of(context).translate('category')}',
          style: TextStyle(color: Colors.black54),
        ),
        SizedBox(
          height: 5,
        ),
        DropdownSearch<Category>(
            mode: Mode.BOTTOM_SHEET,
            label: '${AppLocalizations.of(context).translate('select_category')}',

            popupTitle: Text(
              '${AppLocalizations.of(context).translate('existing_category')}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            searchBoxDecoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.fromLTRB(12, 12, 8, 0),
              prefixIcon: Icon(Icons.search),
              labelText: '${AppLocalizations.of(context).translate('search_category')}',
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
