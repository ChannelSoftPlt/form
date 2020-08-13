import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my/object/category.dart';
import 'package:my/shareWidget/progress_bar.dart';
import 'package:my/shareWidget/toast.dart';
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
        title: new Text('Product Category'),
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
              'Close',
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
                'Delete',
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
              action == 'create' ? 'Create' : 'Update',
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
      _showToast(
          action == 'create' ? 'Create Successfully!' : 'Update Successfully!');

      setState(() {
        _reset();
      });
    } else if (data['status'] == '3')
      _showToast('This category already existed!');
    else
      _showToast('Something Went Wrong!');
  }

  deleteCategory(context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: Text("Delete Request"),
          content: Text("Confirm to this this item? \n${categoryName.text}\n\n*This category will remove from other products as well"),
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
                Map data = await Domain().deleteCategory(selectedId.toString());

                if (data['status'] == '1') {
                  _showToast('Delete Successfully!');
                  setState(() {
                    Navigator.of(context).pop();
                    _reset();
                  });
                } else
                  _showToast('Something Went Wrong!');
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
              'Close',
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
              'Create New',
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
                List jsonProduct = data['category'];
                print(jsonProduct);

                category.addAll(jsonProduct
                    .map((jsonObject) => Category.fromJson(jsonObject))
                    .toList());

                print(category.length);

                return customListView();
              }
            }
          }
          return CustomProgressBar();
        });
  }

  /*
  * create category ui
  * */
  Widget createCategoryUI() {
    return Container(
      child: Theme(
        data: new ThemeData(
          primaryColor: Colors.orange,
        ),
        child: TextField(
          controller: categoryName,
          textAlign: TextAlign.start,
          decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 14),
            labelText: 'Category Name',
            labelStyle: TextStyle(fontSize: 14, color: Colors.blueGrey),
            hintText: 'Category Name',
            border: new OutlineInputBorder(
                borderSide: new BorderSide(color: Colors.teal)),
          ),
        ),
      ),
    );
  }

  Widget customListView() {
    return Container(
        width: double.maxFinite,
        child: ListView.builder(
            itemCount: category.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  ListTile(
                      onTap: () => widget.onSelect(
                          category[index].name, category[index].categoryId),
                      title: Text(
                        category[index].name,
                        style: TextStyle(
                            color: Color.fromRGBO(89, 100, 109, 1),
                            fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            action = 'update';
                            actionStream.add('create');
                            categoryName.text = category[index].name;
                            selectedId = category[index].categoryId;
                          });
                        },
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 0, 0, 0),
                    child: Divider(
                      color: Colors.teal.shade100,
                      thickness: 1.0,
                    ),
                  ),
                ],
              );
            }));
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
