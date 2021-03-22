import 'package:flutter/material.dart';
import 'package:my/object/productVariant/variantGroup.dart';

class VariantChildListView extends StatelessWidget {
  final VariantChild variantChild;
  final Function(VariantChild, String) onClick;
  final Key key;

  VariantChildListView({this.variantChild, this.onClick, this.key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return mainContent();
  }

  Widget mainContent() {
    return Container(
      height: 70,
      child: Card(
        child: Container(
            padding: EdgeInsets.all(5),
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.unfold_more,
                      color: Colors.grey,
                    )),
                Expanded(
                    flex: 5,
                    child: Text(
                      variantChild.name,
                      maxLines: 1,
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    )),
                Expanded(
                    flex: 2,
                    child: Text(
                      variantChild.price.toString(),
                      style: TextStyle(color: Colors.black87, fontSize: 12),
                    )),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Colors.blueGrey,
                      ),
                      onPressed: () => onClick(variantChild, 'edit')),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      onPressed: () => onClick(variantChild, 'delete')),
                )
              ],
            )),
      ),
    );
  }
}
