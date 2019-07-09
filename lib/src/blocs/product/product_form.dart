import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_time/main.dart';
import 'package:flutter_time/src/blocs/product/save_product_button.dart';
import 'package:flutter_time/src/model/product.dart';
import 'package:flutter_time/src/shared_preferences_repository.dart';
import 'package:flutter_time/src/validators.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:uuid/uuid.dart';

import 'bloc.dart';

class ProductForm extends StatefulWidget {
  final Product product;

  const ProductForm({Key key, this.product}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  ProductsBloc _productsBloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _productsBloc = getIt<ProductsBloc>();
    if (widget.product != null) {
      _nameController.text = widget.product.name;
      _descriptionController.text = widget.product.description;
      _priceController.text = widget.product.price.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Form(
        child: ListView(
          children: <Widget>[
            _buildNameWidget(),
            _buildDescriptionWidget(),
            _buildPriceWidget(),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SaveProductButton(
                    onPressed: _onFormSubmitted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceWidget() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(FontAwesomeIcons.dollarSign),
        labelText: 'Price',
      ),
      validator: (price) {
        if (price.trim().isEmpty) {
          return 'Empty';
        }
        if (!Validators.isValidPrice(price)) {
          return 'Invalid price';
        }

        return null;
      },
      keyboardType:
          TextInputType.numberWithOptions(signed: false, decimal: true),
      controller: _priceController,
      autovalidate: true,
      autocorrect: false,
    );
  }

  Widget _buildDescriptionWidget() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.description),
        labelText: 'Description',
      ),
      validator: (description) {
        if (description.trim().isEmpty) {
          return 'Empty';
        }
        return null;
      },
      controller: _descriptionController,
      maxLines: 2,
      autovalidate: true,
      autocorrect: false,
    );
  }

  Widget _buildNameWidget() {
    return TextFormField(
      decoration: InputDecoration(
        icon: Icon(Icons.title),
        labelText: 'Name',
      ),
      validator: (name) {
        if (name.trim().isEmpty) {
          return 'Empty';
        }
        return null;
      },
      controller: _nameController,
      autovalidate: true,
      autocorrect: false,
    );
  }

  void _onFormSubmitted() {
    var sharedPreferences = getIt<SharedPreferencesRepository>();
    if (widget.product != null) {
      var updatedProduct = Product(
        id: widget.product.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        owner: sharedPreferences.getLastEmailAddress(),
        price: double.parse(_priceController.text.trim()),
        rating: widget.product.rating,
      );
      _productsBloc.dispatch(
        UpdateProduct(updatedProduct),
      );
    } else {
      _productsBloc.dispatch(
        AddProduct(
          Product(
            id: Uuid().v4(),
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            owner: sharedPreferences.getLastEmailAddress(),
            price: double.tryParse(
              _priceController.text.trim(),
            ),
          ),
        ),
      );
    }

    Navigator.of(context).pop();
  }
}
