import 'package:flutter/material.dart';
import 'package:my/fragment/product/product_detail_dialog.dart';
import 'package:my/object/product.dart';
import 'package:my/utils/domain.dart';

class ProductListView extends StatefulWidget {
  final Product product;

  ProductListView({this.product});

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () => showProductDetail(context, true),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Image.network('${Domain.imagePath}${widget.product.image}',
                  height: 100, width: 120, fit: BoxFit.fill),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.categoryName ?? 'No Category',
                        maxLines: 2,
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        widget.product.status == 0 ? 'Active' : 'Disable',
                        maxLines: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: widget.product.status == 0
                                ? Colors.green
                                : Colors.red),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        widget.product.description,
                        maxLines: 2,
                        style: TextStyle(fontSize: 10),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    'RM ${widget.product.price}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    'Details',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.orangeAccent),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  showProductDetail(mainContext, bool action) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return ProductDetailDialog(
          product: widget.product,
          isUpdate: action,
        );
      },
    );
  }
}
