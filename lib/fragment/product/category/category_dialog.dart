import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my/object/category.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class CategoryDialog extends StatefulWidget {
  final Function(String, int) onSelect;

  CategoryDialog({this.onSelect});

  @override
  _GroupingDialogState createState() => _GroupingDialogState();
}

class _GroupingDialogState extends State<CategoryDialog> {
  List<Category> category = [];
  StreamController actionStream;
  String action = 'display';

  var categoryName = TextEditingController();
  int selectedId = -1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    actionStream = StreamController();
    actionStream.add('display');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: new Text(
            '${AppLocalizations.of(context).translate('product_category')}'),
        actions: <Widget>[
          action == 'display' ? displayCategoryButton() : createCategoryButton()
        ],
        content: mainContent(context));
  }

  /*
  * action button for creating /update / delete category
  * */
  Widget createCategoryButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed: () {
              setState(() {
                /*
                * set state back to display category
                * */
                _reset();
              });
            },
            child: Text(
              '${AppLocalizations.of(context).translate('close')}',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
        Visibility(
          visible: action == 'update',
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RaisedButton(
              elevation: 5,
              color: Colors.red[300],
              onPressed: () {
                deleteCategory(context);
              },
              child: Text(
                '${AppLocalizations.of(context).translate('delete')}',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            elevation: 5,
            color: Colors.orangeAccent,
            onPressed: () {
              createOrUpdateCategory(context);
            },
            child: Text(
              action == 'create'
                  ? '${AppLocalizations.of(context).translate('create')}'
                  : '${AppLocalizations.of(context).translate('update')}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  createOrUpdateCategory(context) async {
    Map data = action != 'create'
        ? await Domain()
            .updateCategory(categoryName.text, selectedId.toString())
        : await Domain().createCategory(categoryName.text);

    if (data['status'] == '1') {
      _showToast(action == 'create'
          ? '${AppLocalizations.of(context).translate('create_success')}'
          : '${AppLocalizations.of(context).translate('update_success')}');

      setState(() {
        _reset();
      });
    } else if (data['status'] == '3')
      _showToast(
          '${AppLocalizations.of(context).translate('category_existed')}');
    else
      _showToast(
          '${AppLocalizations.of(context).translate('something_went_wrong')}');
  }

  deleteCategory(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text(
              "${AppLocalizations.of(context).translate('delete_request')}"),
          content: Text(
              "${AppLocalizations.of(context).translate('confirm_to_delete')} \n${categoryName.text}\n*${AppLocalizations.of(context).translate('category_will_remove_product')}"),
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
                Map data = await Domain().deleteCategory(selectedId.toString());

                if (data['status'] == '1') {
                  _showToast(
                      '${AppLocalizations.of(context).translate('delete_success')}');
                  setState(() {
                    Navigator.of(context).pop();
                    _reset();
                  });
                } else
                  _showToast(
                      '${AppLocalizations.of(context).translate('something_went_wrong')}');
              },
            ),
          ],
        );
      },
    );
  }

  /*
  * action button for display category
  * */
  Widget displayCategoryButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '${AppLocalizations.of(context).translate('close')}',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RaisedButton(
            elevation: 5,
            color: Colors.orangeAccent,
            onPressed: () {
              setState(() {
                actionStream.add('create');
                action = 'create';
              });
            },
            child: Text(
              '${AppLocalizations.of(context).translate('create_new')}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget mainContent(context) {
    return StreamBuilder(
        stream: actionStream.stream,
        builder: (context, object) {
          print(object.toString());
          if (object.data == 'display') {
            return displayCategoryUI();
          } else if (object.data == 'create') {
            return createCategoryUI();
          }
          return CustomProgressBar();
        });
  }

  /*
  * display category ui
  * */
  Widget displayCategoryUI() {
    return FutureBuilder(
        future: Domain().fetchCategory(),
        builder: (context, object) {
          if (object.hasData) {
            if (object.connectionState == ConnectionState.done) {
              Map data = object.data;
              if (data['status'] == '1') {
                category.clear();
                List jsonProduct = data['category'];

                category.addAll(jsonProduct
                    .map((jsonObject) => Category.fromJson(jsonObject))
                    .toList());

                return customListView();
              } else {
                return Text(
                    '${AppLocalizations.of(context).translate('no_category_found')}');
              }
            }
          }
          return Container(width: 500, height: 500, child: CustomProgressBar());
        });
  }

  /*
  * create category ui
  * */
  Widget createCategoryUI() {
    return Container(
      child: TextField(
        controller: categoryName,
        textAlign: TextAlign.start,
        decoration: InputDecoration(
          hintStyle: TextStyle(fontSize: 14),
          labelText:
              '${AppLocalizations.of(context).translate('category_name')}',
          labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
          hintText:
              '${AppLocalizations.of(context).translate('category_name')}',
          border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.teal)),
        ),
      ),
    );
  }

  Widget customListView() {
    return Container(
        height: 500,
        width: 500,
        child: ReorderableListView(
          children: category
              .asMap()
              .map((index, category) =>
                  MapEntry(index, categoryListItem(category, index)))
              .values
              .toList(),
          onReorder: _onReorder,
        ));
  }

  Widget categoryListItem(Category category, int position) {
    return Card(
      key: Key(category.name),
      elevation: 5,
      child: ListTile(
          leading: Icon(Icons.unfold_more),
          onTap: () => widget.onSelect(category.name, category.categoryId),
          title: Text(
            category.name,
            style:
                TextStyle(color: Colors.black87, fontSize: 14),
          ),
          trailing: IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                action = 'update';
                actionStream.add('create');
                categoryName.text = category.name;
                selectedId = category.categoryId;
              });
            },
          )),
    );
  }

  _onReorder(int oldIndex, int newIndex) async {
    if (newIndex > category.length) newIndex = category.length;
    if (oldIndex < newIndex) newIndex--;

    Category categoryObject = category[oldIndex];
    category.removeAt(oldIndex);
    category.insert(newIndex, categoryObject);

    await updateCategorySequence();
    setState(() {});
  }

  updateCategorySequence() async {
    for (int i = 0; i < category.length; i++) {
      category[i].sequence = i + 1;
    }
    Map data = await Domain().updateCategorySequence(jsonEncode(category));
    if (data['status'] == '1') {
      _showToast(
          '${AppLocalizations.of(context).translate('update_category_sequence')}');
    }
  }

  _reset() {
    category.clear();
    actionStream.add('display');
    categoryName.clear();
    action = 'display';
    selectedId = -1;
  }

  _showToast(message) {
    CustomToast(message, context).show();
  }
}
