import 'package:flutter/material.dart';
import 'package:my/object/productVariant/variantGroup.dart';
import 'package:my/translation/AppLocalizations.dart';

class VariantListItem extends StatefulWidget {
  final VariantGroup variantGroup;
  final Function(String) onClick;
  final Key key;

  VariantListItem({this.variantGroup, this.onClick, this.key})
      : super(key: key);

  @override
  _VariantListItemState createState() => _VariantListItemState();
}

class _VariantListItemState extends State<VariantListItem> {
  bool isExpand = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  countHeight() {
    var height = 130;
    if (widget.variantGroup.variantChild != null &&
        widget.variantGroup.variantChild.length > 0) {
      height = height + (25 * widget.variantGroup.variantChild.length);
    }
    return height.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: countHeight(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(5, 1, 5, 1),
        child: Card(
          elevation: 3,
          child: Container(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        widget.variantGroup.groupName,
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.blueGrey,
                        ),
                        onPressed: () => widget.onClick('edit')),
                    IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () => widget.onClick('delete'))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppLocalizations.of(context).translate('select_type')} : ${AppLocalizations.of(context).translate(widget.variantGroup.type == 1 ? 'single' : 'multiple')}',
                      style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                    ),
                    Visibility(
                      visible: widget.variantGroup.option == 1,
                      child: Text(
                        '${AppLocalizations.of(context).translate('compulsory')}',
                        style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
                  child: Divider(
                    color: Colors.teal.shade100,
                    thickness: 1.0,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1,
                        child: Text(
                          AppLocalizations.of(context).translate('type'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                      flex: 1,
                      child: Text(
                        AppLocalizations.of(context).translate('add_on_price'),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                for (int i = 0;
                    i < widget.variantGroup.variantChild.length;
                    i++)
                  Container(
                    height: 25,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                  widget.variantGroup.variantChild[i].name)),
                          Expanded(
                              flex: 1,
                              child: Text(
                                  'RM ${widget.variantGroup.variantChild[i].price}'))
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
