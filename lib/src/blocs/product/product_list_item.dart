import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/product/live_product_editor.dart';
import 'package:flutter_time/src/blocs/product/star_rating_widget.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/model/remote_configuration.dart';

import 'bloc.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final WeekendPromoConfiguration weekendPromoConfiguration;

  ProductItem({Key key, @required this.product, this.weekendPromoConfiguration})
      : super(key: key);

  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.product.id),
      background: Container(
        color: Colors.redAccent,
      ),
      onDismissed: (_) => _removeProduct(context),
      child: ListTile(
          key: Key(widget.product.id),
          title: Text(widget.product.name),
          subtitle: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.product.description,
                  style: TextStyle(
                      color: widget.weekendPromoConfiguration.enabled
                          ? Colors.green
                          : Colors.black),
                ),
                StarRating(
                  color: Colors.green,
                  rating: widget.product.rating,
                  starCount: 5,
                )
              ],
            ),
          ),
          trailing: Text(widget.product.price.toStringAsFixed(2)),
          onTap: () => _editProduct(context)),
    );
  }

  void _editProduct(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return LiveProductEditor(
          owner: widget.product.owner,
          productId: widget.product.id,
        );
      }),
    );
  }

  void _removeProduct(BuildContext context) {
    var productsBloc = getIt<ProductsBloc>();
    productsBloc.dispatch(DeleteProduct(widget.product));
  }
}
