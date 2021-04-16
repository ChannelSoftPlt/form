import 'package:flutter/material.dart';
import 'package:my/fragment/product/product_detail.dart';
import 'package:my/object/product.dart';
import 'package:my/translation/AppLocalizations.dart';
import 'package:my/utils/domain.dart';

class ProductListView extends StatefulWidget {
  final Product product;
  final Function(bool, Product) openProductDetail;

  ProductListView({this.product, this.openProductDetail});

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  @override
  Widget build(BuildContext context) {
    print(widget.product.variation);
    return Card(
      elevation: 5,
      margin: EdgeInsets.all(10.0),
      child: InkWell(
        onTap: () => widget.openProductDetail(true, widget.product),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FadeInImage(
                  height: 100,
                  width: 120,
                  fit: BoxFit.cover,
                  image: NetworkImage(
                      '${Domain.imagePath}${widget.product.image}'),
                  placeholder:
                      NetworkImage('${Domain.imagePath}no-image-found.png')),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.categoryName ??
                            '${AppLocalizations.of(context).translate('label_no_category')}',
                        maxLines: 2,
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.product.name,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        widget.product.status == 0
                            ? '${AppLocalizations.of(context).translate('active')}'
                            : '${AppLocalizations.of(context).translate('disable')}',
                        maxLines: 2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
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
                        style: TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${widget.product.price}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  Visibility(
                    visible: widget.product.variation != '[]',
                    child: Text(
                      AppLocalizations.of(context).translate('add_on_available'),
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 10, color: Colors.green),
                    ),
                  ),
                  SizedBox(
                    height: 60,
                  ),
                  Text(
                    '${AppLocalizations.of(context).translate('details')}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProductDetailDialog(
                product: widget.product,
                isUpdate: action,
              )),
    );
  }
}
