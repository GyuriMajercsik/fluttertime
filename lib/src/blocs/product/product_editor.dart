import 'package:flutter/material.dart';
import 'package:flutter_time/src/blocs/product/product_form.dart';

class ProductEditor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create product')),
      body: ProductForm(),
    );
  }
}
